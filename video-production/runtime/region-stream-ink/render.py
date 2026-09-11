from __future__ import annotations

import math
from pathlib import Path
from typing import Any

import cv2
import numpy as np


class RenderCancelled(RuntimeError):
    pass


def read_image(path: Path, flags: int = cv2.IMREAD_COLOR) -> np.ndarray | None:
    """Use imdecode because cv2.imread is not Unicode-safe on all Windows builds."""
    try:
        payload = np.fromfile(path, dtype=np.uint8)
    except OSError:
        return None
    return cv2.imdecode(payload, flags)


def fit_image(image: np.ndarray, width: int, height: int, mode: str) -> np.ndarray:
    source_h, source_w = image.shape[:2]
    scale = min(width / source_w, height / source_h) if mode == "pad" else max(width / source_w, height / source_h)
    resized_w = max(1, int(round(source_w * scale)))
    resized_h = max(1, int(round(source_h * scale)))
    resized = cv2.resize(image, (resized_w, resized_h), interpolation=cv2.INTER_AREA if scale < 1 else cv2.INTER_CUBIC)
    if mode == "pad":
        canvas = np.full((height, width, 3), 255, dtype=np.uint8)
        x = (width - resized_w) // 2
        y = (height - resized_h) // 2
        canvas[y : y + resized_h, x : x + resized_w] = resized
        return canvas
    x = max(0, (resized_w - width) // 2)
    y = max(0, (resized_h - height) // 2)
    return resized[y : y + height, x : x + width].copy()


def rect_mask(height: int, width: int, rect: Any, sx: float, sy: float) -> np.ndarray:
    mask = np.zeros((height, width), dtype=bool)
    x0 = max(0, min(width, int(round(rect.x * sx))))
    y0 = max(0, min(height, int(round(rect.y * sy))))
    x1 = max(0, min(width, int(round(rect.right * sx))))
    y1 = max(0, min(height, int(round(rect.bottom * sy))))
    mask[y0:y1, x0:x1] = True
    return mask


def morphological_skeleton(binary: np.ndarray) -> np.ndarray:
    image = binary.astype(np.uint8) * 255
    skeleton = np.zeros_like(image)
    element = cv2.getStructuringElement(cv2.MORPH_CROSS, (3, 3))
    limit = max(image.shape)
    for _ in range(limit):
        eroded = cv2.erode(image, element)
        opened = cv2.dilate(eroded, element)
        skeleton = cv2.bitwise_or(skeleton, cv2.subtract(image, opened))
        image = eroded
        if cv2.countNonZero(image) == 0:
            break
    return skeleton > 0


def ordered_points(ink: np.ndarray, mode: str, grid_edge: int = 4) -> list[tuple[int, int]]:
    target = morphological_skeleton(ink) if mode == "skeleton" else ink
    if mode == "grid":
        points: list[tuple[int, int]] = []
        for y in range(0, target.shape[0], grid_edge):
            row = []
            for x in range(0, target.shape[1], grid_edge):
                if target[y : y + grid_edge, x : x + grid_edge].any():
                    row.append((min(x + grid_edge // 2, target.shape[1] - 1), min(y + grid_edge // 2, target.shape[0] - 1)))
            points.extend(row if (y // grid_edge) % 2 == 0 else reversed(row))
        return points
    count, labels = cv2.connectedComponents(target.astype(np.uint8), connectivity=8)
    components: list[list[tuple[int, int]]] = []
    for label in range(1, count):
        ys, xs = np.where(labels == label)
        points = sorted(zip(xs.tolist(), ys.tolist()), key=lambda p: (p[1], p[0]))
        if points:
            components.append(points)
    components.sort(key=lambda points: points[0])
    return [point for component in components for point in component]


def progress_index(length: int, frame: int, frames: int) -> int:
    if length <= 1 or frames <= 1:
        return max(0, length - 1)
    return int(round(frame * (length - 1) / (frames - 1)))


class RegionRenderer:
    def __init__(self, image: np.ndarray, annotation: dict[str, Any], job: dict[str, Any]):
        spec = job["output_spec"]
        self.width = spec["width_px"]
        self.height = spec["height_px"]
        self.source = fit_image(image, self.width, self.height, spec["fit_mode"])
        self.annotation = annotation
        self.job = job
        self.sx = self.width / annotation["canvas"]["width"]
        self.sy = self.height / annotation["canvas"]["height"]
        gray = cv2.cvtColor(self.source, cv2.COLOR_BGR2GRAY)
        self.ink = gray < 245
        self.canvas = np.full_like(self.source, 255)
        self.region_masks = {region["region_id"]: rect_mask(self.height, self.width, region["rect"], self.sx, self.sy) for region in annotation["regions"]}
        self.permanent = np.zeros((self.height, self.width), dtype=bool)
        self.protections = annotation["protected_regions"]
        for item in self.protections:
            if item["kind"] == "permanent":
                self.permanent |= rect_mask(self.height, self.width, item["rect"], self.sx, self.sy)

    def coverage_facts(self) -> dict[str, Any]:
        covered = np.zeros_like(self.ink)
        for mask in self.region_masks.values():
            covered |= mask
        eligible = self.ink & ~self.permanent
        uncovered = eligible & ~covered
        return {"ink_pixels": int(self.ink.sum()), "permanently_protected_ink_pixels": int((self.ink & self.permanent).sum()), "uncovered_ink_pixels": int(uncovered.sum()), "coverage_ratio": 1.0 if eligible.sum() == 0 else float(1.0 - uncovered.sum() / eligible.sum())}

    def allowed_mask(self, index: int) -> np.ndarray:
        region = self.annotation["regions"][index]
        allowed = self.region_masks[region["region_id"]].copy()
        for later in self.annotation["regions"][index + 1 :]:
            allowed &= ~self.region_masks[later["region_id"]]
        for protection in self.protections:
            mask = rect_mask(self.height, self.width, protection["rect"], self.sx, self.sy)
            if protection["kind"] == "permanent":
                allowed &= ~mask
            elif self.annotation["regions"].index(next(item for item in self.annotation["regions"] if item["region_id"] == protection["until_region_id"])) > index:
                allowed &= ~mask
        return allowed

    def _tip(self, frame: np.ndarray, point: tuple[int, int] | None) -> np.ndarray:
        overlay = self.job["render_style"]["tip_overlay"]
        if overlay == "none" or point is None:
            return frame
        tip = cv2.imread(overlay["path"], cv2.IMREAD_UNCHANGED)
        if tip is None or tip.shape[2] != 4:
            return frame
        output = frame.copy()
        x, y = point
        h, w = tip.shape[:2]
        x0, y0 = max(0, x - w // 2), max(0, y - h // 2)
        x1, y1 = min(self.width, x0 + w), min(self.height, y0 + h)
        crop = tip[: y1 - y0, : x1 - x0]
        alpha = crop[:, :, 3:4].astype(np.float32) / 255.0
        output[y0:y1, x0:x1] = (crop[:, :, :3] * alpha + output[y0:y1, x0:x1] * (1.0 - alpha)).astype(np.uint8)
        return output

    def render_frames(self, cancel_check=None) -> tuple[list[np.ndarray], dict[str, Any]]:
        total = self.job["timing"]["scene_duration_frames"]
        style = self.job["render_style"]
        frames: list[np.ndarray] = []
        cursor = 0
        per_region: list[dict[str, Any]] = []
        for index, region in enumerate(self.annotation["regions"]):
            if cancel_check and cancel_check():
                raise RenderCancelled("render cancelled before region execution")
            while cursor < region["start_frame"]:
                frames.append(self.canvas.copy())
                cursor += 1
            allowed = self.allowed_mask(index)
            region_ink = self.ink & allowed
            points = ordered_points(region_ink, style["ink_path"])
            duration = region["duration_frames"]
            ink_frames = duration if style["reveal_mode"] == "ink_only" else max(1, duration // 2)
            color_frames = duration - ink_frames
            revealed = np.zeros(self.ink.shape, dtype=np.uint8)
            last_point: tuple[int, int] | None = None
            for frame_index in range(ink_frames):
                if cancel_check and cancel_check():
                    raise RenderCancelled("render cancelled during ink execution")
                if points:
                    end = progress_index(len(points), frame_index, ink_frames)
                    for point in points[: end + 1]:
                        cv2.circle(revealed, point, 2, 255, thickness=-1)
                    ink_now = (revealed > 0) & region_ink
                    self.canvas[ink_now] = self.source[ink_now]
                    last_point = points[end]
                frames.append(self._tip(self.canvas.copy(), last_point))
                cursor += 1
            for frame_index in range(color_frames):
                if cancel_check and cancel_check():
                    raise RenderCancelled("render cancelled during color execution")
                progress = (frame_index + 1) / max(1, color_frames)
                limit = int(math.ceil(self.height * progress))
                reveal = allowed.copy()
                reveal[limit:, :] = False
                self.canvas[reveal] = self.source[reveal]
                frames.append(self._tip(self.canvas.copy(), last_point))
                cursor += 1
            per_region.append({"region_id": region["region_id"], "start_frame": region["start_frame"], "frame_count": duration, "ink_path_points": len(points), "empty_path": len(points) == 0})
        while cursor < total:
            if cancel_check and cancel_check():
                raise RenderCancelled("render cancelled during tail hold")
            frames.append(self.canvas.copy())
            cursor += 1
        if len(frames) != total:
            raise RuntimeError(f"renderer emitted {len(frames)} frames for a {total}-frame job")
        return frames, {"regions": per_region, "frame_count": len(frames), "coverage": self.coverage_facts()}


def write_mp4v(frames: list[np.ndarray], path: Path, fps: int, width: int, height: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    writer = cv2.VideoWriter(str(path), cv2.VideoWriter_fourcc(*"mp4v"), fps, (width, height))
    if not writer.isOpened():
        raise RuntimeError("OpenCV VideoWriter could not open the temporary output")
    try:
        for frame in frames:
            writer.write(frame)
    finally:
        writer.release()
