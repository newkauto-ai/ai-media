# Region Stream Ink Local Renderer Adapter v1.0

This optional Adapter belongs to `video-production`. It does not create another Controller, Skill, Manifest, Gate, QA system, state source, or retry ledger.

## Capability and provenance

- `adapter_id`: `region_stream_ink`
- access: `local_cli`
- output: silent `visual_track.mp4`
- native audio: `none`
- renderer: isolated Python runtime using OpenCV and NumPy for frame generation, OpenCV `VideoWriter` for the temporary `mp4v` stream, FFmpeg first and PyAV second for verified H.264 `yuv420p`
- inspiration and adapted algorithm concepts: `geeklee/srt-whiteboard-animation`, pinned at commit `696a724`, MIT license; the retained notice is at `runtime/region-stream-ink/LICENSE.upstream-MIT.txt`
- local differences: integer-frame authority, strict annotation/job contracts, explicit output geometry, true `ink_only`, separated deferred/permanent protection, uncovered-ink preflight, no default hand/brand/font dependency, structured JSON facts, verified dual-route H.264, and homogeneous-only merge

The implementation includes no upstream examples, hand/tip assets, fonts, FFmpeg binary, or Python wheels. Example media remains outside the plugin. Custom tip overlays require a non-empty `rights_evidence_ref`; the default is `none`.

## Intake and selection

Select this Adapter only in managed production after the existing Controller and Stage boundaries permit it. It is not part of `external_prompt_only`.

Before a formal Job, record or confirm for this video:

- target platform and intended viewing context;
- `aspect_ratio`, named `resolution`, even `width_px`, and even `height_px`;
- explicit `fit_mode: pad | crop`;
- source-image path/checksum/rights evidence;
- annotation path/checksum/current revision approval evidence;
- integer frame rate, total frames, tail-hold frames, and non-overlapping segments;
- `ink_path: grid | skeleton`, `reveal_mode: ink_only | ink_then_color`, and tip-overlay choice.

No global aspect ratio or resolution exists. `UNKNOWN` output fields block formal execution, and the CLI has no `cap_long_edge=1080` fallback. Changing geometry invalidates image composition, annotation preview, and prior render results for that revision, not the Topic or frozen Script.

Imported user images use the existing media intake, checksum, provenance, rights, and suitability checks; they do not require a media-generation Cost Gate. A paid source-image request still requires the existing Visual Baseline and exact image Cost Gate. Local CPU rendering itself has no media-generation Cost Gate.

## Commands

Create the isolated runtime once (or when its version changes):

```powershell
video-production/runtime/region-stream-ink/setup-runtime.ps1
```

Then invoke the CLI with the Python path returned by that script:

```powershell
<isolated-python> video-production/runtime/region-stream-ink/renderer_cli.py validate --job <job.json>
<isolated-python> video-production/runtime/region-stream-ink/renderer_cli.py preview --job <job.json> --output <annotation_preview.png>
<isolated-python> video-production/runtime/region-stream-ink/renderer_cli.py render --job <job.json> --report <execution-report.json>
<isolated-python> video-production/runtime/region-stream-ink/renderer_cli.py merge --inputs <clip-a.mp4> <clip-b.mp4> --output <visual_track.mp4> --report <merge-report.json>
```

For cancellation, pass `--cancel-file <path>` and create that file from the supervising process. The CLI stops at a frame boundary, returns structured `status: cancelled`, and does not claim an output.

Every command prints one structured JSON object. A successful render report contains `job_id`, `revision_id`, `clip_id`, `adapter_id`, Renderer version, canonical input hash, input and output checksums, encoder attempts, actual media facts, exact frame count, coverage facts, and `external_audio_sync: not_verified`. It never records approval, QA PASS, user acceptance, publication, or retry state.

## Execution and failure rules

- The annotation preview is an artifact for existing revision-bound human evidence; it is not a new Annotation Gate.
- Tail hold is inside `scene_duration_frames`; no frame may be appended implicitly.
- Empty masks and paths emit the assigned number of static frames.
- `ink_only` never runs color reveal and never restores the original image at the end.
- `ink_then_color` reveals only the currently allowed region. Permanent protection is never revealed. Deferred protection remains hidden until its named region.
- Uncovered eligible ink blocks unless annotation explicitly records `allow_uncovered_ink: true`.
- FFmpeg and PyAV failures return `h264_encoding_failed`; the temporary `mp4v` file is never reported as a successful deliverable.
- Merge validates width, height, frame rate, codec, pixel format, and time base before concatenation. Heterogeneous inputs are rejected in v1.0.
- Success requires H.264 `yuv420p`, the declared geometry/frame rate/count, no audio streams, and full decode. Merge additionally returns an ordered clip-offset table.
- Cancellation or process failure may leave the `.mp4v.tmp.mp4` diagnostic intermediate; a successful H.264 render removes it. Completed verified Clips remain independently reusable.

After rendering, use existing media intake to bind the real file to one `clip_id + revision_id + sha256`, write Production QA only to `production_manifest.qa.results`, and route retries only through existing Execution State. Renderer success means only that a silent visual track passed deterministic execution checks; it does not prove visual quality, external narration sync, human approval, Final Master completion, or publication.

## License boundary

- Adapted upstream code/concepts: MIT, notice retained.
- NumPy: BSD-3-Clause; OpenCV Python packages: Apache-2.0; Pillow: HPND; PyAV: BSD-3-Clause. Verify the pinned release metadata before redistribution.
- FFmpeg is detected as a system dependency and is not bundled. Its applicable license depends on the installed build and configuration; record `ffmpeg -version` for the Job environment.
- Fonts, examples, source images, and optional tip assets are not bundled. Their rights must be established independently.

Rollback is to stop selecting `region_stream_ink` for new Jobs. Existing Script, ADP, assets, QA, and other Adapters remain valid. Retain Renderer/version/license evidence for historical outputs; removing the isolated runtime makes those Jobs non-rerenderable but does not invalidate already verified files.
