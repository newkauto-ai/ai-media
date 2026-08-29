#!/usr/bin/env python3
"""Local-only Publishing & Packaging v1.2 compiler, validator, and Notion projector."""

from __future__ import annotations

import argparse
import copy
import datetime as dt
import hashlib
import json
import math
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

from PIL import Image, ImageDraw, ImageFont, ImageOps, PngImagePlugin, ImageStat


SCHEMA_VERSION = "1.2"
REVIEW_POLICY_VERSION = "publishing-packaging-v1.2"
SUPPORTED_PLATFORMS = ("xiaohongshu", "douyin", "youtube_shorts", "youtube_long")
PLATFORM_LABELS = {"xiaohongshu": "小红书", "douyin": "抖音", "youtube_shorts": "YouTube Shorts", "youtube_long": "YouTube Long"}
VIDEO_EXTENSIONS = {".mp4", ".mov", ".mkv", ".webm", ".m4v"}
IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp"}
HASH_FIELDS = (
    "source_binding",
    "profile_snapshot",
    "titles",
    "cover_prompt",
    "cover",
    "copy",
    "rights_and_disclosure",
    "timing",
    "review",
    "platform_overlay",
    "safety",
)
LEGACY_HASH_FIELDS = tuple(key for key in HASH_FIELDS if key not in {"titles", "cover_prompt"})


class CompileError(RuntimeError):
    pass


def read_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def canonical_json(value: Any) -> bytes:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest().upper()


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest().upper()


def normalize_hash(value: Any) -> str:
    return str(value or "").replace("sha256:", "").strip().upper()


def parse_datetime(value: str | None) -> dt.datetime:
    if not value:
        return dt.datetime.now(dt.timezone.utc)
    text = str(value).strip().replace("Z", "+00:00")
    parsed = dt.datetime.fromisoformat(text)
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=dt.timezone.utc)
    return parsed


def iso(value: dt.datetime) -> str:
    return value.isoformat(timespec="seconds")


def resolve_local_path(raw: Any, base_dir: Path) -> Path | None:
    if not raw:
        return None
    text = str(raw).strip()
    if re.match(r"^[A-Za-z][A-Za-z0-9+.-]*://", text) and not text.lower().startswith("file://"):
        return None
    if text.lower().startswith("file://"):
        text = text[7:]
    candidate = Path(text)
    if not candidate.is_absolute():
        candidate = base_dir / candidate
    return candidate.resolve()


def run_process(command: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, capture_output=True, text=True, encoding="utf-8", errors="replace", check=False)


def find_command(name: str) -> str | None:
    return shutil.which(name)


def probe_media(path: Path) -> dict[str, Any]:
    result: dict[str, Any] = {
        "path": str(path),
        "exists": path.is_file(),
        "file_size_bytes": path.stat().st_size if path.is_file() else None,
        "kind": "unknown",
        "width": None,
        "height": None,
        "duration_seconds": None,
    }
    if not path.is_file():
        return result
    suffix = path.suffix.lower()
    if suffix in IMAGE_EXTENSIONS:
        with Image.open(path) as image:
            result.update(kind="image", width=image.width, height=image.height, duration_seconds=0.0)
        return result
    if suffix not in VIDEO_EXTENSIONS:
        return result
    result["kind"] = "video"
    ffprobe = find_command("ffprobe")
    if not ffprobe:
        result["probe_error"] = "ffprobe_missing"
        return result
    command = [
        ffprobe,
        "-v",
        "error",
        "-select_streams",
        "v:0",
        "-show_entries",
        "stream=width,height:format=duration",
        "-of",
        "json",
        str(path),
    ]
    completed = run_process(command)
    if completed.returncode != 0:
        result["probe_error"] = completed.stderr.strip() or "ffprobe_failed"
        return result
    payload = json.loads(completed.stdout)
    streams = payload.get("streams") or []
    if streams:
        result["width"] = streams[0].get("width")
        result["height"] = streams[0].get("height")
    duration = (payload.get("format") or {}).get("duration")
    if duration is not None:
        result["duration_seconds"] = round(float(duration), 3)
    return result


def load_profile(platform: str, profile_dir: Path) -> dict[str, Any]:
    filename = {
        "xiaohongshu": "xiaohongshu.json",
        "douyin": "douyin.json",
        "youtube_shorts": "youtube-shorts.json",
        "youtube_long": "youtube-long.json",
    }[platform]
    profile_path = profile_dir / filename
    profile = read_json(profile_path)
    rules: list[dict[str, Any]] = []
    if profile.get("extends"):
        parent = read_json(profile_dir / profile["extends"])
        rules.extend(copy.deepcopy(parent.get("rules") or []))
    rules.extend(copy.deepcopy(profile.get("rules") or []))
    profile["rules"] = rules
    profile["_path"] = str(profile_path.resolve())
    return profile


def evaluate_profile(profile: dict[str, Any], as_of: dt.datetime) -> dict[str, Any]:
    evaluated: list[dict[str, Any]] = []
    critical_states: list[str] = []
    heuristic_stale = False
    for original in profile.get("rules") or []:
        rule = copy.deepcopy(original)
        effective = str(rule.get("status") or "unknown")
        review_after = rule.get("review_after")
        if effective == "current" and review_after:
            if as_of.date() > dt.date.fromisoformat(review_after):
                effective = "stale"
        rule["effective_status"] = effective
        evaluated.append(rule)
        if rule.get("critical") or rule.get("rule_type") in {"policy", "disclosure", "capability"}:
            critical_states.append(effective)
        if rule.get("rule_type") == "heuristic" and effective != "current":
            heuristic_stale = True
    if any(state in {"stale", "contradicted"} for state in critical_states):
        critical_status = "stale"
    elif any(state != "current" for state in critical_states):
        critical_status = "unknown"
    else:
        critical_status = "current"
    rules_hash = sha256_bytes(canonical_json(evaluated))
    evidence_refs = [
        f"{rule.get('rule_id')}|{rule.get('source_url')}|{rule.get('verified_at')}|{rule.get('effective_status')}"
        for rule in evaluated
    ]
    return {
        "platform_profile_id": profile.get("profile_id"),
        "platform_profile_version": profile.get("profile_version"),
        "profile_path": profile.get("_path"),
        "rules_hash": rules_hash,
        "critical_rules_status": critical_status,
        "heuristic_stale": heuristic_stale,
        "evidence_refs": evidence_refs,
        "evaluated_rules": evaluated,
    }


def rule_value(snapshot: dict[str, Any], field: str, default: Any = None) -> Any:
    matches = [r for r in snapshot.get("evaluated_rules") or [] if r.get("field") == field and r.get("effective_status") == "current"]
    return matches[-1].get("value") if matches else default


def source_binding(input_data: dict[str, Any], input_dir: Path) -> tuple[dict[str, Any], list[str], bool]:
    source = input_data.get("source_artifact") or {}
    prompt_only = bool((input_data.get("execution_mode") or {}).get("cover_prompt_only"))
    reasons: list[str] = []
    source_path = resolve_local_path(source.get("path_or_uri"), input_dir)
    expected_hash = normalize_hash(source.get("checksum_sha256"))
    version = str(source.get("artifact_version") or "").strip()
    if source_path is None and not prompt_only:
        reasons.append("source_path_missing_or_non_local")
    elif source_path is not None and not source_path.is_file():
        reasons.append("source_file_missing")
    if not expected_hash and not prompt_only:
        reasons.append("source_checksum_missing")
    if not version and not prompt_only:
        reasons.append("artifact_version_missing")
    observed_hash = sha256_file(source_path) if source_path and source_path.is_file() else None
    if observed_hash and expected_hash and observed_hash != expected_hash:
        reasons.append("source_checksum_mismatch")
    observed = probe_media(source_path) if source_path else {"exists": False, "kind": "unknown"}
    declared_size = source.get("file_size_bytes")
    if observed.get("exists") and declared_size not in (None, 0) and int(declared_size) != observed.get("file_size_bytes"):
        reasons.append("source_file_size_mismatch")
    for key in ("width", "height"):
        declared = source.get(key)
        actual = observed.get(key)
        if declared not in (None, 0) and actual not in (None, 0) and int(declared) != int(actual):
            reasons.append(f"source_{key}_mismatch")
    if observed.get("kind") != "video" and not prompt_only:
        reasons.append("source_is_not_final_video_media")
    qa_status = str(source.get("final_qa_status") or ("not_supplied" if prompt_only else "blocked"))
    if qa_status == "blocked" and not prompt_only:
        reasons.append("source_final_qa_blocked")
    upstream = input_data.get("upstream_refs") or {}
    binding = {
        "artifact_id": source.get("artifact_id"),
        "artifact_version": version or None,
        "artifact_path": str(source_path) if source_path else str(source.get("path_or_uri") or ""),
        "artifact_checksum_sha256": observed_hash or expected_hash or None,
        "declared_checksum_sha256": expected_hash or None,
        "file_size_bytes": observed.get("file_size_bytes"),
        "duration_seconds": observed.get("duration_seconds"),
        "width": observed.get("width"),
        "height": observed.get("height"),
        "source_kind": observed.get("kind"),
        "final_qa_status": qa_status,
        "inspected_at": source.get("inspected_at"),
        "cover_prompt_only": prompt_only,
        "frozen_script_hash": normalize_hash(upstream.get("frozen_script_hash")) or None,
        "adp_hash": normalize_hash(upstream.get("audiovisual_direction_hash")) or None,
        "production_manifest_hash": normalize_hash(upstream.get("production_manifest_hash")) or None,
        "production_manifest_version": upstream.get("production_manifest_version"),
    }
    stale = "source_checksum_mismatch" in reasons or any(r.startswith("source_") and r.endswith("_mismatch") for r in reasons)
    return binding, reasons, stale


def image_quality_score(path: Path) -> float:
    with Image.open(path) as image:
        gray = ImageOps.grayscale(image.resize((256, 256)))
        stat = ImageStat.Stat(gray)
        mean = stat.mean[0]
        stddev = stat.stddev[0]
        exposure = max(0.0, 1.0 - abs(mean - 128.0) / 128.0)
        return round(exposure * 0.45 + min(stddev / 64.0, 1.0) * 0.55, 6)


def extract_candidate_frames(video_path: Path, output_dir: Path, duration: float | None) -> tuple[Path | None, list[dict[str, Any]], str | None]:
    ffmpeg = find_command("ffmpeg")
    if not ffmpeg:
        return None, [], "ffmpeg_missing"
    if not duration or duration <= 0:
        return None, [], "video_duration_unknown"
    output_dir.mkdir(parents=True, exist_ok=True)
    timestamps = sorted({round(max(0.0, duration * ratio), 3) for ratio in (0.2, 0.5, 0.8)})
    candidates: list[dict[str, Any]] = []
    for index, timestamp in enumerate(timestamps, start=1):
        frame = output_dir / f"candidate-{index:02d}.png"
        completed = run_process([ffmpeg, "-hide_banner", "-loglevel", "error", "-y", "-ss", str(timestamp), "-i", str(video_path), "-frames:v", "1", str(frame)])
        if completed.returncode == 0 and frame.is_file():
            candidates.append({"path": str(frame.resolve()), "timestamp_seconds": timestamp, "technical_score": image_quality_score(frame), "checksum_sha256": sha256_file(frame)})
    if not candidates:
        return None, [], "frame_extraction_failed"
    selected = max(candidates, key=lambda item: item["technical_score"])
    return Path(selected["path"]), candidates, None


def validate_declared_asset(entry: dict[str, Any], input_dir: Path, require_approval: bool, require_compatibility: bool = False) -> tuple[Path | None, str | None]:
    path = resolve_local_path(entry.get("path") or entry.get("source_ref"), input_dir)
    if not path or not path.is_file():
        return None, "declared_asset_missing"
    if path.suffix.lower() not in IMAGE_EXTENSIONS:
        return None, "declared_asset_not_supported_image"
    expected = normalize_hash(entry.get("checksum_sha256"))
    observed = sha256_file(path)
    if not expected or expected != observed:
        return None, "declared_asset_checksum_missing_or_mismatch"
    if require_approval:
        if entry.get("approval_status") != "approved":
            return None, "keyframe_not_approved"
        if not (entry.get("approval_evidence_ref") or entry.get("approval_ref")):
            return None, "keyframe_approval_evidence_missing"
        compatible = entry.get("compatible_artifact_version")
        if require_compatibility and compatible in (None, ""):
            return None, "keyframe_artifact_compatibility_missing"
    rights = entry.get("rights_status")
    if rights == "blocked":
        return None, "asset_rights_blocked"
    if not (entry.get("rights_provenance_ref") or entry.get("rights_ref")):
        return None, "asset_rights_provenance_missing"
    return path, None


