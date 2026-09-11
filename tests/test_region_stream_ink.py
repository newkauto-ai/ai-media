from __future__ import annotations

import copy
import hashlib
import json
import subprocess
import sys
import unittest
import uuid
from pathlib import Path

import cv2
import numpy as np

PLUGIN_ROOT = Path(__file__).resolve().parents[1]
RUNTIME = PLUGIN_ROOT / "video-production" / "runtime" / "region-stream-ink"
sys.path.insert(0, str(RUNTIME))

from annotation import ContractError, validate_annotation, validate_job  # noqa: E402
from encode import EncodeError, merge_homogeneous, video_facts  # noqa: E402
from render import RegionRenderer, read_image  # noqa: E402


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class RegionStreamInkTests(unittest.TestCase):
    def setUp(self) -> None:
        temp_base = PLUGIN_ROOT / ".test-tmp"
        temp_base.mkdir(parents=True, exist_ok=True)
        self.root = temp_base / ("case-" + uuid.uuid4().hex)
        self.root.mkdir(parents=True, exist_ok=True)
        self.image_path = self.root / "source.png"
        image = np.full((64, 64, 3), 255, dtype=np.uint8)
        cv2.putText(image, "Aa", (2, 15), cv2.FONT_HERSHEY_SIMPLEX, 0.4, (0, 0, 0), 1, cv2.LINE_AA)
        cv2.rectangle(image, (5, 20), (25, 38), (0, 0, 0), -1)
        cv2.arrowedLine(image, (3, 58), (42, 40), (0, 0, 0), 2)
        cv2.arrowedLine(image, (3, 40), (42, 58), (0, 0, 0), 2)
        cv2.circle(image, (52, 22), 10, (0, 0, 200), -1)
        ok, encoded = cv2.imencode(".png", image)
        self.assertTrue(ok)
        encoded.tofile(self.image_path)
        self.annotation = {
            "schema_version": "1.0",
            "canvas": {"width": 64, "height": 64},
            "regions": [
                {"region_id": "r1", "rect": {"x": 0, "y": 0, "width": 32, "height": 40}, "start_frame": 1, "duration_frames": 4, "allow_spatial_overlap_with": []},
                {"region_id": "r2", "rect": {"x": 32, "y": 0, "width": 32, "height": 40}, "start_frame": 5, "duration_frames": 3, "allow_spatial_overlap_with": []},
                {"region_id": "r3", "rect": {"x": 0, "y": 40, "width": 48, "height": 24}, "start_frame": 8, "duration_frames": 3, "allow_spatial_overlap_with": []},
            ],
            "protected_regions": [{"kind": "permanent", "rect": {"x": 48, "y": 40, "width": 16, "height": 24}}],
            "allow_uncovered_ink": True,
        }
        self.annotation_path = self.root / "annotation.json"
        self.annotation_path.write_text(json.dumps(self.annotation), encoding="utf-8")

    def tearDown(self) -> None:
        pass

    def job(self, output: str = "visual_track.mp4", width: int = 64, height: int = 64, mode: str = "ink_only", path_mode: str = "grid") -> dict:
        return {
            "contract_version": "1.0",
            "job_id": "job-1",
            "revision_id": "rev-1",
            "clip_id": "clip-1",
            "adapter_id": "region_stream_ink",
            "source_image": {"path": str(self.image_path), "sha256": digest(self.image_path), "rights_evidence_ref": "fixture-owned"},
            "annotation": {"path": str(self.annotation_path), "sha256": digest(self.annotation_path), "approval_evidence_ref": "fixture-only"},
            "timing": {"frame_rate": 6, "scene_duration_frames": 12, "tail_hold_frames": 1, "segments": [{"element_id": item["region_id"], "start_frame": item["start_frame"], "duration_frames": item["duration_frames"]} for item in self.annotation["regions"]]},
            "output_spec": {"aspect_ratio": f"{width}:{height}", "resolution": f"{width}x{height}", "width_px": width, "height_px": height, "fit_mode": "pad"},
            "render_style": {"ink_path": path_mode, "reveal_mode": mode, "tip_overlay": "none"},
            "output_path": str(self.root / output),
        }

    def write_job(self, job: dict, name: str = "job.json") -> Path:
        path = self.root / name
        path.write_text(json.dumps(job), encoding="utf-8")
        return path

    def run_cli(self, *args: str) -> tuple[subprocess.CompletedProcess[str], dict]:
        result = subprocess.run([sys.executable, str(RUNTIME / "renderer_cli.py"), *args], capture_output=True, text=True, encoding="utf-8", errors="replace", check=False)
        return result, json.loads(result.stdout.strip().splitlines()[-1])

    def test_annotation_valid_and_invalid_cases(self) -> None:
        validated = validate_annotation(self.annotation)
        validate_job(self.job(), validated)
        invalid_cases = []
        empty = copy.deepcopy(self.annotation); empty["regions"] = []; invalid_cases.append((empty, "empty_regions"))
        bounds = copy.deepcopy(self.annotation); bounds["regions"][0]["rect"]["width"] = 80; invalid_cases.append((bounds, "out_of_bounds"))
        timeline = copy.deepcopy(self.annotation); timeline["regions"][1]["start_frame"] = 4; invalid_cases.append((timeline, "timeline_overlap"))
        overlap = copy.deepcopy(self.annotation); overlap["regions"][1]["rect"] = {"x": 20, "y": 0, "width": 40, "height": 40}; invalid_cases.append((overlap, "undeclared_spatial_overlap"))
        deferred = copy.deepcopy(self.annotation); deferred["protected_regions"].append({"kind": "deferred", "rect": {"x": 1, "y": 1, "width": 2, "height": 2}, "until_region_id": "missing"}); invalid_cases.append((deferred, "unknown_deferred_target"))
        for value, code in invalid_cases:
            with self.subTest(code=code), self.assertRaises(ContractError) as caught:
                validate_annotation(value)
            self.assertEqual(code, caught.exception.code)
        unknown = self.job(); unknown["output_spec"]["aspect_ratio"] = "UNKNOWN"
        with self.assertRaises(ContractError) as caught:
            validate_job(unknown, validated)
        self.assertEqual("unknown_output_spec", caught.exception.code)
        unlicensed_tip = self.job(); unlicensed_tip["render_style"]["tip_overlay"] = {"path": "tip.png"}
        with self.assertRaises(ContractError) as caught:
            validate_job(unlicensed_tip, validated)
        self.assertEqual("invalid_string", caught.exception.code)

    def test_preview_uses_no_external_font_or_bundled_tip(self) -> None:
        output = self.root / "annotation-preview.png"
        result, report = self.run_cli("preview", "--job", str(self.write_job(self.job(), "preview-job.json")), "--output", str(output))
        self.assertEqual(0, result.returncode, result.stderr + result.stdout)
        self.assertTrue(output.is_file())
        self.assertEqual("none_opencv_hershey", report["font_dependency"])

    def test_empty_path_zero_ink_keeps_exact_frame_budget(self) -> None:
        white = np.full((64, 64, 3), 255, dtype=np.uint8)
        ann = validate_annotation(self.annotation)
        for path_mode in ("grid", "skeleton"):
            renderer = RegionRenderer(white, ann, self.job(path_mode=path_mode))
            frames, facts = renderer.render_frames()
            self.assertEqual(12, len(frames))
            self.assertTrue(all(item["empty_path"] for item in facts["regions"]))

    def test_deferred_and_permanent_protection_and_spatial_overlap(self) -> None:
        ann = {
            "schema_version": "1.0", "canvas": {"width": 64, "height": 64},
            "regions": [
                {"region_id": "early", "rect": {"x": 0, "y": 0, "width": 48, "height": 64}, "start_frame": 0, "duration_frames": 4, "allow_spatial_overlap_with": ["late"]},
                {"region_id": "late", "rect": {"x": 32, "y": 0, "width": 32, "height": 64}, "start_frame": 4, "duration_frames": 4, "allow_spatial_overlap_with": ["early"]},
            ],
            "protected_regions": [
                {"kind": "deferred", "rect": {"x": 34, "y": 0, "width": 10, "height": 64}, "until_region_id": "late"},
                {"kind": "permanent", "rect": {"x": 50, "y": 0, "width": 10, "height": 64}},
            ], "allow_uncovered_ink": True,
        }
        validated = validate_annotation(ann)
        job = self.job(); job["timing"] = {"frame_rate": 6, "scene_duration_frames": 10, "tail_hold_frames": 2, "segments": [{"element_id": "early", "start_frame": 0, "duration_frames": 4}, {"element_id": "late", "start_frame": 4, "duration_frames": 4}]}
        renderer = RegionRenderer(read_image(self.image_path), validated, job)
        frames, _ = renderer.render_frames()
        self.assertTrue(np.all(frames[3][:, 36:42] == 255), "deferred area leaked in the early region")
        self.assertTrue(np.all(frames[-1][:, 50:60] == 255), "permanent protection was revealed")

    def test_uncovered_ink_preflight_blocks_without_explicit_acceptance(self) -> None:
        ann = copy.deepcopy(self.annotation)
        ann["regions"] = [ann["regions"][0]]
        ann["allow_uncovered_ink"] = False
        ann_path = self.root / "uncovered.json"; ann_path.write_text(json.dumps(ann), encoding="utf-8")
        job = self.job(); job["annotation"] = {"path": str(ann_path), "sha256": digest(ann_path), "approval_evidence_ref": "fixture-only"}; job["timing"]["segments"] = job["timing"]["segments"][:1]
        result, report = self.run_cli("render", "--job", str(self.write_job(job, "uncovered-job.json")))
        self.assertEqual(2, result.returncode)
        self.assertEqual("uncovered_ink", report["error"]["code"])

    def test_render_modes_paths_content_shapes_and_explicit_specs(self) -> None:
        for path_mode in ("grid", "skeleton"):
            for reveal_mode in ("ink_only", "ink_then_color"):
                for width, height in ((64, 64), (96, 54)):
                    ann = validate_annotation(self.annotation)
                    renderer = RegionRenderer(read_image(self.image_path), ann, self.job(width=width, height=height, mode=reveal_mode, path_mode=path_mode))
                    frames, facts = renderer.render_frames()
                    self.assertEqual(12, facts["frame_count"])
                    self.assertEqual((height, width, 3), frames[-1].shape)
                    self.assertGreater(sum(item["ink_path_points"] for item in facts["regions"]), 0)
                    self.assertTrue(np.all(frames[-1][int(height * .7):, int(width * .8):] == 255), "permanent or uncovered content appeared at the end")

    def test_ffmpeg_success_h264_no_audio_full_decode_and_structured_output(self) -> None:
        job_path = self.write_job(self.job())
        result, report = self.run_cli("render", "--job", str(job_path))
        self.assertEqual(0, result.returncode, result.stderr + result.stdout)
        self.assertEqual("success", report["status"])
        self.assertEqual("ffmpeg", report["encoding"]["selected"])
        self.assertEqual("h264", report["media_facts"]["codec"])
        self.assertEqual("yuv420p", report["media_facts"]["pix_fmt"])
        self.assertEqual(0, report["media_facts"]["audio_stream_count"])
        self.assertEqual(12, report["media_facts"]["frame_count"])
        self.assertTrue(report["media_facts"]["timestamps"]["monotonic"])
        self.assertEqual("not_verified", report["external_audio_sync"])
        self.assertIn("qa_pass", report["claims_not_made"])

    def test_pyav_fallback_and_dual_failure(self) -> None:
        fallback = self.job("fallback.mp4")
        result, report = self.run_cli("render", "--job", str(self.write_job(fallback, "fallback.json")), "--force-ffmpeg-failure")
        self.assertEqual(0, result.returncode, result.stderr + result.stdout)
        self.assertEqual("pyav", report["encoding"]["selected"])
        failure = self.job("must-not-exist.mp4")
        result, report = self.run_cli("render", "--job", str(self.write_job(failure, "failure.json")), "--force-ffmpeg-failure", "--force-pyav-failure")
        self.assertEqual(3, result.returncode)
        self.assertEqual("h264_encoding_failed", report["error"]["code"])
        self.assertFalse((self.root / "must-not-exist.mp4").exists())
        self.assertTrue((self.root / "must-not-exist.mp4v.failed.mp4").exists())

    def test_cancel_file_returns_structured_cancelled_without_output(self) -> None:
        cancel = self.root / "cancel.now"; cancel.write_text("cancel", encoding="utf-8")
        job = self.job("cancelled.mp4")
        result, report = self.run_cli("render", "--job", str(self.write_job(job, "cancelled.json")), "--cancel-file", str(cancel))
        self.assertEqual(5, result.returncode)
        self.assertEqual("cancelled", report["status"])
        self.assertFalse((self.root / "cancelled.mp4").exists())

    def test_homogeneous_merge_offsets_and_heterogeneous_rejection(self) -> None:
        paths = []
        for index in range(2):
            job = self.job(f"clip-{index}.mp4")
            result, report = self.run_cli("render", "--job", str(self.write_job(job, f"clip-{index}.json")))
            self.assertEqual(0, result.returncode, result.stderr + result.stdout)
            paths.append(Path(report["output_path"]))
        merged = self.root / "merged.mp4"
        result, report = self.run_cli("merge", "--inputs", *(str(path) for path in paths), "--output", str(merged))
        self.assertEqual(0, result.returncode, result.stderr + result.stdout)
        self.assertEqual(24, report["facts"]["frame_count"])
        self.assertTrue(report["facts"]["timestamps"]["monotonic"])
        self.assertEqual([0, 12], [item["start_frame"] for item in report["clip_offsets"]])
        self.assertEqual(digest(merged), report["output_sha256"])
        self.assertEqual("not_verified", report["external_audio_sync"])
        different = self.job("different.mp4", width=96, height=54)
        result, report2 = self.run_cli("render", "--job", str(self.write_job(different, "different.json")))
        self.assertEqual(0, result.returncode, result.stderr + result.stdout)
        with self.assertRaises(EncodeError) as caught:
            merge_homogeneous([paths[0], Path(report2["output_path"])], self.root / "bad-merge.mp4")
        self.assertEqual("heterogeneous_inputs", caught.exception.code)


if __name__ == "__main__":
    unittest.main(verbosity=2)
