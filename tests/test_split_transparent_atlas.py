from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from PIL import Image, ImageDraw


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPT = PROJECT_ROOT / "video-production" / "scripts" / "split-transparent-atlas.py"
SKILL_SCRIPT = PROJECT_ROOT / "skills" / "video-production" / "scripts" / "split-transparent-atlas.py"
WRAPPER = PROJECT_ROOT / "video-production" / "scripts" / "split-transparent-atlas.ps1"
SKILL_WRAPPER = PROJECT_ROOT / "skills" / "video-production" / "scripts" / "split-transparent-atlas.ps1"


class SplitTransparentAtlasTests(unittest.TestCase):
    def run_script(self, *args: str) -> subprocess.CompletedProcess[str]:
        environment = os.environ.copy()
        environment["PYTHONUTF8"] = "1"
        return subprocess.run(
            [sys.executable, str(SCRIPT), *args],
            text=True,
            capture_output=True,
            encoding="utf-8",
            env=environment,
            check=False,
        )

    def test_two_by_two_true_alpha_named_crop_and_report(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            atlas_path = root / "atlas.png"
            output_dir = root / "layers"
            report_path = root / "split-report.json"

            atlas = Image.new("RGBA", (200, 200), (0, 0, 0, 0))
            draw = ImageDraw.Draw(atlas)
            draw.rectangle((20, 20, 80, 80), fill=(160, 30, 20, 255))
            draw.rectangle((120, 20, 180, 80), fill=(30, 80, 160, 255))
            draw.rectangle((20, 120, 80, 180), fill=(220, 190, 120, 255))
            atlas.save(atlas_path)

            result = self.run_script(
                "--input",
                str(atlas_path),
                "--output-dir",
                str(output_dir),
                "--grid",
                "2x2",
                "--names",
                "emperor,envoy,seal",
                "--report",
                str(report_path),
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            report = json.loads(report_path.read_text(encoding="utf-8"))
            self.assertFalse(report["background_removal_performed"])
            self.assertFalse(report["outline_generated_or_recolored"])
            self.assertEqual(report["grid"], "2x2")
            self.assertEqual([item["cell"] for item in report["outputs"]], ["A", "B", "C"])
            self.assertEqual([item["filename"] for item in report["outputs"]], ["emperor.png", "envoy.png", "seal.png"])

            for filename in ("emperor.png", "envoy.png", "seal.png"):
                with Image.open(output_dir / filename) as image:
                    self.assertEqual(image.mode, "RGBA")
                    alpha_min, alpha_max = image.getchannel("A").getextrema()
                    self.assertEqual(alpha_min, 0)
                    self.assertEqual(alpha_max, 255)

            repeated = self.run_script(
                "--input",
                str(atlas_path),
                "--output-dir",
                str(output_dir),
                "--grid",
                "2x2",
                "--names",
                "emperor,envoy,seal",
                "--report",
                str(report_path),
            )
            self.assertEqual(repeated.returncode, 2)
            self.assertIn("refusing to overwrite", repeated.stderr)

    def test_rejects_opaque_source(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            atlas_path = root / "opaque.png"
            Image.new("RGB", (100, 100), (255, 0, 255)).save(atlas_path)
            result = self.run_script(
                "--input",
                str(atlas_path),
                "--output-dir",
                str(root / "layers"),
                "--grid",
                "2x2",
                "--names",
                "subject",
            )
            self.assertEqual(result.returncode, 2)
            self.assertIn("no Alpha channel", result.stderr)

    def test_rejects_edge_contact_and_nonempty_unused_cell(self) -> None:
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            edge_path = root / "edge.png"
            edge = Image.new("RGBA", (200, 200), (0, 0, 0, 0))
            ImageDraw.Draw(edge).rectangle((0, 20, 70, 80), fill=(1, 2, 3, 255))
            edge.save(edge_path)
            edge_result = self.run_script(
                "--input",
                str(edge_path),
                "--output-dir",
                str(root / "edge-layers"),
                "--grid",
                "2x2",
                "--names",
                "subject",
            )
            self.assertEqual(edge_result.returncode, 2)
            self.assertIn("cell edge", edge_result.stderr)

            unused_path = root / "unused.png"
            unused = Image.new("RGBA", (200, 200), (0, 0, 0, 0))
            draw = ImageDraw.Draw(unused)
            draw.rectangle((20, 20, 80, 80), fill=(1, 2, 3, 255))
            draw.rectangle((120, 20, 180, 80), fill=(4, 5, 6, 255))
            unused.save(unused_path)
            unused_result = self.run_script(
                "--input",
                str(unused_path),
                "--output-dir",
                str(root / "unused-layers"),
                "--grid",
                "2x2",
                "--names",
                "subject",
            )
            self.assertEqual(unused_result.returncode, 2)
            self.assertIn("unused cell B is not empty", unused_result.stderr)

    def test_manifest_skill_script_mirror_is_exact(self) -> None:
        self.assertEqual(SCRIPT.read_bytes(), SKILL_SCRIPT.read_bytes())
        self.assertEqual(WRAPPER.read_bytes(), SKILL_WRAPPER.read_bytes())


if __name__ == "__main__":
    unittest.main()
