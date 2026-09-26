"""Synthetic mechanical tests. No media approval or generation is performed."""

from __future__ import annotations

import copy
import hashlib
import importlib.util
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import uuid
from unittest.mock import patch

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
ENTRYPOINTS = (
    ROOT / "video-production/scripts/validate-vox-production.py",
    ROOT / "skills/video-production/scripts/validate-vox-production.py",
)


def load(path: Path):
    spec = importlib.util.spec_from_file_location("vox_preflight", path)
    module = importlib.util.module_from_spec(spec)
    assert spec and spec.loader
    spec.loader.exec_module(module)
    return module


def media(path: Path, transparent: bool = False) -> dict:
    if transparent:
        image = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
        for x in range(2, 14):
            for y in range(2, 14):
                image.putpixel((x, y), (210, 30, 20, 255))
    else:
        image = Image.new("RGBA", (16, 16), (240, 230, 210, 255))
    image.save(path)
    return {"path": str(path), "revision_id": "r1", "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def review(review_id: str, checksum: str, checks: tuple[str, ...]) -> dict:
    return {
        "schema_version": "2.2",
        "review_id": review_id,
        "target": {"target_type": "vox_poster_shot", "revision_id": "r1", "media_checksum": checksum},
        "lineage": {"dependency_hashes": {
            "frozen_script": "1" * 64, "audiovisual_direction_package": "2" * 64,
            "production_manifest": "3" * 64, "poster_shot_map": "4" * 64,
            "poster_media": checksum}},
        "provenance": {"fixture_only": False},
        "decision": {"verdict": "PASS", "generation_gate_recommendation": "withhold"},
        "controller_mapping": {"verdict": "pass"},
        "findings": [
            {"check_id": check, "check_result": "pass", "confidence": "high",
             "severity": "optional", "evidence": ["synthetic"]}
            for check in checks
        ],
    }


class PreflightTest(unittest.TestCase):
    def setUp(self):
        directory = Path(os.environ.get("VOX_TEST_TEMP") or tempfile.gettempdir()) / ("vox-preflight-" + uuid.uuid4().hex)
        directory.mkdir()
        self.directory = directory
        base_ref = media(directory / "base.png")
        other_ref = media(directory / "other.png")
        overlay_ref = media(directory / "overlay.png", transparent=True)
        preview_ref = media(directory / "preview.png")
        audio_path = directory / "audio.mp3"
        audio_path.write_bytes(b"synthetic audio fixture")
        self.audio_hash = hashlib.sha256(audio_path.read_bytes()).hexdigest()
        self.assets = [
            {"asset_id": "base", "design_role": "base_scene", "media_ref": base_ref,
             "used_by_poster_shots": ["PS-A", "PS-B"], "implementation_route": "generated_asset",
             "qa": {"suitability": "approved", "evidence_refs": ["synthetic-base-review"]},
             "request_evidence": {"reuse_search": {"status": "bounded_complete", "scope": ["local"],
                                                  "candidates": [], "remaining_gap": "no usable base"},
                                  "authorization_ref": "synthetic-authorization"}},
            {"asset_id": "other", "design_role": "base_scene", "media_ref": other_ref,
             "used_by_poster_shots": ["PS-C"], "implementation_route": "reuse_existing",
             "qa": {"suitability": "approved", "evidence_refs": ["synthetic-base-review"]}},
            {"asset_id": "overlay", "design_role": "critical_typography", "media_ref": overlay_ref,
             "used_by_poster_shots": ["PS-A", "PS-B"], "implementation_route": "generated_asset",
             "planned_layout": {"x": 1, "y": 2}, "required_effective_px": {"width": 10, "height": 10},
             "critical_text": {"exact_text": "已核对", "realization": "verified_typography_png",
                               "verification_ref": "synthetic-glyph-review"},
             "request_evidence": {"reuse_search": {"status": "bounded_complete", "scope": ["local"],
                                                  "candidates": [], "remaining_gap": "no suitable title"},
                                  "authorization_ref": "synthetic-authorization"}},
            {"asset_id": "preview", "design_role": "complete_poster", "media_ref": preview_ref,
             "used_by_poster_shots": ["PS-A", "PS-B"]},
        ]
        self.design = {
            "layout_intent": {"reading_path": ["title", "scene"], "text_region": "upper",
                              "independent_groups": ["title"]},
            "base_asset_id": "base", "overlay_asset_ids": ["overlay"],
            "layout": {"overlay": {"x": 1, "y": 2}}, "renderer_ref": "remotion:poster-v1",
            "review_refs": {},
        }
        def shot(name, beat, design):
            return {"local_assembly_plan": {"poster_shot_id": name, "source_beat_id": beat,
                    "poster_spec": {"pilot_design_route": "production_reconstructable",
                                    "decomposition_decision": "partial_decomposition",
                                    "production_design": design}}}
        self.manifest = {"scenes": [{"shots": [shot("PS-A", "B-A", self.design),
                                                shot("PS-B", "B-B", copy.deepcopy(self.design)),
                                                shot("PS-C", "B-B", {"base_asset_id": "other"})]}],
                         "assets": self.assets, "qa": {"results": []},
                         "audio_production": {"final_narration_master": {
                             "path": str(audio_path), "revision_id": "audio-r1",
                             "sha256": self.audio_hash, "duration_seconds": 10}}}
        self.base_hash = base_ref["sha256"]
        self.preview_hash = preview_ref["sha256"]

    def tearDown(self):
        shutil.rmtree(self.directory)

    def test_source_and_published_actions(self):
        for entrypoint in ENTRYPOINTS:
            with self.subTest(entrypoint=entrypoint):
                module = load(entrypoint)
                manifest = copy.deepcopy(self.manifest)
                self.assertEqual(module.find_shot(manifest, "PS-A")["local_assembly_plan"]["source_beat_id"], "B-A")
                self.assertEqual(module.find_shot(manifest, "PS-B")["local_assembly_plan"]["source_beat_id"], "B-B")
                self.assertEqual(module.find_shot(manifest, "PS-C")["local_assembly_plan"]["source_beat_id"], "B-B")
                self.assertTrue(module.validate(manifest, "PS-A", "request_base", "base", None)["eligible"])
                self.assertTrue(module.validate(manifest, "PS-A", "request_overlay", "overlay", None)["eligible"])
                atlas_request = copy.deepcopy(manifest)
                atlas_asset = next(a for a in atlas_request["assets"] if a["asset_id"] == "overlay")
                atlas_asset["design_role"] = "decoration"
                atlas_asset["implementation_route"] = "temporary_atlas"
                with self.assertRaises(module.Blocked):
                    module.validate(atlas_request, "PS-A", "request_overlay", "overlay", None)
                atlas_asset["atlas_plan"] = {"estimated_cell_content_px": {"width": 12, "height": 12}}
                self.assertTrue(module.validate(atlas_request, "PS-A", "request_overlay", "overlay", None)["eligible"])
                result = module.validate(manifest, "PS-A", "compose_preview", None, None)
                self.assertTrue(result["eligible"])
                design = manifest["scenes"][0]["shots"][0]["local_assembly_plan"]["poster_spec"]["production_design"]
                design["preview_asset_ref"] = {"asset_id": "preview", "sha256": self.preview_hash,
                                               "input_hash": result["input_hash"]}
                poster_checks = ("visual_quality", "poster_readiness", "typography_split_test",
                                 "context_separation_test", "decorative_independence_test",
                                 "rectangle_risk_test", "motion_sequence_test")
                manifest["qa"]["results"].append(review("poster-review", self.preview_hash, poster_checks))
                design["review_refs"]["poster"] = "poster-review"
                self.assertTrue(module.validate(manifest, "PS-A", "plan_motion", None, None)["eligible"])
                with self.assertRaises(module.Blocked):
                    module.validate(manifest, "PS-A", "render", None, None)
                design["motion_preplan"] = {"narration_range": [0, 5], "attention_targets": ["title"],
                                            "exposure_bounds": "bounded"}
                plan = manifest["scenes"][0]["shots"][0]["local_assembly_plan"]
                plan["motion_plan"] = {"route": "remotion_living_poster"}
                design["output_geometry"] = {"width": 720, "height": 1280, "fps": 30}
                design["render_input_hash"] = module.fingerprint({
                    "preview": result["input_hash"], "motion": plan["motion_plan"],
                    "preplan": design["motion_preplan"], "geometry": design["output_geometry"],
                    "audio": {"revision_id": "audio-r1", "sha256": self.audio_hash}})
                with self.assertRaises(module.Blocked):
                    module.validate(manifest, "PS-A", "render", None, None)
                static_checks = ("static_reconstruction", "pre_entry_exposure",
                                 "handoff_exposure", "extreme_exposure")
                manifest["qa"]["results"].append(review("static-review", self.preview_hash, static_checks))
                design["review_refs"]["static"] = "static-review"
                self.assertTrue(module.validate(manifest, "PS-A", "render", None, None)["eligible"])
                output_path = self.directory / "synthetic-output.mp4"
                output_path.write_bytes(b"candidate, not approved media")
                with self.assertRaises(module.Blocked):
                    module.validate(manifest, "PS-A", "intake", None, str(output_path))
                output_hash = hashlib.sha256(output_path.read_bytes()).hexdigest()
                design["render_report"] = {"input_hash": design["render_input_hash"],
                                           "media_sha256": output_hash,
                                           "technical_review_ref": "technical-review",
                                           "continuous_viewing_ref": "viewing-review"}
                manifest["qa"]["results"].append(review("technical-review", output_hash, ()))
                manifest["qa"]["results"].append(review("viewing-review", output_hash,
                                                        ("continuous_viewing",)))
                with patch.object(module.shutil, "which", return_value="synthetic-ffprobe"), \
                     patch.object(module.subprocess, "run", return_value=subprocess.CompletedProcess(
                         args=[], returncode=0, stdout='{"format":{"duration":"5"}}')):
                    self.assertTrue(module.validate(manifest, "PS-A", "intake", None, str(output_path))["eligible"])
                    no_viewing = copy.deepcopy(manifest)
                    no_viewing["qa"]["results"][-1]["findings"][0]["evidence"] = []
                    with self.assertRaises(module.Blocked):
                        module.validate(no_viewing, "PS-A", "intake", None, str(output_path))

                low_res = copy.deepcopy(manifest)
                next(a for a in low_res["assets"] if a["asset_id"] == "overlay")["required_effective_px"]["width"] = 20
                with self.assertRaises(module.Blocked):
                    module.validate(low_res, "PS-A", "compose_preview", None, None)
                unverified = copy.deepcopy(manifest)
                next(a for a in unverified["assets"] if a["asset_id"] == "overlay")["critical_text"]["verification_ref"] = None
                with self.assertRaises(module.Blocked):
                    module.validate(unverified, "PS-A", "compose_preview", None, None)
                route = copy.deepcopy(manifest)
                route_asset = next(a for a in route["assets"] if a["asset_id"] == "overlay")
                route_asset["design_role"] = "route_texture"
                route_asset.pop("critical_text")
                with self.assertRaises(module.Blocked):
                    module.validate(route, "PS-A", "compose_preview", None, None)
                route_asset["route_registration"] = {
                    "path_ref": "synthetic-path", "motion_use": "progressive",
                    "texture_sha256": route_asset["media_ref"]["sha256"],
                    "layout_hash": module.fingerprint(design["layout"])}
                self.assertTrue(module.validate(route, "PS-A", "compose_preview", None, None)["eligible"])
                stale_route = copy.deepcopy(route)
                next(a for a in stale_route["assets"] if a["asset_id"] == "overlay")["route_registration"]["layout_hash"] = "0" * 64
                with self.assertRaises(module.Blocked):
                    module.validate(stale_route, "PS-A", "compose_preview", None, None)
                stale_audio = copy.deepcopy(manifest)
                stale_audio["audio_production"]["final_narration_master"]["sha256"] = "0" * 64
                with self.assertRaises(module.Blocked):
                    module.validate(stale_audio, "PS-A", "render", None, None)
                with self.assertRaises(module.Blocked):
                    module.validate(stale_audio, "PS-A", "intake", None, str(output_path))
                must_fix = copy.deepcopy(manifest)
                must_fix["qa"]["results"][0]["findings"][0].update(
                    {"severity": "must_fix", "resolution": "unresolved"})
                with self.assertRaises(module.Blocked):
                    module.validate(must_fix, "PS-A", "plan_motion", None, None)
                legacy = copy.deepcopy(manifest)
                legacy["qa"]["results"][0]["schema_version"] = "2.1"
                with self.assertRaises(module.Blocked):
                    module.validate(legacy, "PS-A", "plan_motion", None, None)
                missing_dependency = copy.deepcopy(manifest)
                missing_dependency["qa"]["results"][0]["lineage"]["dependency_hashes"].pop("poster_shot_map")
                with self.assertRaises(module.Blocked):
                    module.validate(missing_dependency, "PS-A", "plan_motion", None, None)
                stale = copy.deepcopy(manifest)
                next(a for a in stale["assets"] if a["asset_id"] == "overlay")["media_ref"]["sha256"] = "0" * 64
                with self.assertRaises(module.Blocked):
                    module.validate(stale, "PS-A", "render", None, None)


if __name__ == "__main__":
    unittest.main()
