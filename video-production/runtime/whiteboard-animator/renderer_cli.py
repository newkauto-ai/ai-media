"""Bounded local whiteboard renderer based on whiteboard-animator 0.1.1.

The CLI owns execution facts only. It never records approval, QA PASS, retry
state, or inferred hidden structure.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
import subprocess
import sys
import tempfile
import traceback
from pathlib import Path

import cv2
import numpy as np
from PIL import Image


RUNTIME_ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(RUNTIME_ROOT / "upstream"))

from whiteboard_animator.animator import WhiteboardAnimator  # noqa: E402


ADAPTER_ID = "whiteboard_animator"
RENDERER_VERSION = "0.5.0-ai-media.1"
UPSTREAM_VERSION = "0.1.1"
UPSTREAM_COMMIT = "e6e4dbcfc06e65b82490323a78bd9c277a9e2a0b"
LEGACY_CHARACTER_PART_ORDER = ("head", "body", "hands", "feet")
CHARACTER_PART_ORDER = (
    "head", "body", "upper_arms", "forearms", "hands",
    "thighs", "lower_legs", "feet",
)
CHARACTER_STROKE_PHASE_ORDER = ("outline", "details")
DETAILED_CHARACTER_ORDER_POLICY = "head_body_upper_arms_forearms_hands_thighs_lower_legs_feet"


class ContractError(RuntimeError):
    def __init__(self, code: str, message: str, field: str | None = None):
        super().__init__(message)
        self.code = code
        self.field = field


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def read_json(path: Path) -> dict:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ContractError("invalid_job", "job must be a JSON object")
    return value


def resolve_path(job_path: Path, value: str) -> Path:
    path = Path(value)
    if not path.is_absolute():
        path = job_path.parent / path
    return path.resolve()


def require_job(job_path: Path) -> dict:
    job = read_json(job_path)
    required = [
        "contract_version", "adapter_id", "job_id", "revision_id",
        "source", "output", "output_spec", "timing",
    ]
    missing = [name for name in required if name not in job]
    if missing:
        raise ContractError("missing_field", f"missing required fields: {missing}")
    if job["contract_version"] not in ("1.0", "1.1", "1.2", "1.3"):
        raise ContractError("unsupported_contract", "contract_version must be 1.0, 1.1, 1.2, or 1.3", "contract_version")
    if job["adapter_id"] != ADAPTER_ID:
        raise ContractError("wrong_adapter", f"adapter_id must be {ADAPTER_ID}", "adapter_id")
    requested_route = job.get("render_route")
    if requested_route is not None:
        if job["contract_version"] in ("1.0", "1.1"):
            raise ContractError(
                "render_route_requires_contract_1_2",
                "render_route is an adaptive-routing field and requires contract_version 1.2 or 1.3",
                "render_route",
            )
        if requested_route not in ("auto", "flat_auto", "structured_semantic"):
            raise ContractError("invalid_render_route", "render_route must be auto, flat_auto, or structured_semantic", "render_route")
    elif job["contract_version"] in ("1.2", "1.3"):
        job["render_route"] = "auto"

    source = job["source"]
    if not isinstance(source, dict) or not source.get("path") or not source.get("sha256") or not str(source.get("rights_evidence", "")).strip():
        raise ContractError("invalid_source", "source.path, source.sha256, and source.rights_evidence are required", "source")
    source_path = resolve_path(job_path, source["path"])
    if not source_path.is_file():
        raise ContractError("missing_source", f"source image not found: {source_path}", "source.path")
    actual_source_hash = sha256_file(source_path)
    if actual_source_hash != str(source["sha256"]).upper():
        raise ContractError("source_checksum_mismatch", "source image checksum does not match", "source.sha256")
    supersample_scale = int(source.get("supersample_scale", 1))
    if supersample_scale not in (1, 4):
        raise ContractError("invalid_supersample_scale", "source.supersample_scale must be 1 or 4", "source.supersample_scale")
    if job["contract_version"] in ("1.2", "1.3") and supersample_scale != 4:
        raise ContractError("source_supersampling_required", "contract 1.2+ requires a 4x supersampled source", "source.supersample_scale")

    timing = job["timing"]
    total = float(timing.get("total_duration_seconds", 0))
    policy = timing.get("policy", "manual")
    if policy not in ("manual", "auto"):
        raise ContractError("invalid_timing_policy", "timing.policy must be auto or manual", "timing.policy")
    draw = float(timing.get("draw_duration_seconds", 0))
    fps = int(timing.get("fps", 0))
    if total <= 0 or fps <= 0 or (policy == "manual" and (draw <= 0 or draw > total)):
        raise ContractError("invalid_timing", "require 0 < draw_duration <= total_duration and fps > 0", "timing")
    if abs(total * fps - round(total * fps)) > 1e-6:
        raise ContractError("non_integer_frame_budget", "total_duration_seconds * fps must be an integer", "timing")

    output_spec = job["output_spec"]
    for name in ("width_px", "height_px"):
        if not isinstance(output_spec.get(name), int) or output_spec[name] <= 0 or output_spec[name] % 2:
            raise ContractError("invalid_output_geometry", f"{name} must be a positive even integer", f"output_spec.{name}")
    if output_spec.get("pixel_format") != "yuv420p" or output_spec.get("native_audio") != "none":
        raise ContractError("invalid_output_policy", "pixel_format must be yuv420p and native_audio must be none", "output_spec")

    segment = job.get("segment_window")
    if segment is not None:
        if job["contract_version"] != "1.3" or not isinstance(segment, dict):
            raise ContractError("segment_window_requires_1_3", "segment_window requires contract_version 1.3", "segment_window")
        logical_frames = int(round(total * fps))
        start = segment.get("start_frame"); end = segment.get("end_frame_exclusive")
        if not isinstance(start, int) or not isinstance(end, int) or start < 0 or end <= start or end > logical_frames:
            raise ContractError("invalid_segment_window", "require 0 <= start_frame < end_frame_exclusive <= logical total frames", "segment_window")
        if segment.get("logical_total_frames") != logical_frames:
            raise ContractError("segment_logical_frame_mismatch", "segment logical_total_frames must equal timing total frames", "segment_window.logical_total_frames")
        if segment.get("boundary_mode") not in ("continuous_canvas", "board_cut"):
            raise ContractError("invalid_segment_boundary_mode", "boundary_mode must be continuous_canvas or board_cut", "segment_window.boundary_mode")

    tip = job.get("tip_overlay")
    if tip is not None:
        if not isinstance(tip, dict):
            raise ContractError("invalid_tip_overlay", "tip_overlay must be an object", "tip_overlay")
        for name in ("path", "sha256", "rights_evidence", "tip_anchor", "height_fraction"):
            if name not in tip:
                raise ContractError("missing_tip_field", f"tip_overlay.{name} is required", f"tip_overlay.{name}")
        anchor = tip["tip_anchor"]
        if not (isinstance(anchor, list) and len(anchor) == 2 and all(isinstance(x, (int, float)) and 0 <= x <= 1 for x in anchor)):
            raise ContractError("invalid_tip_anchor", "tip_anchor must be [x,y] normalized to 0..1", "tip_overlay.tip_anchor")
        if not isinstance(tip["height_fraction"], (int, float)) or not 0 < float(tip["height_fraction"]) <= 1:
            raise ContractError("invalid_tip_size", "height_fraction must be greater than 0 and at most 1", "tip_overlay.height_fraction")
        hand_path = resolve_path(job_path, tip["path"])
        if not hand_path.is_file() or sha256_file(hand_path) != str(tip["sha256"]).upper():
            raise ContractError("tip_checksum_mismatch", "tip asset is missing or checksum does not match", "tip_overlay")
        hand_image = read_cv_image(hand_path, cv2.IMREAD_UNCHANGED)
        if hand_image.ndim != 3 or hand_image.shape[2] != 4:
            raise ContractError("tip_not_rgba", "tip asset must decode as RGBA", "tip_overlay.path")
        if not str(tip["rights_evidence"]).strip():
            raise ContractError("missing_rights_evidence", "tip overlay requires rights evidence", "tip_overlay.rights_evidence")

    job["_job_path"] = job_path
    job["_source_path"] = source_path
    job["_output_path"] = resolve_path(job_path, str(job["output"]))
    if tip is not None:
        job["_tip_path"] = resolve_path(job_path, tip["path"])

    structured = job.get("structured_layers")
    if job.get("segment_window") is not None and not structured:
        raise ContractError("segmented_flat_route_unsupported", "segment_window requires explicit structured semantic layers", "segment_window")
    if structured is not None:
        if not isinstance(structured, dict) or structured.get("mode") not in (
            "prepainted_background_object_reveal", "stacked_layer_object_complete_reveal",
        ):
            raise ContractError(
                "invalid_structured_layers",
                "structured_layers.mode is not supported",
                "structured_layers.mode",
            )

        def require_asset(value, field: str) -> Path:
            if not isinstance(value, dict) or not value.get("path") or not value.get("sha256") or not str(value.get("rights_evidence", "")).strip():
                raise ContractError("invalid_structured_asset", f"{field} requires path, sha256, and rights_evidence", field)
            asset_path = resolve_path(job_path, value["path"])
            if not asset_path.is_file():
                raise ContractError("missing_structured_asset", f"asset not found: {asset_path}", f"{field}.path")
            if sha256_file(asset_path) != str(value["sha256"]).upper():
                raise ContractError("structured_asset_checksum_mismatch", f"checksum does not match: {field}", f"{field}.sha256")
            return asset_path

        if structured["mode"] == "stacked_layer_object_complete_reveal":
            if job["contract_version"] not in ("1.1", "1.2", "1.3"):
                raise ContractError("structured_mode_requires_1_1", "stacked layer mode requires contract_version 1.1, 1.2, or 1.3", "contract_version")
            paper = structured.get("paper_rgb")
            if not (isinstance(paper, list) and len(paper) == 3 and all(isinstance(x, int) and 0 <= x <= 255 for x in paper)):
                raise ContractError("invalid_paper_rgb", "paper_rgb must contain three integer RGB values", "structured_layers.paper_rgb")
            layers = structured.get("layers")
            if not isinstance(layers, list) or not layers:
                raise ContractError("invalid_structured_layers", "structured_layers.layers must contain at least one layer", "structured_layers.layers")
            ids, draw_orders, z_indices = set(), set(), set()
            for index, layer in enumerate(layers):
                field = f"structured_layers.layers[{index}]"
                if not isinstance(layer, dict) or not str(layer.get("id", "")).strip():
                    raise ContractError("invalid_structured_layer", f"{field}.id is required", f"{field}.id")
                for value, seen, code, name in (
                    (layer["id"], ids, "duplicate_structured_layer_id", "id"),
                    (layer.get("draw_order"), draw_orders, "duplicate_structured_draw_order", "draw_order"),
                    (layer.get("z_index"), z_indices, "duplicate_structured_z_index", "z_index"),
                ):
                    if name != "id" and (not isinstance(value, int) or value < 0):
                        raise ContractError("invalid_structured_order", f"{field}.{name} must be a non-negative integer", f"{field}.{name}")
                    if value in seen:
                        raise ContractError(code, f"duplicate {name}: {value}", f"{field}.{name}")
                    seen.add(value)
                layer["_color_rgba_path"] = require_asset(layer.get("color_rgba"), f"{field}.color_rgba")
                reveal_mode = layer.get("reveal_mode")
                if reveal_mode not in ("line_then_fill", "direct_fill"):
                    raise ContractError("invalid_reveal_mode", f"{field}.reveal_mode must be line_then_fill or direct_fill", f"{field}.reveal_mode")
                semantic_kind = layer.get("semantic_kind", "illustration")
                if semantic_kind not in ("geometry", "text", "illustration", "character", "shadow"):
                    raise ContractError("invalid_semantic_kind", f"{field}.semantic_kind is invalid", f"{field}.semantic_kind")
                text_regions = layer.get("text_regions", [])
                if semantic_kind == "text" and not text_regions:
                    raise ContractError("text_regions_required", f"{field} text layer requires explicit text_regions", f"{field}.text_regions")
                stroke_order_policy = layer.get("stroke_order_policy")
                head_bbox = layer.get("head_bbox")
                character_parts = layer.get("character_parts")
                if semantic_kind == "character":
                    if job["contract_version"] != "1.3":
                        raise ContractError("character_head_first_requires_1_3", f"{field} character head-first metadata requires contract_version 1.3", field)
                    if reveal_mode != "line_then_fill":
                        raise ContractError("character_requires_line_then_fill", f"{field} character layer must use line_then_fill", f"{field}.reveal_mode")
                    if stroke_order_policy == "head_first":
                        width_px = int(job["output_spec"]["width_px"])
                        height_px = int(job["output_spec"]["height_px"])
                        if character_parts is not None:
                            raise ContractError("legacy_character_order_must_not_mix_parts", f"{field} legacy head_first cannot declare character_parts", field)
                        if not (
                            isinstance(head_bbox, list) and len(head_bbox) == 4
                            and all(isinstance(value, int) for value in head_bbox)
                            and 0 <= head_bbox[0] < head_bbox[2] <= width_px
                            and 0 <= head_bbox[1] < head_bbox[3] <= height_px
                        ):
                            raise ContractError("invalid_character_head_bbox", f"{field}.head_bbox must be an in-bounds output-space [left,top,right,bottom] box", f"{field}.head_bbox")
                    elif stroke_order_policy in ("head_body_hands_feet", DETAILED_CHARACTER_ORDER_POLICY):
                        if head_bbox is not None:
                            raise ContractError("character_part_order_must_not_use_head_bbox", f"{field} ordered character parts replace head_bbox", field)
                        expected_order = CHARACTER_PART_ORDER if stroke_order_policy == DETAILED_CHARACTER_ORDER_POLICY else LEGACY_CHARACTER_PART_ORDER
                        if not isinstance(character_parts, list) or len(character_parts) != len(expected_order):
                            raise ContractError("character_parts_required", f"{field}.character_parts must contain {', '.join(expected_order)}", f"{field}.character_parts")
                        actual_order = [part.get("part") if isinstance(part, dict) else None for part in character_parts]
                        if actual_order != list(expected_order):
                            raise ContractError("invalid_character_part_order", f"{field}.character_parts must be ordered {', '.join(expected_order)}", f"{field}.character_parts")
                        for part_index, part in enumerate(character_parts):
                            part_field = f"{field}.character_parts[{part_index}]"
                            part["_mask_rgba_path"] = require_asset(part.get("mask_rgba"), f"{part_field}.mask_rgba")
                            if stroke_order_policy == DETAILED_CHARACTER_ORDER_POLICY:
                                part["_outline_mask_rgba_path"] = require_asset(part.get("outline_mask_rgba"), f"{part_field}.outline_mask_rgba")
                                part["_detail_mask_rgba_path"] = require_asset(part.get("detail_mask_rgba"), f"{part_field}.detail_mask_rgba")
                    else:
                        raise ContractError("character_part_order_required", f"{field} character layer must use {DETAILED_CHARACTER_ORDER_POLICY} for new Jobs; older policies are compatibility input only", f"{field}.stroke_order_policy")
                elif stroke_order_policy is not None or head_bbox is not None or character_parts is not None:
                    raise ContractError("character_order_metadata_requires_character", f"{field} head-first metadata is only valid for semantic_kind: character", field)
                previous_key = None
                seen_reading_orders = set()
                for region_index, region in enumerate(text_regions):
                    region_field = f"{field}.text_regions[{region_index}]"
                    bbox = region.get("bbox") if isinstance(region, dict) else None
                    if not (isinstance(bbox, list) and len(bbox) == 4 and all(isinstance(x, int) for x in bbox) and bbox[0] < bbox[2] and bbox[1] < bbox[3]):
                        raise ContractError("invalid_text_region", f"{region_field}.bbox must be [left,top,right,bottom]", f"{region_field}.bbox")
                    order = region.get("reading_order")
                    if not isinstance(order, int) or order < 0 or order in seen_reading_orders:
                        raise ContractError("invalid_text_reading_order", f"{region_field}.reading_order must be unique", f"{region_field}.reading_order")
                    seen_reading_orders.add(order)
                    if region.get("direction", "left_to_right") != "left_to_right":
                        raise ContractError("unsupported_text_direction", "only left_to_right text is supported", f"{region_field}.direction")
                    key = (int(region.get("line_order", 0)), bbox[0], order)
                    if previous_key is not None and key < previous_key:
                        raise ContractError("text_reading_order_mismatch", "text regions must be declared top-to-bottom and left-to-right", region_field)
                    previous_key = key
                fill_duration = layer.get("fill_duration_seconds")
                if policy == "manual" and (not isinstance(fill_duration, (int, float)) or float(fill_duration) <= 0):
                    raise ContractError("invalid_structured_duration", f"{field}.fill_duration_seconds must be greater than zero", f"{field}.fill_duration_seconds")
                stroke_duration = layer.get("stroke_duration_seconds", 0)
                if reveal_mode == "line_then_fill":
                    layer["_line_art_rgba_path"] = require_asset(layer.get("line_art_rgba"), f"{field}.line_art_rgba")
                    if policy == "manual" and (not isinstance(stroke_duration, (int, float)) or float(stroke_duration) <= 0):
                        raise ContractError("invalid_structured_duration", f"{field}.stroke_duration_seconds must be greater than zero", f"{field}.stroke_duration_seconds")
                elif layer.get("line_art_rgba") is not None or (policy == "manual" and float(stroke_duration or 0) != 0):
                    raise ContractError("direct_fill_must_not_have_line_stage", f"{field} direct_fill must omit line_art_rgba and stroke_duration_seconds", field)
            if policy == "manual":
                structured_duration = sum(float(x.get("stroke_duration_seconds", 0)) + float(x["fill_duration_seconds"]) for x in layers)
                if abs(structured_duration - draw) > 1.0 / fps / 2.0:
                    raise ContractError("structured_duration_mismatch", f"structured layer durations total {structured_duration:g}s but draw_duration_seconds is {draw:g}s", "structured_layers.layers")
            return job

        if job["contract_version"] != "1.0":
            raise ContractError("legacy_mode_requires_1_0", "prepainted background mode remains contract_version 1.0", "contract_version")
        structured["_background_path"] = require_asset(structured.get("background"), "structured_layers.background")
        structured["_line_art_path"] = require_asset(structured.get("line_art"), "structured_layers.line_art")
        objects = structured.get("objects")
        if not isinstance(objects, list) or not objects:
            raise ContractError("invalid_structured_objects", "structured_layers.objects must contain at least one object", "structured_layers.objects")
        ids, orders = set(), set()
        for index, obj in enumerate(objects):
            field = f"structured_layers.objects[{index}]"
            if not isinstance(obj, dict) or not str(obj.get("id", "")).strip():
                raise ContractError("invalid_structured_object", f"{field}.id is required", f"{field}.id")
            if obj["id"] in ids:
                raise ContractError("duplicate_structured_object_id", f"duplicate object id: {obj['id']}", f"{field}.id")
            ids.add(obj["id"])
            if not isinstance(obj.get("order"), int) or obj["order"] < 0 or obj["order"] in orders:
                raise ContractError("invalid_structured_object_order", f"{field}.order must be a unique non-negative integer", f"{field}.order")
            orders.add(obj["order"])
            obj["_mask_path"] = require_asset(obj.get("mask"), f"{field}.mask")
            for duration_name in ("stroke_duration_seconds", "fill_duration_seconds"):
                duration = obj.get(duration_name)
                if not isinstance(duration, (int, float)) or float(duration) <= 0:
                    raise ContractError("invalid_structured_duration", f"{field}.{duration_name} must be greater than zero", f"{field}.{duration_name}")
                if abs(float(duration) * fps - round(float(duration) * fps)) > 1e-6:
                    raise ContractError("non_integer_structured_frame_budget", f"{field}.{duration_name} * fps must be an integer", f"{field}.{duration_name}")
        structured_duration = sum(
            float(obj["stroke_duration_seconds"]) + float(obj["fill_duration_seconds"])
            for obj in objects
        )
        if abs(structured_duration - draw) > 1.0 / fps / 2.0:
            raise ContractError(
                "structured_duration_mismatch",
                f"structured object durations total {structured_duration:g}s but draw_duration_seconds is {draw:g}s",
                "structured_layers.objects",
            )
    return job


def frame_window(job: dict) -> tuple[int, int, int]:
    fps = int(job["timing"]["fps"])
    logical_total = int(round(float(job["timing"]["total_duration_seconds"]) * fps))
    segment = job.get("segment_window")
    if segment is None:
        return 0, logical_total, logical_total
    return int(segment["start_frame"]), int(segment["end_frame_exclusive"]), logical_total


def load_source(path: Path) -> np.ndarray:
    with Image.open(path) as image:
        rgba = image.convert("RGBA")
        background = Image.new("RGBA", image.size, "white")
        return np.array(Image.alpha_composite(background, rgba).convert("RGB"))


def alpha_aware_area_downsample(rgba: np.ndarray, width: int, height: int) -> np.ndarray:
    """Resize RGBA in premultiplied-alpha space so translucent edges keep their color."""
    if rgba.shape[:2] == (height, width):
        return rgba.copy()
    alpha = rgba[:, :, 3:4].astype(np.float32) / 255.0
    premultiplied = rgba[:, :, :3].astype(np.float32) * alpha
    resized_alpha = cv2.resize(alpha, (width, height), interpolation=cv2.INTER_AREA)
    if resized_alpha.ndim == 2:
        resized_alpha = resized_alpha[:, :, None]
    resized_rgb = cv2.resize(premultiplied, (width, height), interpolation=cv2.INTER_AREA)
    safe_alpha = np.maximum(resized_alpha, 1e-6)
    straight_rgb = np.where(resized_alpha > 1e-6, resized_rgb / safe_alpha, 0.0)
    return np.dstack((np.clip(straight_rgb, 0, 255), np.clip(resized_alpha * 255.0, 0, 255))).astype(np.uint8)


def load_job_source(job: dict) -> np.ndarray:
    with Image.open(job["_source_path"]) as image:
        if int(job["source"].get("supersample_scale", 1)) == 4 and image.mode != "RGBA":
            raise ContractError("supersampled_source_not_rgba", "4x source must be a true RGBA image", "source.path")
        rgba = np.array(image.convert("RGBA"))
    scale = int(job["source"].get("supersample_scale", 1))
    width = int(job["output_spec"]["width_px"])
    height = int(job["output_spec"]["height_px"])
    if scale == 4:
        expected = (height * 4, width * 4)
        if rgba.shape[:2] != expected:
            raise ContractError(
                "supersampled_source_geometry_mismatch",
                f"4x source must be {width * 4}x{height * 4}, got {rgba.shape[1]}x{rgba.shape[0]}",
                "source.path",
            )
        rgba = alpha_aware_area_downsample(rgba, width, height)
    background = np.full((rgba.shape[0], rgba.shape[1], 3), 255.0, dtype=np.float32)
    alpha = rgba[:, :, 3:4].astype(np.float32) / 255.0
    return np.clip(background * (1.0 - alpha) + rgba[:, :, :3].astype(np.float32) * alpha, 0, 255).astype(np.uint8)


def estimate_skeleton_length(mask: np.ndarray) -> int:
    remaining = mask.astype(np.uint8).copy()
    skeleton = np.zeros_like(remaining)
    kernel = cv2.getStructuringElement(cv2.MORPH_CROSS, (3, 3))
    while np.any(remaining):
        opened = cv2.morphologyEx(remaining, cv2.MORPH_OPEN, kernel)
        skeleton |= remaining & ~opened
        remaining = cv2.erode(remaining, kernel)
    return int(skeleton.sum())


PACE_PROFILES = {
    "calm": {"stroke_px_per_second": 260.0, "fill_px_per_second": 18000.0, "glyphs_per_second": 2.4, "lift_seconds": 0.16, "region_transition_seconds": 0.18, "min_row_seconds": 0.65, "min_hold_seconds": 1.25},
    "normal": {"stroke_px_per_second": 390.0, "fill_px_per_second": 28000.0, "glyphs_per_second": 3.6, "lift_seconds": 0.11, "region_transition_seconds": 0.12, "min_row_seconds": 0.48, "min_hold_seconds": 0.9},
    "energetic": {"stroke_px_per_second": 560.0, "fill_px_per_second": 42000.0, "glyphs_per_second": 5.0, "lift_seconds": 0.075, "region_transition_seconds": 0.08, "min_row_seconds": 0.36, "min_hold_seconds": 0.65},
}


def allocate_frames(weights: list[float], frame_budget: int) -> list[int]:
    if not weights:
        return []
    if frame_budget < len(weights):
        return [1 if index < frame_budget else 0 for index in range(len(weights))]
    total = max(sum(weights), 1e-9)
    raw = [weight / total * frame_budget for weight in weights]
    frames = [max(1, int(math.floor(value))) for value in raw]
    while sum(frames) < frame_budget:
        index = max(range(len(frames)), key=lambda i: raw[i] - frames[i])
        frames[index] += 1
    while sum(frames) > frame_budget:
        candidates = [i for i, value in enumerate(frames) if value > 1]
        if not candidates:
            break
        index = min(candidates, key=lambda i: raw[i] - frames[i])
        frames[index] -= 1
    return frames


def phase_seconds(metric: dict, profile: dict) -> float:
    if metric["phase"] == "stroke":
        return max(
            metric["skeleton_length_px"] / profile["stroke_px_per_second"] + metric["pen_lifts"] * profile["lift_seconds"],
            metric["text_glyphs"] / profile["glyphs_per_second"],
            metric["text_rows"] * profile["min_row_seconds"],
        )
    return metric["fill_area_px"] / profile["fill_px_per_second"] + metric["fill_regions"] * profile["region_transition_seconds"]


def choose_auto_timing(job: dict, phase_metrics: list[dict]) -> dict:
    fps = int(job["timing"]["fps"])
    total_frames = int(round(float(job["timing"]["total_duration_seconds"]) * fps))
    requested = job["timing"].get("pace")
    candidates = [requested] if requested in PACE_PROFILES else ["calm", "normal", "energetic"]
    text_glyphs = sum(item["text_glyphs"] for item in phase_metrics)
    selected, required, available_frames = None, None, None
    attempts = []
    for pace in candidates:
        profile = PACE_PROFILES[pace]
        readable = text_glyphs / profile["glyphs_per_second"] if text_glyphs else 0.0
        hold_seconds = max(profile["min_hold_seconds"], min(readable, 3.0))
        candidate_available = total_frames - int(math.ceil(hold_seconds * fps))
        seconds = [phase_seconds(metric, profile) for metric in phase_metrics]
        required_frames = max(len(seconds), int(math.ceil(sum(seconds) * fps)))
        attempts.append({"pace": pace, "required_draw_frames": required_frames, "available_draw_frames": candidate_available})
        if required_frames <= candidate_available:
            selected, required, available_frames = pace, seconds, candidate_available
            break
    insufficient = selected is None
    if insufficient:
        selected = candidates[-1]
        profile = PACE_PROFILES[selected]
        required = [phase_seconds(metric, profile) for metric in phase_metrics]
        hold_seconds = max(profile["min_hold_seconds"], min(text_glyphs / profile["glyphs_per_second"] if text_glyphs else 0.0, 3.0))
        available_frames = max(0, total_frames - int(math.ceil(hold_seconds * fps)))
    draw_frames = min(available_frames, max(len(required), int(math.ceil(sum(required) * fps))))
    insufficient = insufficient or draw_frames < len(required)
    phase_frames = allocate_frames(required, draw_frames)
    job["timing"]["draw_duration_seconds"] = draw_frames / fps
    return {
        "policy": "auto", "requested_pace": requested, "selected_pace": selected,
        "total_frames": total_frames, "draw_frames": draw_frames, "hold_frames": total_frames - draw_frames,
        "phase_frames": phase_frames, "frame_budget_conserved": sum(phase_frames) + total_frames - draw_frames == total_frames,
        "insufficient_duration": insufficient,
        "reduction_reasons": ["reduce_object_count_or_text_or_split_semantic_board"] if insufficient else [],
        "attempts": attempts,
        "calibration": PACE_PROFILES[selected],
    }


def load_mask(path: Path) -> np.ndarray:
    with Image.open(path) as image:
        rgba = np.array(image.convert("RGBA"))
    alpha = rgba[:, :, 3]
    luminance = cv2.cvtColor(rgba[:, :, :3], cv2.COLOR_RGB2GRAY)
    return (alpha > 127) & (luminance > 127)


def resize_mask(mask: np.ndarray, width: int, height: int) -> np.ndarray:
    if mask.shape == (height, width):
        return mask
    return cv2.resize(mask.astype(np.uint8), (width, height), interpolation=cv2.INTER_NEAREST) > 0


def load_rgba(path: Path) -> np.ndarray:
    with Image.open(path) as image:
        if image.mode != "RGBA":
            raise ContractError("structured_asset_not_rgba", f"asset must be a true RGBA image: {path}")
        return np.array(image)


def resize_job_rgba(job: dict, rgba: np.ndarray, width: int, height: int) -> np.ndarray:
    if rgba.shape[:2] == (height, width):
        return rgba
    if int(job["source"].get("supersample_scale", 1)) == 4:
        return alpha_aware_area_downsample(rgba, width, height)
    return cv2.resize(rgba, (width, height), interpolation=cv2.INTER_AREA)


def text_region_metrics(layer: dict) -> tuple[int, int]:
    regions = layer.get("text_regions", [])
    glyphs = sum(max(0, int(region.get("glyph_count", 0))) for region in regions)
    rows = len({int(region.get("line_order", 0)) for region in regions})
    return glyphs, rows


def prepare_auto_structured_timing(job: dict, source_rgb: np.ndarray) -> None:
    if job["timing"].get("policy", "manual") != "auto":
        return
    structured = job.get("structured_layers")
    if not structured:
        return
    if structured["mode"] != "stacked_layer_object_complete_reveal":
        raise ContractError("auto_timing_requires_stacked_layers", "auto timing currently requires flat input or stacked semantic layers", "structured_layers.mode")
    height, width = source_rgb.shape[:2]
    phase_metrics = []
    phase_owners = []
    for layer in sorted(structured["layers"], key=lambda value: value["draw_order"]):
        color_native = load_rgba(layer["_color_rgba_path"])
        color = resize_job_rgba(job, color_native, width, height)
        color_mask = color[:, :, 3] > 0
        if layer["reveal_mode"] == "line_then_fill":
            line_native = load_rgba(layer["_line_art_rgba_path"])
            line = resize_job_rgba(job, line_native, width, height)
            line_mask = line[:, :, 3] > 0
            glyphs, rows = text_region_metrics(layer)
            if layer.get("semantic_kind") == "character":
                if layer["stroke_order_policy"] in ("head_body_hands_feet", DETAILED_CHARACTER_ORDER_POLICY):
                    part_masks = load_character_part_masks(job, layer, color_native.shape[:2], line_mask.shape)
                    components = sum(cv2.connectedComponents((line_mask & part_mask).astype(np.uint8))[0] - 1 for _, part_mask in part_masks)
                else:
                    left, top, right, bottom = layer["head_bbox"]
                    head_region = np.zeros_like(line_mask, dtype=bool)
                    head_region[top:bottom, left:right] = True
                    components = sum(
                        cv2.connectedComponents(region.astype(np.uint8))[0] - 1
                        for region in (line_mask & head_region, line_mask & ~head_region)
                    )
            else:
                components = cv2.connectedComponents(line_mask.astype(np.uint8))[0] - 1
            phase_metrics.append({
                "owner": layer["id"], "phase": "stroke", "skeleton_length_px": estimate_skeleton_length(line_mask),
                "fill_area_px": 0, "pen_lifts": max(1, int(components)), "fill_regions": 0,
                "text_glyphs": glyphs, "text_rows": rows,
            })
            phase_owners.append((layer, "stroke_duration_seconds"))
        phase_metrics.append({
            "owner": layer["id"], "phase": "fill", "skeleton_length_px": 0,
            "fill_area_px": int(color_mask.sum()), "pen_lifts": 0, "fill_regions": 1,
            "text_glyphs": 0, "text_rows": 0,
        })
        phase_owners.append((layer, "fill_duration_seconds"))
    plan = choose_auto_timing(job, phase_metrics)
    fps = int(job["timing"]["fps"])
    for (layer, field), frames in zip(phase_owners, plan["phase_frames"]):
        layer[field] = frames / fps
    plan["phase_metrics"] = [dict(metric, allocated_frames=frames) for metric, frames in zip(phase_metrics, plan["phase_frames"])]
    job["_auto_timing_plan"] = plan


def split_explicit_text_components(animator: WhiteboardAnimator, line_alpha: np.ndarray, layer: dict) -> list[dict]:
    regions = sorted(layer.get("text_regions", []), key=lambda value: value["reading_order"])
    if not regions:
        component = animator._build_component_group(animator._build_connected_components(line_alpha, min_area=1), is_text=False)
        return [] if component is None else [component]
    covered = np.zeros_like(line_alpha, dtype=bool)
    text_components = []
    height, width = line_alpha.shape
    for region in regions:
        left, top, right, bottom = region["bbox"]
        if left < 0 or top < 0 or right > width or bottom > height:
            raise ContractError("text_region_out_of_bounds", f"text region {region.get('id', region['reading_order'])} is outside the output canvas")
        region_mask = np.zeros_like(line_alpha, dtype=bool)
        region_mask[top:bottom, left:right] = line_alpha[top:bottom, left:right]
        if int(region_mask.sum()) < 1:
            raise ContractError("empty_text_region", f"text region {region.get('id', region['reading_order'])} contains no line pixels")
        covered |= region_mask
        component = animator._build_component_group(animator._build_connected_components(region_mask, min_area=1), is_text=True)
        if component is not None:
            component.update({"is_text": True, "_text_region_id": region.get("id"), "_reading_order": region["reading_order"]})
            text_components.append(component)
    geometry = line_alpha & ~covered
    result = []
    geometry_component = animator._build_component_group(animator._build_connected_components(geometry, min_area=1), is_text=False)
    if geometry_component is not None:
        result.append(geometry_component)
    return result + text_components


def split_character_head_first_components(
    animator: WhiteboardAnimator,
    mask: np.ndarray,
    head_bbox: list[int],
    *,
    is_fill: bool,
) -> tuple[list[dict], int]:
    """Split authored character pixels into deterministic head then remainder passes."""
    left, top, right, bottom = head_bbox
    head_region = np.zeros_like(mask, dtype=bool)
    head_region[top:bottom, left:right] = True
    head_mask = mask & head_region
    head_pixels = int(head_mask.sum())
    if head_pixels < 1:
        raise ContractError(
            "empty_character_head_region",
            "character head_bbox contains no authored pixels",
            "structured_layers.layers[].head_bbox",
        )

    ordered = []
    for region_name, region_mask in (("head", head_mask), ("remainder", mask & ~head_region)):
        parts = animator._build_connected_components(region_mask, min_area=1)
        if not parts:
            continue
        for part in parts:
            part["is_fill"] = is_fill
        component = animator._build_component_group(parts, is_text=False)
        if component is None:
            continue
        component["is_fill"] = is_fill
        component["_character_region"] = region_name
        if is_fill and component.get("_sub_components"):
            component["_multicolor_fill"] = True
        ordered.append(component)
    return ordered, head_pixels


def load_character_part_masks(
    job: dict,
    layer: dict,
    native_shape: tuple[int, int],
    output_shape: tuple[int, int],
) -> list[tuple[str, np.ndarray]]:
    """Load checksum-bound authored part masks without inferring anatomy from pixels."""
    native_height, native_width = native_shape
    output_height, output_width = output_shape
    native_masks = []
    for part in layer["character_parts"]:
        with Image.open(part["_mask_rgba_path"]) as image:
            if image.mode != "RGBA":
                raise ContractError(
                    "character_part_mask_not_rgba",
                    f"character part {part['part']} mask must be a true RGBA image",
                    "structured_layers.layers[].character_parts[].mask_rgba",
                )
            mask_native = np.array(image)
        if mask_native.shape[:2] != (native_height, native_width):
            raise ContractError(
                "character_part_geometry_mismatch",
                f"character part {part['part']} mask must match source geometry {native_width}x{native_height}",
                "structured_layers.layers[].character_parts[].mask_rgba",
            )
        part_mask = mask_native[:, :, 3] > 0
        if int(part_mask.sum()) < 1:
            raise ContractError(
                "empty_character_part_mask",
                f"character part {part['part']} mask contains no alpha pixels",
                "structured_layers.layers[].character_parts[].mask_rgba",
            )
        native_masks.append((part["part"], part_mask))
    native_ownership = np.sum(np.stack([mask for _, mask in native_masks]), axis=0)
    if int((native_ownership > 1).sum()):
        raise ContractError(
            "overlapping_character_part_masks",
            "character part masks overlap at source geometry",
            "structured_layers.layers[].character_parts",
        )
    coverage_scores = np.stack([
        cv2.resize(mask.astype(np.float32), (output_width, output_height), interpolation=cv2.INTER_AREA)
        for _, mask in native_masks
    ])
    owners = np.argmax(coverage_scores, axis=0)
    covered = np.max(coverage_scores, axis=0) > 0
    ordered = []
    for index, (part_name, _) in enumerate(native_masks):
        output_mask = covered & (owners == index)
        if int(output_mask.sum()) < 1:
            raise ContractError(
                "empty_character_part_mask",
                f"character part {part_name} mask contains no output-space pixels",
                "structured_layers.layers[].character_parts[].mask_rgba",
            )
        ordered.append((part_name, output_mask))
    return ordered


def validate_character_part_coverage(
    line_alpha: np.ndarray,
    color_alpha: np.ndarray,
    part_masks: list[tuple[str, np.ndarray]],
) -> None:
    authored = line_alpha | color_alpha
    ownership = np.zeros_like(authored, dtype=np.uint8)
    for _, part_mask in part_masks:
        ownership += (part_mask & authored).astype(np.uint8)
    if int(((ownership > 1) & authored).sum()):
        raise ContractError(
            "overlapping_character_part_masks",
            "character part masks overlap on authored line or color pixels",
            "structured_layers.layers[].character_parts",
        )
    if int((authored & (ownership == 0)).sum()):
        raise ContractError(
            "uncovered_character_part_pixels",
            "character part masks must cover every authored line and color pixel",
            "structured_layers.layers[].character_parts",
        )


def load_character_stroke_phase_masks(
    layer: dict,
    native_shape: tuple[int, int],
    output_shape: tuple[int, int],
    part_masks: list[tuple[str, np.ndarray]],
) -> list[tuple[str, np.ndarray, np.ndarray]]:
    """Load authored outline/detail masks; do not infer semantic interiors from pixels."""
    native_height, native_width = native_shape
    output_height, output_width = output_shape
    output_parts = dict(part_masks)
    ordered = []
    for part in layer["character_parts"]:
        with Image.open(part["_mask_rgba_path"]) as image:
            native_part = np.array(image)[:, :, 3] > 0
        native_phases = []
        for phase in CHARACTER_STROKE_PHASE_ORDER:
            path = part[f"_{phase[:-1] if phase == 'details' else phase}_mask_rgba_path"]
            with Image.open(path) as image:
                if image.mode != "RGBA":
                    raise ContractError(
                        "character_stroke_phase_mask_not_rgba",
                        f"character part {part['part']} {phase} mask must be a true RGBA image",
                        f"structured_layers.layers[].character_parts[].{phase[:-1] if phase == 'details' else phase}_mask_rgba",
                    )
                rgba = np.array(image)
            if rgba.shape[:2] != (native_height, native_width):
                raise ContractError(
                    "character_stroke_phase_geometry_mismatch",
                    f"character part {part['part']} {phase} mask must match source geometry {native_width}x{native_height}",
                    "structured_layers.layers[].character_parts",
                )
            native_phases.append(rgba[:, :, 3] > 0)
        if int((native_phases[0] & native_phases[1]).sum()):
            raise ContractError(
                "overlapping_character_stroke_phase_masks",
                f"character part {part['part']} outline and detail masks overlap at source geometry",
                "structured_layers.layers[].character_parts",
            )
        if any(int((phase_mask & ~native_part).sum()) for phase_mask in native_phases):
            raise ContractError(
                "character_stroke_phase_outside_part",
                f"character part {part['part']} outline/detail masks must stay inside its part mask",
                "structured_layers.layers[].character_parts",
            )
        coverage_scores = np.stack([
            cv2.resize(mask.astype(np.float32), (output_width, output_height), interpolation=cv2.INTER_AREA)
            for mask in native_phases
        ])
        owners = np.argmax(coverage_scores, axis=0)
        covered = np.max(coverage_scores, axis=0) > 0
        part_output = output_parts[part["part"]]
        resized = [covered & part_output & (owners == index) for index in range(2)]
        ordered.append((part["part"], resized[0], resized[1]))
    return ordered


def validate_character_stroke_phase_coverage(
    line_alpha: np.ndarray,
    phase_masks: list[tuple[str, np.ndarray, np.ndarray]],
) -> None:
    ownership = np.zeros_like(line_alpha, dtype=np.uint8)
    for part_name, outline_mask, detail_mask in phase_masks:
        outline_pixels = int((line_alpha & outline_mask).sum())
        if outline_pixels < 1:
            raise ContractError(
                "empty_character_outline_region",
                f"character part {part_name} must contain authored outline pixels",
                "structured_layers.layers[].character_parts[].outline_mask_rgba",
            )
        ownership += (line_alpha & outline_mask).astype(np.uint8)
        ownership += (line_alpha & detail_mask).astype(np.uint8)
    if int(((ownership > 1) & line_alpha).sum()):
        raise ContractError(
            "overlapping_character_stroke_phase_masks",
            "character outline and detail masks overlap on authored line pixels",
            "structured_layers.layers[].character_parts",
        )
    if int((line_alpha & (ownership == 0)).sum()):
        raise ContractError(
            "uncovered_character_stroke_phase_pixels",
            "outline/detail masks must assign every authored character line pixel exactly once",
            "structured_layers.layers[].character_parts",
        )


def split_character_ordered_stroke_components(
    animator: WhiteboardAnimator,
    line_alpha: np.ndarray,
    phase_masks: list[tuple[str, np.ndarray, np.ndarray]],
) -> tuple[list[dict], dict[str, int], dict[str, int]]:
    """Schedule each anatomical part as outline first, then authored interior details."""
    ordered, outline_counts, detail_counts = [], {}, {}
    for part_name, outline_mask, detail_mask in phase_masks:
        for phase, region_mask, counts in (
            ("outline", outline_mask, outline_counts),
            ("details", detail_mask, detail_counts),
        ):
            phase_line = line_alpha & region_mask
            pixels = int(phase_line.sum())
            counts[part_name] = pixels
            if pixels < 1:
                continue
            parts = animator._build_connected_components(phase_line, min_area=1)
            for component_part in parts:
                component_part["is_fill"] = False
            component = animator._build_component_group(parts, is_text=False)
            if component is None:
                raise ContractError("structured_layer_untraceable", f"cannot build character part {part_name} {phase}")
            component.update({"is_fill": False, "_character_region": part_name, "_character_stroke_phase": phase})
            ordered.append(component)
    return ordered, outline_counts, detail_counts


def split_character_ordered_part_components(
    animator: WhiteboardAnimator,
    mask: np.ndarray,
    part_masks: list[tuple[str, np.ndarray]],
    *,
    is_fill: bool,
) -> tuple[list[dict], dict[str, int]]:
    """Split authored character pixels into explicit anatomical-part passes."""
    ordered = []
    pixel_counts = {}
    for part_name, region_mask in part_masks:
        part_mask = mask & region_mask
        pixels = int(part_mask.sum())
        pixel_counts[part_name] = pixels
        if pixels < 1:
            raise ContractError(
                "empty_character_part_region",
                f"character part {part_name} contains no authored {'fill' if is_fill else 'line'} pixels",
                "structured_layers.layers[].character_parts",
            )
        parts = animator._build_connected_components(part_mask, min_area=1)
        for part in parts:
            part["is_fill"] = is_fill
        component = animator._build_component_group(parts, is_text=False)
        if component is None:
            raise ContractError("structured_layer_untraceable", f"cannot build character part {part_name}")
        component["is_fill"] = is_fill
        component["_character_region"] = part_name
        if is_fill and component.get("_sub_components"):
            component["_multicolor_fill"] = True
        ordered.append(component)
    return ordered, pixel_counts


def stacked_layer_analysis(job: dict, source_rgb: np.ndarray, animator: WhiteboardAnimator) -> tuple[dict, list, list]:
    structured = job["structured_layers"]
    native_source = load_source(job["_source_path"])
    native_height, native_width = native_source.shape[:2]
    height, width = source_rgb.shape[:2]
    ordered = sorted(structured["layers"], key=lambda value: value["draw_order"])
    prepared_layers, schedule, reports = [], [], []
    cursor = 0.0
    for index, layer in enumerate(ordered):
        color_native = load_rgba(layer["_color_rgba_path"])
        if color_native.shape[:2] != (native_height, native_width):
            raise ContractError("structured_geometry_mismatch", f"layer {layer['id']} color asset must match source geometry {native_width}x{native_height}", f"structured_layers.layers[{index}].color_rgba")
        color = resize_job_rgba(job, color_native, width, height)
        color_alpha = color[:, :, 3] > 0
        color_pixels = int(color_alpha.sum())
        if color_pixels < 16:
            raise ContractError("structured_color_alpha_missing", f"layer {layer['id']} has fewer than 16 color-alpha pixels")
        line = None
        stroke_component = None
        stroke_components = []
        layer_stroke_schedule = []
        line_pixels = 0
        head_line_pixels = 0
        head_color_pixels = 0
        character_part_masks = []
        character_stroke_phase_masks = []
        character_part_line_pixels = {}
        character_part_color_pixels = {}
        character_part_outline_pixels = {}
        character_part_detail_pixels = {}
        unrelated_pixels = 0
        stroke_duration = float(layer.get("stroke_duration_seconds", 0))
        if layer.get("semantic_kind") == "character" and layer.get("stroke_order_policy") in ("head_body_hands_feet", DETAILED_CHARACTER_ORDER_POLICY):
            character_part_masks = load_character_part_masks(job, layer, color_native.shape[:2], color_alpha.shape)
            if layer["stroke_order_policy"] == DETAILED_CHARACTER_ORDER_POLICY:
                character_stroke_phase_masks = load_character_stroke_phase_masks(
                    layer, color_native.shape[:2], color_alpha.shape, character_part_masks,
                )
        if layer["reveal_mode"] == "line_then_fill":
            line_native = load_rgba(layer["_line_art_rgba_path"])
            if line_native.shape[:2] != (native_height, native_width):
                raise ContractError("structured_geometry_mismatch", f"layer {layer['id']} line asset must match source geometry {native_width}x{native_height}", f"structured_layers.layers[{index}].line_art_rgba")
            line = resize_job_rgba(job, line_native, width, height)
            line_alpha = line[:, :, 3] > 0
            line_pixels = int(line_alpha.sum())
            if line_pixels < 16:
                raise ContractError("structured_line_alpha_missing", f"layer {layer['id']} has fewer than 16 line-alpha pixels")
            tolerance = max(1, int(structured.get("line_alpha_tolerance_px", 3)))
            allowed = cv2.dilate(color_alpha.astype(np.uint8), np.ones((tolerance * 2 + 1, tolerance * 2 + 1), dtype=np.uint8)) > 0
            unrelated = line_alpha & ~allowed
            unrelated_pixels = int(unrelated.sum())
            if unrelated_pixels / max(line_pixels, 1) > 0.01:
                raise ContractError("structured_line_outside_layer_alpha", f"layer {layer['id']} has materially unrelated line alpha")
            if layer.get("semantic_kind") == "character":
                if layer["stroke_order_policy"] in ("head_body_hands_feet", DETAILED_CHARACTER_ORDER_POLICY):
                    validate_character_part_coverage(line_alpha, color_alpha, character_part_masks)
                    if layer["stroke_order_policy"] == DETAILED_CHARACTER_ORDER_POLICY:
                        validate_character_stroke_phase_coverage(line_alpha, character_stroke_phase_masks)
                        stroke_components, character_part_outline_pixels, character_part_detail_pixels = split_character_ordered_stroke_components(
                            animator, line_alpha, character_stroke_phase_masks,
                        )
                        character_part_line_pixels = {
                            name: character_part_outline_pixels[name] + character_part_detail_pixels[name]
                            for name in CHARACTER_PART_ORDER
                        }
                    else:
                        stroke_components, character_part_line_pixels = split_character_ordered_part_components(
                            animator, line_alpha, character_part_masks, is_fill=False,
                        )
                else:
                    stroke_components, head_line_pixels = split_character_head_first_components(
                        animator, line_alpha, layer["head_bbox"], is_fill=False,
                    )
            else:
                stroke_components = split_explicit_text_components(animator, line_alpha, layer)
            if not stroke_components:
                raise ContractError("structured_layer_untraceable", f"cannot build line component for layer {layer['id']}")
            stroke_component = animator._build_component_group(stroke_components, is_text=False)
            stroke_component["_children"] = stroke_components
            child_weights = [max(1.0, float(estimate_skeleton_length(child["mask"]))) for child in stroke_components]
            child_frames = allocate_frames(child_weights, max(len(child_weights), int(round(stroke_duration * job["timing"]["fps"]))))
            child_cursor = cursor
            for child, frames in zip(stroke_components, child_frames):
                child_duration = frames / job["timing"]["fps"]
                child.update({"is_fill": False, "_structured_object_id": layer["id"], "_structured_phase": "stroke"})
                schedule.append((child, child_cursor, child_duration))
                layer_stroke_schedule.append((child, child_cursor, child_duration))
                child_cursor += child_duration
        if layer.get("semantic_kind") == "character":
            if layer["stroke_order_policy"] in ("head_body_hands_feet", DETAILED_CHARACTER_ORDER_POLICY):
                fill_parts, character_part_color_pixels = split_character_ordered_part_components(
                    animator, color_alpha, character_part_masks, is_fill=True,
                )
            else:
                fill_parts, head_color_pixels = split_character_head_first_components(
                    animator, color_alpha, layer["head_bbox"], is_fill=True,
                )
        else:
            fill_parts = animator._build_connected_components(color_alpha, min_area=1)
            for part in fill_parts:
                part["is_fill"] = True
        fill_component = animator._build_component_group(fill_parts, is_text=False)
        if fill_component is None:
            raise ContractError("structured_layer_untraceable", f"cannot build fill component for layer {layer['id']}")
        fill_component.update({"is_fill": True, "_multicolor_fill": True, "_structured_object_id": layer["id"], "_structured_phase": "fill"})
        fill_start = cursor + stroke_duration
        fill_duration = float(layer["fill_duration_seconds"])
        schedule.append((fill_component, fill_start, fill_duration))
        prepared_layers.append({
            "id": layer["id"], "draw_order": int(layer["draw_order"]), "z_index": int(layer["z_index"]), "reveal_mode": layer["reveal_mode"],
            "color_rgba": color, "line_rgba": line, "stroke_component": stroke_component, "stroke_components": stroke_components, "stroke_schedule": layer_stroke_schedule, "fill_component": fill_component,
            "stroke_start": cursor, "stroke_duration": stroke_duration, "fill_start": fill_start, "fill_duration": fill_duration,
        })
        reports.append({
            "id": layer["id"], "draw_order": int(layer["draw_order"]), "z_index": int(layer["z_index"]), "reveal_mode": layer["reveal_mode"], "semantic_kind": layer.get("semantic_kind", "illustration"),
            "color_alpha_pixels": color_pixels, "line_alpha_pixels": line_pixels, "line_outside_alpha_tolerance_pixels": unrelated_pixels,
            "stroke_order_policy": layer.get("stroke_order_policy"), "head_bbox": layer.get("head_bbox"),
            "head_line_alpha_pixels": head_line_pixels, "head_color_alpha_pixels": head_color_pixels,
            "character_part_order": list(character_part_line_pixels),
            "character_part_line_alpha_pixels": character_part_line_pixels,
            "character_part_color_alpha_pixels": character_part_color_pixels,
            "character_part_stroke_phase_order": list(CHARACTER_STROKE_PHASE_ORDER) if character_stroke_phase_masks else [],
            "character_part_outline_alpha_pixels": character_part_outline_pixels,
            "character_part_detail_alpha_pixels": character_part_detail_pixels,
            "text_reading_order": [region.get("id", region["reading_order"]) for region in sorted(layer.get("text_regions", []), key=lambda value: value["reading_order"])],
            "stroke_start_frame": None if not stroke_component else int(round(cursor * job["timing"]["fps"])),
            "stroke_end_frame": None if not stroke_component else int(round(fill_start * job["timing"]["fps"])),
            "fill_start_frame": int(round(fill_start * job["timing"]["fps"])),
            "fill_end_frame": int(round((fill_start + fill_duration) * job["timing"]["fps"])),
        })
        cursor = fill_start + fill_duration

    paper = np.empty_like(source_rgb)
    paper[:] = np.array(structured["paper_rgb"], dtype=np.uint8)
    composite = paper.astype(np.float32)
    for layer in sorted(prepared_layers, key=lambda value: value["z_index"]):
        rgba = layer["color_rgba"].astype(np.float32)
        alpha = rgba[:, :, 3:4] / 255.0
        composite = composite * (1.0 - alpha) + rgba[:, :, :3] * alpha
    composite = np.clip(composite, 0, 255).astype(np.uint8)
    error = np.abs(composite.astype(np.int16) - source_rgb.astype(np.int16))
    comparison = {"mean_abs_error": float(error.mean()), "p95_abs_error": float(np.percentile(error, 95)), "max_abs_error": int(error.max()), "pixel_mismatch_ratio_gt_8": float((np.max(error, axis=2) > 8).mean())}
    supported = comparison["mean_abs_error"] <= 2.0 and comparison["p95_abs_error"] <= 4.0 and comparison["pixel_mismatch_ratio_gt_8"] <= 0.01
    job["_stacked_layers"], job["_stacked_paper_rgb"] = prepared_layers, paper
    return ({
        "supported": supported, "reason": None if supported else "flattened_final_composite_drift",
        "warnings": [] if supported else ["flattened_final_composite_differs_from_source"],
        "layer_reports": reports, "draw_order": [x["id"] for x in ordered],
        "z_order": [x["id"] for x in sorted(prepared_layers, key=lambda value: value["z_index"])],
        "final_composite_comparison": comparison,
    }, [component for component, _, _ in schedule], schedule)


def structured_analysis(job: dict, source_rgb: np.ndarray, animator: WhiteboardAnimator) -> tuple[dict, list, list]:
    structured = job["structured_layers"]
    if structured["mode"] == "stacked_layer_object_complete_reveal":
        return stacked_layer_analysis(job, source_rgb, animator)
    native_source = load_source(job["_source_path"])
    native_height, native_width = native_source.shape[:2]

    background_native = load_source(structured["_background_path"])
    line_native = load_source(structured["_line_art_path"])
    for field, image in (("background", background_native), ("line_art", line_native)):
        if image.shape[:2] != (native_height, native_width):
            raise ContractError(
                "structured_geometry_mismatch",
                f"structured_layers.{field} must match source geometry {native_width}x{native_height}",
                f"structured_layers.{field}.path",
            )

    height, width = source_rgb.shape[:2]
    background_rgb = animator._downscale(background_native)
    line_rgb = animator._downscale(line_native)
    if background_rgb.shape[:2] != (height, width) or line_rgb.shape[:2] != (height, width):
        raise ContractError("structured_geometry_mismatch", "structured assets do not resolve to source render geometry")

    threshold = int(structured.get("line_art_threshold", 220))
    line_mask = cv2.cvtColor(line_rgb, cv2.COLOR_RGB2GRAY) < threshold
    ordered_objects = sorted(structured["objects"], key=lambda value: value["order"])
    ownership = np.zeros((height, width), dtype=np.uint16)
    prepared = []
    schedule = []
    stroke_cursor = 0.0
    fill_cursor = sum(float(obj["stroke_duration_seconds"]) for obj in ordered_objects)
    object_reports = []

    for object_index, obj in enumerate(ordered_objects, 1):
        native_mask = load_mask(obj["_mask_path"])
        if native_mask.shape != (native_height, native_width):
            raise ContractError(
                "structured_geometry_mismatch",
                f"mask for {obj['id']} must match source geometry {native_width}x{native_height}",
                f"structured_layers.objects[{object_index - 1}].mask.path",
            )
        mask = resize_mask(native_mask, width, height)
        area = int(mask.sum())
        if area < 32:
            raise ContractError("structured_mask_too_small", f"mask for {obj['id']} has fewer than 32 pixels")
        overlap = mask & (ownership > 0)
        if overlap.any():
            raise ContractError(
                "structured_mask_overlap",
                f"mask for {obj['id']} overlaps earlier object masks by {int(overlap.sum())} pixels",
                f"structured_layers.objects[{object_index - 1}].mask.path",
            )
        ownership[mask] = object_index

        stroke_mask = mask & line_mask
        fill_mask = mask & ~stroke_mask
        stroke_area, fill_area = int(stroke_mask.sum()), int(fill_mask.sum())
        if stroke_area < 16:
            raise ContractError("structured_line_art_missing", f"line art contributes fewer than 16 pixels inside {obj['id']}")
        if fill_area < 16:
            raise ContractError("structured_fill_missing", f"mask for {obj['id']} has fewer than 16 fill pixels")

        stroke_parts = animator._build_connected_components(stroke_mask, min_area=1)
        stroke_component = animator._build_component_group(stroke_parts, is_text=False)
        if stroke_component is None:
            raise ContractError("structured_line_art_missing", f"cannot build stroke component for {obj['id']}")
        stroke_component["is_fill"] = False
        stroke_component["_structured_object_id"] = obj["id"]
        stroke_component["_structured_phase"] = "stroke"

        fill_parts = []
        for component in animator._build_connected_components(fill_mask, min_area=1):
            component["is_fill"] = True
            fill_parts.append(component)
        fill_component = animator._build_component_group(fill_parts, is_text=False)
        if fill_component is None:
            raise ContractError("structured_fill_missing", f"cannot build fill component for {obj['id']}")
        fill_component["is_fill"] = True
        fill_component["_multicolor_fill"] = True
        fill_component["_structured_object_id"] = obj["id"]
        fill_component["_structured_phase"] = "fill"

        stroke_duration = float(obj["stroke_duration_seconds"])
        fill_duration = float(obj["fill_duration_seconds"])
        prepared.append((stroke_component, fill_component))
        schedule.append((stroke_component, stroke_cursor, stroke_duration))
        object_reports.append({
            "id": obj["id"], "order": int(obj["order"]), "mask_pixels": area,
            "stroke_pixels": stroke_area, "fill_pixels": fill_area,
            "stroke_start": stroke_cursor, "stroke_end": stroke_cursor + stroke_duration,
            "fill_start": fill_cursor, "fill_end": fill_cursor + fill_duration,
        })
        stroke_cursor += stroke_duration
        fill_cursor += fill_duration

    stroke_schedule = schedule
    fill_schedule = []
    fill_cursor = sum(float(obj["stroke_duration_seconds"]) for obj in ordered_objects)
    for obj, (_, fill_component) in zip(ordered_objects, prepared):
        fill_duration = float(obj["fill_duration_seconds"])
        fill_schedule.append((fill_component, fill_cursor, fill_duration))
        fill_cursor += fill_duration
    schedule = stroke_schedule + fill_schedule
    components = [component for component, _, _ in schedule]

    union = ownership > 0
    outside = ~union
    outside_abs = np.abs(source_rgb.astype(np.int16) - background_rgb.astype(np.int16))[outside]
    outside_mean = float(outside_abs.mean()) if outside_abs.size else 0.0
    outside_p95 = float(np.percentile(outside_abs, 95)) if outside_abs.size else 0.0
    warnings = []
    supported = True
    reason = None
    if outside_mean > 1.0 or outside_p95 > 4.0:
        supported = False
        reason = "clean_background_drift_outside_object_masks"
        warnings.append("clean_background_differs_outside_object_masks")

    job["_structured_background_rgb"] = background_rgb
    return ({
        "supported": supported,
        "reason": reason,
        "warnings": warnings,
        "background_rgb": background_rgb,
        "object_union_mask": union,
        "object_reports": object_reports,
        "outside_background_mean_abs_error": outside_mean,
        "outside_background_p95_abs_error": outside_p95,
        "background_sha256": sha256_file(structured["_background_path"]),
        "line_art_sha256": sha256_file(structured["_line_art_path"]),
    }, components, schedule)


def analyze(job: dict) -> tuple[dict, np.ndarray, list, list]:
    source_rgb = load_job_source(job)
    animator = WhiteboardAnimator()
    if int(job["source"].get("supersample_scale", 1)) != 4 and job.get("structured_layers", {}).get("mode") == "stacked_layer_object_complete_reveal":
        source_rgb = animator._downscale(source_rgb)
    elif int(job["source"].get("supersample_scale", 1)) != 4:
        source_rgb = animator._downscale(animator._enforce_white_bg(source_rgb))
    timing = job["timing"]
    structured_facts = None
    prepare_auto_structured_timing(job, source_rgb)
    if job.get("structured_layers"):
        structured_facts, components, schedule = structured_analysis(job, source_rgb, animator)
    else:
        components = animator._sort_components_layered(animator._find_components(source_rgb))
        if timing.get("policy", "manual") == "auto":
            metrics = []
            for component in components:
                is_fill = bool(component.get("is_fill"))
                metrics.append({
                    "owner": f"component-{len(metrics)}", "phase": "fill" if is_fill else "stroke",
                    "skeleton_length_px": 0 if is_fill else estimate_skeleton_length(component["mask"]),
                    "fill_area_px": int(component["area"]) if is_fill else 0,
                    "pen_lifts": 0 if is_fill else max(1, len(component.get("sub_components", [])) or 1),
                    "fill_regions": 1 if is_fill else 0, "text_glyphs": 0, "text_rows": 0,
                })
            plan = choose_auto_timing(job, metrics)
            cursor = 0.0
            schedule = []
            for component, frames in zip(components, plan["phase_frames"]):
                duration = frames / timing["fps"]
                schedule.append((component, cursor, duration))
                cursor += duration
            plan["phase_metrics"] = [dict(metric, allocated_frames=frames) for metric, frames in zip(metrics, plan["phase_frames"])]
            job["_auto_timing_plan"] = plan
        else:
            schedule = animator._schedule_components(components, float(timing["draw_duration_seconds"]))

    gray = cv2.cvtColor(source_rgb, cv2.COLOR_RGB2GRAY)
    source_ink = gray < 240
    ink_pixels = int(source_ink.sum())
    total_pixels = int(source_ink.size)
    largest_area = max((int(component["area"]) for component in components), default=0)
    ink_ratio = ink_pixels / total_pixels if total_pixels else 0.0
    largest_share = largest_area / ink_pixels if ink_pixels else 0.0
    mixed_groups = [component for component in components if component.get("_mixed_stroke_fill") or component.get("_contains_mixed_stroke_fill")]
    detected_text_components = sum(bool(component.get("is_text")) for component in components)
    complexity_class = "complex" if ink_ratio > 0.55 or len(components) > 24 else ("moderate" if ink_ratio > 0.25 or len(components) > 10 else "simple")
    structured = job.get("structured_layers")
    adaptive_contract = job["contract_version"] in ("1.2", "1.3")
    flat_route_reasons = []
    if adaptive_contract and not structured:
        if complexity_class != "simple":
            flat_route_reasons.append(f"flat_source_complexity_{complexity_class}")
        if detected_text_components > 4:
            flat_route_reasons.append("embedded_text_requires_explicit_text_regions")
    schedule_end = max((float(start + duration) for _, start, duration in schedule), default=0.0)
    manual_schedule_overflow = (
        adaptive_contract
        and not structured
        and timing.get("policy", "manual") == "manual"
        and schedule_end > float(timing["draw_duration_seconds"]) + 0.5 / int(timing["fps"])
    )

    native_h, native_w = source_rgb.shape[:2]
    out_h, out_w = native_h + native_h % 2, native_w + native_w % 2
    expected = job["output_spec"]
    if (out_w, out_h) != (expected["width_px"], expected["height_px"]):
        raise ContractError(
            "output_geometry_mismatch",
            f"source resolves to {out_w}x{out_h}, job declares {expected['width_px']}x{expected['height_px']}",
            "output_spec",
        )

    warnings = []
    if ink_ratio > 0.70:
        warnings.append("most_of_frame_is_non_white")
    if largest_share > 0.70 and ink_ratio > 0.35:
        warnings.append("one_connected_component_dominates_reveal")
    requested_route = job.get("render_route", "auto")
    resolved_route = "structured_semantic" if structured or flat_route_reasons else "flat_auto"
    route_blockers = []
    if requested_route == "flat_auto" and structured:
        route_blockers.append("flat_auto_cannot_accept_structured_layers")
    if requested_route == "flat_auto" and flat_route_reasons:
        route_blockers.append("flat_auto_unsuitable_for_complex_source")
    if requested_route == "structured_semantic" and not structured:
        route_blockers.append("structured_semantic_requires_explicit_layers")
    if resolved_route == "structured_semantic" and not structured:
        route_blockers.append("structured_semantic_requires_explicit_layers")
    supported = not warnings
    reason = None
    if structured:
        warnings = list(structured_facts["warnings"])
        supported = bool(structured_facts["supported"])
        reason = structured_facts["reason"]
    elif flat_route_reasons:
        supported = False
        reason = "structured_semantic_requires_explicit_layers"
        warnings = list(warnings) + flat_route_reasons
    elif warnings:
        supported = False
        reason = "unsupported_full_frame_connected_scene_without_structured_layers"
    if route_blockers:
        supported = False
        if reason is None:
            reason = route_blockers[0]
    if manual_schedule_overflow:
        supported = False
        if reason is None:
            reason = "flat_schedule_exceeds_declared_draw_budget"
        warnings = list(warnings) + ["actual_schedule_exceeds_declared_draw_budget"]
        route_blockers.append("flat_schedule_exceeds_declared_draw_budget")
    auto_plan = job.get("_auto_timing_plan")
    if auto_plan and auto_plan["insufficient_duration"] and not flat_route_reasons:
        supported = False
        reason = "insufficient_duration_for_bounded_whiteboard_pace"
        warnings = list(warnings) + auto_plan["reduction_reasons"]

    entries = []
    for index, (component, start, duration) in enumerate(schedule):
        entries.append({
            "index": index,
            "start": float(start),
            "end": float(start + duration),
            "duration": float(duration),
            "is_fill": bool(component.get("is_fill")),
            "is_text": bool(component.get("is_text")),
            "text_region_id": component.get("_text_region_id"),
            "reading_order": component.get("_reading_order"),
            "structured_object_id": component.get("_structured_object_id"),
            "structured_phase": component.get("_structured_phase"),
            "character_part": component.get("_character_region"),
            "character_stroke_phase": component.get("_character_stroke_phase"),
            "mixed_stroke_fill": bool(component.get("_mixed_stroke_fill") or component.get("_contains_mixed_stroke_fill")),
            "bbox": [int(component["left"]), int(component["top"]), int(component["right"]), int(component["bottom"])],
            "area_px": int(component["area"]),
        })

    if structured and structured["mode"] == "stacked_layer_object_complete_reveal":
        structured_report = {
            "mode": structured["mode"], "layer_count": len(structured_facts["layer_reports"]),
            "layers": structured_facts["layer_reports"], "draw_order": structured_facts["draw_order"],
            "z_order": structured_facts["z_order"], "final_composite_comparison": structured_facts["final_composite_comparison"],
            "render_policy": "paper_then_z_composite_with_draw_order_reveal_modes",
        }
    elif structured:
        structured_report = {
            "mode": structured["mode"], "background_sha256": structured_facts["background_sha256"],
            "line_art_sha256": structured_facts["line_art_sha256"], "object_count": len(structured_facts["object_reports"]),
            "objects": structured_facts["object_reports"], "outside_background_mean_abs_error": structured_facts["outside_background_mean_abs_error"],
            "outside_background_p95_abs_error": structured_facts["outside_background_p95_abs_error"],
            "render_policy": "background_prepainted_then_all_strokes_then_all_fills",
        }
    else:
        structured_report = None
    def planned_asset(asset: dict, alpha_required: bool) -> dict:
        path = resolve_path(job["_job_path"], asset["path"])
        with Image.open(path) as image:
            dimensions = [int(image.width), int(image.height)]
            mode = image.mode
        return {"path": asset["path"], "sha256": asset["sha256"], "rights_evidence": asset["rights_evidence"], "dimensions_px": dimensions, "alpha_required": alpha_required, "observed_mode": mode}

    layer_plan = []
    if structured and structured["mode"] == "stacked_layer_object_complete_reveal":
        for layer in sorted(structured["layers"], key=lambda value: value["draw_order"]):
            assets = [planned_asset(layer["color_rgba"], True)] + ([planned_asset(layer["line_art_rgba"], True)] if layer.get("line_art_rgba") else [])
            layer_plan.append({
                "id": layer["id"], "semantic_kind": layer.get("semantic_kind", "illustration"),
                "draw_order": layer["draw_order"], "z_index": layer["z_index"], "reveal_mode": layer["reveal_mode"],
                "stroke_order_policy": layer.get("stroke_order_policy"), "head_bbox": layer.get("head_bbox"),
                "character_parts": [{
                    "part": part["part"],
                    "mask_rgba": planned_asset(part["mask_rgba"], True),
                    **({
                        "outline_mask_rgba": planned_asset(part["outline_mask_rgba"], True),
                        "detail_mask_rgba": planned_asset(part["detail_mask_rgba"], True),
                    } if part.get("outline_mask_rgba") and part.get("detail_mask_rgba") else {}),
                } for part in layer.get("character_parts", [])],
                "text_regions": layer.get("text_regions", []),
                "assets": assets,
            })
    else:
        layer_plan.append({"id": "flat-source", "semantic_kind": "illustration", "draw_order": 0, "z_index": 0, "reveal_mode": "auto_trace", "text_regions": [], "assets": [planned_asset(job["source"], job["contract_version"] in ("1.2", "1.3"))]})
    source_plan = {
        "complexity_class": complexity_class, "target_object_count": len(layer_plan) if structured else len(components),
        "text_line_count": sum(len(layer.get("text_regions", [])) for layer in structured.get("layers", [])) if structured else 0,
        "text_glyph_count": sum(sum(int(region.get("glyph_count", 0)) for region in layer.get("text_regions", [])) for layer in structured.get("layers", [])) if structured else 0,
        "detected_text_component_count": detected_text_components,
        "flat_auto_eligible": not flat_route_reasons,
        "flat_auto_rejection_reasons": flat_route_reasons,
        "line_density_ratio": ink_ratio, "palette_limit": int(job.get("source_plan", {}).get("palette_limit", 8)),
        "canvas": {"target_width_px": out_w, "target_height_px": out_h, "work_width_px": out_w * int(job["source"].get("supersample_scale", 1)), "work_height_px": out_h * int(job["source"].get("supersample_scale", 1)), "supersample_scale": int(job["source"].get("supersample_scale", 1)), "downsample": "premultiplied_alpha_area" if int(job["source"].get("supersample_scale", 1)) == 4 else "legacy"},
        "layers": layer_plan,
    }
    report = {
        "contract_version": job["contract_version"],
        "adapter_id": ADAPTER_ID,
        "renderer_version": RENDERER_VERSION,
        "upstream": {"name": "whiteboard-animator", "version": UPSTREAM_VERSION, "commit": UPSTREAM_COMMIT, "license": "MIT"},
        "status": "supported" if supported else "human_review",
        "reason": reason,
        "job_id": job["job_id"],
        "revision_id": job["revision_id"],
        "source_sha256": sha256_file(job["_source_path"]),
        "width_px": out_w,
        "height_px": out_h,
        "source_ink_pixels": ink_pixels,
        "non_white_coverage_ratio": ink_ratio,
        "component_count": len(components),
        "fill_component_count": sum(bool(component.get("is_fill")) for component in components),
        "mixed_stroke_fill_group_count": len(mixed_groups),
        "largest_component_share_of_ink": largest_share,
        "warnings": warnings,
        "routing": {
            "requested": requested_route, "route": resolved_route, "confidence": 0.96 if structured else (0.95 if flat_route_reasons else (0.9 if not warnings else 0.35)),
            "basis": {"non_white_coverage_ratio": ink_ratio, "largest_component_share_of_ink": largest_share, "component_count": len(components), "complexity_class": complexity_class, "text_region_count": source_plan["text_line_count"], "detected_text_component_count": detected_text_components, "has_structured_layers": bool(structured), "flat_auto_eligible": not flat_route_reasons},
            "blockers": list(dict.fromkeys(route_blockers + ([reason] if not supported and reason and reason not in route_blockers else []))),
        },
        "whiteboard_source_plan": source_plan,
        "timing_plan": auto_plan or {"policy": "manual", "selected_pace": timing.get("pace"), "total_frames": int(round(float(timing["total_duration_seconds"]) * timing["fps"])), "draw_frames": int(round(float(timing["draw_duration_seconds"]) * timing["fps"])), "hold_frames": int(round((float(timing["total_duration_seconds"]) - float(timing["draw_duration_seconds"])) * timing["fps"])), "actual_schedule_end_seconds": schedule_end, "schedule_fits_draw_budget": not manual_schedule_overflow, "frame_budget_conserved": not manual_schedule_overflow},
        "segment_window": job.get("segment_window"),
        "schedule": entries,
        "structured_layers": structured_report,
        "claims_not_made": ["human_acceptance", "media_quality", "hidden_structure_recovery", "qa_pass", "retry_state"],
    }
    return report, source_rgb, components, schedule


def encode_structured_video(job: dict, output_path: Path, source_rgb: np.ndarray, schedule: list) -> None:
    if job["structured_layers"]["mode"] == "stacked_layer_object_complete_reveal":
        return encode_stacked_layer_video(job, output_path, source_rgb)
    animator = WhiteboardAnimator()
    timing, _ = timing_map(animator, source_rgb, schedule)
    background = job["_structured_background_rgb"]
    total = float(job["timing"]["total_duration_seconds"])
    fps = int(job["timing"]["fps"])
    start_frame, end_frame, _ = frame_window(job)
    height, width = source_rgb.shape[:2]
    out_height, out_width = height + height % 2, width + width % 2
    finite = np.isfinite(timing)
    fade = max(float(getattr(animator, "fade_duration", 0.08)), 1.0 / fps)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    process = subprocess.Popen([
        "ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-f", "rawvideo", "-pix_fmt", "rgb24",
        "-s:v", f"{out_width}x{out_height}", "-r", str(fps), "-i", "pipe:0", "-an", "-c:v", "libx264",
        "-preset", str(job.get("encoding", {}).get("preset", "medium")),
        "-crf", str(job.get("encoding", {}).get("crf", 18)), "-pix_fmt", "yuv420p", str(output_path),
    ], stdin=subprocess.PIPE, stderr=subprocess.PIPE)
    assert process.stdin is not None
    for frame_index in range(start_frame, end_frame):
        target_time = frame_index / fps
        alpha = np.zeros((height, width), dtype=np.float32)
        alpha[finite] = np.clip((target_time - timing[finite]) / fade, 0.0, 1.0)
        frame = np.clip(
            source_rgb.astype(np.float32) * alpha[..., None]
            + background.astype(np.float32) * (1.0 - alpha[..., None]),
            0, 255,
        ).astype(np.uint8)
        if (out_height, out_width) != (height, width):
            padded = np.full((out_height, out_width, 3), 255, dtype=np.uint8)
            padded[:height, :width] = frame
            frame = padded
        process.stdin.write(np.ascontiguousarray(frame).tobytes())
    process.stdin.close()
    stderr = process.stderr.read().decode("utf-8", errors="replace") if process.stderr else ""
    code = process.wait()
    if code != 0:
        raise ContractError("ffmpeg_failed", f"ffmpeg failed ({code}): {stderr}")


def encode_stacked_layer_video(job: dict, output_path: Path, source_rgb: np.ndarray) -> None:
    animator = WhiteboardAnimator()
    total, fps = float(job["timing"]["total_duration_seconds"]), int(job["timing"]["fps"])
    start_frame, end_frame, _ = frame_window(job)
    height, width = source_rgb.shape[:2]
    out_height, out_width = height + height % 2, width + width % 2
    fade = max(float(getattr(animator, "fade_duration", 0.08)), 1.0 / fps)
    traced_layers = []
    for layer in job["_stacked_layers"]:
        stroke_timing = None
        if layer["stroke_schedule"]:
            stroke_timing = np.full((height, width), np.inf, dtype=np.float32)
            for component, start, duration in layer["stroke_schedule"]:
                traced = animator._trace_component(component, start, duration)
                mask = component["mask"]
                stroke_timing[mask] = traced[mask]
        fill_timing = animator._trace_component(layer["fill_component"], layer["fill_start"], layer["fill_duration"])
        traced_layers.append((layer, stroke_timing, fill_timing))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    process = subprocess.Popen([
        "ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-f", "rawvideo", "-pix_fmt", "rgb24",
        "-s:v", f"{out_width}x{out_height}", "-r", str(fps), "-i", "pipe:0", "-an", "-c:v", "libx264",
        "-preset", str(job.get("encoding", {}).get("preset", "medium")),
        "-crf", str(job.get("encoding", {}).get("crf", 18)), "-pix_fmt", "yuv420p", str(output_path),
    ], stdin=subprocess.PIPE, stderr=subprocess.PIPE)
    assert process.stdin is not None
    for frame_index in range(start_frame, end_frame):
        now = frame_index / fps
        frame = job["_stacked_paper_rgb"].astype(np.float32).copy()
        for layer, stroke_timing, fill_timing in sorted(traced_layers, key=lambda value: value[0]["z_index"]):
            color = layer["color_rgba"].astype(np.float32)
            fill_reveal = np.zeros((height, width), dtype=np.float32)
            fill_finite = np.isfinite(fill_timing)
            fill_reveal[fill_finite] = np.clip((now - fill_timing[fill_finite]) / fade, 0.0, 1.0)
            if stroke_timing is not None:
                line = layer["line_rgba"].astype(np.float32)
                line_reveal = np.zeros((height, width), dtype=np.float32)
                stroke_finite = np.isfinite(stroke_timing)
                line_reveal[stroke_finite] = np.clip((now - stroke_timing[stroke_finite]) / fade, 0.0, 1.0)
                line_alpha = (line[:, :, 3] / 255.0) * line_reveal * (1.0 - fill_reveal)
                frame = frame * (1.0 - line_alpha[:, :, None]) + line[:, :, :3] * line_alpha[:, :, None]
            color_alpha = (color[:, :, 3] / 255.0) * fill_reveal
            frame = frame * (1.0 - color_alpha[:, :, None]) + color[:, :, :3] * color_alpha[:, :, None]
        encoded = np.clip(frame, 0, 255).astype(np.uint8)
        if (out_height, out_width) != (height, width):
            padded = np.full((out_height, out_width, 3), 255, dtype=np.uint8)
            padded[:height, :width] = encoded
            encoded = padded
        process.stdin.write(np.ascontiguousarray(encoded).tobytes())
    process.stdin.close()
    stderr = process.stderr.read().decode("utf-8", errors="replace") if process.stderr else ""
    code = process.wait()
    if code != 0:
        raise ContractError("ffmpeg_failed", f"ffmpeg failed ({code}): {stderr}")


def timing_map(animator: WhiteboardAnimator, source_rgb: np.ndarray, schedule: list) -> tuple[np.ndarray, np.ndarray]:
    height, width = source_rgb.shape[:2]
    timing = np.full((height, width), np.inf, dtype=np.float32)
    component_ids = np.full((height, width), -1, dtype=np.int16)
    for index, (component, start, duration) in enumerate(schedule):
        traced = animator._trace_component(component, start, duration)
        region = (slice(component["top"], component["bottom"] + 1), slice(component["left"], component["right"] + 1))
        mask = component["mask"][region]
        crop = traced[region]
        if np.any(mask & ~np.isfinite(crop)):
            raise ContractError("incomplete_timing", f"component {index} has missing timing pixels")
        timing[region][mask] = crop[mask]
        component_ids[region][mask] = index
    return timing, component_ids


def schedule_timing_maps(animator: WhiteboardAnimator, schedule: list) -> list[np.ndarray]:
    """Keep phase maps separate so a later fill can never overwrite stroke timing."""
    return [animator._trace_component(component, start, duration) for component, start, duration in schedule]


def active_component(schedule: list, target_time: float) -> int | None:
    for index, (_, start, duration) in enumerate(schedule):
        if start - 1e-6 <= target_time <= start + duration + 1e-6:
            return index
    return None


def frontier_point(timing: np.ndarray, component: dict, target_time: float, frame_interval: float, previous_point):
    ys, xs = np.where(component["mask"] & np.isfinite(timing))
    if len(xs) == 0:
        return None, 0
    times = timing[ys, xs]
    delta = np.abs(times - target_time)
    selected = delta <= frame_interval * 0.34
    if int(selected.sum()) < 12:
        take = min(96, len(times))
        nearest = np.argpartition(delta, take - 1)[:take]
        selected = np.zeros(len(times), dtype=bool)
        selected[nearest] = True
    candidate_x = xs[selected].astype(np.float32)
    candidate_y = ys[selected].astype(np.float32)
    candidate_dt = delta[selected].astype(np.float32)
    if not len(candidate_x):
        return None, 0
    if previous_point is not None:
        squared = (candidate_x - previous_point[0]) ** 2 + (candidate_y - previous_point[1]) ** 2
        nearest_index = int(np.argmin(squared))
        local = (candidate_x - candidate_x[nearest_index]) ** 2 + (candidate_y - candidate_y[nearest_index]) ** 2 <= 11.0 ** 2
        candidate_x, candidate_y, candidate_dt = candidate_x[local], candidate_y[local], candidate_dt[local]
    weights = 1.0 / (candidate_dt + frame_interval * 0.08)
    centroid = (float(np.average(candidate_x, weights=weights)), float(np.average(candidate_y, weights=weights)))
    # The centroid is only a selection hint. The final anchor is always one real
    # active frontier pixel, which prevents concave fills from pulling the tip out.
    snap_index = int(np.argmin((candidate_x - centroid[0]) ** 2 + (candidate_y - centroid[1]) ** 2))
    return (float(candidate_x[snap_index]), float(candidate_y[snap_index])), int(selected.sum())


def read_cv_image(path: Path, flags: int) -> np.ndarray:
    data = np.fromfile(path, dtype=np.uint8)
    image = cv2.imdecode(data, flags)
    if image is None:
        raise ContractError("image_decode_failed", f"cannot decode image: {path}")
    return image


def overlay_tip(job: dict, engine_path: Path, output_path: Path, source_rgb: np.ndarray, schedule: list) -> dict:
    capture = cv2.VideoCapture(str(engine_path))
    if not capture.isOpened():
        raise ContractError("engine_video_unreadable", f"cannot open engine video: {engine_path}")
    fps = float(capture.get(cv2.CAP_PROP_FPS))
    width = int(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
    frames = []
    while True:
        ok, frame = capture.read()
        if not ok:
            break
        frames.append(frame)
    capture.release()
    if not frames:
        raise ContractError("empty_engine_video", "engine video has no decodable frames")

    animator = WhiteboardAnimator()
    timing_maps = schedule_timing_maps(animator, schedule)
    if timing_maps and timing_maps[0].shape != (height, width):
        padded_maps = []
        for timing in timing_maps:
            padded = np.full((height, width), np.inf, dtype=np.float32)
            padded[: timing.shape[0], : timing.shape[1]] = timing
            padded_maps.append(padded)
        timing_maps = padded_maps

    tip = job["tip_overlay"]
    frame_interval = 1.0 / fps
    lag = frame_interval
    max_step = float(tip.get("max_continuous_step_fraction", 52.0 / 384.0)) * height
    points, opacities, component_by_frame, pen_up_frames, candidate_counts = [], [], [], [], []
    post_snap_outside_count = 0
    previous_point = None
    previous_component = None
    start_frame, _, _ = frame_window(job)
    for frame_index in range(len(frames)):
        target_time = (start_frame + frame_index) / fps - lag
        component_index = active_component(schedule, target_time)
        if component_index is None:
            points.append(None); opacities.append(0.0); component_by_frame.append(None); candidate_counts.append(0)
            previous_point = None; previous_component = None
            continue
        same_component = component_index == previous_component
        point, count = frontier_point(timing_maps[component_index], schedule[component_index][0], target_time, frame_interval, previous_point if same_component else None)
        if point is not None:
            px, py = int(round(point[0])), int(round(point[1]))
            mask = schedule[component_index][0]["mask"]
            if py < 0 or px < 0 or py >= mask.shape[0] or px >= mask.shape[1] or not mask[py, px]:
                post_snap_outside_count += 1
        force_boundary_hide = frame_index == 0 and bool(job.get("segment_window", {}).get("hide_tip_on_first_frame", False))
        is_pen_up = force_boundary_hide or point is None or not same_component or (previous_point is not None and math.dist(previous_point, point) > max_step)
        points.append(point); opacities.append(0.0 if is_pen_up else float(tip.get("opacity", 0.94)))
        component_by_frame.append(component_index); candidate_counts.append(count)
        if is_pen_up and point is not None:
            pen_up_frames.append(frame_index)
        previous_point, previous_component = point, component_index

    rgba = read_cv_image(job["_tip_path"], cv2.IMREAD_UNCHANGED)
    if rgba.ndim != 3 or rgba.shape[2] != 4:
        raise ContractError("tip_not_rgba", "tip asset must decode as RGBA")
    target_height = int(round(height * float(tip["height_fraction"])))
    target_width = int(round(rgba.shape[1] * target_height / rgba.shape[0]))
    rgba = cv2.resize(rgba, (target_width, target_height), interpolation=cv2.INTER_AREA)
    anchor = (int(round(float(tip["tip_anchor"][0]) * target_width)), int(round(float(tip["tip_anchor"][1]) * target_height)))
    hand_bgr = rgba[:, :, :3]
    hand_alpha = rgba[:, :, 3].astype(np.float32) / 255.0

    output_path.parent.mkdir(parents=True, exist_ok=True)
    process = subprocess.Popen([
        "ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-f", "rawvideo", "-pix_fmt", "bgr24",
        "-s:v", f"{width}x{height}", "-r", f"{fps:g}", "-i", "pipe:0", "-an", "-c:v", "libx264",
        "-preset", str(job.get("encoding", {}).get("preset", "medium")), "-crf", str(job.get("encoding", {}).get("crf", 18)),
        "-pix_fmt", "yuv420p", str(output_path),
    ], stdin=subprocess.PIPE, stderr=subprocess.PIPE)
    assert process.stdin is not None
    for frame, point, opacity in zip(frames, points, opacities):
        if point is not None and opacity > 0:
            x = int(round(point[0] - anchor[0])); y = int(round(point[1] - anchor[1]))
            x0, y0 = max(0, x), max(0, y)
            x1, y1 = min(width, x + target_width), min(height, y + target_height)
            if x0 < x1 and y0 < y1:
                sx0, sy0 = x0 - x, y0 - y
                sx1, sy1 = sx0 + x1 - x0, sy0 + y1 - y0
                alpha = hand_alpha[sy0:sy1, sx0:sx1] * opacity
                alpha3 = alpha[..., None]
                frame[y0:y1, x0:x1] = np.clip(
                    hand_bgr[sy0:sy1, sx0:sx1].astype(np.float32) * alpha3
                    + frame[y0:y1, x0:x1].astype(np.float32) * (1.0 - alpha3), 0, 255,
                ).astype(np.uint8)
        process.stdin.write(np.ascontiguousarray(frame).tobytes())
    process.stdin.close()
    stderr = process.stderr.read().decode("utf-8", errors="replace") if process.stderr else ""
    code = process.wait()
    if code != 0:
        raise ContractError("ffmpeg_failed", f"ffmpeg failed ({code}): {stderr}")

    continuous_steps = []
    for index in range(1, len(points)):
        if points[index - 1] is not None and points[index] is not None and opacities[index - 1] > 0 and opacities[index] > 0 and component_by_frame[index - 1] == component_by_frame[index]:
            continuous_steps.append(math.dist(points[index - 1], points[index]))
    positive_counts = [count for count in candidate_counts if count > 0]
    return {
        "method": "native_unencoded_timing_frontier",
        "tip_anchor": tip["tip_anchor"],
        "tip_asset_sha256": sha256_file(job["_tip_path"]),
        "visible_tip_frames": sum(opacity > 0 for opacity in opacities),
        "pen_up_hidden_frames": len(pen_up_frames),
        "boundary_first_frame_tip_hidden": bool(not opacities or opacities[0] == 0.0),
        "candidate_count_median": float(np.percentile(positive_counts, 50)) if positive_counts else 0.0,
        "snap_to_active_frontier": True,
        "post_snap_outside_count": post_snap_outside_count,
        "continuous_tip_step_median_px": float(np.percentile(continuous_steps, 50)) if continuous_steps else 0.0,
        "continuous_tip_step_p95_px": float(np.percentile(continuous_steps, 95)) if continuous_steps else 0.0,
    }


def render(job: dict, preflight: dict, source_rgb: np.ndarray, components: list, schedule: list) -> dict:
    if preflight["status"] != "supported":
        raise ContractError("unsupported_input", preflight["reason"] or "input requires human review")
    output_path = job["_output_path"]
    output_path.parent.mkdir(parents=True, exist_ok=True)
    total = float(job["timing"]["total_duration_seconds"])
    draw = float(job["timing"]["draw_duration_seconds"])
    fps = int(job["timing"]["fps"])
    animator = WhiteboardAnimator()
    engine_path = output_path
    temporary = None
    if job.get("tip_overlay"):
        handle, name = tempfile.mkstemp(suffix=".engine.mp4", dir=str(output_path.parent))
        os.close(handle)
        temporary = Path(name)
        engine_path = temporary
    if job.get("structured_layers"):
        encode_structured_video(job, engine_path, source_rgb, schedule)
    else:
        animator.render_to_file(source_rgb, draw, total, str(engine_path), fps=fps, bitrate=str(job.get("encoding", {}).get("bitrate", "1500k")), preset=str(job.get("encoding", {}).get("engine_preset", "veryfast")))
    tip_report = None
    try:
        if job.get("tip_overlay"):
            tip_report = overlay_tip(job, engine_path, output_path, source_rgb, schedule)
    finally:
        if temporary is not None and temporary.exists():
            temporary.unlink()

    capture = cv2.VideoCapture(str(output_path))
    if not capture.isOpened():
        raise ContractError("output_unreadable", f"cannot open output: {output_path}")
    frame_count = 0
    while True:
        ok, _ = capture.read()
        if not ok:
            break
        frame_count += 1
    measured_fps = float(capture.get(cv2.CAP_PROP_FPS))
    width = int(capture.get(cv2.CAP_PROP_FRAME_WIDTH)); height = int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
    capture.release()
    start_frame, end_frame, logical_total_frames = frame_window(job)
    expected_frames = end_frame - start_frame
    if frame_count != expected_frames:
        raise ContractError("frame_count_mismatch", f"expected {expected_frames} frames, decoded {frame_count}")
    result = dict(preflight)
    result.update({
        "status": "success_pending_human_review",
        "output": str(output_path),
        "output_sha256": sha256_file(output_path),
        "frame_count": frame_count,
        "fps": measured_fps,
        "width_px": width,
        "height_px": height,
        "duration_seconds": frame_count / measured_fps,
        "audio_policy": "none",
        "tip_overlay": tip_report,
        "logical_frame_range": [start_frame, end_frame],
        "logical_total_frames": logical_total_frames,
        "segment_boundary_mode": job.get("segment_window", {}).get("boundary_mode"),
    })
    return result


def save_report(report: dict, destination: str | None) -> None:
    text = json.dumps(report, ensure_ascii=False, indent=2) + "\n"
    if destination:
        path = Path(destination).resolve()
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
    print(text, end="")


def main() -> int:
    parser = argparse.ArgumentParser(description="AI-media whiteboard animator local renderer")
    parser.add_argument("action", choices=("preflight", "render"))
    parser.add_argument("--job", required=True)
    parser.add_argument("--report")
    args = parser.parse_args()
    try:
        job_path = Path(args.job).resolve()
        job = require_job(job_path)
        preflight, source_rgb, components, schedule = analyze(job)
        report = preflight if args.action == "preflight" else render(job, preflight, source_rgb, components, schedule)
        save_report(report, args.report)
        return 0 if report["status"] == "supported" or report["status"].startswith("success") else 3
    except ContractError as exc:
        save_report({
            "contract_version": "1.0", "adapter_id": ADAPTER_ID, "status": "failed",
            "failure_type": "contract_or_unsupported", "error": {"code": exc.code, "message": str(exc), "field": exc.field},
            "claims_not_made": ["approval", "qa_pass", "retry_state", "human_acceptance"],
        }, args.report)
        return 2
    except Exception as exc:  # execution boundary must stay structured
        save_report({
            "contract_version": "1.0", "adapter_id": ADAPTER_ID, "status": "failed",
            "failure_type": "runtime", "error": {"code": "unexpected_runtime_error", "message": str(exc)},
            "debug_trace": traceback.format_exc() if os.environ.get("WHITEBOARD_ANIMATOR_DEBUG") == "1" else None,
            "claims_not_made": ["approval", "qa_pass", "retry_state", "human_acceptance"],
        }, args.report)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
