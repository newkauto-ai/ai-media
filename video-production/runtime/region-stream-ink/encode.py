from __future__ import annotations

import json
import shutil
import subprocess
from fractions import Fraction
from pathlib import Path
from typing import Any


class EncodeError(RuntimeError):
    def __init__(self, code: str, message: str, attempts: list[dict[str, Any]] | None = None):
        super().__init__(message)
        self.code = code
        self.attempts = attempts or []


def _run(command: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, capture_output=True, text=True, encoding="utf-8", errors="replace", check=False)


def ffprobe(path: Path, ffprobe_bin: str = "ffprobe", count_frames: bool = True) -> dict[str, Any]:
    command = [ffprobe_bin, "-v", "error", "-show_streams", "-show_format", "-of", "json"]
    if count_frames:
        command.extend(["-count_frames"])
    command.append(str(path))
    result = _run(command)
    if result.returncode != 0:
        raise EncodeError("probe_failed", result.stderr.strip() or "ffprobe failed")
    return json.loads(result.stdout)


def video_facts(path: Path, ffprobe_bin: str = "ffprobe") -> dict[str, Any]:
    data = ffprobe(path, ffprobe_bin)
    videos = [stream for stream in data.get("streams", []) if stream.get("codec_type") == "video"]
    audios = [stream for stream in data.get("streams", []) if stream.get("codec_type") == "audio"]
    if len(videos) != 1:
        raise EncodeError("invalid_video_stream_count", f"expected one video stream, found {len(videos)}")
    stream = videos[0]
    rate = stream.get("avg_frame_rate") or stream.get("r_frame_rate") or "0/1"
    frames = stream.get("nb_read_frames") or stream.get("nb_frames")
    return {
        "width_px": int(stream["width"]),
        "height_px": int(stream["height"]),
        "codec": stream.get("codec_name"),
        "pix_fmt": stream.get("pix_fmt"),
        "frame_rate": str(rate),
        "time_base": stream.get("time_base"),
        "frame_count": int(frames) if frames not in (None, "N/A") else None,
        "duration_seconds": float(stream.get("duration") or data.get("format", {}).get("duration") or 0),
        "audio_stream_count": len(audios),
    }


def decode_all(path: Path, ffmpeg_bin: str = "ffmpeg") -> None:
    result = _run([ffmpeg_bin, "-v", "error", "-i", str(path), "-map", "0:v:0", "-f", "null", "-"])
    if result.returncode != 0:
        raise EncodeError("full_decode_failed", result.stderr.strip() or "full decode failed")


def timestamp_facts(path: Path, ffprobe_bin: str = "ffprobe") -> dict[str, Any]:
    result = _run([ffprobe_bin, "-v", "error", "-select_streams", "v:0", "-show_frames", "-show_entries", "frame=best_effort_timestamp_time", "-of", "json", str(path)])
    if result.returncode != 0:
        raise EncodeError("timestamp_probe_failed", result.stderr.strip() or "timestamp probe failed")
    values = [float(frame["best_effort_timestamp_time"]) for frame in json.loads(result.stdout).get("frames", []) if frame.get("best_effort_timestamp_time") not in (None, "N/A")]
    if not values or any(right <= left for left, right in zip(values, values[1:])):
        raise EncodeError("non_monotonic_timestamps", "video timestamps are missing or not strictly increasing")
    return {"monotonic": True, "timestamp_count": len(values), "first_seconds": values[0], "last_seconds": values[-1]}


def _verify_h264(path: Path, width: int, height: int, fps: int, expected_frames: int, ffmpeg_bin: str, ffprobe_bin: str) -> dict[str, Any]:
    facts = video_facts(path, ffprobe_bin)
    actual_fps = Fraction(facts["frame_rate"])
    if facts["codec"] != "h264" or facts["pix_fmt"] != "yuv420p":
        raise EncodeError("output_codec_mismatch", f"expected H.264 yuv420p, found {facts['codec']} {facts['pix_fmt']}")
    if facts["width_px"] != width or facts["height_px"] != height or actual_fps != Fraction(fps, 1):
        raise EncodeError("output_spec_mismatch", "encoded dimensions or frame rate do not match the job")
    if facts["frame_count"] != expected_frames:
        raise EncodeError("frame_count_mismatch", f"expected {expected_frames} frames, found {facts['frame_count']}")
    if facts["audio_stream_count"] != 0:
        raise EncodeError("unexpected_audio", "visual_track must not contain audio")
    decode_all(path, ffmpeg_bin)
    facts["timestamps"] = timestamp_facts(path, ffprobe_bin)
    return facts


