# Whiteboard Animator Local Renderer Adapter v1.3

## Identity and provenance

- `adapter_id`: `whiteboard_animator`
- `adapter_type`: `local_renderer`
- `access_route`: `local_cli`
- AI-media Renderer version: `0.5.0-ai-media.1`
- frozen upstream: `whiteboard-animator` `0.1.1`, commit `e6e4dbcfc06e65b82490323a78bd9c277a9e2a0b`, MIT
- upstream notice: `runtime/whiteboard-animator/LICENSE.upstream-MIT.txt`

This is the single active local whiteboard Renderer. It replaces, and is not an alias for, the removed `region_stream_ink` implementation. Controller, Manifest, QA, Gate, Execution State, continuity, and retry ownership remain unchanged.

## Supported input

Use for sparse whiteboard line art, equations, diagrams, and simple flat illustrations that the preflight can separate into credible components. The frozen implementation includes the accepted gyroscope v2 mixed stroke/fill split: connected thin strokes remain strokes, thick colored islands become fills, and all stroke passes are scheduled before fill passes.

Do not use a full-frame story illustration merely because it reaches the correct final frame. The flat-image route still returns `human_review` when most of the frame is non-white or one connected component dominates the reveal. If explicit assets are unavailable, the result is `unsupported_full_frame_connected_scene_without_structured_layers`; do not render or claim success.

Complex full-frame illustrations may use `structured_layers.mode: prepainted_background_object_reveal` only when the Job supplies checksum-bound assets rather than asking the Renderer to infer them:

- one clean, prepainted background matching the source geometry;
- one line-art image;
- one non-overlapping visible-pixel mask per object, with explicit order and integer-frame stroke/fill durations.

The Renderer preserves the background, draws every object's line pass first, then reveals source color inside the same masks. It rejects mask overlap, missing line/fill pixels, duration mismatch, geometry mismatch, and background drift outside the object union. It does not claim recovery of the artist's original strokes or hidden pixels; asset preparation and semantic ownership remain upstream responsibilities.

Contract `1.1` adds `stacked_layer_object_complete_reveal` for aligned authored RGBA layers. Each layer has independent draw order and z-index plus one explicit reveal mode: `line_then_fill` requires supplied line RGBA and positive stroke/fill durations; `direct_fill` accepts only color RGBA and never derives or flashes an outline. The complete z-ordered composite over `paper_rgb` must match the checksum-bound flattened source. Cross-layer alpha overlap is expected, and the Renderer never manufactures backgrounds, masks, shadows, line art, or hidden pixels.

## Tip overlay

`tip_overlay` is optional. When present, it requires a checksum-bound RGBA asset, rights evidence, and an explicit normalized `tip_anchor: [x, y]`. Image decoding is Unicode-safe. The overlay follows the Renderer’s unencoded timing frontier, delays by one frame so ink is not preceded by the tip, and inserts an explicit pen-up frame on component changes or large jumps. It does not derive motion from encoded video differences or place the tip by sprite centre.

The accepted cel-hand asset used in the frozen pilot had `tip_anchor: [0.225, 0.075]`; that value is evidence for that asset, not a default for unrelated assets.

## Execution

Run through the manifest-declared Skill entry:

```powershell
skills/video-production/scripts/whiteboard-animator-cli.ps1 -Action preflight -Job <job.json> -Report <report.json>
skills/video-production/scripts/whiteboard-animator-cli.ps1 -Action render -Job <job.json> -Report <report.json>
```

The immutable Job follows [Whiteboard Animator Render Contract](../contracts/whiteboard-animator-render-contract.md). Output geometry and integer-frame timing are explicit. The Renderer emits execution facts and `success_pending_human_review`; it never writes approval, semantic QA, user acceptance, actual end state, or retry state.

## Runtime and boundaries

- Runtime dependencies are pinned in `runtime/whiteboard-animator/requirements.lock`; setup is explicit and does not silently download during a render.
- Output is silent H.264 `yuv420p`; BGM, narration, SFX, and assembly remain separate assets.
- Imported source and tip assets require provenance and rights evidence. Paid source-image generation still requires the existing image Cost Gate.
- `external_prompt_only` cannot execute this local Renderer.
- A technical preflight, fixture, full decode, final-frame fidelity, or historical human acceptance of a frozen sample is not approval of a new output.

## Rollback

Stop selecting `whiteboard_animator` for new Jobs and restore the pre-deletion source snapshot if historical `region_stream_ink` rerendering is required. Historical deliverables remain valid evidence; the removed ID must not be reintroduced as an active alias without a new explicit migration decision.

## Adaptive route, source, and pace extension

Contract `1.2` keeps this single Renderer. `flat_auto` is limited to sparse, separable, low-text sources. Cards, multi-line text, overlap/z-order, and complex line/fill relationships use `structured_semantic` with explicit RGBA layers and text regions. `auto` reports its route, quantified evidence, confidence, and blockers; complex flat input without layers remains `human_review`.

New 1.2 sources are authored at 4x output geometry and reduced with premultiplied-alpha area filtering. Preflight emits a reviewable source plan covering complexity, object/text load, line density, palette limit, work/output canvas, alpha policy, layer semantics/order, and checksum/rights evidence. Automatic timing uses skeleton length, fill area, pen lifts, text burden, and frame budget to select `calm`, `normal`, or `energetic`; `hyper` is not enabled. Tip motion uses phase-specific timing and snaps to the active mask frontier, with `post_snap_outside_count: 0` required.

## Style, Pilot, and segmented-production extension

Contract `1.3` adds upstream production planning without adding a second Renderer. `whiteboard-production-cli.ps1` maps a registry-`ready` Profile to a deterministic `whiteboard_style_slice`; it records accept/transform/drop/block decisions and the source/slice hashes. The Renderer receives only already-authored assets and the immutable Job. It does not open, parse, or reinterpret a Style Profile.

The local compiler is intentionally narrow: text, cards, arrows, icons, geometry, and deterministic simple flat elements only. It emits 4x RGBA source/layers, reading and draw/z order, rights evidence, and SHA-256. Complex characters or illustrations return source-brief / prompt-package-ready without a provider call.

A Pilot fingerprint binds the style slice, source template, Renderer behavior, route, geometry/fps, and tip asset/anchor. A changed fingerprint requires a risk-selected 3–6 second final-resolution Pilot; propagation remains blocked until existing Controller/Review evidence records human acceptance. Exact accepted fingerprints may be reused.

The pre-render plan uses the full preflight metrics and an evidenced local benchmark to select `single_render`, `segmented_render`, or `human_review`. Segment windows are supported only for explicit structured semantic Jobs. A continuous-canvas segment renders a non-overlapping global frame range from the same deterministic full timeline and hides the tip on the first boundary frame; a board cut uses an independent Job. The orchestrator runs one immutable Job at a time, stops after a failed technical check, retains prior passed segments, and merges compatible outputs by stream copy or one explicitly authorized controlled final encode. Merge success remains `success_pending_human_review`.