def choose_cover_source(
    input_data: dict[str, Any],
    binding: dict[str, Any],
    input_dir: Path,
    platform_dir: Path,
) -> dict[str, Any]:
    media_path = Path(binding["artifact_path"]) if binding.get("artifact_path") else None
    attempts: list[dict[str, Any]] = []
    cover_inputs = input_data.get("cover_inputs") or {}
    sources = input_data.get("cover_sources") or {}
    approved_assets = list(cover_inputs.get("approved_assets") or [])
    dedicated = [item for item in approved_assets if item.get("dedicated_cover") is True or item.get("asset_type") == "cover"]
    approved_visuals = list(cover_inputs.get("approved_keyframes") or []) + list(sources.get("approved_keyframes") or [])
    approved_visuals += [item for item in approved_assets if item not in dedicated and item.get("asset_type") in {"keyframe", "scene"}]
    for route, entries in (("approved_dedicated_cover", dedicated), ("approved_visual_reference", approved_visuals)):
        for entry in entries:
            compatible = entry.get("compatible_artifact_version")
            if compatible and binding.get("artifact_version") and compatible != binding.get("artifact_version"):
                attempts.append({"route": route, "status": "rejected", "error": "asset_artifact_version_incompatible", "source_ref": entry.get("path")})
                continue
            path, error = validate_declared_asset(entry, input_dir, require_approval=True, require_compatibility=False)
            attempts.append({"route": route, "status": "selected" if path else "rejected", "error": error, "source_ref": entry.get("path")})
            if path:
                return {
                    "source_type": route,
                    "source_ref": str(path.resolve()),
                    "source_checksum_sha256": sha256_file(path),
                    "approval_evidence_ref": entry.get("approval_evidence_ref") or entry.get("approval_ref"),
                    "rights_provenance_ref": entry.get("rights_provenance_ref") or entry.get("rights_ref"),
                    "attempts": attempts,
                    "generation_authorization_ref": None,
                }
    for entry in sources.get("supplied_assets") or []:
        path, error = validate_declared_asset(entry, input_dir, require_approval=False)
        attempts.append({"route": "supplied_asset", "status": "selected" if path else "rejected", "error": error, "source_ref": entry.get("path")})
        if path:
            return {
                "source_type": "supplied_asset",
                "source_ref": str(path),
                "source_checksum_sha256": sha256_file(path),
                "rights_provenance_ref": entry.get("rights_provenance_ref"),
                "attempts": attempts,
                "generation_authorization_ref": None,
            }
    if media_path and media_path.is_file() and binding.get("source_kind") == "video":
        selected, candidates, error = extract_candidate_frames(media_path, platform_dir / "candidate-frames", binding.get("duration_seconds"))
        attempts.append({"route": "extracted_frame_optional", "status": "selected" if selected else "unavailable", "error": error, "candidates": candidates})
        if selected:
            return {
                "source_type": "extracted_frame_optional",
                "source_ref": str(selected.resolve()),
                "source_checksum_sha256": sha256_file(selected),
                "attempts": attempts,
                "generation_authorization_ref": None,
            }
    fallback = sources.get("generated_background_fallback") or {}
    attempts.append({
        "route": "generated_background",
        "status": "not_called",
        "error": "actual_generated_background_missing",
        "required_gate": {key: fallback.get(key) for key in ("model", "quantity", "estimated_cost", "stopping_condition", "generation_authorization_ref")},
    })
    return {
        "source_type": "generated_background",
        "source_ref": "",
        "source_checksum_sha256": None,
        "attempts": attempts,
        "generation_authorization_ref": fallback.get("generation_authorization_ref"),
        "blocked_reason": "no_actual_cover_source_and_generation_not_called",
    }


def find_system_font() -> Path | None:
    candidates = [
        Path(r"C:\Windows\Fonts\NotoSansSC-VF.ttf"),
        Path(r"C:\Windows\Fonts\simhei.ttf"),
        Path(r"C:\Windows\Fonts\Dengb.ttf"),
    ]
    return next((path for path in candidates if path.is_file()), None)


def load_series_rules(input_data: dict[str, Any], input_dir: Path) -> tuple[dict[str, Any], str, list[str]]:
    context = input_data.get("series_context") or {}
    issues: list[str] = []
    ref = resolve_local_path(context.get("packaging_visual_rules_ref"), input_dir)
    if ref:
        if not ref.is_file():
            issues.append("series_rules_file_missing")
        else:
            rules = read_json(ref)
            if context.get("source_status") != "ready" or rules.get("status") != "ready":
                issues.append("series_rules_not_ready")
            elif context.get("packaging_visual_rules_version") != rules.get("version"):
                issues.append("series_rules_version_mismatch")
            else:
                return rules, "approved_series", issues
    local = context.get("run_local_constraints")
    if isinstance(local, dict) and local:
        return {"status": "run_local", "version": "run-local", "fields": local, "variants": []}, "run_local_constraints", issues
    return {"status": "fallback", "version": "1.1", "fields": {}, "variants": []}, "field_fallback", issues


def resolve_titles(input_data: dict[str, Any], platform: str) -> dict[str, str]:
    core = input_data.get("content_core") or {}
    supplied = (input_data.get("platform_copy") or {}).get(platform) or {}
    legacy = (input_data.get("legacy_packaging") or {}).get(platform) or {}
    story_hook = str(core.get("story_hook") or core.get("hook") or "").strip()
    explicit_platform = str((core.get("platform_titles") or {}).get(platform) or "").strip()
    supplied_platform = str(supplied.get("platform_title") or supplied.get("title_or_caption") or supplied.get("title") or supplied.get("text") or "").strip()
    legacy_platform = str(legacy.get("title") or legacy.get("text") or "").strip()
    platform_title = explicit_platform or supplied_platform or legacy_platform or str(core.get("topic") or story_hook).strip()
    approved_cover = str((core.get("approved_cover_titles") or {}).get(platform) or "").strip()
    cover_title = approved_cover or platform_title or str(core.get("core_promise") or story_hook).strip()
    return {"story_hook": story_hook, "platform_title": platform_title, "cover_title": cover_title}


def resolve_series_fields(input_data: dict[str, Any], platform: str, snapshot: dict[str, Any], input_dir: Path) -> dict[str, Any]:
    rules, source, issues = load_series_rules(input_data, input_dir)
    generic = {
        "brand_color": "#F6C445",
        "accent_color": "#FFFFFF",
        "text_color": "#FFFFFF",
        "panel_color": "#101820",
        "border_width_ratio": 0.0,
        "series_mark": "",
        "layout_variant": "clean-title-space-v1",
        "show_border": False,
        "show_series_mark": False,
        "show_title_panel": False,
        "font_path": str(find_system_font() or ""),
        "font_rights_status": "system" if find_system_font() else "unknown",
    }
    resolved: dict[str, Any] = {}
    sources: dict[str, str] = {}
    base_fields = rules.get("fields") or {}
    variant_fields: dict[str, Any] = {}
    for variant in rules.get("variants") or []:
        if variant.get("status") != "ready":
            continue
        platforms = variant.get("platforms") or []
        if not platforms or platform in platforms:
            variant_fields.update(variant.get("fields") or {})
    for key, fallback in generic.items():
        if key in variant_fields:
            resolved[key] = variant_fields[key]
            sources[key] = "approved_series_variant"
        elif key in base_fields:
            resolved[key] = base_fields[key]
            sources[key] = "series_base"
        else:
            resolved[key] = fallback
            sources[key] = "field_fallback"
    for exception in (input_data.get("series_context") or {}).get("approved_exceptions") or []:
        if exception.get("approval_status") == "approved" and exception.get("approval_evidence_ref") and exception.get("field"):
            resolved[exception["field"]] = exception.get("value")
            sources[exception["field"]] = f"approved_exception:{exception.get('approval_evidence_ref')}"
        else:
            issues.append("unapproved_series_exception_ignored")
    resolved["cover_text"] = resolve_titles(input_data, platform)["cover_title"]
    sources["cover_text"] = "approved_cover_title_or_platform_title_fallback"
    resolved["width"] = int(rule_value(snapshot, "cover.width", 1080))
    resolved["height"] = int(rule_value(snapshot, "cover.height", 1920))
    resolved["format"] = str(rule_value(snapshot, "cover.format", "PNG"))
    resolved["max_file_size_bytes"] = int(rule_value(snapshot, "cover.max_file_size_bytes", 50 * 1024 * 1024))
    resolved["safe_zone"] = rule_value(snapshot, "cover.safe_zone", {"left": 0.08, "top": 0.08, "right": 0.08, "bottom": 0.12})
    for key in ("width", "height", "format", "max_file_size_bytes", "safe_zone"):
        sources[key] = "platform_profile"
    return {"source": source, "fields": resolved, "field_sources": sources, "issues": sorted(set(issues))}


