# Whiteboard Animator Render Contract v1.3

## Job authority

The immutable Job JSON uses `adapter_id: whiteboard_animator` and the executable schema at `runtime/whiteboard-animator/schemas/render-job.schema.json`. It binds:

- job and revision IDs;
- source path, SHA-256, and rights evidence;
- exact even output width and height, `yuv420p`, and `native_audio: none`;
- total duration, draw duration, and frame rate with an integer total frame budget;
- optional checksum-bound RGBA tip asset, rights evidence, normalized `tip_anchor`, size, opacity, and pen-up threshold;
- output path and bounded encoding settings.

For `structured_layers.mode: prepainted_background_object_reveal`, the same immutable Job additionally binds a clean background, line-art image, ordered visible-pixel object masks, and exact stroke/fill durations. Every asset requires path, SHA-256, and rights evidence. Object IDs and orders are unique, masks are non-overlapping, and each phase duration must resolve to an integer frame count.

Contract `1.1` may instead use `structured_layers.mode: stacked_layer_object_complete_reveal` with aligned true-RGBA semantic layers over explicit `paper_rgb`. Every layer has unique ID, draw order, and z-index, a checksum- and rights-bound color RGBA, a positive fill duration, and `reveal_mode: line_then_fill | direct_fill`. `line_then_fill` also requires non-empty line RGBA and positive stroke duration. `direct_fill` must omit both; it preserves source color and alpha without any temporary outline. Layer phase boundaries are retained in seconds and mapped onto the declared output frame clock; the total video frame budget remains integral. Contract `1.0` and its legacy mode remain accepted unchanged.

Relative paths resolve from the Job file. Missing, mismatched, unknown, or odd output geometry blocks execution. The Adapter does not silently crop, pad to another aspect ratio, or invent an output size; the declared dimensions must equal the Renderer’s source-derived dimensions after its pinned maximum-dimension rule and even-pixel padding.

## Mandatory preflight

Every Job runs `preflight` before `render`. The report includes source checksum, resolved geometry, non-white coverage, component count, fill count, mixed stroke/fill count, largest-component share, and ordered schedule.

The flat-image route is supported only when the source remains sparse/component-separable. Either of the following blocks render and returns `human_review`:

- non-white coverage greater than `0.70`;
- one connected component holding more than `0.70` of all ink pixels while non-white coverage is also greater than `0.35`.

Without structured line art or layers, the reason is `unsupported_full_frame_connected_scene_without_structured_layers`. A structured Job bypasses the flat-image density guard only after validating all supplied assets. It returns `human_review` if the clean background differs from the source outside the union of object masks; geometry, checksum, mask overlap, missing line/fill content, or duration errors fail the contract.

Stacked-layer preflight accepts overlap across layers, validates each declared reveal mode and alpha payload, and composites all complete color layers bottom-to-top by z-index. Material drift from the checksum-bound flattened source blocks with `flattened_final_composite_drift`; it is never repainted from that source.

## Accepted rendering behavior

- Mixed connected components are split before tracing using color/chroma, minimum area, and distance-transform depth.
- Thin colored lines remain strokes; thick colored islands become fills.
- Stroke passes finish before fill passes; source ink pixels are neither duplicated nor silently omitted.
- Optional hand/tip motion follows unencoded Renderer timing, uses the explicit contact anchor, and hides on component changes or large jumps.
- Flat source images never receive guessed pixels behind later foreground objects. The rejected gyroscope v3 hidden-underlay technique is outside this contract.
- Structured scenes start from the supplied clean background, complete all ordered line passes, then complete all ordered source-color fills. Background pixels outside the supplied visible object masks are never replaced by the source during reveal.
- Stacked scenes follow draw order for phase timing but z-order for every frame. `line_then_fill` replaces temporary supplied line evidence as its color arrives; `direct_fill` reveals supplied RGBA directly and can never create a black or gray outline stage.
- New contract 1.3 character layers use `semantic_kind: character`, `reveal_mode: line_then_fill`, `stroke_order_policy: head_body_upper_arms_forearms_hands_thighs_lower_legs_feet`, and eight checksum-bound authored true-RGBA part masks ordered `head`, `body`, `upper_arms`, `forearms`, `hands`, `thighs`, `lower_legs`, `feet`. Animals map these to upper/lower forelimbs, front paws, upper/lower hindlimbs, and hind paws. Every part additionally binds `outline_mask_rgba` and `detail_mask_rgba`; outline evidence is scheduled before interior-detail evidence for that part. The masks must be source-geometry-aligned, non-overlapping, inside their owning part, collectively exhaustive over authored line/color evidence, and contain a non-empty outline; a detail mask may contain no authored line pixels. Their categorical ownership is reduced to output geometry without soft blending. The Renderer treats masks as authoritative semantic evidence and never infers anatomy or interior meaning. `head_body_hands_feet` and `head_first` plus `head_bbox` remain compatibility input only; character-order metadata is invalid on non-character layers.

