from __future__ import annotations

import argparse
import json
import os
import shutil
import sys
import tempfile
import traceback
from pathlib import Path
from typing import Any

from annotation import ContractError, canonical_hash, sha256_file, validate_annotation, validate_job
from encode import EncodeError, encode_h264, merge_homogeneous
from preview import create_preview
from render import RegionRenderer, RenderCancelled, read_image, write_mp4v

RENDERER_VERSION = "0.1.0"


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def save_report(report: dict[str, Any], path: Path | None) -> None:
    # ASCII-safe stdout avoids Windows console-codepage corruption of machine paths.
    payload = json.dumps(report, ensure_ascii=True, sort_keys=True)
    if path:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(payload + "\n", encoding="utf-8")
    print(payload)


def validate_files(job: dict[str, Any], job_path: Path) -> tuple[dict[str, Any], dict[str, Any], Path, Path]:
    annotation_path = Path(job["annotation"]["path"])
    source_path = Path(job["source_image"]["path"])
    if not annotation_path.is_absolute():
        annotation_path = (job_path.parent / annotation_path).resolve()
    if not source_path.is_absolute():
        source_path = (job_path.parent / source_path).resolve()
    if not annotation_path.is_file() or not source_path.is_file():
        raise ContractError("missing_input", "source image and annotation paths must exist")
    annotation = validate_annotation(load_json(annotation_path))
    value = validate_job(job, annotation)
    if sha256_file(source_path).lower() != value["source_image"]["sha256"].lower():
        raise ContractError("source_hash_mismatch", "source image checksum does not match", "source_image.sha256")
    if sha256_file(annotation_path).lower() != value["annotation"]["sha256"].lower():
        raise ContractError("annotation_hash_mismatch", "annotation checksum does not match", "annotation.sha256")
    return value, annotation, source_path, annotation_path


