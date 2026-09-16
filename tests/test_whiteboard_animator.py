import hashlib
import importlib.util
import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw


PLUGIN_ROOT = Path(__file__).resolve().parents[1]
MANIFEST = json.loads((PLUGIN_ROOT / ".codex-plugin" / "plugin.json").read_text(encoding="utf-8"))
SKILLS_ROOT = (PLUGIN_ROOT / MANIFEST["skills"]).resolve()
SKILL_ENTRY = SKILLS_ROOT / "video-production" / "scripts" / "whiteboard-animator-cli.ps1"
FIXTURES = Path(__file__).resolve().parent / "fixtures" / "whiteboard-animator"
POWERSHELL = shutil.which("pwsh") or shutil.which("powershell")
LEGACY_CHARACTER_PART_ORDER = ("head", "body", "hands", "feet")
CHARACTER_PART_ORDER = (
    "head", "body", "upper_arms", "forearms", "hands",
    "thighs", "lower_legs", "feet",
)


def load_renderer_module():
    path = PLUGIN_ROOT / "video-production" / "runtime" / "whiteboard-animator" / "renderer_cli.py"
    spec = importlib.util.spec_from_file_location("whiteboard_renderer_cli", path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def load_production_planner_module():
    path = PLUGIN_ROOT / "video-production" / "runtime" / "whiteboard-animator" / "production_planner.py"
    spec = importlib.util.spec_from_file_location("whiteboard_production_planner", path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest().upper()


def output_geometry(path: Path) -> tuple[int, int]:
    with Image.open(path) as image:
        width, height = image.size
    if max(width, height) > 1280:
        scale = 1280 / max(width, height)
        width, height = int(width * scale), int(height * scale)
    return width + width % 2, height + height % 2


class WhiteboardAnimatorManifestEntrypointTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if POWERSHELL is None:
            raise unittest.SkipTest("PowerShell is unavailable")
        if not SKILL_ENTRY.is_file():
            raise AssertionError(f"manifest-declared Skill entry missing: {SKILL_ENTRY}")

    def make_job(self, root: Path, fixture_name: str, with_tip: bool = False) -> Path:
        source = FIXTURES / fixture_name
        width, height = output_geometry(source)
        job = {
            "contract_version": "1.0",
            "adapter_id": "whiteboard_animator",
            "job_id": f"fixture-{source.stem}",
            "revision_id": "r1",
            "source": {"path": str(source), "sha256": sha256(source), "rights_evidence": "bundled regression fixture"},
            "output": str(root / f"{source.stem}.mp4"),
            "output_spec": {"width_px": width, "height_px": height, "pixel_format": "yuv420p", "native_audio": "none"},
            "timing": {"total_duration_seconds": 2.0, "draw_duration_seconds": 1.5, "fps": 24},
        }
        if with_tip:
            tip = FIXTURES / "手笔素材.png"
            job["tip_overlay"] = {
                "path": str(tip), "sha256": sha256(tip), "rights_evidence": "accepted local fixture asset",
                "tip_anchor": [0.225, 0.075], "height_fraction": 0.6901041667,
                "max_continuous_step_fraction": 0.1354166667, "opacity": 0.94,
            }
        path = root / f"{source.stem}.job.json"
        path.write_text(json.dumps(job, ensure_ascii=False, indent=2), encoding="utf-8")
        return path

    def run_preflight(self, fixture_name: str, expected_code: int = 0, with_tip: bool = False):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            job = self.make_job(root, fixture_name, with_tip=with_tip)
            report = root / "report.json"
            command = [POWERSHELL, "-NoProfile", "-File", str(SKILL_ENTRY), "-Action", "preflight", "-Job", str(job), "-Report", str(report), "-PythonPath", str(Path(__import__("sys").executable))]
            completed = subprocess.run(command, capture_output=True, text=True, encoding="utf-8")
            self.assertEqual(completed.returncode, expected_code, msg=completed.stdout + completed.stderr)
            self.assertTrue(report.is_file(), msg=completed.stdout + completed.stderr)
            return json.loads(report.read_text(encoding="utf-8"))

    def run_job(self, root: Path, job: dict, action: str = "preflight", expected_code: int = 0):
        job_path = root / "structured.job.json"
        report_path = root / f"structured.{action}.json"
        job_path.write_text(json.dumps(job, ensure_ascii=False, indent=2), encoding="utf-8")
        command = [
            POWERSHELL, "-NoProfile", "-File", str(SKILL_ENTRY), "-Action", action,
            "-Job", str(job_path), "-Report", str(report_path),
            "-PythonPath", str(Path(__import__("sys").executable)),
        ]
        completed = subprocess.run(command, capture_output=True, text=True, encoding="utf-8")
        self.assertEqual(completed.returncode, expected_code, msg=completed.stdout + completed.stderr)
        self.assertTrue(report_path.is_file(), msg=completed.stdout + completed.stderr)
        return json.loads(report_path.read_text(encoding="utf-8"))

    def make_structured_job(self, root: Path) -> dict:
        size = (320, 180)
        background = Image.new("RGB", size, (242, 236, 216))
        source = background.copy()
        source_draw = ImageDraw.Draw(source)
        source_draw.rectangle((36, 38, 122, 150), fill=(173, 92, 66), outline=(30, 27, 24), width=4)
        source_draw.ellipse((174, 30, 280, 152), fill=(66, 115, 139), outline=(30, 27, 24), width=4)

        line_art = Image.new("RGB", size, "white")
        line_draw = ImageDraw.Draw(line_art)
        line_draw.rectangle((36, 38, 122, 150), outline="black", width=4)
        line_draw.ellipse((174, 30, 280, 152), outline="black", width=4)

        mask_a = Image.new("L", size, 0)
        ImageDraw.Draw(mask_a).rectangle((36, 38, 122, 150), fill=255)
        mask_b = Image.new("L", size, 0)
        ImageDraw.Draw(mask_b).ellipse((174, 30, 280, 152), fill=255)

        paths = {}
        for name, image in (("source", source), ("background", background), ("line_art", line_art), ("mask_a", mask_a), ("mask_b", mask_b)):
            path = root / f"{name}.png"
            image.save(path)
            paths[name] = path

        asset = lambda name: {"path": str(paths[name]), "sha256": sha256(paths[name]), "rights_evidence": "generated regression fixture"}
        return {
            "contract_version": "1.0", "adapter_id": "whiteboard_animator",
            "job_id": "structured-fixture", "revision_id": "r1",
            "source": asset("source"), "output": str(root / "structured.mp4"),
            "output_spec": {"width_px": 320, "height_px": 180, "pixel_format": "yuv420p", "native_audio": "none"},
            "timing": {"total_duration_seconds": 1.25, "draw_duration_seconds": 1.0, "fps": 12},
            "structured_layers": {
                "mode": "prepainted_background_object_reveal",
                "background": asset("background"), "line_art": asset("line_art"), "line_art_threshold": 220,
                "objects": [
                    {"id": "rectangle", "order": 0, "mask": asset("mask_a"), "stroke_duration_seconds": 0.25, "fill_duration_seconds": 0.25},
                    {"id": "ellipse", "order": 1, "mask": asset("mask_b"), "stroke_duration_seconds": 0.25, "fill_duration_seconds": 0.25},
                ],
            },
        }

    def make_stacked_job(self, root: Path) -> dict:
        size = (320, 180)
        specs = [
            ("character", 0, 2, "line_then_fill", (90, 35, 190, 160), (204, 89, 72, 255), 0.4, 0.3),
            ("midground", 1, 1, "line_then_fill", (40, 60, 260, 150), (77, 139, 98, 255), 0.3, 0.2),
            ("shadow", 2, 0, "direct_fill", (70, 150, 250, 166), (217, 211, 204, 145), 0.0, 0.3),
        ]
        records = []
        for name, draw_order, z_index, reveal_mode, box, color, stroke, fill in specs:
            rgba = Image.new("RGBA", size, (0, 0, 0, 0))
            ImageDraw.Draw(rgba).rectangle(box, fill=color, outline=(32, 28, 25, 255) if reveal_mode == "line_then_fill" else None, width=4)
            color_path = root / f"{name}.rgba.png"
            rgba.save(color_path)
            line_path = None
            if reveal_mode == "line_then_fill":
                line = Image.new("RGBA", size, (0, 0, 0, 0))
                ImageDraw.Draw(line).rectangle(box, outline=(32, 28, 25, 255), width=4)
                line_path = root / f"{name}.line.png"
                line.save(line_path)
            records.append((name, draw_order, z_index, reveal_mode, color_path, line_path, stroke, fill))
        composite = Image.new("RGBA", size, (249, 247, 241, 255))
        for record in sorted(records, key=lambda value: value[2]):
            composite = Image.alpha_composite(composite, Image.open(record[4]).convert("RGBA"))
        source_path = root / "stacked-source.png"
        composite.convert("RGB").save(source_path)
        asset = lambda path: {"path": str(path), "sha256": sha256(path), "rights_evidence": "generated regression fixture"}
        layers = []
        for name, draw_order, z_index, reveal_mode, color_path, line_path, stroke, fill in records:
            layer = {"id": name, "draw_order": draw_order, "z_index": z_index, "reveal_mode": reveal_mode, "color_rgba": asset(color_path), "fill_duration_seconds": fill}
            if line_path is not None:
                layer.update({"line_art_rgba": asset(line_path), "stroke_duration_seconds": stroke})
            layers.append(layer)
        return {
            "contract_version": "1.1", "adapter_id": "whiteboard_animator", "job_id": "stacked-fixture", "revision_id": "r1",
            "source": asset(source_path), "output": str(root / "stacked.mp4"),
            "output_spec": {"width_px": 320, "height_px": 180, "pixel_format": "yuv420p", "native_audio": "none"},
            "timing": {"total_duration_seconds": 2.0, "draw_duration_seconds": 1.5, "fps": 20},
            "structured_layers": {"mode": "stacked_layer_object_complete_reveal", "paper_rgb": [249, 247, 241], "layers": layers},
        }

    def make_character_head_first_job(self, root: Path) -> dict:
        target = (160, 90)
        size = (target[0] * 4, target[1] * 4)
        paper = (249, 247, 241, 255)
        color = Image.new("RGBA", size, (0, 0, 0, 0))
        line = Image.new("RGBA", size, (0, 0, 0, 0))
        color_draw, line_draw = ImageDraw.Draw(color), ImageDraw.Draw(line)

        head = (224, 20, 416, 156)
        body = (80, 204, 560, 340)
        color_draw.ellipse(head, fill=(242, 166, 90, 255), outline=(36, 49, 58, 255), width=14)
        color_draw.rounded_rectangle(body, radius=24, fill=(74, 144, 164, 255), outline=(36, 49, 58, 255), width=14)
        line_draw.ellipse(head, outline=(36, 49, 58, 255), width=14)
        line_draw.rounded_rectangle(body, radius=24, outline=(36, 49, 58, 255), width=14)

        source = Image.new("RGBA", size, paper)
        source = Image.alpha_composite(source, color)
        paths = {}
        for name, image in (("source", source), ("character", color), ("character-line", line)):
            path = root / f"{name}.png"
            image.save(path)
            paths[name] = path
        asset = lambda name: {"path": str(paths[name]), "sha256": sha256(paths[name]), "rights_evidence": "generated regression fixture"}
        return {
            "contract_version": "1.3", "adapter_id": "whiteboard_animator", "render_route": "structured_semantic",
            "job_id": "character-head-first", "revision_id": "r1",
            "source": dict(asset("source"), supersample_scale=4), "output": str(root / "character-head-first.mp4"),
            "output_spec": {"width_px": target[0], "height_px": target[1], "pixel_format": "yuv420p", "native_audio": "none"},
            "timing": {"policy": "manual", "total_duration_seconds": 2.0, "draw_duration_seconds": 1.5, "fps": 20},
            "structured_layers": {"mode": "stacked_layer_object_complete_reveal", "paper_rgb": list(paper[:3]), "layers": [{
                "id": "learner", "draw_order": 0, "z_index": 0, "reveal_mode": "line_then_fill",
                "semantic_kind": "character", "stroke_order_policy": "head_first", "head_bbox": [54, 3, 106, 41],
                "color_rgba": asset("character"), "line_art_rgba": asset("character-line"),
                "stroke_duration_seconds": 0.8, "fill_duration_seconds": 0.7,
            }]},
        }

    def make_character_part_order_job(self, root: Path) -> dict:
        target = (160, 90)
        size = (target[0] * 4, target[1] * 4)
        paper = (249, 247, 241, 255)
        color = Image.new("RGBA", size, (0, 0, 0, 0))
        line = Image.new("RGBA", size, (0, 0, 0, 0))
        color_draw, line_draw = ImageDraw.Draw(color), ImageDraw.Draw(line)
        shapes = {
            "head": ("ellipse", (256, 16, 384, 112), (242, 166, 90, 255)),
            "body": ("rectangle", (248, 120, 392, 240), (74, 144, 164, 255)),
            "hands": ("ellipses", ((176, 144, 224, 192), (416, 144, 464, 192)), (242, 166, 90, 255)),
            "feet": ("ellipses", ((248, 280, 304, 328), (336, 280, 392, 328)), (36, 49, 58, 255)),
        }
        masks = {}
        for part_name, (shape, geometry, fill) in shapes.items():
            mask = Image.new("RGBA", size, (0, 0, 0, 0))
            mask_draw = ImageDraw.Draw(mask)
            geometries = geometry if shape == "ellipses" else (geometry,)
            for box in geometries:
                if shape in ("ellipse", "ellipses"):
                    color_draw.ellipse(box, fill=fill, outline=(36, 49, 58, 255), width=12)
                    line_draw.ellipse(box, outline=(36, 49, 58, 255), width=12)
                    mask_draw.ellipse(box, fill=(255, 255, 255, 255))
                else:
                    color_draw.rectangle(box, fill=fill, outline=(36, 49, 58, 255), width=12)
                    line_draw.rectangle(box, outline=(36, 49, 58, 255), width=12)
                    mask_draw.rectangle(box, fill=(255, 255, 255, 255))
            masks[part_name] = mask

        source = Image.new("RGBA", size, paper)
        source = Image.alpha_composite(source, color)
        paths = {}
        images = [("source", source), ("character", color), ("character-line", line)]
        images.extend((f"mask-{name}", masks[name]) for name in LEGACY_CHARACTER_PART_ORDER)
        for name, image in images:
            path = root / f"{name}.png"
            image.save(path)
            paths[name] = path
        asset = lambda name: {"path": str(paths[name]), "sha256": sha256(paths[name]), "rights_evidence": "generated regression fixture"}
        return {
            "contract_version": "1.3", "adapter_id": "whiteboard_animator", "render_route": "structured_semantic",
            "job_id": "character-part-order", "revision_id": "r1",
            "source": dict(asset("source"), supersample_scale=4), "output": str(root / "character-part-order.mp4"),
            "output_spec": {"width_px": target[0], "height_px": target[1], "pixel_format": "yuv420p", "native_audio": "none"},
            "timing": {"policy": "manual", "total_duration_seconds": 2.5, "draw_duration_seconds": 2.0, "fps": 20},
            "structured_layers": {"mode": "stacked_layer_object_complete_reveal", "paper_rgb": list(paper[:3]), "layers": [{
                "id": "learner", "draw_order": 0, "z_index": 0, "reveal_mode": "line_then_fill",
                "semantic_kind": "character", "stroke_order_policy": "head_body_hands_feet",
                "character_parts": [{"part": name, "mask_rgba": asset(f"mask-{name}")} for name in LEGACY_CHARACTER_PART_ORDER],
                "color_rgba": asset("character"), "line_art_rgba": asset("character-line"),
                "stroke_duration_seconds": 1.2, "fill_duration_seconds": 0.8,
            }]},
        }

    def make_detailed_character_order_job(self, root: Path) -> dict:
        target = (200, 120)
        size = (target[0] * 4, target[1] * 4)
        paper = (249, 247, 241, 255)
        ink = (36, 49, 58, 255)
        color = Image.new("RGBA", size, (0, 0, 0, 0))
        line = Image.new("RGBA", size, (0, 0, 0, 0))
        color_draw, line_draw = ImageDraw.Draw(color), ImageDraw.Draw(line)
        shapes = {
            "head": ("ellipse", [(320, 20, 480, 120)], (242, 166, 90, 255)),
            "body": ("rectangle", [(320, 135, 480, 250)], (74, 144, 164, 255)),
            "upper_arms": ("rectangle", [(230, 145, 310, 175), (490, 145, 570, 175)], (74, 144, 164, 255)),
            "forearms": ("rectangle", [(140, 180, 220, 210), (580, 180, 660, 210)], (74, 144, 164, 255)),
            "hands": ("ellipse", [(80, 170, 130, 220), (670, 170, 720, 220)], (242, 166, 90, 255)),
            "thighs": ("rectangle", [(335, 265, 385, 350), (415, 265, 465, 350)], (74, 144, 164, 255)),
            "lower_legs": ("rectangle", [(335, 360, 385, 425), (415, 360, 465, 425)], (74, 144, 164, 255)),
            "feet": ("ellipse", [(300, 430, 385, 470), (415, 430, 500, 470)], (36, 49, 58, 255)),
        }
        masks, outlines, details = {}, {}, {}
        for part_name in CHARACTER_PART_ORDER:
            shape, boxes, fill = shapes[part_name]
            mask = Image.new("RGBA", size, (0, 0, 0, 0))
            outline = Image.new("RGBA", size, (0, 0, 0, 0))
            detail = Image.new("RGBA", size, (0, 0, 0, 0))
            mask_draw, outline_draw, detail_draw = ImageDraw.Draw(mask), ImageDraw.Draw(outline), ImageDraw.Draw(detail)
            for x1, y1, x2, y2 in boxes:
                draw_shape = "ellipse" if shape == "ellipse" else "rectangle"
                getattr(color_draw, draw_shape)((x1, y1, x2, y2), fill=fill, outline=ink, width=8)
                getattr(line_draw, draw_shape)((x1, y1, x2, y2), outline=ink, width=8)
                getattr(mask_draw, draw_shape)((x1, y1, x2, y2), fill=(255, 255, 255, 255))
                getattr(outline_draw, draw_shape)((x1, y1, x2, y2), outline=(255, 255, 255, 255), width=8)
                y = (y1 + y2) // 2
                detail_segment = (x1 + 16, y, x2 - 16, y)
                color_draw.line(detail_segment, fill=ink, width=5)
                line_draw.line(detail_segment, fill=ink, width=5)
                detail_draw.line(detail_segment, fill=(255, 255, 255, 255), width=5)
            masks[part_name], outlines[part_name], details[part_name] = mask, outline, detail

        source = Image.alpha_composite(Image.new("RGBA", size, paper), color)
        paths = {}
        images = [("source", source), ("character", color), ("character-line", line)]
        for name in CHARACTER_PART_ORDER:
            images.extend(((f"mask-{name}", masks[name]), (f"outline-{name}", outlines[name]), (f"detail-{name}", details[name])))
        for name, image in images:
            path = root / f"{name}.png"
            image.save(path)
            paths[name] = path
        asset = lambda name: {"path": str(paths[name]), "sha256": sha256(paths[name]), "rights_evidence": "generated regression fixture"}
        return {
            "contract_version": "1.3", "adapter_id": "whiteboard_animator", "render_route": "structured_semantic",
            "job_id": "character-detailed-part-order", "revision_id": "r1",
            "source": dict(asset("source"), supersample_scale=4), "output": str(root / "character-detailed-part-order.mp4"),
            "output_spec": {"width_px": target[0], "height_px": target[1], "pixel_format": "yuv420p", "native_audio": "none"},
            "timing": {"policy": "manual", "total_duration_seconds": 4.0, "draw_duration_seconds": 3.5, "fps": 20},
            "structured_layers": {"mode": "stacked_layer_object_complete_reveal", "paper_rgb": list(paper[:3]), "layers": [{
                "id": "learner", "draw_order": 0, "z_index": 0, "reveal_mode": "line_then_fill",
                "semantic_kind": "character", "stroke_order_policy": "head_body_upper_arms_forearms_hands_thighs_lower_legs_feet",
                "character_parts": [{
                    "part": name,
                    "mask_rgba": asset(f"mask-{name}"),
                    "outline_mask_rgba": asset(f"outline-{name}"),
                    "detail_mask_rgba": asset(f"detail-{name}"),
                } for name in CHARACTER_PART_ORDER],
                "color_rgba": asset("character"), "line_art_rgba": asset("character-line"),
                "stroke_duration_seconds": 2.7, "fill_duration_seconds": 0.8,
            }]},
        }

    def test_supported_reference_set_through_manifest_skill_entry(self):
        reports = {
            "equation": self.run_preflight("equation.png", with_tip=True),
            "simple": self.run_preflight("simple_sun_house_tree.png"),
            "gyroscope": self.run_preflight("gyroscope.png"),
            "energy_flow": self.run_preflight("energy_flow.png"),
        }
        for name, report in reports.items():
            self.assertEqual(report["status"], "supported", msg=name)
            self.assertEqual(report["adapter_id"], "whiteboard_animator")
            self.assertGreater(report["component_count"], 0)

        gyroscope = reports["gyroscope"]
        self.assertGreaterEqual(gyroscope["mixed_stroke_fill_group_count"], 1)
        fill_indexes = [entry["index"] for entry in gyroscope["schedule"] if entry["is_fill"]]
        stroke_indexes = [entry["index"] for entry in gyroscope["schedule"] if not entry["is_fill"]]
        self.assertTrue(fill_indexes and stroke_indexes)
        self.assertGreater(min(fill_indexes), max(stroke_indexes))

    def test_full_frame_connected_village_is_expected_reject(self):
        report = self.run_preflight("complex_village.png", expected_code=3)
        self.assertEqual(report["status"], "human_review")
        self.assertEqual(report["reason"], "unsupported_full_frame_connected_scene_without_structured_layers")
        self.assertIn("most_of_frame_is_non_white", report["warnings"])
        self.assertIn("one_connected_component_dominates_reveal", report["warnings"])

    def test_structured_layers_preflight_and_render(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            job = self.make_structured_job(root)
            preflight = self.run_job(root, job)
            self.assertEqual(preflight["status"], "supported")
            self.assertEqual(preflight["structured_layers"]["object_count"], 2)
            self.assertEqual(preflight["structured_layers"]["render_policy"], "background_prepainted_then_all_strokes_then_all_fills")
            self.assertAlmostEqual(preflight["schedule"][-1]["end"], 1.0, places=6)

            rendered = self.run_job(root, job, action="render")
            self.assertEqual(rendered["status"], "success_pending_human_review")
            self.assertEqual(rendered["frame_count"], 15)
            self.assertTrue(Path(rendered["output"]).is_file())

    def test_stacked_layers_support_line_then_fill_and_line_free_direct_fill(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            job = self.make_stacked_job(root)
            preflight = self.run_job(root, job)
            self.assertEqual(preflight["status"], "supported")
            facts = preflight["structured_layers"]
            self.assertEqual(facts["draw_order"], ["character", "midground", "shadow"])
            self.assertEqual(facts["z_order"], ["shadow", "midground", "character"])
            shadow = next(layer for layer in facts["layers"] if layer["id"] == "shadow")
            self.assertEqual(shadow["reveal_mode"], "direct_fill")
            self.assertEqual(shadow["line_alpha_pixels"], 0)
            self.assertIsNone(shadow["stroke_start_frame"])

            rendered = self.run_job(root, job, action="render")
            self.assertEqual(rendered["status"], "success_pending_human_review")
            capture = cv2.VideoCapture(str(job["output"]))
            frames = []
            while True:
                ok, frame = capture.read()
                if not ok:
                    break
                frames.append(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            capture.release()
            self.assertEqual(len(frames), 40)
            expected = np.array(Image.open(job["source"]["path"]).convert("RGB"))
            final_error = np.abs(frames[-1].astype(np.int16) - expected.astype(np.int16))
            self.assertLess(float(final_error.mean()), 3.0)
            self.assertLess(float(np.percentile(final_error, 95)), 7.0)
            # During the last direct-fill interval, the shadow-only strip never gains dark outline pixels.
            before = frames[23][153:167, 205:245]
            during = frames[27][153:167, 205:245]
            self.assertLessEqual(int((during.min(axis=2) < 100).sum()), int((before.min(axis=2) < 100).sum()) + 2)
            # Character was drawn first but remains above the later midground at their overlap.
            self.assertLess(float(np.abs(frames[23][100, 120].astype(np.int16) - expected[100, 120].astype(np.int16)).mean()), 12.0)

    def test_character_layer_draws_head_before_remainder_for_line_and_fill(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            job = self.make_character_head_first_job(root)
            preflight = self.run_job(root, job)
            self.assertEqual(preflight["status"], "supported")
            layer = preflight["structured_layers"]["layers"][0]
            self.assertEqual(layer["semantic_kind"], "character")
            self.assertEqual(layer["stroke_order_policy"], "head_first")
            self.assertEqual(layer["head_bbox"], [54, 3, 106, 41])
            self.assertGreater(layer["head_line_alpha_pixels"], 0)
            self.assertGreater(layer["head_color_alpha_pixels"], 0)
            source_layer = preflight["whiteboard_source_plan"]["layers"][0]
            self.assertEqual(source_layer["stroke_order_policy"], "head_first")
            self.assertEqual(source_layer["head_bbox"], [54, 3, 106, 41])
            stroke_entries = [entry for entry in preflight["schedule"] if entry["structured_phase"] == "stroke"]
            self.assertEqual(len(stroke_entries), 2)
            self.assertLessEqual(stroke_entries[0]["bbox"][3], 40)
            self.assertGreaterEqual(stroke_entries[1]["bbox"][1], 50)

            rendered = self.run_job(root, job, action="render")
            self.assertEqual(rendered["status"], "success_pending_human_review")
            capture = cv2.VideoCapture(str(job["output"]))
            frames = []
            while True:
                ok, frame = capture.read()
                if not ok:
                    break
                frames.append(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            capture.release()
            self.assertEqual(len(frames), 40)
            paper = np.array([249, 247, 241], dtype=np.int16)

            early_line_delta = np.max(np.abs(frames[2].astype(np.int16) - paper), axis=2)
            self.assertGreater(int((early_line_delta[3:41, 54:106] > 18).sum()), 8)
            self.assertLess(int((early_line_delta[51:86, 20:140] > 18).sum()), 8)

            early_fill = frames[20].astype(np.int16)
            self.assertGreater(float(np.abs(early_fill[22, 80] - paper).mean()), 20.0)
            self.assertLess(float(np.abs(early_fill[68, 80] - paper).mean()), 10.0)

    def test_character_layer_requires_explicit_head_first_metadata(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            job = self.make_character_head_first_job(root)
            del job["structured_layers"]["layers"][0]["head_bbox"]
            report = self.run_job(root, job, expected_code=2)
            self.assertEqual(report["error"]["code"], "invalid_character_head_bbox")

    def test_character_layer_draws_head_body_hands_then_feet_for_line_and_fill(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            job = self.make_character_part_order_job(root)
            preflight = self.run_job(root, job)
            self.assertEqual(preflight["status"], "supported")
            layer = preflight["structured_layers"]["layers"][0]
            self.assertEqual(layer["stroke_order_policy"], "head_body_hands_feet")
            self.assertEqual(layer["character_part_order"], list(LEGACY_CHARACTER_PART_ORDER))
            self.assertTrue(all(layer["character_part_line_alpha_pixels"][name] > 0 for name in LEGACY_CHARACTER_PART_ORDER))
            self.assertTrue(all(layer["character_part_color_alpha_pixels"][name] > 0 for name in LEGACY_CHARACTER_PART_ORDER))
            source_layer = preflight["whiteboard_source_plan"]["layers"][0]
            self.assertEqual([part["part"] for part in source_layer["character_parts"]], list(LEGACY_CHARACTER_PART_ORDER))
            stroke_entries = [entry for entry in preflight["schedule"] if entry["structured_phase"] == "stroke"]
            self.assertEqual([entry["character_part"] for entry in stroke_entries], list(LEGACY_CHARACTER_PART_ORDER))

            rendered = self.run_job(root, job, action="render")
            self.assertEqual(rendered["status"], "success_pending_human_review")
            capture = cv2.VideoCapture(str(job["output"]))
            frames = []
            while True:
                ok, frame = capture.read()
                if not ok:
                    break
                frames.append(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            capture.release()
            self.assertEqual(len(frames), 50)
            paper = np.array([249, 247, 241], dtype=np.int16)
            early_fill = frames[30].astype(np.int16)
            self.assertGreater(float(np.abs(early_fill[16, 80] - paper).mean()), 20.0)
            self.assertLess(float(np.abs(early_fill[76, 69] - paper).mean()), 10.0)

    def test_new_character_part_order_requires_all_four_ordered_masks(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            job = self.make_character_part_order_job(root)
            job["structured_layers"]["layers"][0]["character_parts"].reverse()
            report = self.run_job(root, job, expected_code=2)
            self.assertEqual(report["error"]["code"], "invalid_character_part_order")

            job = self.make_character_part_order_job(root)
            job["structured_layers"]["layers"][0].pop("character_parts")
            report = self.run_job(root, job, expected_code=2)
            self.assertEqual(report["error"]["code"], "character_parts_required")

            job = self.make_character_part_order_job(root)
            parts = job["structured_layers"]["layers"][0]["character_parts"]
            parts[1]["mask_rgba"] = dict(parts[0]["mask_rgba"])
            report = self.run_job(root, job, expected_code=2)
            self.assertEqual(report["error"]["code"], "overlapping_character_part_masks")

    def test_detailed_character_draws_each_outline_then_details_in_anatomical_order(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            job = self.make_detailed_character_order_job(root)
            preflight = self.run_job(root, job)
            self.assertEqual(preflight["status"], "supported")
            layer = preflight["structured_layers"]["layers"][0]
            self.assertEqual(layer["character_part_order"], list(CHARACTER_PART_ORDER))
            self.assertEqual(layer["character_part_stroke_phase_order"], ["outline", "details"])
            self.assertTrue(all(layer["character_part_outline_alpha_pixels"][name] > 0 for name in CHARACTER_PART_ORDER))
            self.assertTrue(all(layer["character_part_detail_alpha_pixels"][name] > 0 for name in CHARACTER_PART_ORDER))
            expected = [(name, phase) for name in CHARACTER_PART_ORDER for phase in ("outline", "details")]
            stroke_entries = [entry for entry in preflight["schedule"] if entry["structured_phase"] == "stroke"]
            self.assertEqual([(entry["character_part"], entry["character_stroke_phase"]) for entry in stroke_entries], expected)
            source_parts = preflight["whiteboard_source_plan"]["layers"][0]["character_parts"]
            self.assertTrue(all("outline_mask_rgba" in part and "detail_mask_rgba" in part for part in source_parts))

            rendered = self.run_job(root, job, action="render")
            self.assertEqual(rendered["status"], "success_pending_human_review")
            capture = cv2.VideoCapture(str(job["output"]))
            frame_count = int(capture.get(cv2.CAP_PROP_FRAME_COUNT))
            capture.release()
            self.assertEqual(frame_count, 80)

    def test_detailed_character_requires_ordered_parts_and_exact_stroke_phase_coverage(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            job = self.make_detailed_character_order_job(root)
            job["structured_layers"]["layers"][0]["character_parts"].reverse()
            report = self.run_job(root, job, expected_code=2)
            self.assertEqual(report["error"]["code"], "invalid_character_part_order")

            job = self.make_detailed_character_order_job(root)
            part = job["structured_layers"]["layers"][0]["character_parts"][0]
            part.pop("detail_mask_rgba")
            report = self.run_job(root, job, expected_code=2)
            self.assertEqual(report["error"]["code"], "invalid_structured_asset")

            job = self.make_detailed_character_order_job(root)
            parts = job["structured_layers"]["layers"][0]["character_parts"]
            parts[0]["detail_mask_rgba"] = dict(parts[0]["outline_mask_rgba"])
            report = self.run_job(root, job, expected_code=2)
            self.assertEqual(report["error"]["code"], "overlapping_character_stroke_phase_masks")

    def test_direct_fill_rejects_any_line_stage(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            job = self.make_stacked_job(root)
            shadow = next(layer for layer in job["structured_layers"]["layers"] if layer["id"] == "shadow")
            shadow["line_art_rgba"] = job["structured_layers"]["layers"][0]["line_art_rgba"]
            report = self.run_job(root, job, expected_code=2)
            self.assertEqual(report["error"]["code"], "direct_fill_must_not_have_line_stage")

    def test_contract_1_2_flat_auto_uses_4x_alpha_aware_source_plan(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            target = (160, 90)
            high = Image.new("RGBA", (target[0] * 4, target[1] * 4), (255, 255, 255, 0))
            draw = ImageDraw.Draw(high)
            draw.ellipse((40, 36, 280, 276), fill=(250, 194, 50, 255), outline=(25, 25, 25, 255), width=15)
            draw.line((320, 52, 560, 300), fill=(30, 30, 30, 255), width=13)
            source = root / "supersampled.png"
            high.save(source)
            job = {
                "contract_version": "1.2", "adapter_id": "whiteboard_animator", "render_route": "auto",
                "job_id": "supersample-flat", "revision_id": "r1",
                "source": {"path": str(source), "sha256": sha256(source), "rights_evidence": "generated regression fixture", "supersample_scale": 4},
                "output": str(root / "flat.mp4"),
                "output_spec": {"width_px": target[0], "height_px": target[1], "pixel_format": "yuv420p", "native_audio": "none"},
                "timing": {"policy": "auto", "total_duration_seconds": 6.0, "fps": 24},
            }
            report = self.run_job(root, job)
            self.assertEqual(report["status"], "supported")
            self.assertEqual(report["routing"]["route"], "flat_auto")
            self.assertEqual(report["whiteboard_source_plan"]["canvas"]["supersample_scale"], 4)
            self.assertEqual(report["whiteboard_source_plan"]["canvas"]["downsample"], "premultiplied_alpha_area")
            planned_source = report["whiteboard_source_plan"]["layers"][0]["assets"][0]
            self.assertEqual(planned_source["dimensions_px"], [target[0] * 4, target[1] * 4])
            self.assertTrue(planned_source["alpha_required"])
            self.assertEqual(planned_source["observed_mode"], "RGBA")
            self.assertTrue(report["timing_plan"]["frame_budget_conserved"])
            self.assertIn(report["timing_plan"]["selected_pace"], ("calm", "normal", "energetic"))
            rgba = np.array(high)
            downsampled = load_renderer_module().alpha_aware_area_downsample(rgba, *target)
            partial_alpha = downsampled[:, :, 3]
            self.assertGreater(int(((partial_alpha > 0) & (partial_alpha < 255)).sum()), 20)

    def test_legacy_contract_rejects_adaptive_route_field(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            job_path = self.make_job(root, "simple_sun_house_tree.png")
            job = json.loads(job_path.read_text(encoding="utf-8"))
            job["render_route"] = "flat_auto"
            report = self.run_job(root, job, expected_code=2)
            self.assertEqual(report["error"]["code"], "render_route_requires_contract_1_2")

    def test_contract_1_3_auto_routes_complex_flat_source_to_structured_review(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            target = (160, 90)
            high = Image.new("RGBA", (target[0] * 4, target[1] * 4), (255, 255, 255, 0))
            draw = ImageDraw.Draw(high)
            for row in range(2):
                for column in range(4):
                    left = (6 + column * 39) * 4
                    top = (7 + row * 40) * 4
                    right = left + 30 * 4
                    bottom = top + 30 * 4
                    draw.rounded_rectangle((left, top, right, bottom), radius=10, fill=(220, 220, 220, 255), outline=(30, 30, 30, 255), width=7)
                    for line in range(3):
                        y = top + (8 + line * 7) * 4
                        draw.line((left + 6 * 4, y, right - 6 * 4, y), fill=(30, 30, 30, 255), width=5)
            source = root / "complex-flat-cards.png"
            high.save(source)
            job = {
                "contract_version": "1.3", "adapter_id": "whiteboard_animator", "render_route": "auto",
                "job_id": "complex-flat-auto", "revision_id": "r1",
                "source": {"path": str(source), "sha256": sha256(source), "rights_evidence": "generated regression fixture", "supersample_scale": 4},
                "output": str(root / "complex-flat.mp4"),
                "output_spec": {"width_px": target[0], "height_px": target[1], "pixel_format": "yuv420p", "native_audio": "none"},
                "timing": {"policy": "auto", "total_duration_seconds": 1.0, "fps": 24},
            }
            report = self.run_job(root, job, expected_code=3)
            self.assertEqual(report["status"], "human_review")
            self.assertEqual(report["routing"]["route"], "structured_semantic")
            self.assertEqual(report["reason"], "structured_semantic_requires_explicit_layers")
            self.assertFalse(report["whiteboard_source_plan"]["flat_auto_eligible"])
            self.assertIn("structured_semantic_requires_explicit_layers", report["routing"]["blockers"])
            self.assertIn(report["whiteboard_source_plan"]["complexity_class"], ("moderate", "complex"))

            forced = json.loads(json.dumps(job))
            forced["job_id"] = "complex-flat-forced"
            forced["render_route"] = "flat_auto"
            forced_report = self.run_job(root, forced, expected_code=3)
            self.assertEqual(forced_report["routing"]["route"], "structured_semantic")
            self.assertIn("flat_auto_unsuitable_for_complex_source", forced_report["routing"]["blockers"])

    def test_contract_1_2_manual_flat_schedule_overflow_is_human_review(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            target = (160, 90)
            high = Image.new("RGBA", (target[0] * 4, target[1] * 4), (255, 255, 255, 0))
            draw = ImageDraw.Draw(high)
            draw.line((40, 80, 200, 80), fill=(30, 30, 30, 255), width=8)
            draw.line((400, 240, 560, 240), fill=(30, 30, 30, 255), width=8)
            source = root / "simple-overflow.png"
            high.save(source)
            job = {
                "contract_version": "1.2", "adapter_id": "whiteboard_animator", "render_route": "auto",
                "job_id": "simple-flat-overflow", "revision_id": "r1",
                "source": {"path": str(source), "sha256": sha256(source), "rights_evidence": "generated regression fixture", "supersample_scale": 4},
                "output": str(root / "simple-overflow.mp4"),
                "output_spec": {"width_px": target[0], "height_px": target[1], "pixel_format": "yuv420p", "native_audio": "none"},
                "timing": {"policy": "manual", "total_duration_seconds": 1.0, "draw_duration_seconds": 0.01, "fps": 24},
            }
            report = self.run_job(root, job, expected_code=3)
            self.assertEqual(report["status"], "human_review")
            self.assertEqual(report["routing"]["route"], "flat_auto")
            self.assertEqual(report["reason"], "flat_schedule_exceeds_declared_draw_budget")
            self.assertFalse(report["timing_plan"]["schedule_fits_draw_budget"])
            self.assertFalse(report["timing_plan"]["frame_budget_conserved"])
            self.assertGreater(report["timing_plan"]["actual_schedule_end_seconds"], job["timing"]["draw_duration_seconds"])

    def test_contract_1_2_structured_text_order_and_auto_timing(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            target = (160, 90)
            size = (target[0] * 4, target[1] * 4)
            paper = (249, 247, 241, 255)
            color = Image.new("RGBA", size, (0, 0, 0, 0))
            line = Image.new("RGBA", size, (0, 0, 0, 0))
            color_draw, line_draw = ImageDraw.Draw(color), ImageDraw.Draw(line)
            # Two explicit rows; boxes are authored at 4x while region metadata is output-space.
            for box in ((40, 40, 520, 130), (40, 190, 560, 285)):
                color_draw.rounded_rectangle(box, radius=22, fill=(232, 225, 202, 255))
                line_draw.rectangle((box[0] + 24, box[1] + 28, box[2] - 24, box[1] + 45), fill=(30, 30, 30, 255))
            source_rgba = Image.new("RGBA", size, paper)
            source_rgba = Image.alpha_composite(source_rgba, color)
            source_rgba = Image.alpha_composite(source_rgba, line)
            paths = {}
            for name, image in (("source", source_rgba), ("color", Image.alpha_composite(color, line)), ("line", line)):
                path = root / f"{name}.png"; image.save(path); paths[name] = path
            asset = lambda name: {"path": str(paths[name]), "sha256": sha256(paths[name]), "rights_evidence": "generated regression fixture"}
            job = {
                "contract_version": "1.2", "adapter_id": "whiteboard_animator", "render_route": "auto",
                "job_id": "text-card", "revision_id": "r1",
                "source": dict(asset("source"), supersample_scale=4), "output": str(root / "text.mp4"),
                "output_spec": {"width_px": target[0], "height_px": target[1], "pixel_format": "yuv420p", "native_audio": "none"},
                "timing": {"policy": "auto", "total_duration_seconds": 12.0, "fps": 24},
                "structured_layers": {"mode": "stacked_layer_object_complete_reveal", "paper_rgb": list(paper[:3]), "layers": [{
                    "id": "copy", "draw_order": 0, "z_index": 0, "reveal_mode": "line_then_fill", "semantic_kind": "text",
                    "color_rgba": asset("color"), "line_art_rgba": asset("line"),
                    "text_regions": [
                        {"id": "row-1", "bbox": [10, 10, 140, 33], "line_order": 0, "reading_order": 0, "direction": "left_to_right", "glyph_count": 8},
                        {"id": "row-2", "bbox": [10, 47, 145, 73], "line_order": 1, "reading_order": 1, "direction": "left_to_right", "glyph_count": 10}
                    ]
                }]},
            }
            report = self.run_job(root, job)
            self.assertEqual(report["status"], "supported")
            self.assertEqual(report["routing"]["route"], "structured_semantic")
            text_entries = [entry for entry in report["schedule"] if entry["is_text"]]
            self.assertEqual([entry["text_region_id"] for entry in text_entries], ["row-1", "row-2"])
            self.assertLessEqual(text_entries[0]["end"], text_entries[1]["start"])
            self.assertEqual(report["structured_layers"]["layers"][0]["text_reading_order"], ["row-1", "row-2"])
            self.assertTrue(report["timing_plan"]["frame_budget_conserved"])
            short_job = json.loads(json.dumps(job))
            short_job["job_id"] = "text-card-too-short"
            short_job["timing"]["total_duration_seconds"] = 1.0
            short_report = self.run_job(root, short_job, expected_code=3)
            self.assertEqual(short_report["status"], "human_review")
            self.assertEqual(short_report["reason"], "insufficient_duration_for_bounded_whiteboard_pace")
            self.assertEqual(short_report["timing_plan"]["selected_pace"], "energetic")
            self.assertIn("reduce_object_count_or_text_or_split_semantic_board", short_report["timing_plan"]["reduction_reasons"])

    def test_frontier_centroid_is_snapped_back_inside_concave_region(self):
        renderer = load_renderer_module()
        mask = np.zeros((30, 30), dtype=bool)
        mask[5:25, 5:8] = True; mask[5:25, 22:25] = True; mask[22:25, 5:25] = True
        timing = np.full(mask.shape, np.inf, dtype=np.float32)
        timing[mask] = 1.0
        component = {"mask": mask}
        point, count = renderer.frontier_point(timing, component, 1.0, 1 / 24, None)
        self.assertGreater(count, 0)
        self.assertTrue(mask[int(point[1]), int(point[0])])

    def test_tip_render_reports_zero_post_snap_outside(self):
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            job_path = self.make_job(root, "equation.png", with_tip=True)
            job = json.loads(job_path.read_text(encoding="utf-8"))
            result = self.run_job(root, job, action="render")
            self.assertEqual(result["status"], "success_pending_human_review")
            self.assertTrue(result["tip_overlay"]["snap_to_active_frontier"])
            self.assertEqual(result["tip_overlay"]["post_snap_outside_count"], 0)

    def make_v1_3_compiled_source(self, root: Path, job_id: str = "v13-source") -> tuple[dict, dict]:
        planner = load_production_planner_module()
        tip = FIXTURES / "手笔素材.png"
        request = {
            "canvas": {"width_px": 160, "height_px": 90, "paper_rgba": [249, 247, 241, 255]},
            "output_dir": str(root / job_id), "job_id": job_id, "revision_id": "r1",
            "rights_evidence": "programmatic regression fixture", "total_duration_seconds": 6.0, "fps": 12,
            "style_slice_sha256": "A" * 64,
            "tip_overlay": {
                "path": str(tip), "sha256": sha256(tip), "rights_evidence": "accepted local fixture asset",
                "tip_anchor": [0.225, 0.075], "height_fraction": 0.35,
                "max_continuous_step_fraction": 0.2, "opacity": 0.94,
            },
            "elements": [
                {"id": "card", "type": "card", "bbox": [6, 6, 104, 40], "fill_rgba": [240, 229, 196, 255], "line_rgba": [34, 31, 28, 255], "line_width": 2, "draw_order": 0, "z_index": 0},
                {"id": "curve", "type": "arrow", "points": [[15, 68], [42, 46], [68, 62], [92, 35]], "line_rgba": [42, 93, 132, 255], "line_width": 3, "draw_order": 1, "z_index": 1},
                {"id": "icon", "type": "icon", "shape": "ellipse", "bbox": [110, 34, 142, 66], "fill_rgba": [231, 119, 74, 255], "line_rgba": [34, 31, 28, 255], "line_width": 2, "draw_order": 2, "z_index": 2},
                {"id": "copy", "type": "text", "text": "RISK", "position": [14, 12], "bbox": [14, 12, 60, 28], "font_path": "C:/Windows/Fonts/arial.ttf", "font_size": 12, "line_rgba": [34, 31, 28, 255], "draw_order": 3, "z_index": 3, "line_order": 0, "reading_order": 0},
            ],
        }
        compiled = planner.compile_simple_source(request)
        return compiled, json.loads(Path(compiled["render_job"]).read_text(encoding="utf-8"))

    def test_contract_1_3_style_mapping_is_deterministic_and_does_not_mutate_profiles(self):
        planner = load_production_planner_module()
        registry = PLUGIN_ROOT / "style-profiles" / "registry.json"
        profile_dir = PLUGIN_ROOT / "style-profiles"
        before = {path: sha256(path) for path in profile_dir.rglob("*") if path.is_file()}
        results = {
            profile_id: planner.map_style_profile(registry, profile_id)
            for profile_id in ("vox_transcript_driven_handmade_collage", "youth_weather_luminous_anime", "photoreal_future_scifi_family")
        }
        repeat = planner.map_style_profile(registry, "vox_transcript_driven_handmade_collage")
        self.assertEqual(results["vox_transcript_driven_handmade_collage"]["style_slice_sha256"], repeat["style_slice_sha256"])
        self.assertIn(results["vox_transcript_driven_handmade_collage"]["compatibility"], ("compatible", "transformed", "partial"))
        self.assertIn(results["youth_weather_luminous_anime"]["compatibility"], ("compatible", "transformed", "partial", "human_review"))
        self.assertIn(results["photoreal_future_scifi_family"]["compatibility"], ("partial", "human_review", "unsupported"))
        self.assertTrue(results["photoreal_future_scifi_family"]["blockers"])
        after = {path: sha256(path) for path in profile_dir.rglob("*") if path.is_file()}
        self.assertEqual(before, after)

    def test_contract_1_3_local_source_compiler_and_complex_asset_boundary(self):
        planner = load_production_planner_module()
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            compiled, job = self.make_v1_3_compiled_source(root)
            self.assertEqual(compiled["status"], "compiled_local_source")
            self.assertEqual(compiled["text_reading_order"], ["copy"])
            with Image.open(compiled["source"]["path"]) as image:
                self.assertEqual(image.size, (640, 360))
                self.assertEqual(image.mode, "RGBA")
            report = self.run_job(root, job)
            self.assertEqual(report["status"], "supported")
            self.assertEqual(report["contract_version"], "1.3")
            self.assertEqual(report["routing"]["route"], "structured_semantic")
            complex_result = planner.compile_simple_source({
                "canvas": {"width_px": 160, "height_px": 90}, "output_dir": str(root / "complex"),
                "rights_evidence": "brief-only fixture", "elements": [{"id": "hero", "type": "complex_character", "brief": "original mascot"}],
            })
            self.assertEqual(complex_result["status"], "prompt_package_ready")
            self.assertEqual(complex_result["external_actions"]["provider_calls"], [])

    def test_contract_1_3_pilot_fingerprint_blocks_propagation_and_reuses_exact_acceptance(self):
        planner = load_production_planner_module()
        fingerprint = planner.pilot_fingerprint({
            "style_slice_sha256": "A" * 64, "source_template_version": "template-1",
            "renderer_behavior_version": "renderer-1", "render_route": "structured_semantic",
            "geometry": [1280, 720], "fps": 24, "tip_asset_sha256": "B" * 64, "tip_anchor": [0.225, 0.075],
        })
        blocked = planner.evaluate_pilot_gate(fingerprint["pilot_fingerprint_sha256"], [])
        self.assertFalse(blocked["propagation_allowed"])
        accepted = planner.evaluate_pilot_gate(fingerprint["pilot_fingerprint_sha256"], [{
            "pilot_fingerprint_sha256": fingerprint["pilot_fingerprint_sha256"], "human_accepted": True, "evidence_ref": "review://pilot-1"
        }])
        self.assertTrue(accepted["propagation_allowed"])
        changed = planner.pilot_fingerprint(dict(fingerprint["fields"], fps=30))
        self.assertFalse(planner.evaluate_pilot_gate(changed["pilot_fingerprint_sha256"], [{
            "pilot_fingerprint_sha256": fingerprint["pilot_fingerprint_sha256"], "human_accepted": True, "evidence_ref": "review://pilot-1"
        }])["propagation_allowed"])
        selected = planner.select_pilot({"candidates": [
            {"candidate_id": "simple", "text_rows": 0, "layer_count": 1},
            {"candidate_id": "risk", "curves_or_diagonals": True, "line_and_fill": True, "tip_required": True, "text_rows": 1, "pen_lifts": 3, "layer_count": 4},
        ]})
        self.assertEqual(selected["selected"]["candidate_id"], "risk")

    def test_contract_1_3_render_plan_segments_semantic_groups_and_merges_exact_frames(self):
        planner = load_production_planner_module()
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            compiled, job = self.make_v1_3_compiled_source(root)
            preflight = self.run_job(root, job)
            preflight_path = root / "preflight.json"; preflight_path.write_text(json.dumps(preflight), encoding="utf-8")
            plan = planner.build_render_plan({
                "job_path": compiled["render_job"], "preflight_report": str(preflight_path), "output_dir": str(root / "segments"),
                "pilot_gate": {"propagation_allowed": True, "approval_evidence_ref": "review://pilot"},
                "benchmark": {"effective_work_units_per_second": 1000, "max_safe_render_seconds": 2.0, "safety_factor": 1.25, "evidence_ref": "benchmark://fixture"},
            })
            self.assertEqual(plan["decision"], "segmented_render")
            self.assertGreaterEqual(len(plan["segments"]), 2)
            for left, right in zip(plan["segments"], plan["segments"][1:]):
                self.assertEqual(left["frame_range"][1], right["frame_range"][0])
                self.assertEqual(right["boundary_from_previous"], "continuous_canvas")
            failure_plan = json.loads(json.dumps(plan))
            failed_job = json.loads(Path(failure_plan["segments"][1]["job_path"]).read_text(encoding="utf-8"))
            failed_job["source"]["sha256"] = "0" * 64
            failed_job_path = root / "failed-segment.job.json"; failed_job_path.write_text(json.dumps(failed_job), encoding="utf-8")
            failure_plan["segments"][1]["job_path"] = str(failed_job_path)
            failure_plan_path = root / "failure-plan.json"; failure_plan_path.write_text(json.dumps(failure_plan), encoding="utf-8")
            failed_result = planner.execute_plan({"plan_path": str(failure_plan_path)})
            self.assertEqual(failed_result["status"], "stopped_after_segment_failure")
            self.assertEqual(len(failed_result["retained_passed_segments"]), 1)
            self.assertTrue(failed_result["downstream_segments_not_started"])
            self.assertEqual(failed_result["retry_owner"], "existing_execution_state")
            plan_path = root / "render-plan.json"; plan_path.write_text(json.dumps(plan, ensure_ascii=False, indent=2), encoding="utf-8")
            result = planner.execute_plan({"plan_path": str(plan_path), "final_output": str(root / "merged.mp4")})
            self.assertEqual(result["status"], "success_pending_human_review")
            self.assertEqual(result["merge"]["frame_count"], preflight["timing_plan"]["total_frames"])
            self.assertTrue(result["merge"]["full_decode"])
            self.assertTrue(all(not boundary["flash_white"] for boundary in result["merge"]["boundaries"]))

    def test_contract_1_3_long_static_hold_does_not_force_split_and_board_cut_is_explicit(self):
        planner = load_production_planner_module()
        temp_root = os.environ.get("WHITEBOARD_TEST_TEMP_ROOT") or None
        with tempfile.TemporaryDirectory(dir=temp_root) as directory:
            root = Path(directory)
            compiled, job = self.make_v1_3_compiled_source(root, "hold")
            preflight = self.run_job(root, job)
            preflight["timing_plan"]["total_frames"] += 600
            preflight["timing_plan"]["hold_frames"] += 600
            long_job = json.loads(json.dumps(job)); long_job["timing"]["total_duration_seconds"] += 50
            long_job_path = root / "hold-long.job.json"; long_job_path.write_text(json.dumps(long_job), encoding="utf-8")
            preflight_path = root / "hold-preflight.json"; preflight_path.write_text(json.dumps(preflight), encoding="utf-8")
            plan = planner.build_render_plan({
                "job_path": str(long_job_path), "preflight_report": str(preflight_path), "output_dir": str(root / "hold-plan"),
                "pilot_gate": {"propagation_allowed": True},
                "benchmark": {"effective_work_units_per_second": 500000000, "max_safe_render_seconds": 90, "evidence_ref": "benchmark://fast"},
            })
            self.assertEqual(plan["decision"], "single_render")
            board = planner.build_board_cut_plan({"job_paths": [compiled["render_job"], compiled["render_job"]], "pilot_gate": {"propagation_allowed": True}})
            self.assertEqual(board["segments"][1]["boundary_from_previous"], "board_cut")
            rendered = self.run_job(root, job, action="render")
            self.assertEqual(rendered["status"], "success_pending_human_review")
            board_report = planner.merge_segments(board, root / "board-cut.mp4")
            self.assertEqual(board_report["status"], "success_pending_human_review")
            self.assertEqual(board_report["boundaries"][0]["mode"], "board_cut")


if __name__ == "__main__":
    unittest.main()
