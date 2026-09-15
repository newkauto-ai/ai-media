# Production Manifest Contract v1.7

`production_manifest.json` is the machine source of truth. JSON is used for local Fixture validation; YAML is an equivalent runtime serialization.

Version 1.7 adds one additive `previsualization` subtree and permits an optional local-renderer Adapter/reference projection. The active local whiteboard Adapter is `whiteboard_animator`; `region_stream_ink` is removed rather than retained as an alias. Neither creates a Creative Handoff Snapshot, second approval state, retry counter, or actual-state ledger.

```yaml
production_manifest:
  contract_version: "1.7"
  meta: {project_id, script_id, fixture_only, generated_at}
  semantic_locks: object
  input_provenance: {adp_contract_version, style_profile_ids, template_bindings}
  adapters: [object] # may include optional whiteboard_animator local-renderer capability facts
  prompt_policy:
    contract_version: "1.1"
    independent_request_policy: self_contained
    global_video_layer: string
    identity_invariants: [{anchor_id, text}]
    delivery_defaults: {aspect_ratio, image_resolution, video_resolution, native_audio_mode}
  generation_gate: {state, minimum_generation_set, model, estimated_cost, stopping_condition, approval_evidence}
  lookdev: {status, anchors}
  visual_baselines: [object]
  previsualization:
    fixture_only: boolean
    applicability:
      decision: skip | retain
      production_risk: low | medium | high
      reasons: [string]
      evidence_refs: [string]
    storyboard_plan:
      plan_id: string
      revision_id: string
      content_hash: string
      panel_refs: [string]
      panels: [object]
    prompt_ref: {prompt_id, revision_id, content_hash} | null
    asset_ref: {asset_id, media_checksum} | null
    review_result_ref: string | null
    generation_status: not_required | planned_awaiting_cost_gate | generated_awaiting_review
    cost_gate: object
  scenes: [object]
  clips: [object] # may carry optional local_visual_render_ref
  assets:
    - asset_id: string
        image_prompt_spec: # required for image assets; see the image-prompt portion of Executable Prompt Contract v1.2
        contract_version: "1.1"
        asset_type: character_identity | scene | prop | graphic | keyframe
        prompt_variant: default | story_prop | product_evidence
        source_locks: [object]
        decisions: object
        material_texture: object
        text_handling: object
        consistency_locks: [object]
        allowed_variation: [object]
        reference_bindings: [object]
        negative_constraints: [object]
        output_spec: object
        clause_decision_map: [object]
        executable_prompt: string
        qa: {status, failures}
      call_package: {executable_prompt, reference_bindings, request_parameters, adapter_id, unresolved_fields, generation_status}
  audio_production: object
  bgm_production: object
  continuity_ledger: [object]
  qa: {failure_taxonomy, results, retries} # Review Result v2.1 records are stored in results
```

## Invariants