def _encode_ffmpeg(raw_path: Path, output_path: Path, fps: int, ffmpeg_bin: str) -> None:
    if not shutil.which(ffmpeg_bin):
        raise EncodeError("ffmpeg_unavailable", f"{ffmpeg_bin} was not found")
    result = _run([ffmpeg_bin, "-y", "-v", "error", "-i", str(raw_path), "-an", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-r", str(fps), "-vsync", "cfr", "-movflags", "+faststart", str(output_path)])
    if result.returncode != 0:
        raise EncodeError("ffmpeg_encode_failed", result.stderr.strip() or "FFmpeg encoding failed")


def _encode_pyav(raw_path: Path, output_path: Path, fps: int) -> None:
    try:
        import av
    except ImportError as exc:
        raise EncodeError("pyav_unavailable", str(exc)) from exc
    try:
        with av.open(str(raw_path), mode="r") as source, av.open(str(output_path), mode="w") as target:
            input_stream = source.streams.video[0]
            output_stream = target.add_stream("libx264", rate=fps)
            output_stream.width = input_stream.width
            output_stream.height = input_stream.height
            output_stream.pix_fmt = "yuv420p"
            for frame in source.decode(input_stream):
                for packet in output_stream.encode(frame):
                    target.mux(packet)
            for packet in output_stream.encode():
                target.mux(packet)
    except Exception as exc:
        raise EncodeError("pyav_encode_failed", str(exc)) from exc


def encode_h264(raw_path: Path, output_path: Path, width: int, height: int, fps: int, expected_frames: int, ffmpeg_bin: str = "ffmpeg", ffprobe_bin: str = "ffprobe", force_ffmpeg_failure: bool = False, force_pyav_failure: bool = False) -> tuple[str, dict[str, Any], list[dict[str, Any]]]:
    attempts: list[dict[str, Any]] = []
    output_path.parent.mkdir(parents=True, exist_ok=True)
    try:
        if force_ffmpeg_failure:
            raise EncodeError("ffmpeg_encode_failed", "forced test failure")
        _encode_ffmpeg(raw_path, output_path, fps, ffmpeg_bin)
        facts = _verify_h264(output_path, width, height, fps, expected_frames, ffmpeg_bin, ffprobe_bin)
        attempts.append({"encoder": "ffmpeg", "status": "success"})
        return "ffmpeg", facts, attempts
    except Exception as exc:
        attempts.append({"encoder": "ffmpeg", "status": "failed", "error": str(exc)})
        if output_path.exists():
            output_path.unlink()
    try:
        if force_pyav_failure:
            raise EncodeError("pyav_encode_failed", "forced test failure")
        _encode_pyav(raw_path, output_path, fps)
        facts = _verify_h264(output_path, width, height, fps, expected_frames, ffmpeg_bin, ffprobe_bin)
        attempts.append({"encoder": "pyav", "status": "success"})
        return "pyav", facts, attempts
    except Exception as exc:
        attempts.append({"encoder": "pyav", "status": "failed", "error": str(exc)})
        if output_path.exists():
            output_path.unlink()
        raise EncodeError("h264_encoding_failed", "FFmpeg and PyAV encoding both failed", attempts) from exc


def _homogeneous(facts: list[dict[str, Any]]) -> bool:
    fields = ("width_px", "height_px", "frame_rate", "codec", "pix_fmt", "time_base")
    return all(all(item[field] == facts[0][field] for field in fields) for item in facts[1:])


def merge_homogeneous(inputs: list[Path], output_path: Path, ffmpeg_bin: str = "ffmpeg", ffprobe_bin: str = "ffprobe", force_ffmpeg_failure: bool = False, force_pyav_failure: bool = False) -> dict[str, Any]:
    if len(inputs) < 2:
        raise EncodeError("insufficient_inputs", "merge requires at least two clips")
    facts = [video_facts(path, ffprobe_bin) for path in inputs]
    if not _homogeneous(facts):
        raise EncodeError("heterogeneous_inputs", "width, height, frame rate, codec, pix_fmt, and time base must match")
    expected_frames = sum(int(item["frame_count"]) for item in facts)
    attempts: list[dict[str, Any]] = []
    list_path = output_path.with_suffix(".concat.txt")
    try:
        if force_ffmpeg_failure:
            raise EncodeError("ffmpeg_merge_failed", "forced test failure")
        list_path.write_text("".join(f"file '{str(path.resolve()).replace(chr(39), chr(39)+chr(92)+chr(39)+chr(39))}'\n" for path in inputs), encoding="utf-8")
        result = _run([ffmpeg_bin, "-y", "-v", "error", "-f", "concat", "-safe", "0", "-i", str(list_path), "-an", "-c", "copy", str(output_path)])
        if result.returncode != 0:
            raise EncodeError("ffmpeg_merge_failed", result.stderr.strip() or "FFmpeg merge failed")
        attempts.append({"merger": "ffmpeg", "status": "success"})
    except Exception as exc:
        attempts.append({"merger": "ffmpeg", "status": "failed", "error": str(exc)})
        if output_path.exists():
            output_path.unlink()
        if force_pyav_failure:
            attempts.append({"merger": "pyav", "status": "failed", "error": "forced test failure"})
            raise EncodeError("merge_failed", "FFmpeg and PyAV merge both failed", attempts) from exc
        try:
            import av
            rate = Fraction(facts[0]["frame_rate"])
            with av.open(str(output_path), "w") as target:
                stream = target.add_stream("libx264", rate=rate)
                stream.width = facts[0]["width_px"]
                stream.height = facts[0]["height_px"]
                stream.pix_fmt = "yuv420p"
                for path in inputs:
                    with av.open(str(path), "r") as source:
                        for frame in source.decode(source.streams.video[0]):
                            for packet in stream.encode(frame):
                                target.mux(packet)
                for packet in stream.encode():
                    target.mux(packet)
            attempts.append({"merger": "pyav", "status": "success"})
        except Exception as pyav_exc:
            attempts.append({"merger": "pyav", "status": "failed", "error": str(pyav_exc)})
            raise EncodeError("merge_failed", "FFmpeg and PyAV merge both failed", attempts) from pyav_exc
    finally:
        if list_path.exists():
            list_path.unlink()
    output_facts = video_facts(output_path, ffprobe_bin)
    decode_all(output_path, ffmpeg_bin)
    output_facts["timestamps"] = timestamp_facts(output_path, ffprobe_bin)
    if output_facts["frame_count"] != expected_frames or output_facts["audio_stream_count"] != 0:
        raise EncodeError("merged_output_invalid", "merged frame count or audio-stream policy failed", attempts)
    offsets = []
    cursor = 0
    for path, item in zip(inputs, facts):
        offsets.append({"path": str(path), "start_frame": cursor, "frame_count": item["frame_count"]})
        cursor += item["frame_count"]
    return {"status": "success", "output": str(output_path), "facts": output_facts, "clip_offsets": offsets, "attempts": attempts}