## Result and ownership

`preflight` returns `supported` or `human_review`. `render` returns `success_pending_human_review` only after exact frame-count decoding and checksum calculation. Failures are structured as contract/unsupported or runtime failures.

The report is not a Manifest, approval, QA verdict, continuity state, or retry ledger. Bind successful media through existing intake, place QA in `production_manifest.qa.results`, actual observed state in the existing continuity ledger, and retries in existing Execution State.

## Contract 1.2 adaptive extension

Contract `1.2` compatibly adds `render_route: auto | flat_auto | structured_semantic`, `source.supersample_scale: 4`, and `timing.policy: auto | manual`. Source and structured RGBA assets are authored at exactly four times the declared output geometry, then reduced in premultiplied-alpha space with area filtering. Resizing an already flattened video is not equivalent.

`render_route` is invalid on contract `1.0` and `1.1`; those versions remain compatibility inputs and cannot force an adaptive route. For contract `1.2+`, `auto` resolves an unstructured source to `flat_auto` only when the measured source class is `simple` and detected text burden remains bounded. A `moderate` or `complex` unstructured source resolves to required route `structured_semantic` and returns `human_review` with `structured_semantic_requires_explicit_layers`. Explicitly requesting `flat_auto` cannot override that result.

Text layers declare `semantic_kind: text` plus explicit output-space `text_regions`: bbox, line order, unique reading order, `left_to_right`, and glyph count. Connectivity never supplies semantic order. Stroke and fill retain separate timing maps; the tip follows the active phase map and its final anchor snaps to a real frontier-mask pixel. A successful tip report has `post_snap_outside_count: 0`.

Automatic timing measures skeleton length, fill alpha area, connected pen lifts, glyphs/rows, and the exact frame budget. It selects the slowest fitting `calm`, `normal`, or `energetic` calibration, allocates integer phase frames, and assigns the remainder to the hold. If even `energetic` cannot fit, preflight returns `human_review` with `insufficient_duration_for_bounded_whiteboard_pace`; it recommends reducing objects/copy/decoration or splitting the semantic board instead of unbounded acceleration.

Manual adaptive flat timing also reports the actual schedule end. If per-component minimum durations make that schedule exceed `draw_duration_seconds`, `schedule_fits_draw_budget` and `frame_budget_conserved` are false and preflight returns `human_review` with `flat_schedule_exceeds_declared_draw_budget`.

Every 1.2 preflight reports the resolved route with quantified basis/confidence/blockers, a reviewable `whiteboard_source_plan`, and a frame-conserving `timing_plan`. Contract `1.0` and `1.1` manual Jobs remain compatible.

## Contract 1.3 production extension

Contract `1.3` retains every 1.2 invariant, adds explicit `head → body → upper arms → forearms → hands → thighs → lower legs → feet` ordering plus `outline → interior details` within every newly authored character part, and accepts an optional `segment_window` only for explicit structured semantic Jobs. It binds `start_frame`, exclusive `end_frame`, the unchanged logical total-frame count, `continuous_canvas | board_cut`, and whether the tip must be hidden at the segment boundary. The Renderer evaluates the complete immutable timeline but encodes only that non-overlapping global frame range; it never treats a locally restarted clock as continuity.

Style mapping, simple source compilation, Pilot selection/approval evidence, workload estimation, serial orchestration, and final merge are upstream production-planner responsibilities. The Renderer never reads a Style Profile, chooses a Pilot, claims human acceptance, starts a downstream segment, or owns retry state.

`whiteboard_render_plan` reports total/active/hold seconds and frames, geometry/fps/pixel-frames, layers/objects/text, skeleton length, fill area, pen lifts, benchmark evidence, expected runtime range, decision, reason, and immutable segment Jobs. Splits occur only after complete semantic object groups; a text row, continuous stroke, line-to-fill pair, or semantic action is indivisible. Long static hold alone is not a split trigger.

Final merge requires uniform geometry, fps/timebase, pixel format, encoding, paper/style binding, tip, and color policy. It verifies logical frame-range adjacency, exact total frames/duration, boundary duplicate/gap/flash/state loss, first-frame tip hiding for continuous canvas, complete decode, `native_audio: none`, and SHA-256. Encoding-compatible segments use stream-copy concat; otherwise at most one explicitly authorized controlled final encode is permitted. The result remains `success_pending_human_review` until continuous human viewing.