- No Clip or image call becomes ready without an approved Domain baseline and user-approved cost Gate.
- `previsualization` is null only for a legacy/compatibility input. New runs record either an evidenced `skip` or a `retain` plan. A skip path may not fabricate empty Panel, Prompt, asset, or Review objects.
- `retain` blocks downstream generation until a real Storyboard asset has an immutable revision/checksum and a current Review Result reference. `fixture_only=true`, prompt preview, or local compilation can never satisfy this condition.
- Storyboard Plan, Prompt, Script, ADP, Manifest dependency, or media checksum changes make the prior Storyboard Review stale. The Workflow Controller validates the current review context; the Manifest does not add a second readiness state.
- Storyboard media is previsualization only. It does not satisfy a Visual Baseline, write `actual_end_state`, become a Production Asset, or grant a Cost Gate.
- A real image asset keeps `image_prompt_spec` and `call_package`; raw YAML is not sent to the model.
- A temporary `manual_crop_from_named_transparent_atlas` `2x2` or `3x3` prompt projection is not serialized into this Manifest and is never a Production Asset, approval, generated state, or Remotion input. It binds one intended destination background, keeps project-specific appearance/direction/completeness requirements in per-cell `asset_constraints`, and prefers paper-white/warm-white outlines while selecting a contrasting paper tone when the destination is light or low-contrast. It requests ChatGPT Web transparency but does not prove saved-file Alpha. After verified-Alpha named crop through `scripts/split-transparent-atlas.ps1` and its Python worker, final independent PNGs retain their original planned `asset_id` and must pass existing intake, RGBA/Alpha, edge, destination-background outline contrast at bound delivery size, and safe-area checks before binding. The crop tool performs no background removal, outline invention, provider call, or implicit overwrite.
- An optional `whiteboard_animator` Adapter record contains only `adapter_id`, `adapter_type: local_renderer`, exact Renderer and pinned upstream versions, `access_route: local_cli`, supported input modes, mandatory suitability-preflight policy, and `native_audio: none`. It has no provider/model fiction, approval, QA verdict, retry count, global output default, hidden-structure inference, or active `region_stream_ink` alias.
- A Clip may carry `local_visual_render_ref: {job_id, revision_id, input_hash, adapter_id, whiteboard_style_slice_ref?, pilot_fingerprint_sha256?, pilot_approval_evidence_ref?, whiteboard_render_plan_ref?}`. The optional 1.3 references bind derived style, exact Pilot evidence, and the benchmark-backed plan without embedding them or creating another state owner. The immutable Job Spec and execution report remain artifacts; real output still enters through existing media intake, QA stays in `qa.results`, and retry authority stays in existing Execution State.
- A formal local-render Job requires this video's confirmed `aspect_ratio`, `resolution`, even `width_px`, even `height_px`, and integer-frame timing. `UNKNOWN` blocks execution. Local CPU rendering has no media-generation Cost Gate; paid source-image generation retains the existing Visual Baseline and image Cost Gate. `external_prompt_only` cannot execute this Adapter.
- A new whiteboard 1.3 style/source/Renderer/route/geometry/tip fingerprint blocks propagation until the referenced existing Controller/Review evidence records human acceptance. Exact accepted fingerprints may be reused. Segment reports and merge reports are execution artifacts only; technical success stays `success_pending_human_review`.
- An image decision cannot be empty: it is `explicit`, `inherited`, or justified `not_applicable`. Existing legacy image assets migrate unknown values to `unresolved`, never silently to not applicable.
- Old approved prompts are retained as revisions. New rules create a new revision; legacy Prop remains `story_prop` unless the task explicitly requires inspected product evidence.
- `actual_end_state`, generated file references, AI QA verdicts, and human approval evidence remain null/pending until observed.
- Every independent video call receives its exact global layer and identity anchors. Image output parameters remain reviewable in its call package.
- Timeline segments are serialized with one-decimal boundaries, join exactly, and end at Clip duration.
- `continuity_ledger` is the only source of actual observed state. A Clip and a continuity handshake carry only `state_record_id` references and may not duplicate or override `actual_end_state`.
- Every Scene derives `clip_ids`, reuse count, multi-angle status, and coverage requirement from its coverage plan; approved Scene Baselines are referenced by `baseline_id` and never copied as generated evidence.
- Every Clip may carry `video_prompt_spec`, `clip_performance_binding`, and `state_record_id` references. `executable_video_prompt` is null when a hard deterministic conflict exists; `unknown` is review routing, not failure or retry budget consumption.
- A v1.5 or v1.6 input is read-only migration input. Recompilation writes a new v1.7 revision and never mutates the input file.
- A BGM request remains independent from Video Clip Prompts and voice assets. Its prompt hash, provider/model, duration, output format, estimated credits, approval evidence, provider IDs, checksum, measured duration, and listening QA state must remain reviewable.
- Named-voice selection extends `audio_production` only: preserve requirement provenance, hard constraints, a maximum-three candidate shortlist, evidence URL, account availability, human decision, and provider-call authorization. Public catalog presence is not account entitlement; no candidate may become the approved Voice Profile automatically.
- A new pre-generation review stores the complete Review Result v2.1 in `qa.results`, bound to exact target/input/dependency hashes and evaluator policy version. This additive record does not grant a Cost Gate, mutate retry authority, or duplicate actual state.
