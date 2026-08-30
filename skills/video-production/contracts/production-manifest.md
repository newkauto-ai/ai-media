# Production Manifest Contract v1.7

`production_manifest.json` is the machine source of truth. JSON is used for local Fixture validation; YAML is an equivalent runtime serialization.

Version 1.7 adds one additive `previsualization` subtree. It does not create a Creative Handoff Snapshot, second approval state, retry counter, or actual-state ledger.

```yaml
production_manifest:
  contract_version: "1.7"
  meta: {project_id, script_id, fixture_only, generated_at}
  semantic_locks: object
  input_provenance: {adp_contract_version, style_profile_ids, template_bindings}
  adapters: [object]
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
  clips: [object]
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
- A new pre-generation review stores the complete Review Result v2.1 in `qa.results`, bound to exact target/input/dependency hashes and evaluator policy version. This additive record does not grant a Cost Gate, mutate retry authority, or duplicate actual state.