def parse_hex_color(value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    text = str(value or "#000000").strip().lstrip("#")
    if len(text) == 3:
        text = "".join(char * 2 for char in text)
    if not re.fullmatch(r"[0-9A-Fa-f]{6}", text):
        text = "000000"
    return int(text[0:2], 16), int(text[2:4], 16), int(text[4:6], 16), alpha


def relative_luminance(rgb: tuple[int, int, int]) -> float:
    values = []
    for channel in rgb:
        value = channel / 255.0
        values.append(value / 12.92 if value <= 0.03928 else ((value + 0.055) / 1.055) ** 2.4)
    return values[0] * 0.2126 + values[1] * 0.7152 + values[2] * 0.0722


def contrast_ratio(foreground: str, background: str) -> float:
    fg = parse_hex_color(foreground)[:3]
    bg = parse_hex_color(background)[:3]
    l1, l2 = sorted((relative_luminance(fg), relative_luminance(bg)), reverse=True)
    return round((l1 + 0.05) / (l2 + 0.05), 3)


def wrap_text(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, max_width: int) -> list[str]:
    text = re.sub(r"\s+", " ", text).strip()
    if not text:
        return []
    tokens = list(text) if re.search(r"[\u3400-\u9fff]", text) else text.split(" ")
    separator = "" if len(tokens) == len(text) else " "
    lines: list[str] = []
    current = ""
    for token in tokens:
        candidate = token if not current else current + separator + token
        if draw.textbbox((0, 0), candidate, font=font)[2] <= max_width:
            current = candidate
        else:
            if current:
                lines.append(current)
            current = token
    if current:
        lines.append(current)
    return lines


def compose_cover(source: dict[str, Any], resolved: dict[str, Any], platform: str, platform_dir: Path) -> dict[str, Any]:
    source_path = Path(source.get("source_ref") or "")
    fields = resolved["fields"]
    if not source_path.is_file():
        return {
            "source_type": source.get("source_type"),
            "source_ref": source.get("source_ref"),
            "source_checksum_sha256": source.get("source_checksum_sha256"),
            "composed_asset_path": None,
            "composed_asset_checksum_sha256": None,
            "width": None,
            "height": None,
            "layout_variant": fields.get("layout_variant"),
            "cover_text": fields.get("cover_text"),
            "typography_spec": {},
            "safe_zone_spec": fields.get("safe_zone"),
            "series_bindings": resolved.get("field_sources"),
            "generation_authorization_ref": source.get("generation_authorization_ref"),
            "source_resolution": source,
            "qa": {"overall": "blocked", "blocking_reasons": [source.get("blocked_reason") or "cover_source_missing"]},
        }
    width, height = fields["width"], fields["height"]
    safe = fields["safe_zone"]
    safe_box = (
        round(width * float(safe.get("left", 0.08))),
        round(height * float(safe.get("top", 0.08))),
        round(width * (1.0 - float(safe.get("right", 0.08)))),
        round(height * (1.0 - float(safe.get("bottom", 0.12)))),
    )
    with Image.open(source_path) as background:
        canvas = ImageOps.fit(background.convert("RGB"), (width, height), method=Image.Resampling.LANCZOS, centering=(0.5, 0.5)).convert("RGBA")
    draw = ImageDraw.Draw(canvas, "RGBA")
    border = max(2, round(min(width, height) * float(fields.get("border_width_ratio", 0.012))))
    brand = parse_hex_color(fields.get("brand_color", "#F6C445"), 255)
    if fields.get("show_border") is True:
        draw.rectangle((border // 2, border // 2, width - border // 2 - 1, height - border // 2 - 1), outline=brand, width=border)
    font_path = Path(str(fields.get("font_path") or ""))
    fallback_used = False
    if not font_path.is_file() or fields.get("font_rights_status") not in {"system", "approved"}:
        system_font = find_system_font()
        if not system_font:
            return {
                "source_type": source.get("source_type"), "source_ref": str(source_path), "source_checksum_sha256": source.get("source_checksum_sha256"),
                "composed_asset_path": None, "composed_asset_checksum_sha256": None, "width": None, "height": None,
                "layout_variant": fields.get("layout_variant"), "cover_text": fields.get("cover_text"), "typography_spec": {},
                "safe_zone_spec": safe, "series_bindings": resolved.get("field_sources"), "generation_authorization_ref": None,
                "source_resolution": source, "qa": {"overall": "blocked", "blocking_reasons": ["approved_or_system_font_missing"]},
            }
        font_path = system_font
        fallback_used = True
    title = str(fields.get("cover_text") or "").strip()
    title_size = max(44, round(height * 0.072))
    mark_size = max(24, round(height * 0.025))
    panel_pad = max(18, round(height * 0.018))
    max_text_width = safe_box[2] - safe_box[0] - panel_pad * 2 - 8
    while title_size >= 28:
        title_font = ImageFont.truetype(str(font_path), title_size)
        lines = wrap_text(draw, title, title_font, max_text_width)
        line_height = round(title_size * 1.28)
        total_height = len(lines) * line_height
        if len(lines) <= 3 and total_height <= round((safe_box[3] - safe_box[1]) * 0.42):
            break
        title_size -= 4
    text_truncated = len(lines) > 3
    if text_truncated:
        lines = lines[:3]
        while lines[-1] and draw.textbbox((0, 0), lines[-1] + "…", font=title_font)[2] > max_text_width:
            lines[-1] = lines[-1][:-1]
        lines[-1] += "…"
        total_height = len(lines) * line_height
    panel_bottom = safe_box[3]
    panel_top = max(safe_box[1], panel_bottom - total_height - panel_pad * 2)
    panel_color = parse_hex_color(fields.get("panel_color", "#101820"), 214)
    if fields.get("show_title_panel") is True:
        draw.rounded_rectangle((safe_box[0], panel_top, safe_box[2], panel_bottom), radius=max(16, round(height * 0.014)), fill=panel_color)
    text_color = parse_hex_color(fields.get("text_color", "#FFFFFF"), 255)
    y = panel_top + panel_pad
    line_boxes = []
    for line in lines:
        bbox = draw.textbbox((safe_box[0] + panel_pad, y), line, font=title_font, stroke_width=max(1, title_size // 36))
        draw.text((safe_box[0] + panel_pad, y), line, font=title_font, fill=text_color, stroke_width=max(1, title_size // 36), stroke_fill=(0, 0, 0, 180))
        line_boxes.append(list(bbox))
        y += line_height
    series_mark = str(fields.get("series_mark") or "").strip()
    mark_box = None
    if series_mark and fields.get("show_series_mark") is True:
        mark_font = ImageFont.truetype(str(font_path), mark_size)
        mark_bbox = draw.textbbox((0, 0), series_mark, font=mark_font)
        mark_width = mark_bbox[2] - mark_bbox[0]
        mark_height = mark_bbox[3] - mark_bbox[1]
        mark_x, mark_y = safe_box[0], safe_box[1]
        draw.rounded_rectangle((mark_x, mark_y, mark_x + mark_width + panel_pad * 2, mark_y + mark_height + panel_pad), radius=max(10, panel_pad // 2), fill=brand)
        draw.text((mark_x + panel_pad, mark_y + panel_pad // 3), series_mark, font=mark_font, fill=(20, 24, 28, 255))
        mark_box = [mark_x, mark_y, mark_x + mark_width + panel_pad * 2, mark_y + mark_height + panel_pad]
    platform_dir.mkdir(parents=True, exist_ok=True)
    output_path = platform_dir / f"cover-{platform}.png"
    metadata = PngImagePlugin.PngInfo()
    metadata.add_text("Skill5CoverText", title)
    metadata.add_text("Skill5Platform", platform)
    metadata.add_text("Skill5SourceChecksum", str(source.get("source_checksum_sha256") or ""))
    canvas.convert("RGB").save(output_path, format="PNG", pnginfo=metadata, optimize=True)
    return {
        "source_type": source.get("source_type"),
        "source_ref": str(source_path.resolve()),
        "source_checksum_sha256": source.get("source_checksum_sha256") or sha256_file(source_path),
        "composed_asset_path": str(output_path.resolve()),
        "composed_asset_checksum_sha256": sha256_file(output_path),
        "width": width,
        "height": height,
        "layout_variant": fields.get("layout_variant"),
        "cover_text": title,
        "typography_spec": {
            "font_path": str(font_path.resolve()),
            "font_rights_status": fields.get("font_rights_status") if not fallback_used else "system",
            "fallback_used": fallback_used,
            "title_font_size": title_size,
            "series_mark_font_size": mark_size if series_mark else None,
            "text_truncated": text_truncated,
            "text_color": fields.get("text_color"),
            "panel_color": fields.get("panel_color"),
            "brand_color": fields.get("brand_color"),
            "line_boxes": line_boxes,
            "series_mark_box": mark_box,
        },
        "safe_zone_spec": {"fractions": safe, "pixel_box": list(safe_box)},
        "series_bindings": resolved.get("field_sources"),
        "generation_authorization_ref": source.get("generation_authorization_ref"),
        "source_resolution": source,
        "qa": {},
    }


def normalized_text(value: str) -> str:
    return re.sub(r"[\s\W_]+", "", str(value or ""), flags=re.UNICODE).lower()


def run_ocr(path: Path, expected: str, provided: dict[str, Any] | None, checksum: str) -> dict[str, Any]:
    observed_text = ""
    engine = None
    evidence_ref = None
    if provided and normalize_hash(provided.get("asset_checksum_sha256")) == normalize_hash(checksum):
        observed_text = str(provided.get("observed_text") or "")
        engine = provided.get("engine") or "declared_external_ocr"
        evidence_ref = provided.get("evidence_ref")
    else:
        tesseract = find_command("tesseract")
        if tesseract:
            completed = run_process([tesseract, str(path), "stdout", "-l", "chi_sim+eng", "--psm", "6"])
            if completed.returncode == 0:
                observed_text = completed.stdout.strip()
                engine = "tesseract-local"
    if not engine:
        return {"status": "unknown", "engine": None, "observed_text": None, "evidence_ref": None, "reason": "ocr_runtime_unavailable"}
    expected_normal = normalized_text(expected)
    observed_normal = normalized_text(observed_text)
    if expected_normal and expected_normal in observed_normal:
        status = "pass"
    else:
        overlap = len(set(expected_normal) & set(observed_normal)) / max(1, len(set(expected_normal)))
        status = "uncertain" if overlap >= 0.7 else "fail"
    return {"status": status, "engine": engine, "observed_text": observed_text, "evidence_ref": evidence_ref, "expected_text": expected}


def cover_qa(cover: dict[str, Any], resolved: dict[str, Any], platform: str, input_data: dict[str, Any]) -> dict[str, Any]:
    checks: list[dict[str, Any]] = []
    blocking: list[str] = []
    output_raw = cover.get("composed_asset_path")
    output_path = Path(output_raw) if output_raw else None
    source_raw = cover.get("source_ref")
    source_path = Path(source_raw) if source_raw else None
    expected = resolved["fields"]
    source_ok = bool(source_path and source_path.is_file() and sha256_file(source_path) == normalize_hash(cover.get("source_checksum_sha256")))
    checks.append({"check_id": "cover-source-file-checksum", "status": "pass" if source_ok else "fail"})
    if not source_ok:
        blocking.append("cover_source_file_or_checksum_invalid")
    output_ok = bool(output_path and output_path.is_file() and sha256_file(output_path) == normalize_hash(cover.get("composed_asset_checksum_sha256")))
    checks.append({"check_id": "cover-output-file-checksum", "status": "pass" if output_ok else "fail"})
    if not output_ok:
        blocking.append("cover_output_file_or_checksum_invalid")
    dimension_ok = False
    format_ok = False
    size_ok = False
    metadata_ok = False
    if output_ok and output_path:
        with Image.open(output_path) as image:
            dimension_ok = image.size == (int(expected["width"]), int(expected["height"]))
            format_ok = image.format == str(expected.get("format", "PNG")).upper()
            metadata_ok = image.info.get("Skill5CoverText") == cover.get("cover_text") and image.info.get("Skill5Platform") == platform
        size_ok = output_path.stat().st_size <= int(expected.get("max_file_size_bytes") or 50 * 1024 * 1024)
    for check_id, passed in (("cover-dimensions-aspect", dimension_ok), ("cover-format", format_ok), ("cover-file-size", size_ok), ("composition-text-manifest", metadata_ok)):
        checks.append({"check_id": check_id, "status": "pass" if passed else "fail"})
        if not passed:
            blocking.append(check_id.replace("-", "_"))
    text_not_truncated = not bool((cover.get("typography_spec") or {}).get("text_truncated"))
    checks.append({"check_id": "cover-text-complete", "status": "pass" if text_not_truncated else "fail"})
    if not text_not_truncated:
        blocking.append("cover_text_truncated")
    safe_box = (cover.get("safe_zone_spec") or {}).get("pixel_box") or [0, 0, 0, 0]
    boxes = list((cover.get("typography_spec") or {}).get("line_boxes") or [])
    mark_box = (cover.get("typography_spec") or {}).get("series_mark_box")
    if mark_box:
        boxes.append(mark_box)
    safe_ok = bool(boxes) and all(box[0] >= safe_box[0] and box[1] >= safe_box[1] and box[2] <= safe_box[2] and box[3] <= safe_box[3] for box in boxes)
    checks.append({"check_id": "cover-safe-zone", "status": "pass" if safe_ok else "fail", "safe_box": safe_box, "content_boxes": boxes})
    if not safe_ok:
        blocking.append("cover_safe_zone_failed")
    ratio = contrast_ratio(expected.get("text_color", "#FFFFFF"), expected.get("panel_color", "#101820"))
    contrast_ok = ratio >= float(((input_data.get("qa_policy") or {}).get("minimum_contrast_ratio") or 4.5))
    checks.append({"check_id": "cover-contrast", "status": "pass" if contrast_ok else "fail", "ratio": ratio, "threshold": 4.5})
    if not contrast_ok:
        blocking.append("cover_contrast_failed")
    series_ok = not resolved.get("issues") and all(key in (cover.get("series_bindings") or {}) for key in ("brand_color", "font_path", "layout_variant"))
    checks.append({"check_id": "series-field-bindings", "status": "pass" if series_ok else "fail", "issues": resolved.get("issues")})
    if not series_ok:
        blocking.append("series_binding_failed")
    ocr_evidence = (((input_data.get("qa_evidence") or {}).get("ocr_by_platform") or {}).get(platform))
    ocr = run_ocr(output_path, cover.get("cover_text") or "", ocr_evidence, cover.get("composed_asset_checksum_sha256") or "") if output_path and output_path.is_file() else {"status": "fail", "reason": "cover_missing"}
    checks.append({"check_id": "cover-ocr-readback", **ocr})
    if ocr.get("status") != "pass":
        blocking.append("cover_ocr_not_passed")
    placeholder_pattern = re.compile(r"sample|placeholder|watermark|template|占位|水印|模板", re.I)
    if ocr.get("status") == "pass":
        unexpected = [token for token in placeholder_pattern.findall(str(ocr.get("observed_text") or "")) if token not in str(cover.get("cover_text") or "")]
        watermark_status = "fail" if unexpected else "pass"
        watermark_reason = unexpected
    else:
        watermark_status = "unknown"
        watermark_reason = ["ocr_not_available_for_unexpected_text_scan"]
    checks.append({"check_id": "cover-watermark-placeholder", "status": watermark_status, "findings": watermark_reason})
    if watermark_status != "pass":
        blocking.append("cover_watermark_placeholder_not_passed")
    overall = "pass" if not blocking else "blocked"
    return {"overall": overall, "checks": checks, "blocking_reasons": sorted(set(blocking)), "ocr": ocr, "contrast_ratio": ratio}


def cover_semantic_review(input_data: dict[str, Any], platform: str, cover: dict[str, Any]) -> dict[str, Any]:
    fields = (
        "required_subjects_present", "title_visual_match", "key_action_readable", "critical_subject_unoccluded",
        "thumbnail_readability", "identity_and_style_consistency", "platform_native_composition", "template_residue",
    )
    target_hash = normalize_hash(cover.get("composed_asset_checksum_sha256"))
    supplied = copy.deepcopy((((input_data.get("review_inputs") or {}).get("cover_semantic_review_by_platform") or {}).get(platform) or {}))
    findings: list[dict[str, Any]] = list(supplied.get("findings") or [])
    if not target_hash:
        return {"review_version": "1.0", "target_cover_hash": None, "evidence_source": None, **{name: "unknown" for name in fields}, "verdict": "unknown", "findings": [{"code": "actual_cover_missing"}]}
    if not supplied:
        return {"review_version": "1.0", "target_cover_hash": target_hash, "evidence_source": None, **{name: "unknown" for name in fields}, "verdict": "unknown", "findings": [{"code": "semantic_visual_review_missing"}]}
    if normalize_hash(supplied.get("target_cover_hash")) != target_hash:
        return {"review_version": "1.0", "target_cover_hash": target_hash, "evidence_source": supplied.get("evidence_source"), **{name: "unknown" for name in fields}, "verdict": "unknown", "findings": findings + [{"code": "semantic_review_cover_hash_mismatch"}]}
    result = {"review_version": "1.0", "target_cover_hash": target_hash, "evidence_source": supplied.get("evidence_source")}
    for name in fields:
        value = supplied.get(name, "unknown")
        result[name] = value if value in {"pass", "fail", "unknown", "human_review"} else "unknown"
    declared_verdict = supplied.get("verdict", "unknown")
    if any(result[name] == "fail" for name in fields):
        verdict = "fail"
    elif any(result[name] in {"unknown", "human_review"} for name in fields):
        verdict = "human_review" if any(result[name] == "human_review" for name in fields) else "unknown"
    else:
        verdict = "pass"
    if declared_verdict != verdict:
        findings.append({"code": "semantic_verdict_recomputed", "declared": declared_verdict, "effective": verdict})
    result["verdict"] = verdict
    result["findings"] = findings
    result["approval_ref"] = supplied.get("approval_ref")
    return result


def select_account_profile(input_data: dict[str, Any], platform: str) -> dict[str, Any]:
    for profile in (input_data.get("publishing_context") or {}).get("account_profiles") or []:
        if profile.get("platform") in {platform, "youtube" if platform.startswith("youtube_") else platform}:
            return profile
    return {}


def normalize_list(values: Any) -> list[str]:
    if not isinstance(values, list):
        return []
    result: list[str] = []
    for value in values:
        text = str(value or "").strip()
        if text and text not in result:
            result.append(text)
    return result


def collect_cover_reference_bindings(
    input_data: dict[str, Any], input_dir: Path, cover_source: dict[str, Any], binding: dict[str, Any]
) -> tuple[list[dict[str, Any]], list[str], list[str]]:
    cover_inputs = input_data.get("cover_inputs") or {}
    legacy_sources = input_data.get("cover_sources") or {}
    entries = list(cover_inputs.get("approved_assets") or []) + list(cover_inputs.get("approved_keyframes") or [])
    entries += list(legacy_sources.get("approved_keyframes") or [])
    bindings: list[dict[str, Any]] = []
    blockers: list[str] = []
    warnings: list[str] = []
    seen: set[str] = set()
    allowed_roles = {"identity", "scene", "style", "action", "composition", "prop"}
    for index, entry in enumerate(entries, start=1):
        path = resolve_local_path(entry.get("path") or entry.get("source_ref"), input_dir)
        if not path or not path.is_file():
            blockers.append(f"cover_reference_missing:{index}")
            continue
        observed = sha256_file(path)
        declared = normalize_hash(entry.get("checksum_sha256"))
        version = str(entry.get("version") or entry.get("asset_version") or "").strip()
        role = str(entry.get("reference_role") or ("action" if entry.get("asset_type") == "keyframe" else "identity")).strip()
        approval = str(entry.get("approval_status") or "").strip()
        rights = str(entry.get("rights_status") or ("cleared" if entry.get("rights_provenance_ref") else "unknown")).strip()
        if not declared or declared != observed:
            blockers.append(f"cover_reference_checksum_invalid:{index}")
        if not version:
            blockers.append(f"cover_reference_version_missing:{index}")
        if approval != "approved":
            blockers.append(f"cover_reference_not_approved:{index}")
        if role not in allowed_roles:
            blockers.append(f"cover_reference_role_invalid:{index}")
        if rights == "blocked":
            blockers.append(f"cover_reference_rights_blocked:{index}")
        elif rights != "cleared":
            warnings.append(f"cover_reference_rights_unknown:{index}")
        key = str(path.resolve()).lower()
        if key in seen:
            continue
        seen.add(key)
        bindings.append({
            "asset_id": entry.get("asset_id") or f"cover-reference-{index}",
            "asset_type": entry.get("asset_type") or "keyframe",
            "path": str(path.resolve()),
            "checksum_sha256": observed,
            "version": version or None,
            "approval_status": approval or "unknown",
            "approval_ref": entry.get("approval_ref") or entry.get("approval_evidence_ref"),
            "rights_status": rights or "unknown",
            "rights_ref": entry.get("rights_ref") or entry.get("rights_provenance_ref"),
            "reference_role": role,
        })
    if not bindings and cover_source.get("source_ref"):
        source_path = Path(cover_source["source_ref"])
        rights_refs = normalize_list((input_data.get("rights_and_disclosure") or {}).get("rights_provenance_refs"))
        if source_path.is_file():
            bindings.append({
                "asset_id": "optional-final-frame-reference",
                "asset_type": "keyframe",
                "path": str(source_path.resolve()),
                "checksum_sha256": sha256_file(source_path),
                "version": binding.get("artifact_version") or "unversioned",
                "approval_status": "approved" if binding.get("final_qa_status") == "accepted" else "pending_review",
                "approval_ref": binding.get("artifact_id"),
                "rights_status": "cleared" if rights_refs else "unknown",
                "rights_ref": rights_refs[0] if rights_refs else None,
                "reference_role": "composition",
            })
            if binding.get("final_qa_status") != "accepted":
                blockers.append("optional_final_frame_not_accepted")
            if not rights_refs:
                warnings.append("optional_final_frame_rights_unknown")
    if not bindings:
        blockers.append("COVER_SOURCE_BLOCKED")
    return bindings, sorted(set(blockers)), sorted(set(warnings))


def platform_cover_composition(platform: str, resolved: dict[str, Any]) -> dict[str, Any]:
    safe = resolved["fields"].get("safe_zone") or {}
    if platform == "xiaohongshu":
        native = "3:4 editorial relationship frame; girl and kitten both readable; breathing room for a two-line title; no mechanical crop from 9:16"
        subject = {"girl": "left or lower-left third", "kitten": "near protected center", "relationship": "umbrella shelter line remains legible"}
        avoidance = ["outer 6 percent crop tolerance", "lower interaction area must remain unobscured"]
        priority = "girl choice and kitten vulnerability read together at small-card size"
    elif platform == "douyin":
        native = "9:16 concentrated action frame; girl-to-kitten gesture large enough for feed thumbnail; no mechanical extension from 3:4"
        subject = {"girl": "center-left", "kitten": "lower-center above caption controls", "relationship": "hand and umbrella action inside central safe column"}
        avoidance = ["top title and avatar zone", "right-side action controls", "bottom caption and navigation zone"]
        priority = "one-glance action: she turns toward and shelters the kitten"
    else:
        native = f"{platform} native cover frame using the declared output ratio"
        subject = {"primary": "inside platform safe zone"}
        avoidance = ["platform UI controls"]
        priority = "core promise readable at thumbnail size"
    return {
        "aspect_ratio": f"{resolved['fields']['width']}:{resolved['fields']['height']}",
        "subject_placement": subject,
        "title_safe_zone": safe,
        "platform_ui_avoidance": avoidance,
        "thumbnail_priority": priority,
        "platform_native_composition": native,
    }


def build_cover_prompt_request(
    input_data: dict[str, Any], input_dir: Path, platform: str, resolved: dict[str, Any], cover_source: dict[str, Any], binding: dict[str, Any]
) -> tuple[dict[str, Any], list[str], list[str]]:
    titles = resolve_titles(input_data, platform)
    cover_inputs = input_data.get("cover_inputs") or {}
    references, blockers, warnings = collect_cover_reference_bindings(input_data, input_dir, cover_source, binding)
    request = {
        "contract_version": "1.0",
        "request_id": None,
        "platform": platform,
        "cover_title": titles["cover_title"],
        "visual_thesis": str(cover_inputs.get("visual_thesis") or (input_data.get("content_core") or {}).get("core_promise") or titles["story_hook"]).strip(),
        "required_subjects": normalize_list(cover_inputs.get("required_subjects")),
        "required_action": cover_inputs.get("required_action"),
        "emotional_read": str(cover_inputs.get("emotional_read") or "the required relationship and emotional turn must read at thumbnail size"),
        "reference_bindings": references,
        "composition": platform_cover_composition(platform, resolved),
        "text_strategy": {"generate_text_in_image": False, "reserve_clean_title_space": True, "overlay_title_after_generation": True},
        "consistency_locks": normalize_list(cover_inputs.get("identity_locks")) + normalize_list(cover_inputs.get("style_locks")),
        "allowed_variation": normalize_list(cover_inputs.get("allowed_variation")) or ["micro-expression", "minor rain particle placement"],
        "negative_constraints": normalize_list(cover_inputs.get("forbidden_elements")) + ["exact Chinese text in image", "watermark", "test badge", "generic yellow border", "dark title board", "template residue", "mechanical cross-platform crop"],
        "output_spec": {"aspect_ratio": platform_cover_composition(platform, resolved)["aspect_ratio"], "size": f"{resolved['fields']['width']}x{resolved['fields']['height']}", "quality": "review_draft", "background": "opaque", "output_format": str(resolved['fields'].get("format") or "PNG").lower()},
    }
    request["request_id"] = f"CPR-{sha256_bytes(canonical_json(request))[:20]}"
    return request, blockers, warnings


def compile_cover_prompt_package(request: dict[str, Any], blockers: list[str], warnings: list[str], platform_dir: Path) -> dict[str, Any]:
    request_path = platform_dir / "cover-prompt-request.json"
    write_json(request_path, request)
    request_hash = sha256_bytes(canonical_json(request))
    if blockers:
        package = {
            "contract_version": "1.0", "prompt_package_id": f"CPP-{request_hash[:20]}", "prompt_package_version": "1.0", "prompt_package_hash": None,
            "platform": request.get("platform"), "source_request_hash": request_hash, "image_prompt_spec": None, "executable_prompt": None,
            "reference_bindings": request.get("reference_bindings") or [], "call_package": {"generation_status": "not_authorized", "unresolved_fields": blockers},
            "overlay_spec": {"cover_title": request.get("cover_title"), **(request.get("text_strategy") or {})},
            "prompt_review": {"deterministic_status": "HOLD", "semantic_status": "unknown", "findings": [{"code": item} for item in blockers + warnings]},
            "readiness": {"status": "PROMPT_DRAFT", "blocking_reasons": blockers + warnings}, "compiler_reuse": "video-production/scripts/compile-image-prompt-fixture.ps1",
        }
    else:
        composition = request["composition"]
        spec = {
            "asset_id": f"cover-{request['platform']}-{request_hash[:12].lower()}", "asset_type": "keyframe", "prompt_variant": "cover_visual", "render_mode": "stylized",
            "source_locks": request.get("reference_bindings") or [],
            "decisions": {
                "subject_action": {"status": "explicit", "value": request.get("required_action") or request.get("visual_thesis"), "reason": "cover visual thesis"},
                "context": {"status": "explicit", "value": "inherit_reference", "reason": "approved scene references own the environment"},
                "composition_camera": {"status": "explicit", "value": composition.get("platform_native_composition"), "reason": "platform-native cover"},
                "lighting_outcome": {"status": "inherited", "value": "preserve approved reference lighting and keep faces/action readable", "inherited_from": "approved visual references"},
                "style_aesthetic": {"status": "inherited", "value": "preserve approved style locks", "inherited_from": "approved visual references"},
                "optics": {"status": "explicit", "value": "low-distortion normal perspective with all required subjects readable", "reason": "thumbnail readability"},
                "color": {"status": "explicit", "identity_palette": "preserve approved identity and scene palette", "product_true_color": None, "grade": "no palette rewrite", "reason": "identity continuity"},
            },
            "material_texture": {"status": "inherited", "value": "preserve approved materials and avoid plastic gloss", "inherited_from": "approved references"},
            "text_handling": {"status": "explicit", "value": "generate_text_in_image=false; reserve clean title space; exact Chinese is applied after generation", "reason": "text accuracy"},
            "consistency_locks": request.get("consistency_locks") or [], "allowed_variation": request.get("allowed_variation") or [],
            "reference_bindings": request.get("reference_bindings") or [], "negative_constraints": request.get("negative_constraints") or [], "output_spec": request.get("output_spec"),
            "cover_context": {"platform": request.get("platform"), "platform_native_composition": composition.get("platform_native_composition"), "title_safe_zone": json.dumps(composition.get("title_safe_zone"), ensure_ascii=False, sort_keys=True), "platform_ui_avoidance": composition.get("platform_ui_avoidance"), "thumbnail_priority": composition.get("thumbnail_priority"), "generate_text_in_image": False},
        }
        fixture_path = platform_dir / "cover-prompt-compiler-input.json"
        compiler_output = platform_dir / "cover-prompt-compiler-result.json"
        write_json(fixture_path, {"fixture_only": True, "cases": [{"case_id": f"cover-{request['platform']}", "expected_result": "passed", "image_prompt_spec": spec}]})
        shell = find_command("pwsh") or find_command("powershell")
        compiler = Path(__file__).resolve().parents[1].parent / "video-production" / "scripts" / "compile-image-prompt-fixture.ps1"
        compiled_case = None
        compiler_error = None
        if not shell or not compiler.is_file():
            compiler_error = "existing_image_prompt_compiler_unavailable"
        else:
            completed = run_process([shell, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(compiler), "-FixturePath", str(fixture_path), "-OutputPath", str(compiler_output)])
            if completed.returncode != 0 or not compiler_output.is_file():
                compiler_error = f"existing_image_prompt_compiler_failed:{completed.stderr.strip()}"
            else:
                result = read_json(compiler_output)
                compiled_case = (result.get("cases") or [None])[0]
        deterministic = "PASS" if compiled_case and (compiled_case.get("image_prompt_spec") or {}).get("qa", {}).get("status") == "passed" else "HOLD"
        compile_findings = warnings + ([compiler_error] if compiler_error else [])
        call_package = copy.deepcopy((compiled_case or {}).get("call_package") or {})
        call_package["generation_status"] = "not_authorized"
        package = {
            "contract_version": "1.0", "prompt_package_id": f"CPP-{request_hash[:20]}", "prompt_package_version": "1.0", "prompt_package_hash": None,
            "platform": request.get("platform"), "source_request_hash": request_hash, "image_prompt_spec": (compiled_case or {}).get("image_prompt_spec"),
            "executable_prompt": (compiled_case or {}).get("image_prompt_spec", {}).get("executable_prompt"), "reference_bindings": request.get("reference_bindings") or [],
            "call_package": call_package, "overlay_spec": {"cover_title": request.get("cover_title"), **(request.get("text_strategy") or {})},
            "prompt_review": {"deterministic_status": deterministic, "semantic_status": "unknown", "findings": [{"code": item} for item in compile_findings]},
            "readiness": {"status": "GENERATION_HOLD" if deterministic == "PASS" else "PROMPT_DRAFT", "blocking_reasons": sorted(set(compile_findings + ["real_generation_not_authorized"]))},
            "compiler_reuse": "video-production/scripts/compile-image-prompt-fixture.ps1",
        }
    package["prompt_package_hash"] = sha256_bytes(canonical_json({key: value for key, value in package.items() if key != "prompt_package_hash"}))
    write_json(platform_dir / "cover-prompt-package.json", package)
    return package


def build_copy(input_data: dict[str, Any], platform: str, snapshot: dict[str, Any]) -> dict[str, Any]:
    core = input_data.get("content_core") or {}
    titles = resolve_titles(input_data, platform)
    supplied = copy.deepcopy((input_data.get("platform_copy") or {}).get(platform) or {})
    source = "skill5_platform_copy"
    legacy_consumed: list[str] = []
    if not supplied:
        legacy = copy.deepcopy((input_data.get("legacy_packaging") or {}).get(platform) or {})
        if legacy:
            supplied = legacy
            source = "skill2_legacy_provisional_hint"
            legacy_consumed.append(platform)
    title = titles["platform_title"]
    body = supplied.get("body_or_description")
    if body is None:
        body = supplied.get("body") if supplied.get("body") is not None else supplied.get("description")
    if body is None and platform == "douyin":
        body = None
    elif body is None:
        points = "\n".join(f"- {item}" for item in normalize_list(core.get("key_points")))
        body = str(core.get("core_promise") or "").strip() + (("\n" + points) if points else "")
    title_limit = rule_value(snapshot, "copy.title_max_length")
    description_limit = rule_value(snapshot, "copy.description_max_length")
    length_findings = []
    if title_limit and len(title) > int(title_limit):
        length_findings.append("title_exceeds_profile_limit")
    if description_limit and body is not None and len(str(body)) > int(description_limit):
        length_findings.append("description_exceeds_profile_limit")
    topics = normalize_list(supplied.get("topics"))
    hashtags = normalize_list(supplied.get("hashtags") or supplied.get("tags"))
    keywords = normalize_list(supplied.get("keywords"))
    return {
        "story_hook": titles["story_hook"],
        "platform_title": titles["platform_title"],
        "cover_title": titles["cover_title"],
        "title_or_caption": title,
        "body_or_description": str(body).strip() if body is not None else None,
        "topics": topics,
        "hashtags": hashtags,
        "keywords": keywords,
        "optional_cta": supplied.get("optional_cta"),
        "source": source,
        "legacy_hints_consumed": legacy_consumed,
        "length_findings": length_findings,
    }


def build_overlay(platform: str, packaged_copy: dict[str, Any], cover: dict[str, Any], account: dict[str, Any], input_data: dict[str, Any]) -> dict[str, Any]:
    rights = input_data.get("rights_and_disclosure") or {}
    if platform == "xiaohongshu":
        return {
            "xiaohongshu_overlay": {
                "note_type": "video",
                "title": packaged_copy["title_or_caption"],
                "body": packaged_copy.get("body_or_description") or "",
                "topics": packaged_copy.get("topics") or packaged_copy.get("hashtags") or [],
                "cover_layout_variant": cover.get("layout_variant"),
                "optional_location_or_product_binding": None,
            }
        }
    if platform == "douyin":
        text = packaged_copy["title_or_caption"]
        if packaged_copy.get("body_or_description"):
            text += "\n" + packaged_copy["body_or_description"]
        return {
            "douyin_overlay": {
                "text": text,
                "topics": packaged_copy.get("topics") or packaged_copy.get("hashtags") or [],
                "private_status": account.get("private_status") or "user_select",
                "cover_selection": {"type": "custom_asset", "timestamp_seconds": None, "asset_path": cover.get("composed_asset_path")},
                "allow_download": account.get("allow_download") if account.get("allow_download") in {True, False} else "user_select",
                "ai_declaration_action": rights.get("platform_setting_action"),
                "api_scope_status": "not_requested_v1",
            }
        }
    youtube_base = {
        "channel_id": account.get("account_or_channel_id"),
        "title": packaged_copy["title_or_caption"],
        "description": packaged_copy.get("body_or_description") or "",
        "category_id": account.get("category_id"),
        "tags": packaged_copy.get("hashtags") or packaged_copy.get("keywords") or [],
        "default_language": account.get("default_language") or (input_data.get("source_artifact") or {}).get("language"),
        "privacy_status": account.get("privacy_status") or "user_select",
        "publish_at": None,
        "self_declared_made_for_kids": account.get("self_declared_made_for_kids", "unknown"),
        "contains_synthetic_media": rights.get("contains_synthetic_media", "unknown"),
        "has_paid_product_placement": rights.get("has_paid_product_placement", "unknown"),
        "thumbnail_path": cover.get("composed_asset_path"),
        "optional_playlist_id": account.get("optional_playlist_id"),
    }
    if platform == "youtube_shorts":
        child = {
            "format": "shorts",
            "short_format_validation": {"source_duration_seconds": (input_data.get("source_artifact") or {}).get("duration_seconds"), "status": "observed_not_modified"},
            "first_seconds_promise_match": (input_data.get("review_inputs") or {}).get("promise_match", "unknown"),
        }
        return {"youtube_base_overlay": youtube_base, "youtube_shorts_overlay": child}
    return {
        "youtube_base_overlay": youtube_base,
        "youtube_long_overlay": {"format": "long_form", "chapters": None, "backup_title": None, "browse_and_search_notes": {}},
    }


def timezone_offset(name: str) -> dt.tzinfo:
    try:
        from zoneinfo import ZoneInfo

        return ZoneInfo(name)
    except Exception:
        if name in {"Asia/Singapore", "Asia/Shanghai", "UTC+08:00", "+08:00"}:
            return dt.timezone(dt.timedelta(hours=8))
        return dt.timezone.utc


def combine_date_time(date_value: dt.date, hhmm: str, timezone_name: str) -> dt.datetime:
    hour, minute = (int(part) for part in hhmm.split(":"))
    return dt.datetime.combine(date_value, dt.time(hour, minute), tzinfo=timezone_offset(timezone_name))


def build_publish_window(input_data: dict[str, Any], snapshot: dict[str, Any], as_of: dt.datetime) -> dict[str, Any]:
    context = input_data.get("publishing_context") or {}
    timezone_name = context.get("primary_audience_timezone") or "UTC+08:00"
    requested = context.get("requested_publish_date")
    target_date = dt.date.fromisoformat(requested) if requested else as_of.astimezone(timezone_offset(timezone_name)).date()
    historical = [ref for ref in context.get("historical_performance_refs") or [] if ref.get("status") == "current" and ref.get("windows")]
    evidence: dict[str, Any]
    assumptions: list[str] = []
    unknowns: list[str] = []
    confidence = "low"
    if historical:
        selected = historical[0]
        windows = selected["windows"]
        evidence = {
            "sources": [selected.get("evidence_ref")],
            "sample_period": selected.get("sample_period"),
            "sample_size": selected.get("sample_size"),
            "comparable_content_definition": selected.get("comparable_content_definition"),
            "basis": "current_account_or_comparable_history",
        }
        if selected.get("audience_timezone"):
            timezone_name = selected["audience_timezone"]
        if selected.get("sample_period") and int(selected.get("sample_size") or 0) >= 12 and selected.get("audience_timezone") and selected.get("comparable_content_definition"):
            confidence = "high"
        else:
            confidence = "medium"
            unknowns.append("history_does_not_meet_high_confidence_requirements")
    else:
        windows = rule_value(snapshot, "timing.experiment_windows", [{"start": "19:00", "end": "21:00"}, {"start": "12:00", "end": "13:30"}])
        evidence = {"sources": ["platform_profile:timing.experiment_windows"], "sample_period": None, "sample_size": None, "comparable_content_definition": None, "basis": "audience_routine_experiment"}
        assumptions.append("No current account analytics were supplied; windows are experiments based on audience routine.")
        unknowns.extend(["account_audience_activity_unknown", "series_timing_effect_unknown", "post_publish_effect_unknown"])
        confidence = "unknown" if snapshot.get("heuristic_stale") else "low"
    primary = windows[0]
    alternate = windows[1] if len(windows) > 1 else None
    start = combine_date_time(target_date, primary["start"], timezone_name)
    end = combine_date_time(target_date, primary["end"], timezone_name)
    alternate_window = None
    if alternate:
        alternate_window = {"start": iso(combine_date_time(target_date, alternate["start"], timezone_name)), "end": iso(combine_date_time(target_date, alternate["end"], timezone_name)), "label": "alternate_experiment_window"}
    operational = start + (end - start) / 2 if requested else None
    utc8 = dt.timezone(dt.timedelta(hours=8))
    return {
        "primary_window": {"start": iso(start), "end": iso(end), "label": "primary_experiment_window" if not historical else "primary_evidence_window"},
        "alternate_test_window": alternate_window,
        "audience_timezone": timezone_name,
        "display_timezone": "UTC+08:00",
        "display_primary_window": {"start": iso(start.astimezone(utc8)), "end": iso(end.astimezone(utc8))},
        "operational_selection": iso(operational) if operational else None,
        "operational_selection_label": "window_internal_operational_selection_not_best_time" if operational else None,
        "evidence": evidence,
        "assumptions": assumptions,
        "unknowns": unknowns,
        "confidence": confidence,
    }


def compliance_and_performance(
    input_data: dict[str, Any],
    platform: str,
    snapshot: dict[str, Any],
    packaged_copy: dict[str, Any],
    cover: dict[str, Any],
    overlay: dict[str, Any],
) -> dict[str, Any]:
    findings: list[dict[str, Any]] = []

    def finding(code: str, severity: str, status: str, evidence: str) -> None:
        findings.append({"finding_id": f"PKG-{len(findings)+1:02d}", "code": code, "severity": severity, "status": status, "evidence": [evidence]})

    rights = copy.deepcopy(input_data.get("rights_and_disclosure") or {})
    promise = (input_data.get("review_inputs") or {}).get("promise_match", "unknown")
    metadata_relevance = (input_data.get("review_inputs") or {}).get("metadata_relevance", "unknown")
    if snapshot.get("critical_rules_status") != "current":
        finding("critical_platform_rules_not_current", "blocking", "unknown", snapshot.get("critical_rules_status"))
    if not rights.get("rights_provenance_refs"):
        finding("rights_provenance_missing", "blocking", "unknown", "No rights provenance reference supplied.")
    if rights.get("commercial_relationship", "unknown") == "unknown":
        finding("commercial_relationship_unknown", "blocking", "unknown", "Commercial relationship must be declared.")
    ai_required = rights.get("ai_disclosure_required", "unknown")
    if ai_required == "unknown":
        finding("ai_disclosure_requirement_unknown", "blocking", "unknown", "AI disclosure requirement was not decided.")
    if ai_required is True and not (rights.get("disclosure_text") or rights.get("platform_setting_action")):
        finding("ai_disclosure_action_missing", "blocking", "confirmed", "Disclosure is required but no text/setting action is supplied.")
    if promise == "fail":
        finding("promise_mismatch", "blocking", "confirmed", "Declared package Promise Match failed.")
    elif promise in {"unknown", "human_review", None}:
        finding("promise_match_unresolved", "blocking", "unknown", f"Promise Match is {promise or 'missing'}.")
    if metadata_relevance == "fail":
        finding("metadata_irrelevant", "blocking", "confirmed", "Declared metadata relevance failed.")
    elif metadata_relevance in {"unknown", "human_review", None}:
        finding("metadata_relevance_unresolved", "blocking", "unknown", f"Metadata relevance is {metadata_relevance or 'missing'}.")
    for length_issue in packaged_copy.get("length_findings") or []:
        finding(length_issue, "blocking", "confirmed", "Copy exceeds a current hard limit.")
    if re.search(r"百分之百|保证(?:你|一定|永久)|稳赚|绝对不会", packaged_copy.get("title_or_caption") or ""):
        finding("unsupported_absolute_claim", "blocking", "suspected", "Title contains a high-risk absolute claim pattern requiring evidence/human review.")
    if cover.get("qa", {}).get("overall") != "pass":
        finding("cover_deterministic_qa_not_passed", "blocking", "confirmed", ",".join(cover.get("qa", {}).get("blocking_reasons") or []))
    account = select_account_profile(input_data, platform)
    if platform.startswith("youtube_"):
        if account.get("self_declared_made_for_kids", "unknown") == "unknown":
            finding("made_for_kids_unknown", "blocking", "unknown", "YouTube audience setting must not default to false.")
        ai_profile = input_data.get("content_core", {}).get("ai_generation_profile") or {}
        synthetic = rights.get("contains_synthetic_media", "unknown")
        if synthetic == "unknown":
            finding("synthetic_media_setting_unknown", "blocking", "unknown", "YouTube synthetic media setting is unresolved.")
        if ai_profile and synthetic is False:
            finding("synthetic_media_declaration_conflict", "blocking", "suspected", "AI generation profile exists while synthetic-media declaration is false.")
        if rights.get("has_paid_product_placement", "unknown") == "unknown":
            finding("paid_placement_setting_unknown", "blocking", "unknown", "YouTube paid placement setting is unresolved.")
    confirmed_block = any(f["severity"] == "blocking" and f["status"] in {"confirmed", "suspected"} for f in findings)
    unknown_block = any(f["severity"] == "blocking" and f["status"] == "unknown" for f in findings)
    compliance_status = "HOLD" if confirmed_block else "UNKNOWN" if unknown_block else "PASS"
    supplied_performance = copy.deepcopy((input_data.get("review_inputs") or {}).get("performance_assessment") or {})
    dimensions = ("audience_match", "discovery_match", "title_cover_synergy", "series_consistency", "qualified_click_hypothesis")
    performance = {key: supplied_performance.get(key, "unknown") for key in dimensions}
    performance.update({
        "cover_readability": "pass" if cover.get("qa", {}).get("overall") == "pass" else "unknown",
        "promise_match": promise,
        "evidence": normalize_list(supplied_performance.get("evidence")),
        "score": None,
        "expected_retention": "unknown_until_post_publish_evidence",
    })
    overall_values = [performance[key] for key in dimensions if performance[key] in {"strong", "mixed", "weak"}]
    if not overall_values:
        performance_assessment = "unknown"
    elif "weak" in overall_values:
        performance_assessment = "weak"
    elif "mixed" in overall_values:
        performance_assessment = "mixed"
    else:
        performance_assessment = "strong"
    return {
        "upstream_review_refs": normalize_list((input_data.get("upstream_refs") or {}).get("upstream_review_result_ids")),
        "deterministic_results": cover.get("qa", {}).get("checks") or [],
        "evaluator_result": (input_data.get("review_inputs") or {}).get("evaluator_result"),
        "review_policy_version": REVIEW_POLICY_VERSION,
        "compliance_status": compliance_status,
        "compliance_findings": findings,
        "promise_match": promise,
        "performance_assessment": performance_assessment,
        "performance_advisory": performance,
        "evidence_refs": normalize_list((input_data.get("review_inputs") or {}).get("evidence_refs")),
    }


def copy_is_ready(platform: str, packaged_copy: dict[str, Any]) -> bool:
    if not packaged_copy.get("title_or_caption") or packaged_copy.get("length_findings"):
        return False
    if platform in {"xiaohongshu", "youtube_shorts", "youtube_long"} and not packaged_copy.get("body_or_description"):
        return False
    return True


def package_hash_payload(package: dict[str, Any]) -> dict[str, Any]:
    fields = LEGACY_HASH_FIELDS if package.get("schema_version") == "1.1" else HASH_FIELDS
    return {key: package.get(key) for key in fields}


def compute_package_hash(package: dict[str, Any]) -> str:
    return sha256_bytes(canonical_json(package_hash_payload(package)))


def readiness(
    binding: dict[str, Any],
    source_reasons: list[str],
    stale: bool,
    platform: str,
    packaged_copy: dict[str, Any],
    cover: dict[str, Any],
    snapshot: dict[str, Any],
    review: dict[str, Any],
    safety: dict[str, Any],
) -> dict[str, Any]:
    reasons = list(source_reasons)
    if source_reasons:
        return {"status": "SOURCE_BLOCKED", "blocking_reasons": sorted(set(reasons)), "stale": stale}
    if not copy_is_ready(platform, packaged_copy):
        reasons.append("final_platform_copy_incomplete")
    cover_ready = cover.get("qa", {}).get("overall") == "pass" and bool(cover.get("composed_asset_path"))
    if not cover_ready:
        reasons.extend(cover.get("qa", {}).get("blocking_reasons") or ["cover_asset_not_ready"])
    semantic = review.get("cover_semantic_review") or {}
    semantic_ready = semantic.get("verdict") == "pass" and (semantic.get("evidence_source") != "human" or bool(semantic.get("approval_ref")))
    if not semantic_ready:
        reasons.append(f"cover_semantic_review_{semantic.get('verdict') or 'missing'}")
    if binding.get("final_qa_status") == "provisional":
        reasons.append("source_final_qa_provisional")
    if safety.get("fixture_only"):
        reasons.append("fixture_only_cannot_be_runtime_ready")
    if safety.get("shadow_only"):
        reasons.append("shadow_only_cannot_be_runtime_ready")
    if binding.get("cover_prompt_only"):
        reasons.append("final_media_missing_cover_prompt_only")
    if binding.get("final_qa_status") != "accepted" or safety.get("fixture_only") or safety.get("shadow_only"):
        return {"status": "PACKAGE_DRAFT", "blocking_reasons": sorted(set(reasons)), "stale": stale}
    if not copy_is_ready(platform, packaged_copy):
        return {"status": "PACKAGE_DRAFT", "blocking_reasons": sorted(set(reasons)), "stale": stale}
    if not cover_ready:
        return {"status": "COPY_READY", "blocking_reasons": sorted(set(reasons)), "stale": stale}
    review_block = snapshot.get("critical_rules_status") != "current" or review.get("compliance_status") in {"HOLD", "UNKNOWN"} or review.get("promise_match") != "pass" or not semantic_ready
    if review_block:
        reasons.append("package_review_or_profile_hold")
        return {"status": "REVIEW_HOLD", "blocking_reasons": sorted(set(reasons)), "stale": stale}
    if stale:
        reasons.append("binding_stale")
        return {"status": "REVIEW_HOLD", "blocking_reasons": sorted(set(reasons)), "stale": True}
    return {"status": "READY_FOR_MANUAL_UPLOAD", "blocking_reasons": [], "stale": False}


def manual_checklist(platform: str, overlay: dict[str, Any], review: dict[str, Any]) -> list[str]:
    common = [
        "Open the selected platform manually and confirm the live UI/profile rules are still current.",
        "Select the checksum-bound media file and the package cover file; verify previews before any upload action.",
        "Paste the copy-ready text and verify title, body, Topics/Hashtags, and line breaks.",
        "Confirm rights, commercial relationship, AI/synthetic media, likeness, and other disclosure settings.",
        "Do not claim upload or publication until the platform returns independent evidence.",
    ]
    if platform == "douyin":
        common.insert(3, "Choose privacy/download settings and the AI declaration in the live Douyin UI; API scope remains not requested.")
    if platform == "xiaohongshu":
        common.insert(3, "Check the live Xiaohongshu cover crop and note/topic fields; no location or product is attached by V1.")
    if platform.startswith("youtube_"):
        common.insert(3, "Choose audience, synthetic media, paid placement, privacy, language, thumbnail, and optional playlist settings in YouTube Studio.")
    if review.get("compliance_status") == "WARN":
        common.append("Read and explicitly resolve every compliance warning before manual upload.")
    return common


def build_copy_ready_text(platform: str, packaged_copy: dict[str, Any]) -> str:
    lines = [packaged_copy.get("title_or_caption") or ""]
    if packaged_copy.get("body_or_description"):
        lines.extend(["", packaged_copy["body_or_description"]])
    tags = packaged_copy.get("hashtags") or packaged_copy.get("topics") or []
    if tags:
        lines.extend(["", " ".join(tag if tag.startswith("#") else f"#{tag}" for tag in tags)])
    return "\n".join(lines).strip()


def markdown_projection(package: dict[str, Any]) -> str:
    timing = package["timing"]
    lines = [
        "# Ready for Manual Upload",
        "",
        f"- Package ID: `{package['package_id']}`",
        f"- Platform: `{package['identity']['platform']}`",
        f"- Readiness: `{package['readiness']['status']}`",
        f"- Story Hook: `{package['titles']['story_hook']}`",
        f"- Platform Title: `{package['titles']['platform_title']}`",
        f"- Cover Title: `{package['titles']['cover_title']}`",
        f"- Cover Prompt: `{package['cover_prompt'].get('prompt_package_id')}` / `{package['cover_prompt'].get('readiness', {}).get('status')}`",
        f"- Source media: `{package['source_binding'].get('artifact_path')}`",
        f"- Source checksum: `{package['source_binding'].get('artifact_checksum_sha256')}`",
        f"- Cover: `{package['cover'].get('composed_asset_path')}`",
        f"- Cover checksum: `{package['cover'].get('composed_asset_checksum_sha256')}`",
        f"- Compliance: `{package['review']['compliance_status']}`",
        f"- Promise Match: `{package['review']['promise_match']}`",
        f"- Cover technical QA: `{package['cover'].get('qa', {}).get('overall')}`",
        f"- Cover semantic review: `{package['review'].get('cover_semantic_review', {}).get('verdict')}`",
        f"- Primary publish window: `{timing['primary_window']['start']}` to `{timing['primary_window']['end']}`",
        f"- Confidence: `{timing['confidence']}`",
        f"- Operational selection: `{timing.get('operational_selection')}` (`not best time`)",
        "",
        "## Copy-ready text",
        "",
        package["manual_upload"]["copy_ready_text"],
        "",
        "## Manual UI checklist",
        "",
    ]
    lines.extend(f"- {item}" for item in package["manual_upload"]["platform_ui_checklist"])
    lines.extend(["", "## Blocking reasons / unknowns", ""])
    blockers = package["readiness"]["blocking_reasons"] or ["none"]
    lines.extend(f"- {item}" for item in blockers)
    lines.extend(["", "This local projection is not upload, remote draft, scheduling, publication, approval, or performance evidence.", ""])
    return "\n".join(lines)


def notion_snapshot_body(package: dict[str, Any], attachment_status: str) -> str:
    prompt = package.get("cover_prompt") or {}
    cover = package.get("cover") or {}
    review = package.get("review") or {}
    timing = package.get("timing") or {}
    history = "none (CREATE candidate)"
    lines = [
        "## Publish Package Snapshot",
        "",
        "### Package",
        f"Package ID: `{package.get('package_id')}`  ",
        f"Version: `{package.get('package_version')}`  ",
        f"Hash: `{package.get('package_hash')}`  ",
        f"Generated At: `{package.get('generated_at')}`  ",
        f"Platform: `{package.get('identity', {}).get('platform')}`  ",
        f"Readiness: `{package.get('readiness', {}).get('status')}`",
        "",
        "### Source Binding",
        f"Artifact: `{package.get('source_binding', {}).get('artifact_path')}`  ",
        f"Artifact Hash: `{package.get('source_binding', {}).get('artifact_checksum_sha256')}`  ",
        f"Script / ADP / Manifest: `{package.get('source_binding', {}).get('frozen_script_hash')}` / `{package.get('source_binding', {}).get('adp_hash')}` / `{package.get('source_binding', {}).get('production_manifest_hash')}`  ",
        f"Current QA: `{package.get('source_binding', {}).get('final_qa_status')}`",
        "",
        "### 文案",
        f"Platform Title: {package.get('titles', {}).get('platform_title')}  ",
        f"Cover Title: {package.get('titles', {}).get('cover_title')}  ",
        f"Body: {package.get('copy', {}).get('body_or_description') or ''}  ",
        f"Topics / Hashtags: {', '.join(package.get('copy', {}).get('topics') or package.get('copy', {}).get('hashtags') or [])}",
        "",
        "### Cover Prompt",
        f"Prompt Package: `{prompt.get('prompt_package_id')}` / `{prompt.get('prompt_package_hash')}`  ",
        f"Reference Assets: `{len(prompt.get('reference_bindings') or [])}`  ",
        f"Executable Prompt: {prompt.get('executable_prompt') or 'BLOCKED'}  ",
        f"Negative Constraints: {', '.join((prompt.get('image_prompt_spec') or {}).get('negative_constraints') or [])}",
        "",
        "### 封面",
        f"Asset Path: `{cover.get('composed_asset_path')}`  ",
        f"Checksum: `{cover.get('composed_asset_checksum_sha256')}`  ",
        f"Dimensions: `{cover.get('width')}x{cover.get('height')}`  ",
        f"Source Provenance: `{cover.get('source_type')}`  ",
        f"Preview Attachment Status: `{attachment_status}`",
        "",
        "### 发布窗口",
        f"Primary: `{(timing.get('primary_window') or {}).get('start')}` to `{(timing.get('primary_window') or {}).get('end')}`  ",
        f"Alternate: `{(timing.get('alternate_test_window') or {}).get('start')}` to `{(timing.get('alternate_test_window') or {}).get('end')}`  ",
        f"Timezone / Confidence: `{timing.get('audience_timezone')}` / `{timing.get('confidence')}`  ",
        f"Unknowns: {', '.join(timing.get('unknowns') or [])}",
        "",
        "### Review & Gate",
        f"Technical QA: `{cover.get('qa', {}).get('overall')}`  ",
        f"Semantic Review: `{review.get('cover_semantic_review', {}).get('verdict')}`  ",
        f"Compliance / Promise Match: `{review.get('compliance_status')}` / `{review.get('promise_match')}`  ",
        f"Blocking Reasons: {', '.join(package.get('readiness', {}).get('blocking_reasons') or [])}",
        "",
        "### Manual Upload",
        "Checklist only. No upload, remote draft, scheduling, or publication is claimed.",
        "",
        "### Projection History",
        history,
    ]
    return "\n".join(lines)


def build_notion_projection(package: dict[str, Any], snapshot: dict[str, Any]) -> dict[str, Any]:
    identity = package.get("identity") or {}
    platform = identity.get("platform")
    project_id = identity.get("project_id")
    content_id = identity.get("content_id")
    projection_key = f"{project_id}:{content_id}:{platform}" if project_id and content_id and platform else None
    schema = snapshot.get("publishing_schema") or {}
    required_existing = {"Name": "title", "Platform": "select", "项目": "relation"}
    proposed_delta = {"阶段": "select", "投影键": "rich_text", "Package Hash": "rich_text", "准备状态": "select"}
    base_missing = [name for name, kind in required_existing.items() if schema.get(name) != kind]
    delta_missing = [name for name, kind in proposed_delta.items() if schema.get(name) != kind]
    rows = snapshot.get("publishing_rows") or []
    matches = [row for row in rows if projection_key and row.get("投影键") == projection_key]
    relation_url = (snapshot.get("target_project") or {}).get("url")
    platform_label = PLATFORM_LABELS.get(str(platform), str(platform))
    reasons: list[str] = []
    target_row = None
    if not projection_key:
        row_decision = "BLOCKED"
        reasons.append("projection_key_missing")
    elif len(matches) > 1:
        row_decision = "CONFLICT"
        reasons.append("duplicate_projection_key")
    elif len(matches) == 1:
        target_row = matches[0].get("url")
        row_project = matches[0].get("项目")
        row_platform = matches[0].get("Platform")
        if int(matches[0].get("snapshot_heading_count") or 0) > 1:
            row_decision = "CONFLICT"
            reasons.append("multiple_publish_package_snapshot_headings")
        elif (row_project and relation_url and relation_url not in str(row_project)) or (row_platform and row_platform != platform_label):
            row_decision = "CONFLICT"
            reasons.append("project_or_platform_relation_mismatch")
        elif normalize_hash(matches[0].get("Package Hash")) == normalize_hash(package.get("package_hash")):
            row_decision = "NO_CHANGE"
        else:
            row_decision = "UPDATE"
    else:
        row_decision = "CREATE"
    if base_missing:
        reasons.extend(f"required_live_property_invalid:{name}" for name in base_missing)
    if delta_missing:
        reasons.extend(f"approved_schema_delta_pending:{name}" for name in delta_missing)
    if any(row.get("simulated_readback_matches") is False for row in matches):
        reasons.append("simulated_readback_mismatch")
    if row_decision in {"BLOCKED", "CONFLICT"} or base_missing:
        execution_status = "HOLD"
    elif delta_missing or "simulated_readback_mismatch" in reasons:
        execution_status = "DEGRADED"
    elif row_decision == "NO_CHANGE":
        execution_status = "NO_CHANGE"
    else:
        execution_status = "CANDIDATE"
    local_binary_callable = bool((snapshot.get("attachment_capability") or {}).get("local_binary_upload_callable"))
    attachment_status = "candidate_not_uploaded" if local_binary_callable else "degraded_local_binary_upload_unavailable"
    snapshot_body = notion_snapshot_body(package, attachment_status)
    properties = {
        "Name": f"《雨停之前》｜{platform_label}｜发布准备",
        "Platform": platform_label,
        "项目": [relation_url] if relation_url else [],
        "阶段": "准备",
        "投影键": projection_key,
        "Package Hash": package.get("package_hash"),
        "准备状态": package.get("readiness", {}).get("status"),
    }
    return {
        "contract_version": "1.0", "projection_key": projection_key, "data_source_url": snapshot.get("publishing_data_source_url"),
        "schema_snapshot_hash": snapshot.get("snapshot_hash"), "schema_captured_at": snapshot.get("captured_at"), "proposed_schema_delta": proposed_delta,
        "missing_schema_delta": delta_missing, "row_decision": row_decision, "execution_status": execution_status, "blocking_reasons": sorted(set(reasons)),
        "target_row": target_row, "properties_candidate": properties, "page_body_snapshot": snapshot_body,
        "attachment": {"status": attachment_status, "local_path": package.get("cover", {}).get("composed_asset_path"), "checksum_sha256": package.get("cover", {}).get("composed_asset_checksum_sha256"), "dimensions": [package.get("cover", {}).get("width"), package.get("cover", {}).get("height")]},
        "source_package_path": package.get("package_path"), "source_package_hash": package.get("package_hash"),
        "external_action_audit": {"publish": 0, "remote_draft": 0, "paid_generation": 0, "notion_write": 0, "upload": 0, "browser_automation": 0},
    }


def notion_projection_markdown(result: dict[str, Any]) -> str:
    lines = [
        "# Notion Publish Package Projection Dry Run", "",
        f"- Live schema captured: `{result.get('captured_at')}`",
        f"- Data source: `{result.get('publishing_data_source_url')}`",
        "- Proposed schema delta: `阶段 (Select)`, `投影键 (Rich text)`, `Package Hash (Rich text)`, `准备状态 (Select)`.",
        "- Notion writes/uploads: `0 / 0`.", "",
    ]
    for item in result.get("projections") or []:
        props = item["properties_candidate"]
        lines.extend([
            f"## {props['Platform']} Preview", "",
            f"- Decision: `{item['row_decision']} candidate`",
            f"- Execution status: `{item['execution_status']}`",
            f"- Target row: `{item.get('target_row') or 'new row candidate; existing blank rows are not overwritten'}`",
            f"- Projection key: `{item.get('projection_key')}`",
            f"- Package Hash: `{item.get('source_package_hash')}`",
            f"- Attachment: `{item.get('attachment', {}).get('status')}`",
            f"- Blocking reasons: `{', '.join(item.get('blocking_reasons') or ['none'])}`", "",
            "### Properties candidate", "",
            "```json", json.dumps(props, ensure_ascii=False, indent=2), "```", "",
            item["page_body_snapshot"], "",
        ])
    lines.append("This is a local preview. It is not a Notion write, attachment upload, remote draft, publication, or visual approval.")
    return "\n".join(lines) + "\n"


def compile_one(
    input_data: dict[str, Any],
    input_path: Path,
    output_root: Path,
    profile_dir: Path,
    platform: str,
    as_of: dt.datetime,
) -> dict[str, Any]:
    profile = load_profile(platform, profile_dir)
    snapshot = evaluate_profile(profile, as_of)
    binding, source_reasons, stale = source_binding(input_data, input_path.parent)
    platform_dir = output_root / platform
    platform_dir.mkdir(parents=True, exist_ok=True)
    resolved = resolve_series_fields(input_data, platform, snapshot, input_path.parent)
    cover_source = choose_cover_source(input_data, binding, input_path.parent, platform_dir) if not source_reasons else {
        "source_type": "extracted_frame",
        "source_ref": "",
        "source_checksum_sha256": None,
        "attempts": [],
        "blocked_reason": "source_binding_blocked",
        "generation_authorization_ref": None,
    }
    cover = compose_cover(cover_source, resolved, platform, platform_dir)
    if cover.get("composed_asset_path"):
        cover["qa"] = cover_qa(cover, resolved, platform, input_data)
    prompt_request, prompt_blockers, prompt_warnings = build_cover_prompt_request(input_data, input_path.parent, platform, resolved, cover_source, binding)
    cover_prompt = compile_cover_prompt_package(prompt_request, prompt_blockers, prompt_warnings, platform_dir)
    packaged_copy = build_copy(input_data, platform, snapshot)
    account = select_account_profile(input_data, platform)
    overlay = build_overlay(platform, packaged_copy, cover, account, input_data)
    timing = build_publish_window(input_data, snapshot, as_of)
    review = compliance_and_performance(input_data, platform, snapshot, packaged_copy, cover, overlay)
    review["cover_semantic_review"] = cover_semantic_review(input_data, platform, cover)
    safety = {
        "fixture_only": bool((input_data.get("runtime_context") or {}).get("fixture_only")),
        "shadow_only": bool((input_data.get("runtime_context") or {}).get("shadow_only")),
        "external_actions_called": False,
        "paid_generation_called": False,
        "notion_write_called": False,
        "browser_automation_called": False,
    }
    state = readiness(binding, source_reasons, stale, platform, packaged_copy, cover, snapshot, review, safety)
    project = input_data.get("project") or {}
    package_id = f"PKG-{project.get('project_id','unknown')}-{project.get('content_id','unknown')}-{platform}-v1-2"
    package = {
        "schema_version": SCHEMA_VERSION,
        "package_id": package_id,
        "package_version": "1.2",
        "package_hash": None,
        "generated_at": iso(as_of),
        "identity": {
            "project_id": project.get("project_id"),
            "content_id": project.get("content_id"),
            "platform": platform,
            "account_or_channel_id": account.get("account_or_channel_id"),
            "locale": account.get("locale") or "zh-CN",
        },
        "source_binding": binding,
        "profile_snapshot": snapshot,
        "strategy": {
            "publish_goal": (input_data.get("publishing_context") or {}).get("publish_goal"),
            "audience": (input_data.get("content_core") or {}).get("audience"),
            "discovery_context": (input_data.get("content_core") or {}).get("search_intent"),
            "consumption_context": (input_data.get("content_core") or {}).get("audience_need"),
            "series_rule_source": resolved.get("source"),
            "series_field_sources": resolved.get("field_sources"),
            "legacy_hints_consumed": packaged_copy.get("legacy_hints_consumed"),
            "final_packaging_authority": "publishing_packaging",
            "cover_prompt_only": bool((input_data.get("execution_mode") or {}).get("cover_prompt_only")),
        },
        "titles": resolve_titles(input_data, platform),
        "cover_prompt": cover_prompt,
        "cover": cover,
        "copy": packaged_copy,
        "rights_and_disclosure": copy.deepcopy(input_data.get("rights_and_disclosure") or {}),
        "timing": timing,
        "review": review,
        "readiness": state,
        "manual_upload": {
            "media_path": binding.get("artifact_path"),
            "cover_path": cover.get("composed_asset_path") or "",
            "copy_ready_text": build_copy_ready_text(platform, packaged_copy),
            "platform_ui_checklist": manual_checklist(platform, overlay, review),
        },
        "platform_overlay": overlay,
        "safety": safety,
    }
    package["package_hash"] = compute_package_hash(package)
    package_path = platform_dir / "publish-package.json"
    write_json(package_path, package)
    projection_path = platform_dir / "ready-for-manual-upload.md"
    projection_path.write_text(markdown_projection(package), encoding="utf-8")
    package["package_path"] = str(package_path.resolve())
    package["projection_path"] = str(projection_path.resolve())
    return package


def validate_package(package: dict[str, Any]) -> dict[str, Any]:
    errors: list[str] = []
    if package.get("schema_version") not in {"1.1", SCHEMA_VERSION}:
        errors.append("schema_version_invalid")
    platform = (package.get("identity") or {}).get("platform")
    if platform not in SUPPORTED_PLATFORMS:
        errors.append("platform_invalid")
    expected_hash = compute_package_hash(package)
    if normalize_hash(package.get("package_hash")) != expected_hash:
        errors.append("package_hash_mismatch")
    binding = package.get("source_binding") or {}
    media_path = Path(binding.get("artifact_path") or "")
    if media_path.is_file():
        if sha256_file(media_path) != normalize_hash(binding.get("artifact_checksum_sha256")):
            errors.append("source_checksum_readback_failed")
    elif package.get("readiness", {}).get("status") != "SOURCE_BLOCKED":
        if not (package.get("strategy") or {}).get("cover_prompt_only") or package.get("readiness", {}).get("status") != "PACKAGE_DRAFT":
            errors.append("source_file_missing_but_state_not_source_blocked")
    cover = package.get("cover") or {}
    cover_path = Path(cover.get("composed_asset_path") or "")
    if cover.get("composed_asset_path"):
        if not cover_path.is_file() or sha256_file(cover_path) != normalize_hash(cover.get("composed_asset_checksum_sha256")):
            errors.append("cover_checksum_readback_failed")
    allowed_overlays = {
        "xiaohongshu": {"xiaohongshu_overlay"},
        "douyin": {"douyin_overlay"},
        "youtube_shorts": {"youtube_base_overlay", "youtube_shorts_overlay"},
        "youtube_long": {"youtube_base_overlay", "youtube_long_overlay"},
    }
    if platform in allowed_overlays and set((package.get("platform_overlay") or {}).keys()) != allowed_overlays[platform]:
        errors.append("platform_overlay_cross_contamination_or_missing")
    safety = package.get("safety") or {}
    for key in ("external_actions_called", "paid_generation_called", "notion_write_called", "browser_automation_called"):
        if safety.get(key) is not False:
            errors.append(f"safety_flag_invalid:{key}")
    status = (package.get("readiness") or {}).get("status")
    if status == "READY_FOR_MANUAL_UPLOAD":
        if safety.get("fixture_only") or safety.get("shadow_only"):
            errors.append("fixture_or_shadow_claimed_ready")
        if binding.get("final_qa_status") != "accepted":
            errors.append("nonaccepted_source_claimed_ready")
        if not media_path.is_file() or not cover_path.is_file():
            errors.append("ready_missing_actual_media_or_cover")
        if cover.get("qa", {}).get("overall") != "pass":
            errors.append("ready_cover_qa_not_passed")
        if package.get("schema_version") == SCHEMA_VERSION:
            semantic = (package.get("review") or {}).get("cover_semantic_review") or {}
            if semantic.get("verdict") != "pass" or (semantic.get("evidence_source") == "human" and not semantic.get("approval_ref")):
                errors.append("ready_cover_semantic_review_not_passed")
        if package.get("profile_snapshot", {}).get("critical_rules_status") != "current":
            errors.append("ready_profile_not_current")
        if package.get("review", {}).get("compliance_status") not in {"PASS", "WARN"}:
            errors.append("ready_compliance_not_pass_warn")
        if package.get("review", {}).get("promise_match") != "pass":
            errors.append("ready_promise_not_pass")
    if safety.get("fixture_only") and status == "READY_FOR_MANUAL_UPLOAD":
        errors.append("fixture_ready_forbidden")
    timing = package.get("timing") or {}
    if not timing.get("primary_window") or timing.get("confidence") not in {"high", "medium", "low", "unknown"}:
        errors.append("publish_window_contract_invalid")
    if "best" in str(timing.get("operational_selection_label") or "").lower() and "not_best" not in str(timing.get("operational_selection_label") or "").lower():
        errors.append("best_time_claim_forbidden")
    return {"package_id": package.get("package_id"), "platform": platform, "status": status, "valid": not errors, "errors": errors}


def command_compile(args: argparse.Namespace) -> int:
    input_path = Path(args.input).resolve()
    output_root = Path(args.output).resolve()
    profile_dir = Path(args.profiles).resolve()
    input_data = read_json(input_path)
    targets = (input_data.get("publishing_context") or {}).get("target_platforms") or []
    if not targets:
        summary = {"schema_version": SCHEMA_VERSION, "status": "BLOCKED", "next_action": "ask_user", "blocking_reasons": ["target_platforms_missing"], "packages": [], "external_action_audit": {"publish": 0, "remote_draft": 0, "paid_generation": 0, "notion_write": 0, "browser_automation": 0}}
        write_json(output_root / "index.json", summary)
        print(json.dumps(summary, ensure_ascii=False))
        return 2
    invalid = [platform for platform in targets if platform not in SUPPORTED_PLATFORMS]
    if invalid:
        raise CompileError(f"Unsupported target platforms: {invalid}")
    unique_targets = list(dict.fromkeys(targets))
    as_of = parse_datetime((input_data.get("runtime_context") or {}).get("as_of"))
    packages = [compile_one(input_data, input_path, output_root, profile_dir, platform, as_of) for platform in unique_targets]
    validation = [validate_package(package) for package in packages]
    summary = {
        "schema_version": SCHEMA_VERSION,
        "status": "compiled",
        "selected_platforms": unique_targets,
        "generated_platforms": [package["identity"]["platform"] for package in packages],
        "packages": [{"platform": package["identity"]["platform"], "status": package["readiness"]["status"], "package_path": package["package_path"], "cover_path": package["cover"].get("composed_asset_path"), "package_hash": package["package_hash"]} for package in packages],
        "validation": validation,
        "external_action_audit": {"publish": 0, "remote_draft": 0, "paid_generation": 0, "notion_write": 0, "browser_automation": 0},
    }
    write_json(output_root / "index.json", summary)
    print(json.dumps(summary, ensure_ascii=False))
    return 0 if all(item["valid"] for item in validation) else 1


def command_validate(args: argparse.Namespace) -> int:
    target = Path(args.path).resolve()
    package_paths = [target] if target.is_file() else sorted(target.glob("*/publish-package.json"))
    if not package_paths:
        raise CompileError("No publish-package.json files found")
    results = [validate_package(read_json(path)) for path in package_paths]
    summary = {"valid": all(result["valid"] for result in results), "packages": results}
    print(json.dumps(summary, ensure_ascii=False))
    if args.report:
        write_json(Path(args.report).resolve(), summary)
    return 0 if summary["valid"] else 1


def command_project_notion(args: argparse.Namespace) -> int:
    package_root = Path(args.package_root).resolve()
    snapshot_path = Path(args.snapshot).resolve()
    output_root = Path(args.output).resolve()
    snapshot = read_json(snapshot_path)
    snapshot_payload = {key: value for key, value in snapshot.items() if key != "snapshot_hash"}
    observed_snapshot_hash = sha256_bytes(canonical_json(snapshot_payload))
    declared_snapshot_hash = normalize_hash(snapshot.get("snapshot_hash"))
    if declared_snapshot_hash and declared_snapshot_hash != observed_snapshot_hash:
        raise CompileError("Live Notion snapshot hash mismatch")
    snapshot["snapshot_hash"] = observed_snapshot_hash
    package_paths = sorted(package_root.glob("*/publish-package.json"))
    if not package_paths:
        raise CompileError("No publish-package.json files found for Notion projection")
    projections = []
    for path in package_paths:
        package = read_json(path)
        package["package_path"] = str(path.resolve())
        projections.append(build_notion_projection(package, snapshot))
    result = {
        "contract_version": "1.0", "captured_at": snapshot.get("captured_at"), "publishing_data_source_url": snapshot.get("publishing_data_source_url"),
        "snapshot_hash": observed_snapshot_hash, "projection_count": len(projections), "projections": projections,
        "external_action_audit": {"notion_read_snapshot_used": 1, "notion_write": 0, "publish": 0, "remote_draft": 0, "paid_generation": 0, "upload": 0, "browser_automation": 0},
    }
    output_root.mkdir(parents=True, exist_ok=True)
    write_json(output_root / "notion-projection.json", result)
    (output_root / "notion-projection-preview.md").write_text(notion_projection_markdown(result), encoding="utf-8")
    print(json.dumps({"status": "dry_run", "projection_count": len(projections), "output": str(output_root), "notion_write": 0}, ensure_ascii=False))
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Local-only Publishing & Packaging v1.2 runtime")
    subparsers = parser.add_subparsers(dest="command", required=True)
    compile_parser = subparsers.add_parser("compile")
    compile_parser.add_argument("--input", required=True)
    compile_parser.add_argument("--output", required=True)
    compile_parser.add_argument("--profiles", required=True)
    compile_parser.set_defaults(handler=command_compile)
    validate_parser = subparsers.add_parser("validate")
    validate_parser.add_argument("--path", required=True)
    validate_parser.add_argument("--report")
    validate_parser.set_defaults(handler=command_validate)
    notion_parser = subparsers.add_parser("project-notion")
    notion_parser.add_argument("--package-root", required=True)
    notion_parser.add_argument("--snapshot", required=True)
    notion_parser.add_argument("--output", required=True)
    notion_parser.set_defaults(handler=command_project_notion)
    return parser


def main() -> int:
    args = build_parser().parse_args()
    try:
        return int(args.handler(args))
    except (CompileError, ValueError, OSError, json.JSONDecodeError) as error:
        print(json.dumps({"status": "error", "error": str(error)}, ensure_ascii=False), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
