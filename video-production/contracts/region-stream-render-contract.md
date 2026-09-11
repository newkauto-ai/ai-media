# Region Stream Render Contract v1.0

The immutable Job Spec is an execution artifact referenced by, but not embedded in, the Production Manifest.

```yaml
contract_version: "1.0"
job_id: string
revision_id: string
clip_id: string
adapter_id: region_stream_ink
source_image: {path: string, sha256: string, rights_evidence_ref: string}
annotation: {path: string, sha256: string, approval_evidence_ref: string}
timing:
  frame_rate: integer
  scene_duration_frames: integer
  tail_hold_frames: integer
  segments: [{element_id: string, start_frame: integer, duration_frames: integer}]
output_spec:
  aspect_ratio: confirmed-string
  resolution: confirmed-string
  width_px: even-integer
  height_px: even-integer
  fit_mode: pad | crop
render_style:
  ink_path: grid | skeleton
  reveal_mode: ink_only | ink_then_color
  tip_overlay: none | {path: string, rights_evidence_ref: string}
output_path: string
```

`aspect_ratio`, `resolution`, `width_px`, and `height_px` have no defaults. `UNKNOWN`, missing, odd, or invalid values block a formal Job. Annotation coordinates are created against the confirmed canvas. `pad` and `crop` preserve source aspect ratio; silent stretch is prohibited.

## Annotation

The executable schema is `runtime/region-stream-ink/schemas/annotation.schema.json`. Cross-field validation additionally requires:

- unique ordered `region_id` values;
- positive, in-bounds rectangles;
- non-overlapping integer-frame intervals in declared order;
- reciprocal `allow_spatial_overlap_with` declarations for intentional spatial overlaps;
- `deferred` protection with a valid `until_region_id`, distinct from `permanent` protection;
- an explicit `allow_uncovered_ink` decision;
- Job segments exactly matching region IDs and frame intervals;
- every region ending by `scene_duration_frames - tail_hold_frames`.

An empty annotation region list, zero-area rectangle, out-of-bounds geometry, undeclared spatial overlap, timing overlap, unknown deferred target, or mismatched segment is invalid. A valid region whose image mask/path contains zero ink remains valid and emits its full static-frame allocation.

## Manifest projection

The existing fields are extended only as follows:

```yaml
production_manifest:
  adapters:
    - adapter_id: region_stream_ink
      adapter_type: local_renderer
      renderer_version: string
      access_route: local_cli
      input_modes: [source_image, region_annotation, protected_masks, manual_integer_frame_timeline]
      native_audio: none
  clips:
    - clip_id: string
      revision_id: string
      local_visual_render_ref:
        job_id: string
        revision_id: string
        input_hash: sha256
        adapter_id: region_stream_ink
```

The Job and report remain immutable external artifacts. The Manifest does not copy approval, execution status, QA verdict, output path, or retry count into `local_visual_render_ref`. Actual output uses existing media intake and exact `clip_id + revision_id + sha256`; QA uses existing `qa.results`; retry authority remains existing Execution State; Controller returns use the existing `controller_return` envelope.

## Multi-Clip delivery

Only homogeneous H.264 inputs may merge in v1.0. Before merge, width, height, frame rate, codec, pixel format, and time base must match. The output report includes ordered `{path, start_frame, frame_count}` entries, total frame count, checksum (when called through the delivery wrapper), and `external_audio_sync: not_verified`. There is no SRT importer, automatic segmentation, GPU path, parallel renderer, or complex cache in this version.
