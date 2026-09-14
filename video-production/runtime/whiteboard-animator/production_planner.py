"""Deterministic production planning around the single whiteboard renderer.

This module owns derived style slices, simple local source compilation, Pilot
fingerprints, render planning, serial segment execution, and deterministic
merge checks.  It never interprets a Style Profile inside the Renderer and it
never records human acceptance, QA PASS, retry state, or provider activity.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import math
import re
import subprocess
import sys
import time
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFont


CONTRACT_VERSION = "1.3"
SOURCE_TEMPLATE_VERSION = "whiteboard-simple-source-1.0"
RENDERER_BEHAVIOR_VERSION = "0.5.0-ai-media.1"


class PlanningError(RuntimeError):
    def __init__(self, code: str, message: str, field: str | None = None):
        super().__init__(message)
        self.code = code
        self.field = field


def read_json(path: Path) -> dict:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise PlanningError("invalid_json_object", f"expected object: {path}")
    return value


def write_json(path: Path, value: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest().upper()


def canonical_sha256(value: object) -> str:
    payload = json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(payload.encode("utf-8")).hexdigest().upper()


def _flatten(value: object, prefix: str = "") -> list[tuple[str, object]]:
    if isinstance(value, dict):
        result: list[tuple[str, object]] = []
        for key in sorted(value):
            result.extend(_flatten(value[key], f"{prefix}.{key}" if prefix else key))
        return result
    if isinstance(value, list):
        result = []
        for index, item in enumerate(value):
            result.extend(_flatten(item, f"{prefix}[{index}]"))
        return result
    return [(prefix, value)]


DROP_TOKENS = (
    "camera", "cinematography", "shot", "motion", "transition", "duration", "frame_rate",
    "provider", "model_id", "generation", "audio", "music", "narration", "sound", "voice",
    "retry", "assembly_engine", "caption_pipeline", "timeline", "editing", "weather",
)
FIELD_CATEGORIES = {
    "paper_background": ("paper", "background", "canvas", "surface", "environment", "sky"),
    "palette": ("palette", "color", "accent", "saturation", "contrast"),
    "line": ("line", "outline", "stroke", "ink"),
    "shape_language": ("shape", "simplif", "icon", "character_look", "illustration", "format", "medium", "look", "style", "identity", "visual"),
    "typography_layout": ("typography", "text", "title", "hierarchy", "composition", "card", "caption"),
    "fill_texture_decoration": ("fill", "shadow", "texture", "grain", "halftone", "decoration", "tape", "material"),
    "visual_prohibitions": ("failure", "avoid", "negative", "forbid", "anti_", "preserve", "constraint"),
}
STRONG_INCOMPATIBLE = (
    "photoreal", "photo-real", "真人电影", "真人", "超写实", "写实材质", "volumetric",
    "体积光", "three-dimensional", "3d", "cinematic lighting", "电影光影", "真实材质",
)
TRANSFORMS = (
    (("3d", "three-dimensional", "超写实", "photoreal", "真人"), "simple_flat_shapes_with_dark_outline"),
    (("volumetric", "体积光", "cinematic lighting", "电影光影"), "one_flat_contact_shadow_or_no_shadow"),
    (("material", "texture", "材质", "纹理"), "sparse_paper_texture_with_bounded_density"),
)


def _path_has(path: str, token: str) -> bool:
    lowered = path.lower()
    if token.endswith("_"):
        return any(part.startswith(token) for part in re.split(r"[.\[\]-]+", lowered))
    if "_" in token:
        return token in re.split(r"[.\[\]-]+", lowered)
    words = set(re.split(r"[^a-z0-9]+", lowered.replace("_", ".")))
    return token in words


def _field_category(path: str) -> str | None:
    for category, tokens in FIELD_CATEGORIES.items():
        if any(_path_has(path, token) for token in tokens):
            return category
    return None


def _transform_target(text: str) -> str | None:
    lowered = text.lower()
    for tokens, target in TRANSFORMS:
        if any(token in lowered for token in tokens):
            return target
    return None


def resolve_registry_paths(registry_path: Path, entry: dict) -> tuple[Path, Path]:
    registry = read_json(registry_path)
    plugin_root = registry_path.parent.parent
    source_dir = plugin_root / registry.get("source_directory", "style-profiles/source")
    normalized_dir = plugin_root / registry.get("normalized_directory", "style-profiles/normalized")
    return (source_dir / entry["source_file"]).resolve(), (normalized_dir / entry["normalized_file"]).resolve()


def map_style_profile(registry_path: Path, profile_id: str) -> dict:
    registry_path = registry_path.resolve()
    registry = read_json(registry_path)
    entry = next((item for item in registry.get("profiles", []) if item.get("profile_id") == profile_id), None)
    if entry is None:
        return {"contract_version": CONTRACT_VERSION, "profile_id": profile_id, "compatibility": "unsupported", "blockers": ["profile_not_registered"]}
    if entry.get("status") != "ready":
        return {"contract_version": CONTRACT_VERSION, "profile_id": profile_id, "compatibility": "unsupported", "blockers": ["profile_not_ready"]}
    source_path, normalized_path = resolve_registry_paths(registry_path, entry)
    if not source_path.is_file() or not normalized_path.is_file():
        return {"contract_version": CONTRACT_VERSION, "profile_id": profile_id, "compatibility": "unsupported", "blockers": ["profile_artifact_missing"]}
    actual_source_hash = sha256_file(source_path)
    if actual_source_hash != str(entry.get("source_sha256", "")).upper():
        return {"contract_version": CONTRACT_VERSION, "profile_id": profile_id, "compatibility": "human_review", "blockers": ["profile_source_checksum_mismatch"]}

    normalized = read_json(normalized_path)
    profile = normalized.get("style_profile")
    if not isinstance(profile, dict):
        return {"contract_version": CONTRACT_VERSION, "profile_id": profile_id, "compatibility": "unsupported", "blockers": ["normalized_style_profile_missing"]}
    version = str(profile.get("version") or entry.get("normalized_version") or "UNKNOWN")
    accepted: list[dict] = []
    transformed: list[dict] = []
    dropped: list[dict] = []
    blockers: list[str] = []
    strong_count = 0

    for path, value in _flatten(profile):
        if value is None or value == "" or path.startswith("provenance"):
            continue
        text = f"{path}={value}"
        lowered_path = path.lower()
        category = _field_category(path)
        if path.startswith(("production_modules", "pre_content_modules")):
            dropped.append({"source_path": path, "reason": "not_a_whiteboard_source_visual_field"})
            continue
        if any(_path_has(path, token) for token in DROP_TOKENS):
            dropped.append({"source_path": path, "reason": "not_a_whiteboard_source_visual_field"})
            continue
        if category == "visual_prohibitions":
            accepted.append({"source_path": path, "category": category, "value": value})
            continue
        target = _transform_target(text)
        if target is not None and category is not None:
            strong = any(token in text.lower() for token in STRONG_INCOMPATIBLE)
            strong_count += int(strong)
            transformed.append({
                "source_path": path, "category": category, "source_value": value,
                "mapped_value": target, "reason": "deterministic_whiteboard_flattening",
            })
            continue
        if category is not None:
            accepted.append({"source_path": path, "category": category, "value": value})
            continue
        if path.startswith("audiovisual_modules") and any(_path_has(path, token) for token in ("visual", "look", "style")):
            blockers.append(f"unmapped_visual_critical_field:{path}")
        else:
            dropped.append({"source_path": path, "reason": "outside_whiteboard_field_whitelist"})

    if blockers:
        compatibility = "human_review"
    elif strong_count and not accepted:
        compatibility = "unsupported"
        blockers.append("profile_visual_identity_not_preservable_as_deterministic_whiteboard_source")
    elif strong_count:
        compatibility = "partial"
        blockers.append("strong_realism_or_3d_identity_requires_source_brief_or_human_decision")
    elif transformed:
        compatibility = "transformed"
    elif accepted:
        compatibility = "compatible"
    else:
        compatibility = "unsupported"
        blockers.append("no_supported_whiteboard_visual_fields")

    slice_body = {
        "contract_version": CONTRACT_VERSION,
        "profile_id": profile_id,
        "profile_version": version,
        "source_sha256": actual_source_hash,
        "compatibility": compatibility,
        "accepted_fields": accepted,
        "transformed_fields": transformed,
        "dropped_fields": dropped,
        "blockers": blockers,
        "source_profile_mutation": "forbidden",
    }
    slice_body["style_slice_sha256"] = canonical_sha256(slice_body)
    return slice_body


def _rgba(value: object, default: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
    if value is None:
        return default
    if not isinstance(value, list) or len(value) not in (3, 4) or not all(isinstance(x, int) and 0 <= x <= 255 for x in value):
        raise PlanningError("invalid_rgba", f"invalid RGBA value: {value}")
    return tuple(value + [255] if len(value) == 3 else value)  # type: ignore[return-value]


def _scaled_box(box: list[int], scale: int) -> tuple[int, int, int, int]:
    if len(box) != 4 or box[0] >= box[2] or box[1] >= box[3]:
        raise PlanningError("invalid_bbox", f"invalid bbox: {box}")
    return tuple(int(x * scale) for x in box)  # type: ignore[return-value]


def _draw_element(image: Image.Image, element: dict, scale: int, line_only: bool) -> None:
    draw = ImageDraw.Draw(image)
    kind = element["type"]
    line = _rgba(element.get("line_rgba"), (35, 31, 28, 255))
    fill = (0, 0, 0, 0) if line_only else _rgba(element.get("fill_rgba"), (235, 225, 196, 255))
    width = max(1, int(element.get("line_width", 3) * scale))
    if kind == "text":
        font_path = Path(str(element.get("font_path", "")))
        if not font_path.is_file():
            raise PlanningError("font_required", "text elements require an explicit existing font_path", f"elements.{element.get('id')}.font_path")
        font = ImageFont.truetype(str(font_path), int(element.get("font_size", 18) * scale))
        x, y = (int(v * scale) for v in element["position"])
        draw.text((x, y), str(element.get("text", "")), font=font, fill=line)
        return
    if kind in ("card", "geometry", "icon"):
        box = _scaled_box(element["bbox"], scale)
        shape = element.get("shape", "rounded_rectangle" if kind == "card" else "ellipse")
        if shape == "rounded_rectangle":
            draw.rounded_rectangle(box, radius=int(element.get("radius", 8) * scale), fill=fill, outline=line, width=width)
        elif shape == "rectangle":
            draw.rectangle(box, fill=fill, outline=line, width=width)
        elif shape == "ellipse":
            draw.ellipse(box, fill=fill, outline=line, width=width)
        elif shape == "triangle":
            left, top, right, bottom = box
            draw.polygon(((left + right) // 2, top, right, bottom, left, bottom), fill=fill, outline=line)
        else:
            raise PlanningError("unsupported_simple_shape", f"unsupported local shape: {shape}")
        return
    if kind == "arrow":
        points = [(int(x * scale), int(y * scale)) for x, y in element["points"]]
        if len(points) < 2:
            raise PlanningError("invalid_arrow", "arrow requires at least two points")
        draw.line(points, fill=line, width=width, joint="curve")
        x1, y1 = points[-2]; x2, y2 = points[-1]
        angle = math.atan2(y2 - y1, x2 - x1)
        length = int(element.get("head_size", 10) * scale)
        wing = 0.55
        p1 = (int(x2 - length * math.cos(angle - wing)), int(y2 - length * math.sin(angle - wing)))
        p2 = (int(x2 - length * math.cos(angle + wing)), int(y2 - length * math.sin(angle + wing)))
        draw.polygon((points[-1], p1, p2), fill=line)
        return
    raise PlanningError("unsupported_local_asset_type", f"local compiler does not own {kind}")


def compile_simple_source(request: dict) -> dict:
    canvas = request.get("canvas", {})
    width, height = int(canvas.get("width_px", 0)), int(canvas.get("height_px", 0))
    if width <= 0 or height <= 0 or width % 2 or height % 2:
        raise PlanningError("invalid_output_geometry", "canvas width and height must be positive even integers")
    elements = request.get("elements")
    if not isinstance(elements, list) or not elements:
        raise PlanningError("missing_elements", "at least one source element is required")
    complex_elements = [item for item in elements if item.get("type") not in ("text", "card", "geometry", "icon", "arrow")]
    if complex_elements:
        return {
            "contract_version": CONTRACT_VERSION,
            "status": "prompt_package_ready",
            "source_template_version": request.get("source_template_version", SOURCE_TEMPLATE_VERSION),
            "source_brief": [{"id": item.get("id"), "type": item.get("type"), "brief": item.get("brief"), "local_generation": "not_authorized"} for item in complex_elements],
            "external_actions": {"provider_calls": [], "paid_generation": "not_authorized"},
            "claims_not_made": ["generated_asset", "rights_clearance", "human_acceptance"],
        }
    ids = [str(item.get("id", "")) for item in elements]
    if any(not item for item in ids) or len(set(ids)) != len(ids):
        raise PlanningError("invalid_element_ids", "element IDs must be unique and non-empty")

    output_dir = Path(str(request["output_dir"])).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    scale = 4
    paper = _rgba(canvas.get("paper_rgba"), (249, 247, 241, 255))
    composite = Image.new("RGBA", (width * scale, height * scale), paper)
    rights = str(request.get("rights_evidence", "")).strip()
    if not rights:
        raise PlanningError("missing_rights_evidence", "rights_evidence is required")
    layer_records = []
    text_regions = []
    for element in sorted(elements, key=lambda item: (int(item.get("z_index", 0)), str(item["id"]))):
        color = Image.new("RGBA", composite.size, (0, 0, 0, 0))
        line = Image.new("RGBA", composite.size, (0, 0, 0, 0))
        _draw_element(color, element, scale, line_only=False)
        _draw_element(line, element, scale, line_only=True)
        composite = Image.alpha_composite(composite, color)
        color_path = output_dir / f"{element['id']}.color.rgba.png"
        line_path = output_dir / f"{element['id']}.line.rgba.png"
        color.save(color_path); line.save(line_path)
        region_list = []
        if element["type"] == "text":
            region = {
                "id": str(element.get("region_id", element["id"])),
                "bbox": [int(x) for x in element["bbox"]],
                "line_order": int(element.get("line_order", 0)),
                "reading_order": int(element.get("reading_order", 0)),
                "direction": "left_to_right",
                "glyph_count": len(str(element.get("text", ""))),
            }
            region_list.append(region); text_regions.append(region)
        asset = lambda path: {"path": str(path), "sha256": sha256_file(path), "rights_evidence": rights}
        layer_records.append({
            "id": element["id"], "draw_order": int(element.get("draw_order", len(layer_records))),
            "z_index": int(element.get("z_index", len(layer_records))), "reveal_mode": "line_then_fill",
            "semantic_kind": "text" if element["type"] == "text" else "geometry",
            "text_regions": region_list, "color_rgba": asset(color_path), "line_art_rgba": asset(line_path),
        })
    reading = [item["reading_order"] for item in text_regions]
    if reading != sorted(reading) or len(reading) != len(set(reading)):
        raise PlanningError("invalid_text_reading_order", "text reading_order must be unique and ascending")

    source_path = output_dir / "source.4x.rgba.png"
    composite.save(source_path)
    source_asset = {"path": str(source_path), "sha256": sha256_file(source_path), "rights_evidence": rights, "supersample_scale": 4}
    fps = int(request.get("fps", 24)); duration = float(request.get("total_duration_seconds", 5.0))
    if abs(duration * fps - round(duration * fps)) > 1e-6:
        raise PlanningError("non_integer_frame_budget", "duration * fps must be integral")
    job = {
        "contract_version": CONTRACT_VERSION, "adapter_id": "whiteboard_animator", "render_route": "structured_semantic",
        "job_id": str(request.get("job_id", "compiled-whiteboard-source")), "revision_id": str(request.get("revision_id", "r1")),
        "source": source_asset, "output": str(output_dir / "pilot.mp4"),
        "output_spec": {"width_px": width, "height_px": height, "pixel_format": "yuv420p", "native_audio": "none"},
        "timing": {"policy": "auto", "total_duration_seconds": duration, "fps": fps},
        "structured_layers": {"mode": "stacked_layer_object_complete_reveal", "paper_rgb": list(paper[:3]), "layers": layer_records},
        "source_plan": {"palette_limit": int(request.get("palette_limit", 8))},
    }
    if request.get("tip_overlay") is not None:
        job["tip_overlay"] = request["tip_overlay"]
    job_path = output_dir / "render-job.json"
    write_json(job_path, job)
    return {
        "contract_version": CONTRACT_VERSION, "status": "compiled_local_source", "source_template_version": request.get("source_template_version", SOURCE_TEMPLATE_VERSION),
        "style_slice_sha256": request.get("style_slice_sha256"), "source": source_asset,
        "layers": layer_records, "text_reading_order": [item["id"] for item in sorted(text_regions, key=lambda item: item["reading_order"])],
        "render_job": str(job_path), "external_actions": {"provider_calls": [], "paid_generation": "not_authorized"},
    }


def pilot_fingerprint(request: dict) -> dict:
    fields = {
        "style_slice_sha256": request.get("style_slice_sha256"),
        "source_template_version": request.get("source_template_version", SOURCE_TEMPLATE_VERSION),
        "renderer_behavior_version": request.get("renderer_behavior_version", RENDERER_BEHAVIOR_VERSION),
        "render_route": request.get("render_route"),
        "geometry": request.get("geometry"),
        "fps": request.get("fps"),
        "tip_asset_sha256": request.get("tip_asset_sha256"),
        "tip_anchor": request.get("tip_anchor"),
    }
    if any(value is None for key, value in fields.items() if key not in ("tip_asset_sha256", "tip_anchor")):
        raise PlanningError("incomplete_pilot_fingerprint", "all quality-affecting Pilot fingerprint fields are required")
    return {"fields": fields, "pilot_fingerprint_sha256": canonical_sha256(fields)}


def select_pilot(request: dict) -> dict:
    candidates = request.get("candidates")
    if not isinstance(candidates, list) or not candidates:
        raise PlanningError("missing_pilot_candidates", "at least one planned candidate is required")
    scored = []
    for item in candidates:
        score = (
            4 * int(bool(item.get("curves_or_diagonals")))
            + 4 * int(bool(item.get("line_and_fill")))
            + 3 * int(bool(item.get("tip_required")))
            + 2 * min(int(item.get("text_rows", 0)), 3)
            + min(int(item.get("pen_lifts", 0)), 5)
            + min(int(item.get("layer_count", 0)), 6)
            + min(int(item.get("overlap_count", 0)), 4)
        )
        scored.append({"candidate_id": item["candidate_id"], "risk_score": score, "basis": item})
    scored.sort(key=lambda item: (-item["risk_score"], str(item["candidate_id"])))
    return {"selected": scored[0], "ranking": scored, "selection_policy": "highest_deterministic_representative_risk_not_simplest"}


def evaluate_pilot_gate(fingerprint: str, approval_records: list[dict]) -> dict:
    match = next((item for item in approval_records if item.get("pilot_fingerprint_sha256") == fingerprint and item.get("human_accepted") is True and item.get("evidence_ref")), None)
    if match:
        return {"status": "approved_fingerprint_reuse", "propagation_allowed": True, "approval_evidence_ref": match["evidence_ref"]}
    return {"status": "blocked_pending_human_review", "propagation_allowed": False, "approval_evidence_ref": None}


def _effective_work(metrics: dict) -> float:
    return metrics["active_draw_pixel_frames"] + metrics["hold_pixel_frames"] * 0.15 + metrics["skeleton_length_px"] * 18 + metrics["fill_alpha_area_px"] * 4


def _metrics(job: dict, preflight: dict) -> dict:
    timing = preflight["timing_plan"]
    width, height = int(preflight["width_px"]), int(preflight["height_px"])
    phase_metrics = timing.get("phase_metrics", [])
    return {
        "total_seconds": float(job["timing"]["total_duration_seconds"]),
        "active_draw_seconds": timing["draw_frames"] / int(job["timing"]["fps"]),
        "hold_seconds": timing["hold_frames"] / int(job["timing"]["fps"]),
        "total_frames": int(timing["total_frames"]), "draw_frames": int(timing["draw_frames"]), "hold_frames": int(timing["hold_frames"]),
        "width_px": width, "height_px": height, "fps": int(job["timing"]["fps"]),
        "pixel_frames": width * height * int(timing["total_frames"]),
        "active_draw_pixel_frames": width * height * int(timing["draw_frames"]),
        "hold_pixel_frames": width * height * int(timing["hold_frames"]),
        "layer_count": int((preflight.get("structured_layers") or {}).get("layer_count", 0)),
        "object_count": int(preflight["whiteboard_source_plan"].get("target_object_count", 0)),
        "text_row_count": int(preflight["whiteboard_source_plan"].get("text_line_count", 0)),
        "text_glyph_count": int(preflight["whiteboard_source_plan"].get("text_glyph_count", 0)),
        "skeleton_length_px": sum(int(item.get("skeleton_length_px", 0)) for item in phase_metrics),
        "fill_alpha_area_px": sum(int(item.get("fill_area_px", 0)) for item in phase_metrics),
        "pen_lifts": sum(int(item.get("pen_lifts", 0)) for item in phase_metrics),
    }


def _segment_jobs(job: dict, job_path: Path, preflight: dict, output_dir: Path, ranges: list[tuple[int, int]], boundary_mode: str) -> list[dict]:
    segments = []
    logical_total = int(preflight["timing_plan"]["total_frames"])
    for index, (start, end) in enumerate(ranges):
        segment_job = copy.deepcopy(job)
        segment_job["contract_version"] = CONTRACT_VERSION
        segment_job["job_id"] = f"{job['job_id']}-segment-{index + 1:02d}"
        segment_job["revision_id"] = f"{job['revision_id']}-segment-{index + 1:02d}"
        segment_job["output"] = str(output_dir / f"segment-{index + 1:02d}.mp4")
        segment_job["segment_window"] = {
            "start_frame": start, "end_frame_exclusive": end, "logical_total_frames": logical_total,
            "boundary_mode": boundary_mode, "hide_tip_on_first_frame": index > 0,
        }
        segment_path = output_dir / f"segment-{index + 1:02d}.job.json"
        write_json(segment_path, segment_job)
        segments.append({
            "segment_id": segment_job["job_id"], "job_path": str(segment_path), "output": segment_job["output"],
            "frame_range": [start, end], "expected_frames": end - start,
            "boundary_from_previous": None if index == 0 else boundary_mode,
        })
    return segments


def build_render_plan(request: dict) -> dict:
    job_path = Path(str(request["job_path"])).resolve()
    job = read_json(job_path)
    preflight = read_json(Path(str(request["preflight_report"])).resolve())
    if preflight.get("status") != "supported":
        return {"contract_version": CONTRACT_VERSION, "status": "human_review", "decision": "human_review", "reason": "preflight_not_supported"}
    metrics = _metrics(job, preflight)
    benchmark = request.get("benchmark")
    pilot_gate = request.get("pilot_gate", {})
    scope = request.get("execution_scope", "formal")
    if scope != "pilot" and not pilot_gate.get("propagation_allowed"):
        return {"contract_version": CONTRACT_VERSION, "status": "human_review", "decision": "human_review", "reason": "pilot_fingerprint_not_human_accepted", "metrics": metrics}
    if not isinstance(benchmark, dict) or float(benchmark.get("effective_work_units_per_second", 0)) <= 0 or float(benchmark.get("max_safe_render_seconds", 0)) <= 0:
        return {"contract_version": CONTRACT_VERSION, "status": "human_review", "decision": "human_review", "reason": "local_benchmark_required", "metrics": metrics}
    work = _effective_work(metrics)
    rate = float(benchmark["effective_work_units_per_second"])
    safety = float(benchmark.get("safety_factor", 1.25))
    expected = work / rate * safety
    estimate = {"seconds_low": work / rate, "seconds_high": expected, "basis": benchmark.get("evidence_ref"), "effective_work_units": work}
    max_safe = float(benchmark["max_safe_render_seconds"])
    high_work = expected > max_safe or metrics["active_draw_seconds"] > 14 or metrics["layer_count"] > 12
    decision = "segmented_render" if high_work else "single_render"
    fps = metrics["fps"]; total_frames = metrics["total_frames"]
    ranges: list[tuple[int, int]] = [(0, total_frames)]
    reason = "bounded_workload_including_static_hold_discount"
    if decision == "segmented_render":
        if not job.get("structured_layers") or job.get("render_route") == "flat_auto":
            return {"contract_version": CONTRACT_VERSION, "status": "human_review", "decision": "human_review", "reason": "segmentation_requires_explicit_semantic_layers", "metrics": metrics, "estimate": estimate}
        groups: list[dict] = []
        for entry in preflight.get("schedule", []):
            owner = entry.get("structured_object_id") or f"schedule-{entry['index']}"
            if not groups or groups[-1]["owner"] != owner:
                groups.append({"owner": owner, "start": entry["start"], "end": entry["end"], "entries": [entry]})
            else:
                groups[-1]["end"] = entry["end"]; groups[-1]["entries"].append(entry)
        if len(groups) < 2:
            return {"contract_version": CONTRACT_VERSION, "status": "human_review", "decision": "human_review", "reason": "no_safe_semantic_boundary", "metrics": metrics, "estimate": estimate}
        target_active_frames = max(1, int(metrics["draw_frames"] * max_safe / max(expected, max_safe)))
        boundaries = [0]; accumulated = 0
        for index, group in enumerate(groups):
            group_frames = int(round((group["end"] - group["start"]) * fps))
            if accumulated and accumulated + group_frames > target_active_frames and index < len(groups):
                boundaries.append(int(round(group["start"] * fps))); accumulated = 0
            accumulated += group_frames
        boundaries.append(total_frames)
        boundaries = sorted(set(boundaries))
        ranges = list(zip(boundaries[:-1], boundaries[1:]))
        if len(ranges) < 2:
            return {"contract_version": CONTRACT_VERSION, "status": "human_review", "decision": "human_review", "reason": "workload_high_but_semantic_split_not_beneficial", "metrics": metrics, "estimate": estimate}
        reason = "high_active_work_split_only_after_complete_semantic_object_groups"
    output_dir = Path(str(request["output_dir"])).resolve(); output_dir.mkdir(parents=True, exist_ok=True)
    segments = _segment_jobs(job, job_path, preflight, output_dir, ranges, "continuous_canvas")
    return {
        "contract_version": CONTRACT_VERSION, "status": "planned", "decision": decision, "reason": reason,
        "metrics": metrics, "estimate": estimate, "benchmark": benchmark, "pilot_gate": pilot_gate,
        "segments": segments, "merge": {"boundary_modes": [item["boundary_from_previous"] for item in segments[1:]], "native_audio": "none"},
        "claims_not_made": ["human_acceptance", "media_quality", "qa_pass"],
    }


def build_board_cut_plan(request: dict) -> dict:
    if not request.get("pilot_gate", {}).get("propagation_allowed") and request.get("execution_scope", "formal") != "pilot":
        return {"contract_version": CONTRACT_VERSION, "status": "human_review", "decision": "human_review", "reason": "pilot_fingerprint_not_human_accepted"}
    segments = []
    common = None
    for index, raw_path in enumerate(request.get("job_paths", [])):
        path = Path(str(raw_path)).resolve(); job = read_json(path)
        frames = int(round(float(job["timing"]["total_duration_seconds"]) * int(job["timing"]["fps"])))
        signature = (job["output_spec"]["width_px"], job["output_spec"]["height_px"], job["timing"]["fps"], job["output_spec"]["pixel_format"], job["output_spec"]["native_audio"])
        if common is None: common = signature
        if signature != common:
            return {"contract_version": CONTRACT_VERSION, "status": "human_review", "decision": "human_review", "reason": "board_cut_output_spec_mismatch"}
        segments.append({"segment_id": job["job_id"], "job_path": str(path), "output": job["output"], "frame_range": [0, frames], "expected_frames": frames, "boundary_from_previous": None if index == 0 else "board_cut"})
    if not segments:
        raise PlanningError("missing_board_jobs", "board_cut requires at least one Job")
    return {"contract_version": CONTRACT_VERSION, "status": "planned", "decision": "single_render" if len(segments) == 1 else "segmented_render", "segments": segments, "merge": {"boundary_modes": ["board_cut"] * max(0, len(segments) - 1), "native_audio": "none"}, "claims_not_made": ["human_acceptance", "media_quality", "qa_pass"]}


def _probe_video(path: Path) -> dict:
    command = ["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries", "stream=codec_name,profile,width,height,pix_fmt,r_frame_rate,time_base,level", "-of", "json", str(path)]
    completed = subprocess.run(command, capture_output=True, text=True, encoding="utf-8")
    if completed.returncode != 0:
        raise PlanningError("ffprobe_failed", completed.stderr.strip() or f"cannot probe {path}")
    streams = json.loads(completed.stdout).get("streams", [])
    if len(streams) != 1:
        raise PlanningError("video_stream_invalid", f"expected one video stream: {path}")
    return streams[0]


def _decode_video(path: Path) -> tuple[list[np.ndarray], float]:
    capture = cv2.VideoCapture(str(path))
    if not capture.isOpened():
        raise PlanningError("video_decode_failed", f"cannot open {path}")
    fps = float(capture.get(cv2.CAP_PROP_FPS)); frames = []
    while True:
        ok, frame = capture.read()
        if not ok: break
        frames.append(frame)
    capture.release()
    if not frames or fps <= 0:
        raise PlanningError("video_decode_failed", f"no complete frames in {path}")
    return frames, fps


def merge_segments(plan: dict, output_path: Path, allow_controlled_reencode: bool = False) -> dict:
    segments = plan["segments"]
    paths = [Path(item["output"]).resolve() for item in segments]
    if any(not path.is_file() for path in paths):
        raise PlanningError("segment_output_missing", "all segment outputs are required before merge")
    probes = [_probe_video(path) for path in paths]
    signature_fields = ("codec_name", "profile", "width", "height", "pix_fmt", "r_frame_rate", "time_base", "level")
    compatible = all(tuple(probe.get(field) for field in signature_fields) == tuple(probes[0].get(field) for field in signature_fields) for probe in probes[1:])
    output_path.parent.mkdir(parents=True, exist_ok=True)
    concat_path = output_path.with_suffix(".concat.txt")
    concat_path.write_text("".join(f"file '{str(path).replace(chr(39), chr(39) + '\\\\' + chr(39))}'\n" for path in paths), encoding="utf-8")
    if compatible:
        command = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-f", "concat", "-safe", "0", "-i", str(concat_path), "-an", "-c", "copy", str(output_path)]
        merge_method = "stream_copy_concat"
    elif allow_controlled_reencode:
        command = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-f", "concat", "-safe", "0", "-i", str(concat_path), "-an", "-c:v", "libx264", "-preset", "medium", "-crf", "18", "-pix_fmt", "yuv420p", str(output_path)]
        merge_method = "single_controlled_final_encode"
    else:
        raise PlanningError("segment_encoding_mismatch", "segments are not concat-compatible and controlled final encoding was not authorized")
    completed = subprocess.run(command, capture_output=True, text=True, encoding="utf-8")
    if completed.returncode != 0:
        raise PlanningError("ffmpeg_merge_failed", completed.stderr.strip())

    decoded = [_decode_video(path) for path in paths]
    final_frames, final_fps = _decode_video(output_path)
    expected_frames = sum(int(item["expected_frames"]) for item in segments)
    if len(final_frames) != expected_frames:
        raise PlanningError("merged_frame_count_mismatch", f"expected {expected_frames}, decoded {len(final_frames)}")
    boundaries = []
    logical_cursor = 0
    for index in range(1, len(paths)):
        previous = decoded[index - 1][0][-1]; current = decoded[index][0][0]
        mode = segments[index].get("boundary_from_previous")
        duplicate = bool(np.array_equal(previous, current))
        gray_previous = cv2.cvtColor(previous, cv2.COLOR_BGR2GRAY); gray_current = cv2.cvtColor(current, cv2.COLOR_BGR2GRAY)
        prior_ink = gray_previous < 245; current_ink = gray_current < 245
        # The hand/tip is deliberately hidden at a continuous boundary.  Use
        # pixels stable across the last two frames as the canvas-state basis so
        # disappearing overlay pixels are not misclassified as erased ink.
        if len(decoded[index - 1][0]) > 1:
            prior_stable = prior_ink & (cv2.cvtColor(decoded[index - 1][0][-2], cv2.COLOR_BGR2GRAY) < 245)
        else:
            prior_stable = prior_ink
        state_loss = int((prior_stable & ~current_ink).sum())
        state_loss_ratio = state_loss / max(int(prior_stable.sum()), 1)
        flash_white = bool(mode == "continuous_canvas" and int((prior_stable & current_ink).sum()) < int(prior_stable.sum()) * 0.88)
        if mode == "continuous_canvas" and (duplicate or flash_white or state_loss_ratio > 0.12):
            raise PlanningError("continuous_canvas_boundary_failed", f"boundary {index} failed continuity validation")
        logical_cursor += len(decoded[index - 1][0])
        boundaries.append({
            "boundary_index": index, "output_frame_index": logical_cursor, "mode": mode,
            "duplicate_frame": duplicate, "flash_white": flash_white, "state_loss_ratio": state_loss_ratio,
            "tip_policy": "hidden_on_first_segment_frame" if mode == "continuous_canvas" else "not_applicable_board_cut",
        })
    ranges = [item.get("frame_range") for item in segments]
    if all(item and item[0] is not None for item in ranges) and all(segments[index].get("boundary_from_previous") == "continuous_canvas" for index in range(1, len(segments))):
        for left, right in zip(ranges, ranges[1:]):
            if int(left[1]) != int(right[0]):
                raise PlanningError("logical_frame_gap_or_overlap", "continuous_canvas ranges contain a gap or overlap")
    return {
        "contract_version": CONTRACT_VERSION, "status": "success_pending_human_review", "output": str(output_path),
        "output_sha256": sha256_file(output_path), "frame_count": len(final_frames), "fps": final_fps,
        "duration_seconds": len(final_frames) / final_fps, "merge_method": merge_method,
        "encoding_compatible": compatible, "boundaries": boundaries, "full_decode": True, "native_audio": "none",
        "claims_not_made": ["human_acceptance", "semantic_qa_pass", "media_quality"],
    }


def execute_plan(request: dict) -> dict:
    plan_path = Path(str(request["plan_path"])).resolve(); plan = read_json(plan_path)
    renderer = Path(str(request.get("renderer_path") or Path(__file__).with_name("renderer_cli.py"))).resolve()
    if plan.get("status") != "planned":
        raise PlanningError("plan_not_executable", "render plan must have status planned")
    retained = []; failed = None
    for index, segment in enumerate(plan["segments"]):
        report_path = plan_path.parent / f"segment-{index + 1:02d}.render-report.json"
        started = time.perf_counter()
        completed = subprocess.run([sys.executable, str(renderer), "render", "--job", segment["job_path"], "--report", str(report_path)], capture_output=True, text=True, encoding="utf-8")
        elapsed = time.perf_counter() - started
        report = read_json(report_path) if report_path.is_file() else {"status": "failed", "error": {"code": "report_missing"}}
        if completed.returncode != 0 or report.get("status") != "success_pending_human_review":
            failed = {"segment_id": segment["segment_id"], "report": str(report_path), "renderer_exit_code": completed.returncode, "error": report.get("error")}
            break
        if segment.get("boundary_from_previous") == "continuous_canvas" and report.get("tip_overlay") and not report["tip_overlay"].get("boundary_first_frame_tip_hidden"):
            failed = {"segment_id": segment["segment_id"], "error": {"code": "segment_boundary_tip_not_hidden"}}
            break
        frames, fps = _decode_video(Path(segment["output"]))
        if len(frames) != int(segment["expected_frames"]):
            failed = {"segment_id": segment["segment_id"], "error": {"code": "segment_frame_count_mismatch"}}
            break
        retained.append({"segment_id": segment["segment_id"], "output": segment["output"], "output_sha256": sha256_file(Path(segment["output"])), "frame_count": len(frames), "fps": fps, "elapsed_seconds": elapsed, "report": str(report_path)})
    if failed:
        return {"contract_version": CONTRACT_VERSION, "status": "stopped_after_segment_failure", "retained_passed_segments": retained, "failed_segment": failed, "downstream_segments_not_started": [item["segment_id"] for item in plan["segments"][len(retained) + 1:]], "retry_owner": "existing_execution_state"}
    result = {"contract_version": CONTRACT_VERSION, "status": "segments_success_pending_human_review", "segments": retained}
    if request.get("final_output"):
        result["merge"] = merge_segments(plan, Path(str(request["final_output"])).resolve(), bool(request.get("allow_controlled_reencode", False)))
        result["status"] = "success_pending_human_review"
    if retained:
        total_work = sum(int(item["expected_frames"]) for item in plan["segments"]) * int(plan.get("metrics", {}).get("width_px", 1)) * int(plan.get("metrics", {}).get("height_px", 1))
        elapsed = sum(item["elapsed_seconds"] for item in retained)
        result["benchmark_observation"] = {"effective_work_units_per_second": total_work / max(elapsed, 1e-6), "observed_wall_seconds": elapsed, "evidence_ref": str(plan_path)}
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description="Whiteboard production planner around the single local Renderer")
    parser.add_argument("action", choices=("map-style", "compile-source", "select-pilot", "plan-render", "plan-board-cut", "execute-plan"))
    parser.add_argument("--input", required=True); parser.add_argument("--output", required=True)
    args = parser.parse_args(); destination = Path(args.output).resolve()
    try:
        request = read_json(Path(args.input).resolve())
        if args.action == "map-style":
            result = map_style_profile(Path(request["registry_path"]), str(request["profile_id"]))
        elif args.action == "compile-source":
            result = compile_simple_source(request)
        elif args.action == "select-pilot":
            selected = select_pilot(request); fingerprint = pilot_fingerprint(request["fingerprint"])
            selected["fingerprint"] = fingerprint
            selected["pilot_gate"] = evaluate_pilot_gate(fingerprint["pilot_fingerprint_sha256"], request.get("approval_records", []))
            result = selected
        elif args.action == "plan-render": result = build_render_plan(request)
        elif args.action == "plan-board-cut": result = build_board_cut_plan(request)
        else: result = execute_plan(request)
        write_json(destination, result); print(json.dumps(result, ensure_ascii=False, indent=2)); return 0 if result.get("status") not in ("human_review", "unsupported", "stopped_after_segment_failure") else 3
    except PlanningError as exc:
        result = {"contract_version": CONTRACT_VERSION, "status": "failed", "error": {"code": exc.code, "message": str(exc), "field": exc.field}, "claims_not_made": ["human_acceptance", "qa_pass", "retry_state"]}
        write_json(destination, result); print(json.dumps(result, ensure_ascii=False, indent=2)); return 2
    except Exception as exc:
        result = {"contract_version": CONTRACT_VERSION, "status": "failed", "error": {"code": "unexpected_planning_error", "message": str(exc)}, "claims_not_made": ["human_acceptance", "qa_pass", "retry_state"]}
        write_json(destination, result); print(json.dumps(result, ensure_ascii=False, indent=2)); return 2


if __name__ == "__main__":
    raise SystemExit(main())
