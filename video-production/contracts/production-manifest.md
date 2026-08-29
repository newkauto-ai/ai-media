# Production Manifest Contract v1.6

`production_manifest.json` is the machine source of truth. JSON is used for local Fixture validation; YAML is an equivalent runtime serialization.

```yaml
production_manifest:
  contract_version: "1.6"
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
- A real image asset keeps `image_prompt_spec` and `call_package`; raw YAML is not sent to the model.
- An image decision cannot be empty: it is `explicit`, `inherited`, or justified `not_applicable`. Existing legacy image assets migrate unknown values to `unresolved`, never silently to not applicable.
- Old approved prompts are retained as revisions. New rules create a new revision; legacy Prop remains `story_prop` unless the task explicitly requires inspected product evidence.
- `actual_end_state`, generated file references, AI QA verdicts, and human approval evidence remain null/pending until observed.
- Every independent video call receives its exact global layer and identity anchors. Image output parameters remain reviewable in its call package.
- Timeline segments are serialized with one-decimal boundaries, join exactly, and end at Clip duration.
- `continuity_ledger` is the only source of actual observed state. A Clip and a continuity handshake carry only `state_record_id` references and may not duplicate or override `actual_end_state`.
- Every Scene derives `clip_ids`, reuse count, multi-angle status, and coverage requirement from its coverage plan; approved Scene Baselines are referenced by `baseline_id` and never copied as generated evidence.
- Every Clip may carry `video_prompt_spec`, `clip_performance_binding`, and `state_record_id` references. `executable_video_prompt` is null when a hard deterministic conflict exists; `unknown` is review routing, not failure or retry budget consumption.
- A v1.5 input is read-only migration input. Recompilation writes a new v1.6 revision and never mutates the input file.
- A BGM request remains independent from Video Clip Prompts and voice assets. Its prompt hash, provider/model, duration, output format, estimated credits, approval evidence, provider IDs, checksum, measured duration, and listening QA state must remain reviewable.
- A new pre-generation review stores the complete Review Result v2.1 in `qa.results`, bound to exact target/input/dependency hashes and evaluator policy version. This additive record does not grant a Cost Gate, mutate retry authority, or duplicate actual state.
