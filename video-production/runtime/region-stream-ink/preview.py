from __future__ import annotations

from pathlib import Path
from typing import Any

import cv2

from render import fit_image, read_image


def create_preview(image_path: Path, annotation: dict[str, Any], width: int, height: int, fit_mode: str, output_path: Path) -> dict[str, Any]:
    image = read_image(image_path, cv2.IMREAD_COLOR)
    if image is None:
        raise ValueError(f"cannot read image: {image_path}")
    canvas = fit_image(image, width, height, fit_mode)
    sx = width / annotation["canvas"]["width"]
    sy = height / annotation["canvas"]["height"]
    for index, region in enumerate(annotation["regions"], 1):
        rect = region["rect"]
        p0 = (int(round(rect.x * sx)), int(round(rect.y * sy)))
        p1 = (int(round(rect.right * sx)), int(round(rect.bottom * sy)))
        cv2.rectangle(canvas, p0, p1, (0, 180, 0), 2)
        cv2.putText(canvas, f"R{index} {region['start_frame']}+{region['duration_frames']}", (p0[0] + 4, min(height - 4, p0[1] + 18)), cv2.FONT_HERSHEY_SIMPLEX, 0.45, (0, 90, 0), 1, cv2.LINE_AA)
    for protection in annotation["protected_regions"]:
        rect = protection["rect"]
        color = (0, 0, 255) if protection["kind"] == "permanent" else (0, 165, 255)
        p0 = (int(round(rect.x * sx)), int(round(rect.y * sy)))
        p1 = (int(round(rect.right * sx)), int(round(rect.bottom * sy)))
        cv2.rectangle(canvas, p0, p1, color, 2)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    ok, encoded = cv2.imencode(output_path.suffix or ".png", canvas)
    if not ok:
        raise ValueError(f"cannot write preview: {output_path}")
    encoded.tofile(output_path)
    return {"status": "success", "output": str(output_path), "font_dependency": "none_opencv_hershey"}