def render_job(job_path: Path, report_path: Path | None, force_ffmpeg_failure: bool, force_pyav_failure: bool, cancel_file: Path | None = None) -> dict[str, Any]:
    import cv2

    raw_job = load_json(job_path)
    job, annotation, source_path, annotation_path = validate_files(raw_job, job_path)
    image = read_image(source_path, cv2.IMREAD_COLOR)
    if image is None:
        raise ContractError("unreadable_source", f"cannot decode source image: {source_path}")
    renderer = RegionRenderer(image, annotation, job)
    coverage = renderer.coverage_facts()
    if coverage["uncovered_ink_pixels"] and not annotation["allow_uncovered_ink"]:
        raise ContractError("uncovered_ink", f"{coverage['uncovered_ink_pixels']} ink pixels are outside all approved regions", "allow_uncovered_ink")
    frames, render_facts = renderer.render_frames(lambda: bool(cancel_file and cancel_file.exists()))
    output = Path(job["output_path"])
    if not output.is_absolute():
        output = (job_path.parent / output).resolve()
    raw_dir = Path(tempfile.mkdtemp(prefix="region-stream-ink-raw-"))
    raw_output = raw_dir / "visual_track.mp4v.tmp.mp4"
    write_mp4v(frames, raw_output, job["timing"]["frame_rate"], job["output_spec"]["width_px"], job["output_spec"]["height_px"])
    succeeded = False
    try:
        encoder, media_facts, attempts = encode_h264(raw_output, output, job["output_spec"]["width_px"], job["output_spec"]["height_px"], job["timing"]["frame_rate"], job["timing"]["scene_duration_frames"], force_ffmpeg_failure=force_ffmpeg_failure, force_pyav_failure=force_pyav_failure)
        succeeded = True
    except Exception:
        diagnostic = output.with_name(output.stem + ".mp4v.failed.mp4")
        diagnostic.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(raw_output, diagnostic)
        if isinstance(sys.exc_info()[1], EncodeError):
            sys.exc_info()[1].attempts.append({"intermediate_mp4v": str(diagnostic), "status": "retained_for_encoding_diagnosis"})
        raise
    finally:
        if succeeded:
            shutil.rmtree(raw_dir, ignore_errors=True)
    input_binding = {"job": job, "source_sha256": sha256_file(source_path), "annotation_sha256": sha256_file(annotation_path), "renderer_version": RENDERER_VERSION}
    report = {
        "contract_version": "1.0",
        "status": "success",
        "renderer_version": RENDERER_VERSION,
        "adapter_id": "region_stream_ink",
        "job_id": job["job_id"],
        "revision_id": job["revision_id"],
        "clip_id": job["clip_id"],
        "input_hash": canonical_hash(input_binding),
        "source_image_sha256": input_binding["source_sha256"],
        "annotation_sha256": input_binding["annotation_sha256"],
        "output_path": str(output),
        "output_sha256": sha256_file(output),
        "encoding": {"selected": encoder, "attempts": attempts},
        "media_facts": media_facts,
        "render_facts": render_facts,
        "external_audio_sync": "not_verified",
        "claims_not_made": ["approval", "qa_pass", "retry_state", "human_acceptance", "publication"],
    }
    save_report(report, report_path)
    return report


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Region Stream Ink local renderer")
    sub = parser.add_subparsers(dest="command", required=True)
    render_parser = sub.add_parser("render")
    render_parser.add_argument("--job", required=True, type=Path)
    render_parser.add_argument("--report", type=Path)
    render_parser.add_argument("--force-ffmpeg-failure", action="store_true", help=argparse.SUPPRESS)
    render_parser.add_argument("--force-pyav-failure", action="store_true", help=argparse.SUPPRESS)
    render_parser.add_argument("--cancel-file", type=Path, help="Cancel safely when this file exists")
    validate_parser = sub.add_parser("validate")
    validate_parser.add_argument("--job", required=True, type=Path)
    preview_parser = sub.add_parser("preview")
    preview_parser.add_argument("--job", required=True, type=Path)
    preview_parser.add_argument("--output", required=True, type=Path)
    merge_parser = sub.add_parser("merge")
    merge_parser.add_argument("--inputs", nargs="+", required=True, type=Path)
    merge_parser.add_argument("--output", required=True, type=Path)
    merge_parser.add_argument("--report", type=Path)
    merge_parser.add_argument("--force-ffmpeg-failure", action="store_true", help=argparse.SUPPRESS)
    merge_parser.add_argument("--force-pyav-failure", action="store_true", help=argparse.SUPPRESS)
    args = parser.parse_args(argv)
    try:
        if args.command == "render":
            render_job(args.job.resolve(), args.report, args.force_ffmpeg_failure, args.force_pyav_failure, args.cancel_file)
        elif args.command == "validate":
            job, annotation, source, ann_path = validate_files(load_json(args.job), args.job.resolve())
            save_report({"status": "success", "job_id": job["job_id"], "clip_id": job["clip_id"], "source": str(source), "annotation": str(ann_path), "annotation_regions": len(annotation["regions"])}, None)
        elif args.command == "preview":
            job, annotation, source, _ = validate_files(load_json(args.job), args.job.resolve())
            spec = job["output_spec"]
            save_report(create_preview(source, annotation, spec["width_px"], spec["height_px"], spec["fit_mode"], args.output.resolve()), None)
        else:
            report = merge_homogeneous([path.resolve() for path in args.inputs], args.output.resolve(), force_ffmpeg_failure=args.force_ffmpeg_failure, force_pyav_failure=args.force_pyav_failure)
            report.update({"contract_version": "1.0", "output_sha256": sha256_file(args.output.resolve()), "external_audio_sync": "not_verified", "claims_not_made": ["approval", "qa_pass", "retry_state"]})
            save_report(report, args.report)
        return 0
    except ContractError as exc:
        save_report({"contract_version": "1.0", "status": "failed", "failure_type": "validation", "error": exc.as_dict(), "claims_not_made": ["approval", "qa_pass", "retry_state"]}, getattr(args, "report", None))
        return 2
    except EncodeError as exc:
        save_report({"contract_version": "1.0", "status": "failed", "failure_type": "encoding_or_merge", "error": {"code": exc.code, "message": str(exc)}, "attempts": exc.attempts, "claims_not_made": ["approval", "qa_pass", "retry_state"]}, getattr(args, "report", None))
        return 3
    except RenderCancelled as exc:
        save_report({"contract_version": "1.0", "status": "cancelled", "failure_type": "cancelled", "error": {"code": "render_cancelled", "message": str(exc)}, "claims_not_made": ["approval", "qa_pass", "retry_state"]}, getattr(args, "report", None))
        return 5
    except Exception as exc:
        save_report({"contract_version": "1.0", "status": "failed", "failure_type": "runtime", "error": {"code": "unexpected_runtime_error", "message": str(exc)}, "debug_trace": traceback.format_exc() if os.environ.get("REGION_STREAM_INK_DEBUG") == "1" else None, "claims_not_made": ["approval", "qa_pass", "retry_state"]}, getattr(args, "report", None))
        return 4


if __name__ == "__main__":
    sys.exit(main())
