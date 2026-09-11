from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any


class ContractError(ValueError):
    def __init__(self, code: str, message: str, field: str | None = None):
        super().__init__(message)
        self.code = code
        self.field = field

    def as_dict(self) -> dict[str, Any]:
        value: dict[str, Any] = {"code": self.code, "message": str(self)}
        if self.field:
            value["field"] = self.field
        return value


@dataclass(frozen=True)
class Rect:
    x: int
    y: int
    width: int
    height: int

    @property
    def right(self) -> int:
        return self.x + self.width

    @property
    def bottom(self) -> int:
        return self.y + self.height

    def intersects(self, other: "Rect") -> bool:
        return self.x < other.right and other.x < self.right and self.y < other.bottom and other.y < self.bottom


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def canonical_hash(value: Any) -> str:
    payload = json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def _require_object(value: Any, field: str) -> dict[str, Any]:
    if not isinstance(value, dict):
        raise ContractError("invalid_type", f"{field} must be an object", field)
    return value


def _require_string(value: Any, field: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ContractError("invalid_string", f"{field} must be a non-empty string", field)
    return value


def _require_int(value: Any, field: str, minimum: int = 0) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value < minimum:
        raise ContractError("invalid_integer", f"{field} must be an integer >= {minimum}", field)
    return value


def _rect(value: Any, field: str, canvas_width: int, canvas_height: int) -> Rect:
    item = _require_object(value, field)
    rect = Rect(
        _require_int(item.get("x"), f"{field}.x"),
        _require_int(item.get("y"), f"{field}.y"),
        _require_int(item.get("width"), f"{field}.width", 1),
        _require_int(item.get("height"), f"{field}.height", 1),
    )
    if rect.right > canvas_width or rect.bottom > canvas_height:
        raise ContractError("out_of_bounds", f"{field} exceeds the annotation canvas", field)
    return rect


def validate_annotation(annotation: Any) -> dict[str, Any]:
    ann = _require_object(annotation, "annotation")
    if ann.get("schema_version") != "1.0":
        raise ContractError("unsupported_schema", "annotation.schema_version must be 1.0", "schema_version")
    canvas = _require_object(ann.get("canvas"), "canvas")
    width = _require_int(canvas.get("width"), "canvas.width", 2)
    height = _require_int(canvas.get("height"), "canvas.height", 2)
    regions = ann.get("regions")
    if not isinstance(regions, list) or not regions:
        raise ContractError("empty_regions", "annotation.regions must contain at least one region", "regions")

    ids: list[str] = []
    rects: dict[str, Rect] = {}
    normalized_regions: list[dict[str, Any]] = []
    previous_end = 0
    for index, raw in enumerate(regions):
        field = f"regions[{index}]"
        region = _require_object(raw, field)
        region_id = _require_string(region.get("region_id"), f"{field}.region_id")
        if region_id in ids:
            raise ContractError("duplicate_region_id", f"duplicate region_id: {region_id}", f"{field}.region_id")
        rect = _rect(region.get("rect"), f"{field}.rect", width, height)
        start = _require_int(region.get("start_frame"), f"{field}.start_frame")
        duration = _require_int(region.get("duration_frames"), f"{field}.duration_frames", 1)
        if start < previous_end:
            raise ContractError("timeline_overlap", f"{region_id} overlaps the preceding region", field)
        previous_end = start + duration
        allow = region.get("allow_spatial_overlap_with", [])
        if not isinstance(allow, list) or any(not isinstance(item, str) for item in allow):
            raise ContractError("invalid_overlap_allowlist", f"{field}.allow_spatial_overlap_with must be a string list", field)
        ids.append(region_id)
        rects[region_id] = rect
        normalized_regions.append({**region, "region_id": region_id, "rect": rect, "start_frame": start, "duration_frames": duration, "allow_spatial_overlap_with": allow})

    for index, left in enumerate(normalized_regions):
        for right in normalized_regions[index + 1 :]:
            if rects[left["region_id"]].intersects(rects[right["region_id"]]):
                declared = right["region_id"] in left["allow_spatial_overlap_with"] and left["region_id"] in right["allow_spatial_overlap_with"]
                if not declared:
                    raise ContractError("undeclared_spatial_overlap", f"{left['region_id']} and {right['region_id']} overlap without reciprocal declarations", "regions")

    protections = ann.get("protected_regions", [])
    if not isinstance(protections, list):
        raise ContractError("invalid_protected_regions", "protected_regions must be a list", "protected_regions")
    normalized_protections: list[dict[str, Any]] = []
    for index, raw in enumerate(protections):
        field = f"protected_regions[{index}]"
        item = _require_object(raw, field)
        kind = item.get("kind")
        if kind not in {"deferred", "permanent"}:
            raise ContractError("invalid_protection_kind", f"{field}.kind must be deferred or permanent", field)
        rect = _rect(item.get("rect"), f"{field}.rect", width, height)
        until = item.get("until_region_id")
        if kind == "deferred":
            _require_string(until, f"{field}.until_region_id")
            if until not in ids:
                raise ContractError("unknown_deferred_target", f"{until} is not a region_id", f"{field}.until_region_id")
        elif until is not None:
            raise ContractError("invalid_permanent_target", "permanent protection cannot have until_region_id", field)
        normalized_protections.append({**item, "kind": kind, "rect": rect, "until_region_id": until})

    allow_uncovered = ann.get("allow_uncovered_ink")
    if not isinstance(allow_uncovered, bool):
        raise ContractError("missing_uncovered_policy", "allow_uncovered_ink must be explicitly true or false", "allow_uncovered_ink")
    return {**ann, "canvas": {"width": width, "height": height}, "regions": normalized_regions, "protected_regions": normalized_protections, "allow_uncovered_ink": allow_uncovered}


def validate_job(job: Any, annotation: dict[str, Any]) -> dict[str, Any]:
    value = _require_object(job, "job")
    if value.get("contract_version") != "1.0":
        raise ContractError("unsupported_job_contract", "contract_version must be 1.0", "contract_version")
    for name in ("job_id", "revision_id", "clip_id"):
        _require_string(value.get(name), name)
    if value.get("adapter_id") != "region_stream_ink":
        raise ContractError("wrong_adapter", "adapter_id must be region_stream_ink", "adapter_id")
    source = _require_object(value.get("source_image"), "source_image")
    _require_string(source.get("path"), "source_image.path")
    _require_string(source.get("sha256"), "source_image.sha256")
    _require_string(source.get("rights_evidence_ref"), "source_image.rights_evidence_ref")
    ann_ref = _require_object(value.get("annotation"), "annotation")
    _require_string(ann_ref.get("path"), "annotation.path")
    _require_string(ann_ref.get("sha256"), "annotation.sha256")
    _require_string(ann_ref.get("approval_evidence_ref"), "annotation.approval_evidence_ref")

    timing = _require_object(value.get("timing"), "timing")
    fps = _require_int(timing.get("frame_rate"), "timing.frame_rate", 1)
    total = _require_int(timing.get("scene_duration_frames"), "timing.scene_duration_frames", 1)
    tail = _require_int(timing.get("tail_hold_frames"), "timing.tail_hold_frames")
    if tail >= total:
        raise ContractError("invalid_tail_hold", "tail_hold_frames must be smaller than scene_duration_frames", "timing.tail_hold_frames")
    drawable_end = total - tail
    segments = timing.get("segments")
    if not isinstance(segments, list) or len(segments) != len(annotation["regions"]):
        raise ContractError("segment_mismatch", "timing.segments must match annotation regions", "timing.segments")
    for index, (segment, region) in enumerate(zip(segments, annotation["regions"])):
        field = f"timing.segments[{index}]"
        segment = _require_object(segment, field)
        if segment.get("element_id") != region["region_id"] or segment.get("start_frame") != region["start_frame"] or segment.get("duration_frames") != region["duration_frames"]:
            raise ContractError("segment_mismatch", f"{field} does not match annotation timing", field)
        if region["start_frame"] + region["duration_frames"] > drawable_end:
            raise ContractError("timeline_overflow", f"{region['region_id']} exceeds the drawable frame budget", field)

    spec = _require_object(value.get("output_spec"), "output_spec")
    aspect = _require_string(spec.get("aspect_ratio"), "output_spec.aspect_ratio")
    resolution = _require_string(spec.get("resolution"), "output_spec.resolution")
    out_w = _require_int(spec.get("width_px"), "output_spec.width_px", 2)
    out_h = _require_int(spec.get("height_px"), "output_spec.height_px", 2)
    if out_w % 2 or out_h % 2:
        raise ContractError("odd_output_dimension", "H.264 output dimensions must be even", "output_spec")
    if spec.get("fit_mode") not in {"pad", "crop"}:
        raise ContractError("missing_fit_mode", "output_spec.fit_mode must be pad or crop", "output_spec.fit_mode")
    if aspect == "UNKNOWN" or resolution == "UNKNOWN":
        raise ContractError("unknown_output_spec", "formal jobs require confirmed aspect_ratio and resolution", "output_spec")

    style = _require_object(value.get("render_style"), "render_style")
    if style.get("ink_path") not in {"grid", "skeleton"}:
        raise ContractError("invalid_ink_path", "render_style.ink_path must be grid or skeleton", "render_style.ink_path")
    if style.get("reveal_mode") not in {"ink_only", "ink_then_color"}:
        raise ContractError("invalid_reveal_mode", "render_style.reveal_mode must be ink_only or ink_then_color", "render_style.reveal_mode")
    overlay = style.get("tip_overlay")
    if overlay == "none":
        pass
    elif isinstance(overlay, dict):
        _require_string(overlay.get("path"), "render_style.tip_overlay.path")
        _require_string(overlay.get("rights_evidence_ref"), "render_style.tip_overlay.rights_evidence_ref")
    else:
        raise ContractError("unlicensed_tip_overlay", "tip_overlay must be none or a custom asset with rights evidence", "render_style.tip_overlay")
    _require_string(value.get("output_path"), "output_path")
    return value
