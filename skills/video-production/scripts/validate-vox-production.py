"""Read-only mechanical preflight for managed VOX Poster production.

The existing Production Manifest owns Shot, Asset and QA records. This tool
does not create approvals, reviews, retries, media, or a second state file.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET

from PIL import Image


class Blocked(Exception):
    pass


def require(condition: bool, message: str) -> None:
    if not condition:
        raise Blocked(message)


def fingerprint(value: object) -> str:
    payload = json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(payload.encode("utf-8")).hexdigest()


def read_media(record: dict, *, alpha: bool = False) -> tuple[Path, str, tuple[int, int]]:
    media = record.get("media_ref") or {}
    path_text = media.get("path")
    require(isinstance(path_text, str) and path_text and "latest" not in path_text.lower(), "Exact media path is required; latest is not a revision.")
    path = Path(path_text)
    require(path.is_absolute() and path.is_file(), f"Media file is missing: {path}")
    expected = media.get("sha256")
    actual = hashlib.sha256(path.read_bytes()).hexdigest()
    require(isinstance(expected, str) and actual.lower() == expected.lower(), f"Media checksum mismatch: {path}")
    require(bool(media.get("revision_id")), f"Media revision is missing: {path}")
    if path.suffix.lower() == ".svg":
        try:
            root = ET.parse(path).getroot()
            require(root.tag.endswith("svg"), f"Invalid SVG root: {path}")
            view_box = root.attrib.get("viewBox", "").replace(",", " ").split()
            require(len(view_box) == 4 and float(view_box[2]) > 0 and float(view_box[3]) > 0,
                    f"SVG requires explicit positive viewBox: {path}")
            return path, actual, (int(float(view_box[2])), int(float(view_box[3])))
        except (ET.ParseError, ValueError) as exc:
            raise Blocked(f"SVG cannot be decoded: {path}: {exc}") from exc
    try:
        with Image.open(path) as image:
            image.load()
            size = image.size
            if alpha:
                require("A" in image.getbands() or "transparency" in image.info, f"Overlay has no Alpha channel: {path}")
                rgba = image.convert("RGBA")
                lo, hi = rgba.getchannel("A").getextrema()
                require(lo < 255 and hi > 0, f"Overlay lacks both transparent and visible pixels: {path}")
                box = rgba.getchannel("A").getbbox()
                require(box is not None, f"Overlay is empty: {path}")
                content = (box[2] - box[0], box[3] - box[1])
                needed = record.get("required_effective_px") or {}
                if needed:
                    require(content[0] >= needed.get("width", 0) and content[1] >= needed.get("height", 0),
                            f"Visible content pixels are insufficient: {path}")
    except (OSError, ValueError) as exc:
        raise Blocked(f"Media cannot be decoded: {path}: {exc}") from exc
    return path, actual, size


def review_by_id(manifest: dict, review_id: str, checksum: str | None = None,
                 checks: tuple[str, ...] = (), revision_id: str | None = None) -> dict:
    results = (manifest.get("qa") or {}).get("results") or []
    matches = [value for row in results if isinstance(row, dict)
               for value in [row.get("review_result") or row]
               if isinstance(value, dict) and value.get("review_id") == review_id]
    require(len(matches) == 1, f"Unique current Review is required: {review_id}")
    review = matches[0]
    require(review.get("decision", {}).get("verdict") == "PASS", f"Review is not PASS: {review_id}")
    require(not review.get("provenance", {}).get("fixture_only", True), f"Fixture Review cannot approve: {review_id}")
    if checks:
        require(review.get("schema_version") == "2.2" and
                review.get("controller_mapping", {}).get("verdict") == "pass" and
                review.get("decision", {}).get("generation_gate_recommendation") == "withhold" and
                review.get("target", {}).get("target_type") == "vox_poster_shot",
                f"Current managed VOX v2.2 Review is required: {review_id}")
        dependencies = (review.get("lineage") or {}).get("dependency_hashes") or {}
        require(all(isinstance(dependencies.get(key), str) and bool(dependencies[key])
                    for key in ("frozen_script", "audiovisual_direction_package",
                                "production_manifest", "poster_shot_map", "poster_media")),
                f"Current VOX Review is missing required dependencies: {review_id}")
    if checksum:
        require(review.get("target", {}).get("media_checksum", "").lower() == checksum.lower(),
                f"Review target checksum is stale: {review_id}")
        if checks:
            require(review.get("lineage", {}).get("dependency_hashes", {}).get("poster_media", "").lower() == checksum.lower(),
                    f"Review Poster dependency is stale: {review_id}")
    if revision_id:
        require(review.get("target", {}).get("revision_id") == revision_id,
                f"Review target revision is stale: {review_id}")
    findings = review.get("findings") or []
    require(not any(f.get("severity") == "must_fix" and
                    (f.get("resolution") != "resolved" or f.get("check_result") != "pass") for f in findings),
            f"Review has unresolved must_fix: {review_id}")
    for check in checks:
        matched = [f for f in findings if f.get("check_id") == check]
        require(len(matched) == 1 and matched[0].get("check_result") == "pass" and
                matched[0].get("confidence") == "high" and bool(matched[0].get("evidence")),
                f"Current Review lacks required check {check}: {review_id}")
    return review


def find_shot(manifest: dict, shot_id: str) -> dict:
    shots: list[dict] = []
    for scene in manifest.get("scenes") or []:
        shots.extend(scene.get("shots") or [])
        if scene.get("local_assembly_plan"):
            shots.append(scene)
    shots.extend(manifest.get("shots") or [])
    matches = [s for s in shots if (s.get("local_assembly_plan") or {}).get("poster_shot_id") == shot_id]
    require(len(matches) == 1, f"Unique Poster Shot is required: {shot_id}")
    return matches[0]


def find_asset(manifest: dict, asset_id: str, shot_id: str) -> dict:
    matches = [a for a in manifest.get("assets") or [] if a.get("asset_id") == asset_id]
    require(len(matches) == 1, f"Unique Asset is required: {asset_id}")
    asset = matches[0]
    require(shot_id in (asset.get("used_by_poster_shots") or []), f"Asset is not bound to Poster Shot {shot_id}: {asset_id}")
    return asset


def request_evidence(asset: dict, design: dict) -> None:
    require(bool(design.get("layout_intent", {}).get("reading_path")) and
            bool(design.get("layout_intent", {}).get("text_region")) and
            bool(design.get("layout_intent", {}).get("independent_groups")),
            "Layout, text region, and independent-group intent are required before image requests.")
    evidence = asset.get("request_evidence") or {}
    search = evidence.get("reuse_search") or {}
    require(search.get("status") in ("complete", "bounded_complete") and bool(search.get("scope")) and
            isinstance(search.get("candidates"), list) and bool(search.get("remaining_gap")),
            "Bounded reuse search and real gap are required before an image request.")
    require(bool(evidence.get("authorization_ref")), "A concrete request authorization reference is required.")
    route = asset.get("implementation_route")
    if route == "temporary_atlas":
        require(asset.get("design_role") in ("decoration", "graphic"),
                "Critical design assets use one independent asset by default.")
        needed = asset.get("required_effective_px") or {}
        planned = (asset.get("atlas_plan") or {}).get("estimated_cell_content_px") or {}
        require(needed.get("width", 0) > 0 and needed.get("height", 0) > 0 and
                planned.get("width", 0) >= needed["width"] and planned.get("height", 0) >= needed["height"],
                "Atlas cell estimate does not cover the element's maximum effective-pixel need.")
    else:
        require(route == "generated_asset", "Reuse or local assembly is the selected route; no new image request.")


def poster_inputs(manifest: dict, shot_id: str, design: dict) -> tuple[dict, list[dict], str]:
    base_id = design.get("base_asset_id")
    require(bool(base_id), "Base asset is not bound.")
    base = find_asset(manifest, base_id, shot_id)
    _, base_hash, _ = read_media(base)
    base_qa = base.get("qa") or {}
    if design.get("existing_approved_whole") is True:
        require(not design.get("overlay_asset_ids"), "An approved whole Poster cannot silently acquire new overlays.")
        review_by_id(manifest, (design.get("review_refs") or {}).get("poster"), base_hash,
                     ("visual_quality", "poster_readiness"), (base.get("media_ref") or {}).get("revision_id"))
    else:
        require(base_qa.get("suitability") == "approved" and bool(base_qa.get("evidence_refs")),
                "Base suitability evidence is required; a base is not a complete Poster approval.")
    overlays = []
    for asset_id in design.get("overlay_asset_ids") or []:
        item = find_asset(manifest, asset_id, shot_id)
        _, digest, _ = read_media(item, alpha=True)
        role = item.get("design_role")
        if role == "critical_typography":
            require(item.get("critical_text", {}).get("realization") in ("verified_typography_svg", "verified_typography_png") and
                    bool(item.get("critical_text", {}).get("verification_ref")),
                    f"Critical design typography remains a candidate: {asset_id}")
        if role == "route_texture":
            registration = item.get("route_registration") or {}
            if registration.get("motion_use") != "whole_group":
                require(bool(registration.get("path_ref")) and
                        registration.get("texture_sha256", "").lower() == digest.lower() and
                        registration.get("layout_hash") == fingerprint(design["layout"]),
                        f"Route texture needs a current same-layout registered path or mask: {asset_id}")
        overlays.append({"id": asset_id, "hash": digest, "role": role})
    require(bool(design.get("layout")) and bool(design.get("renderer_ref")), "Exact layout and renderer reference are required.")
    inputs_hash = fingerprint({"base": {"id": base_id, "hash": base_hash}, "overlays": overlays,
                               "layout": design["layout"], "renderer": design["renderer_ref"]})
    return base, overlays, inputs_hash


def validate(manifest: dict, shot_id: str, action: str, asset_id: str | None, output: str | None) -> dict:
    shot = find_shot(manifest, shot_id)
    plan = shot.get("local_assembly_plan") or {}
    require(isinstance(plan.get("source_beat_id"), str) and bool(plan["source_beat_id"]),
            "Each Poster Shot retains one scalar source_beat_id.")
    spec = plan.get("poster_spec") or {}
    design = spec.get("production_design") or {}
    require(spec.get("pilot_design_route") in ("hero_key_art", "production_reconstructable"),
            "Pilot route must be selected before a new design request.")
    if action in ("request_base", "request_overlay"):
        require(bool(asset_id), "Asset ID is required for image-request preflight.")
        asset = find_asset(manifest, asset_id, shot_id)
        request_evidence(asset, design)
        if action == "request_base":
            require(asset.get("design_role") == "base_scene", "Base request must target a base scene.")
        else:
            require(asset.get("design_role") in ("critical_typography", "route_texture", "frame", "decoration", "graphic"),
                    "Overlay request needs an explicit independent design role.")
            base = find_asset(manifest, design.get("base_asset_id"), shot_id)
            read_media(base)
            require(base.get("qa", {}).get("suitability") == "approved" and
                    bool(base.get("qa", {}).get("evidence_refs")), "Base suitability must be confirmed before overlay request.")
            require(bool(asset.get("planned_layout")) and bool(asset.get("required_effective_px")),
                    "Overlay needs planned layout and effective content-pixel requirement.")
            if asset.get("design_role") == "critical_typography":
                require(bool(asset.get("critical_text", {}).get("exact_text")), "Exact critical text is required.")
        return {"eligible": True, "action": action, "poster_shot_id": shot_id, "asset_id": asset_id}

    base, overlays, input_hash = poster_inputs(manifest, shot_id, design)
    if action == "compose_preview":
        require(spec["pilot_design_route"] == "production_reconstructable", "Hero may keep a whole approved source.")
        return {"eligible": True, "action": action, "poster_shot_id": shot_id, "input_hash": input_hash,
                "renderer_ref": design["renderer_ref"]}

    preview = design.get("preview_asset_ref") or {}
    require(preview.get("input_hash") == input_hash, "Preview inputs changed or were not deterministically bound.")
    preview_asset = find_asset(manifest, preview.get("asset_id"), shot_id)
    _, preview_hash, _ = read_media(preview_asset)
    require(preview.get("sha256", "").lower() == preview_hash.lower(), "Preview checksum does not match its bound asset.")
    review_refs = design.get("review_refs") or {}
    poster_checks = ("visual_quality", "poster_readiness")
    if spec["pilot_design_route"] == "production_reconstructable":
        poster_checks += ("typography_split_test", "context_separation_test",
                          "decorative_independence_test", "rectangle_risk_test", "motion_sequence_test")
    review_by_id(manifest, review_refs.get("poster"), preview_hash, poster_checks,
                 (preview_asset.get("media_ref") or {}).get("revision_id"))
    if action == "plan_motion":
        return {"eligible": True, "action": action, "poster_shot_id": shot_id, "input_hash": input_hash}

    preplan = design.get("motion_preplan") or {}
    require(bool(preplan.get("narration_range")) and bool(preplan.get("attention_targets")) and
            bool(preplan.get("exposure_bounds")), "Detailed motion preplan is required after complete Poster approval.")
    if action == "render":
        require(bool(plan.get("motion_plan")) and bool(design.get("output_geometry")),
                "Formal Motion needs an actual motion plan and output geometry.")
        geometry = design["output_geometry"]
        require(all(isinstance(geometry.get(key), int) and geometry[key] > 0
                    for key in ("width", "height", "fps")) and
                geometry["width"] % 2 == 0 and geometry["height"] % 2 == 0,
                "Formal render needs positive even dimensions and integer fps.")
        audio = ((manifest.get("audio_production") or {}).get("final_narration_master") or {})
        audio_path = Path(audio.get("path") or "")
        require(audio_path.is_absolute() and audio_path.is_file() and bool(audio.get("revision_id")) and
                bool(audio.get("sha256")) and float(audio.get("duration_seconds") or 0) > 0,
                "Confirmed read-only Master Audio path, revision, checksum and duration are required.")
        audio_hash = hashlib.sha256(audio_path.read_bytes()).hexdigest()
        require(audio_hash.lower() == audio["sha256"].lower(), "Master Audio changed.")
        interval = preplan["narration_range"]
        require(isinstance(interval, list) and len(interval) == 2 and
                0 <= interval[0] < interval[1] <= float(audio["duration_seconds"]),
                "Motion narration interval must remain inside the confirmed Master Audio.")
        static_ref = review_refs.get("static")
        if static_ref:
            review_by_id(manifest, static_ref, preview_hash,
                         ("static_reconstruction", "pre_entry_exposure", "handoff_exposure", "extreme_exposure"),
                         (preview_asset.get("media_ref") or {}).get("revision_id"))
        else:
            require(spec.get("decomposition_decision") == "keep_whole" and
                    bool(design.get("static_not_applicable_ref")) and
                    preplan.get("exposure_bounds") == "none" and
                    design.get("layout_change") is False,
                    "Current static and exposure Review is required unless an unchanged whole Poster has an evidenced exemption.")
        require(design.get("render_input_hash") == fingerprint({"preview": input_hash, "motion": plan["motion_plan"],
                                                                "preplan": preplan, "geometry": geometry,
                                                                "audio": {"revision_id": audio["revision_id"], "sha256": audio_hash}}),
                "Formal render inputs changed; static Review scope must be refreshed.")
        return {"eligible": True, "action": action, "poster_shot_id": shot_id,
                "render_input_hash": design["render_input_hash"]}

    require(action == "intake" and bool(output), "Output path is required for managed intake.")
    current_render = validate(manifest, shot_id, "render", None, None)
    report = design.get("render_report") or {}
    require(report.get("input_hash") == current_render["render_input_hash"],
            "Render output lacks current input fingerprint.")
    path = Path(output)
    require(path.is_absolute() and path.is_file(), "Exact rendered output is missing.")
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    require(report.get("media_sha256", "").lower() == digest.lower(), "Rendered output checksum is unbound or stale.")
    ffprobe = shutil.which("ffprobe")
    require(bool(ffprobe), "ffprobe is required to inspect a managed rendered output.")
    probe = subprocess.run([ffprobe, "-v", "error", "-show_entries", "format=duration",
                            "-of", "json", str(path)], capture_output=True, text=True, check=False)
    require(probe.returncode == 0, f"Rendered output cannot be probed: {path}")
    try:
        duration = float(json.loads(probe.stdout)["format"]["duration"])
    except (KeyError, TypeError, ValueError, json.JSONDecodeError) as exc:
        raise Blocked(f"Rendered output duration cannot be read: {path}") from exc
    require(duration > 0, "Rendered output duration must be positive.")
    require(bool(report.get("technical_review_ref")) and bool(report.get("continuous_viewing_ref")),
            "Technical QA and continuous-viewing evidence are both required for adoption.")
    review_by_id(manifest, report["technical_review_ref"], digest)
    viewing = review_by_id(manifest, report["continuous_viewing_ref"], digest)
    viewed = [finding for finding in viewing.get("findings") or []
              if finding.get("check_id") == "continuous_viewing"]
    require(len(viewed) == 1 and viewed[0].get("check_result") == "pass" and
            viewed[0].get("confidence") == "high" and bool(viewed[0].get("evidence")),
            "Current exact-output continuous-viewing Review is required for adoption.")
    return {"eligible": True, "action": action, "poster_shot_id": shot_id, "media_sha256": digest}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--shot-id", required=True)
    parser.add_argument("--action", choices=("request_base", "request_overlay", "compose_preview",
                                              "plan_motion", "render", "intake"), required=True)
    parser.add_argument("--asset-id")
    parser.add_argument("--output")
    args = parser.parse_args()
    try:
        require(args.manifest.is_file(), f"Production Manifest is missing: {args.manifest}")
        document = json.loads(args.manifest.read_text(encoding="utf-8-sig"))
        manifest = document.get("production_manifest", document)
        require(not manifest.get("fixture_only", False), "Fixture Manifest cannot authorize production.")
        result = validate(manifest, args.shot_id, args.action, args.asset_id, args.output)
        print(json.dumps(result, ensure_ascii=False))
        return 0
    except (Blocked, OSError, ValueError, KeyError, TypeError) as exc:
        print(json.dumps({"eligible": False, "reason": str(exc)}, ensure_ascii=False), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
