#!/usr/bin/env python3
"""Split a verified transparent 2x2 or 3x3 atlas into named RGBA PNG assets."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

from PIL import Image, UnidentifiedImageError


class SplitError(RuntimeError):
    pass


def parse_grid(value: str) -> tuple[int, int]:
    if value == "2x2":
        return 2, 2
    if value == "3x3":
        return 3, 3
    raise argparse.ArgumentTypeError("grid must be 2x2 or 3x3")


def parse_names(value: str) -> list[str]:
    raw = [item.strip() for item in value.split(",")]
    if not raw or any(not item for item in raw):
        raise argparse.ArgumentTypeError("names must be a non-empty comma-separated list")
    names: list[str] = []
    for item in raw:
        name = item if item.lower().endswith(".png") else f"{item}.png"
        if Path(name).name != name or name in {".png", "..png"}:
            raise argparse.ArgumentTypeError(f"unsafe output name: {item}")
        names.append(name)
    if len({name.casefold() for name in names}) != len(names):
        raise argparse.ArgumentTypeError("output names must be unique")
    return names


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest().upper()


def cell_label(index: int) -> str:
    return chr(ord("A") + index)


def cell_bounds(index: int, columns: int, rows: int, width: int, height: int) -> tuple[int, int, int, int]:
    row, column = divmod(index, columns)
    left = round(column * width / columns)
    right = round((column + 1) * width / columns)
    top = round(row * height / rows)
    bottom = round((row + 1) * height / rows)
    return left, top, right, bottom


def visible_bbox(image: Image.Image, alpha_threshold: int) -> tuple[int, int, int, int] | None:
    alpha = image.getchannel("A")
    mask = alpha.point(lambda value: 255 if value > alpha_threshold else 0)
    return mask.getbbox()


def validate_ratio(value: float, name: str, maximum: float) -> float:
    if value < 0 or value >= maximum:
        raise SplitError(f"{name} must be at least 0 and less than {maximum}")
    return value


def prepare_assets(args: argparse.Namespace) -> tuple[Image.Image, list[dict[str, object]]]:
    input_path = args.input.resolve()
    if not input_path.is_file():
        raise SplitError(f"input atlas does not exist: {input_path}")

    try:
        with Image.open(input_path) as source:
            if source.format != "PNG":
                raise SplitError("input atlas must be a PNG")
            has_alpha = "A" in source.getbands() or "transparency" in source.info
            if not has_alpha:
                raise SplitError("input atlas has no Alpha channel; solid-background removal is not performed")
            atlas = source.convert("RGBA")
    except UnidentifiedImageError as exc:
        raise SplitError("input atlas is not a readable image") from exc

    alpha_min, alpha_max = atlas.getchannel("A").getextrema()
    if alpha_min == 255:
        raise SplitError("input atlas is fully opaque; verify a genuinely transparent Web Chat download")
    if alpha_max <= args.alpha_threshold:
        raise SplitError("input atlas contains no visible subjects")

    columns, rows = args.grid
    capacity = columns * rows
    if len(args.names) > capacity:
        raise SplitError(f"{columns}x{rows} atlas accepts at most {capacity} names")

    padding_ratio = validate_ratio(args.padding_ratio, "padding-ratio", 0.25)
    clearance_ratio = validate_ratio(args.edge_clearance_ratio, "edge-clearance-ratio", 0.25)

    prepared: list[dict[str, object]] = []
    for index in range(capacity):
        bounds = cell_bounds(index, columns, rows, atlas.width, atlas.height)
        cell = atlas.crop(bounds)
        bbox = visible_bbox(cell, args.alpha_threshold)
        label = cell_label(index)

        if index >= len(args.names):
            if bbox is not None:
                raise SplitError(f"unused cell {label} is not empty")
            continue
        if bbox is None:
            raise SplitError(f"mapped cell {label} is empty")

        cell_width, cell_height = cell.size
        clearance = {
            "left": bbox[0],
            "top": bbox[1],
            "right": cell_width - bbox[2],
            "bottom": cell_height - bbox[3],
        }
        required_clearance = round(min(cell_width, cell_height) * clearance_ratio)
        if min(clearance.values()) < required_clearance:
            raise SplitError(
                f"cell {label} subject touches or approaches its cell edge "
                f"(required clearance {required_clearance}px, observed {min(clearance.values())}px)"
            )

        subject_width = bbox[2] - bbox[0]
        subject_height = bbox[3] - bbox[1]
        padding = round(max(subject_width, subject_height) * padding_ratio)
        crop_box = (
            max(0, bbox[0] - padding),
            max(0, bbox[1] - padding),
            min(cell_width, bbox[2] + padding),
            min(cell_height, bbox[3] + padding),
        )
        output_image = cell.crop(crop_box)
        output_alpha_min, output_alpha_max = output_image.getchannel("A").getextrema()
        if output_alpha_min == 255 or output_alpha_max <= args.alpha_threshold:
            raise SplitError(f"cell {label} output does not retain a usable transparent RGBA boundary")

        prepared.append(
            {
                "cell": label,
                "filename": args.names[index],
                "cell_bounds": list(bounds),
                "subject_bbox_in_cell": list(bbox),
                "crop_box_in_cell": list(crop_box),
                "edge_clearance_px": clearance,
                "image": output_image,
            }
        )

    return atlas, prepared


def write_assets(args: argparse.Namespace, atlas: Image.Image, prepared: list[dict[str, object]]) -> dict[str, object]:
    output_dir = args.output_dir.resolve()
    output_paths = [output_dir / str(item["filename"]) for item in prepared]
    report_path = args.report.resolve() if args.report else None
    existing = [path for path in output_paths + ([report_path] if report_path else []) if path and path.exists()]
    if existing and not args.overwrite:
        raise SplitError("refusing to overwrite existing output: " + ", ".join(str(path) for path in existing))

    output_dir.mkdir(parents=True, exist_ok=True)
    records: list[dict[str, object]] = []
    for item, output_path in zip(prepared, output_paths):
        image = item.pop("image")
        assert isinstance(image, Image.Image)
        image.save(output_path, format="PNG")
        record = dict(item)
        record.update(
            {
                "path": str(output_path),
                "width": image.width,
                "height": image.height,
                "mode": image.mode,
                "sha256": sha256(output_path),
            }
        )
        records.append(record)

    report = {
        "tool": "split-transparent-atlas",
        "input": str(args.input.resolve()),
        "input_sha256": sha256(args.input.resolve()),
        "grid": f"{args.grid[0]}x{args.grid[1]}",
        "source_width": atlas.width,
        "source_height": atlas.height,
        "alpha_threshold": args.alpha_threshold,
        "padding_ratio": args.padding_ratio,
        "edge_clearance_ratio": args.edge_clearance_ratio,
        "background_removal_performed": False,
        "outline_generated_or_recolored": False,
        "outputs": records,
    }
    if report_path:
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return report


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Split a verified true-alpha Web Chat atlas into named independent RGBA PNG files."
    )
    parser.add_argument("--input", type=Path, required=True, help="Source transparent PNG atlas")
    parser.add_argument("--output-dir", type=Path, required=True, help="Directory for independent PNG outputs")
    parser.add_argument("--grid", type=parse_grid, required=True, help="Atlas grid: 2x2 or 3x3")
    parser.add_argument("--names", type=parse_names, required=True, help="Row-major comma-separated output names")
    parser.add_argument("--padding-ratio", type=float, default=0.04, help="Transparent padding relative to subject size")
    parser.add_argument(
        "--edge-clearance-ratio",
        type=float,
        default=0.02,
        help="Minimum empty clearance relative to the shorter cell edge",
    )
    parser.add_argument("--alpha-threshold", type=int, default=1, choices=range(0, 255))
    parser.add_argument("--report", type=Path, help="Optional JSON report path")
    parser.add_argument("--overwrite", action="store_true", help="Explicitly replace existing named outputs/report")
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    try:
        atlas, prepared = prepare_assets(args)
        report = write_assets(args, atlas, prepared)
    except SplitError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
