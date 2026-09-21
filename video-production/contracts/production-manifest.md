# Production Manifest Contract v1.8

`production_manifest.json` is the machine source of truth. JSON is used for local Fixture validation; YAML is an equivalent runtime serialization.

Version 1.8 preserves the v1.7 `previsualization` subtree and adds optional VOX Poster Shot projections inside existing Scene/Shot/`local_assembly_plan`, asset, and Review structures. It also permits the existing optional local-renderer Adapter/reference projection. The active local whiteboard Adapter is `whiteboard_animator`; `region_stream_ink` is removed rather than retained as an alias. None creates a Creative Handoff Snapshot, second approval state, retry counter, or actual-state ledger.

```yaml
production_manifest:
  contract_version: "1.8"
  meta: {project_id, script_id, fixture_only, generated_at}
  semantic_locks: object
  input_provenance: {adp_contract_version, style_profile_ids, template_bindings}
  reference_fidelity: object | null # optional profile/evidence/constraint lineage; no duplicate observations
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
    vox_poster: # optional; projected only for the ready VOX Profile
      poster_shot_map_ref: {map_id, revision_id, content_hash}
      representative_poster_shot_ids: [string]
      contact_sheet_ref: {asset_id, media_checksum} | null
      review_result_ref: string | null
      editorial_repetition_warnings: [object]
  scenes: [object] # may carry optional local_assembly_plan or pastoral_craft_montage projection from approved Scene/Shot intent
  clips: [object] # may carry optional local_visual_render_ref or local_assembly_ref
  assets:
    - asset_id: string
        image_prompt_spec: # required for image assets; see the image-prompt portion of Executable Prompt Contract v1.3
        contract_version: "1.1"
        asset_type: character_identity | scene | prop | graphic | keyframe
        prompt_variant: default | story_prop | product_evidence
        pilot_design_route: hero_key_art | production_reconstructable | null
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
      pose_requirements: object | null # project-derived identity/facing/gesture/prop-contact/completeness/background constraints
      reuse_count: integer | null
      used_by_poster_shots: [string]
      production_priority: high | medium | low | null
      implementation_route: reuse_existing | generated_asset | remotion_svg | remotion_css | temporary_atlas | local_graphic | null
      salvage_disposition: # optional after a real asset is unsuitable for its original Shot
        reviewed_uses: [later_beat | hero_poster | cover | title_card | detail_crop | background | transition]
        selected_use: later_beat | hero_poster | cover | title_card | detail_crop | background | transition | reject
        target_ref: string | null
        crop_or_text_limits: [string]
        review_result_ref: string
        rationale: string
  audio_production: object # may carry final_narration_master and assembly event refs; voice/SFX/BGM owners remain separate
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
- A VOX Poster Shot Map must exist before batch asset generation. It is a previsualization/Scene/Shot projection, not a second Manifest or semantic owner. Fixture output, a local Contact Sheet compiler, or a planned review does not prove Poster Readiness or approval.
- Every formal VOX local-assembly Shot records `poster_shot_id`, `source_beat_id`, `shot_role`, `poster_archetype`, `adjacent_shot_difference`, a non-empty `stable_poster_state`, `pilot_design_route`, `decomposition_decision`, `poster_spec`, and `motion_plan`. `pilot_design_route` is exactly one of `hero_key_art` or `production_reconstructable` and is selected before Pilot design/image Prompt compilation. `decomposition_decision` remains exactly one of `keep_whole`, `partial_decomposition`, `full_element_assembly`, or `rebuild_locally`, selected only after route-specific review from actual exposure/editability/quality/cost/risk rather than maximum layer count. The Poster Shot inherits its ADP Beat's semantic function; one Beat may project to multiple Poster Shots without rewriting Script/ADP semantics.
- `poster_spec` records visual hierarchy, primary/secondary elements, background/foreground systems, reading path, text safe area, `critical_text_owner`, `critical_text_realization`, `generate_text_in_image`, decomposition decision, background-plate strategy, runtime outline style, stable-poster-state ref, current Poster Readiness Review ref, and applicable Static Reconstruction evidence ref. Critical VOX names, places, dates, numbers, evidence, quotes, statistics, CTA, and long titles keep `critical_text_owner: remotion` and `generate_text_in_image: false`; realization is `remotion_native_text`, `verified_typography_svg`, or `verified_typography_png`. Verified SVG/PNG remains positioned/timed by Remotion. Hero Typography may not silently degrade to an ordinary CSS font when that loses approved typography character.
- Static Reconstruction Check is an existing `previsualization_storyboard` / Poster Readiness review finding, never a separate Gate or state. It is required for `partial_decomposition`, `full_element_assembly`, `rebuild_locally`, and any whole-poster crop/text/layout change. The no-motion reconstruction preserves composition, hierarchy, focal weight, negative space, palette, and typography character with perceptual/editorial equivalence; pixel-perfect identity is not required and pixel diff alone cannot decide PASS.
- Pilot route review is also an existing `previsualization_storyboard` / Poster Readiness projection. `hero_key_art` reviews visual impact, focal hierarchy, Style fidelity, emotional value, and micro-animation/video-reference feasibility and marks reconstructability not applicable. `production_reconstructable` additionally records `typography_split_test`, `context_separation_test`, `decorative_independence_test`, `rectangle_risk_test`, and `motion_sequence_test`. It must remain one coherent poster while major visual groups are independently reconstructable; no fixed layer count, layout, palette, or project-specific constants are implied.
- Visible horizontal/vertical crop lines, background halos, full-width context strips, title-plus-background rectangles, and adjacent-element fragments are `must_fix` for `production_reconstructable`; rectangular screenshot crops are never an asset fallback. A high-quality but over-fused real result may record `recommended_reclassification: hero_key_art`, enter existing v1.8 salvage/reuse, and require a separate Production Pilot. Reclassification is not a Production PASS or generation authorization.
- `background_plate_strategy` recovers only motion-exposure regions derived from approved translation/rotation/scale/perspective/crop/occlusion changes plus an evidenced safety margin. No exposure means no plate. A full plate is exceptional and requires evidence that near-full hidden background can become visible; unknown hidden content routes to reduced motion, a different decomposition, or human review rather than invention.
- `cut_paper_outline_runtime_style` defaults to `owner: remotion_runtime_style` and `bake_into_new_source_png: false`. Color/contrast and width derive from the bound background, element role/frame occupancy/edge complexity, and final delivery resolution. Paper shadow remains separate. No global `10px/8px/6px` width constants are part of the Style Profile.
- Historical/cultural hero numerals retain source fact bindings and default to locale-appropriate written display; modern data visualization may use Arabic numerals. The asset/critical-text record preserves source value, display value, locale, and mode, and display conversion may not change value, unit, scale, date meaning, or source-fact semantics.
- `motion_plan.route` is `remotion_living_poster`, `remotion_precision_motion`, or `generative_hero_clip`. Camera intent is open descriptive text with zero or more phases, not a closed movement enum or amplitude cap. Element motion records target, motion, timing, and purpose. `generative_hero_clip` requires a concrete non-empty `why_not_remotion`; “more cinematic” is insufficient and never grants a provider call.
- An unresolved Poster Readiness or Production Reconstructability `must_fix` blocks motion compilation for the affected Poster Shot. Missing/stale review evidence maps through existing Review Result/Controller rules and does not consume retry. No Poster Gate, Pilot Gate, Pilot/Poster State Machine, Pilot/Poster Retry Ledger, VOX Manifest, or separate approval state is created.
- The Production Asset Set is derived from current approved Poster Shots. An asset with no `used_by_poster_shots` reference is not production-eligible; eligibility still does not grant a provider call or Cost Gate. Prefer high-reuse assets first and local SVG/CSS/graphics for one-off decoration.
- A generated asset unsuitable for its original Shot is not rejected immediately. Within the existing asset and `production_qa` records, review `later_beat`, `hero_poster`, `cover`, `title_card`, `detail_crop`, `background`, and `transition` in that order; `reject` is valid only after all are evidenced unsuitable. The disposition records target/use, crop/text limits, review ref, and rationale and does not relax facts, identity, era, composition, rights, intake, or authorization.
- A real image asset keeps `image_prompt_spec` and `call_package`; raw YAML is not sent to the model.
- A temporary `manual_crop_from_named_transparent_atlas` `2x2` or `3x3` prompt projection is not serialized into this Manifest and is never a Production Asset, approval, generated state, or Remotion input. It binds one intended destination background, keeps project-specific appearance/direction/completeness requirements in per-cell `asset_constraints`, and requests clean transparent Alpha without baking a new cut-paper outline by default. It requests ChatGPT Web transparency but does not prove saved-file Alpha. After verified-Alpha named crop through `scripts/split-transparent-atlas.ps1` and its Python worker, final independent PNGs retain their original planned `asset_id` and must pass existing intake, RGBA/Alpha, edge, and safe-area checks before binding; runtime outline and separate shadow are then validated on the destination background at delivery size. The crop tool performs no background removal, outline invention, provider call, or implicit overwrite.
- An optional `whiteboard_animator` Adapter record contains only `adapter_id`, `adapter_type: local_renderer`, exact Renderer and pinned upstream versions, `access_route: local_cli`, supported input modes, mandatory suitability-preflight policy, and `native_audio: none`. It has no provider/model fiction, approval, QA verdict, retry count, global output default, hidden-structure inference, or active `region_stream_ink` alias.
- A Clip may carry `local_visual_render_ref: {job_id, revision_id, input_hash, adapter_id, whiteboard_style_slice_ref?, pilot_fingerprint_sha256?, pilot_approval_evidence_ref?, whiteboard_render_plan_ref?}`. The optional 1.3 references bind derived style, exact Pilot evidence, and the benchmark-backed plan without embedding them or creating another state owner. The immutable Job Spec and execution report remain artifacts; real output still enters through existing media intake, QA stays in `qa.results`, and retry authority stays in existing Execution State.
- A formal local-render Job requires this video's confirmed `aspect_ratio`, `resolution`, even `width_px`, even `height_px`, and integer-frame timing. `UNKNOWN` blocks execution. Local CPU rendering has no media-generation Cost Gate; paid source-image generation retains the existing Visual Baseline and image Cost Gate. `external_prompt_only` cannot execute this Adapter.
- A new whiteboard 1.3 style/source/Renderer/route/geometry/tip fingerprint blocks propagation until the referenced existing Controller/Review evidence records human acceptance. Exact accepted fingerprints may be reused. Segment reports and merge reports are execution artifacts only; technical success stays `success_pending_human_review`.
- An image decision cannot be empty: it is `explicit`, `inherited`, or justified `not_applicable`. Existing legacy image assets migrate unknown values to `unresolved`, never silently to not applicable.
- Old approved prompts are retained as revisions. New rules create a new revision; legacy Prop remains `story_prop` unless the task explicitly requires inspected product evidence.
- `actual_end_state`, generated file references, AI QA verdicts, and human approval evidence remain null/pending until observed.
- Every independent video call receives its exact global layer and identity anchors. Image output parameters remain reviewable in its call package.
- A VOX Remotion `local_assembly_plan` extends existing Scene/Shot/asset records only. It may carry the Poster Shot projection plus `information_goal`, `key_layout_states`, `primary_attention_target`, `semantic_end_state`, Pilot design route and route-specific Review ref, decomposition decision, background exposure/recovery bounds, Static Reconstruction evidence ref, critical-text realization, runtime outline style, independent element z-order/geometry/anchors/facing, time-bounded protected regions, caption safe area, intentional crop reason, camera phases, layer events, and absolute narration/caption/SFX bindings. It is not a Pilot/Reconstruction Manifest/Gate, Pilot State Machine, Typography Manifest, Poster State Machine, renderer, approval, QA, retry, or actual-state owner. Static, dynamic, strong-camera, and compound motion are peer choices; action count, historical zoom amplitude, fixed layer count, and membership in a curated motion list are not readiness or failure fields.
- A selected `oriental_pastoral_cinematic_lifestyle` craft Shot may project `pastoral_craft_shot_type`, `breathing_shot_note`, `prior_process_state_ref`, `current_process_state`, `completion_delta`, and `match_cut_or_visual_echo` into its existing Scene/Shot record. `pastoral_craft_shot_type` is `atmosphere_shot`, `process_detail_shot`, `progression_shot`, or null. Atmosphere is a formal narrative node; process detail may end after a credible bounded local action without closing a tutorial; progression requires evidenced prior/current states and a visible delta. The two-process/one-atmosphere pattern is a soft planning tendency, never a Gate, quota, retry rule, or permission to fabricate a missing Shot. Magic growth, full-frame morph, unsupported instant completion, and ungrounded regional/person/craft examples remain prohibited.
- For this local assembly branch, `local_assembly_ref` replaces only inapplicable generative Clip requirements: it does not require a six-module Video Prompt, provider call, or the 6–14 second generation default. Any actually generated video unit remains a normal Clip and keeps those controls. `whiteboard_animator` and `external_prompt_only` retain their own boundaries.
- `audio_production.final_narration_master` binds the confirmed audio revision, checksum, measured duration, sample rate, read-only status, and absolute semantic intervals. Assembly converts visual/caption/SFX events to integer frames at the bound fps while preserving original audio time; estimates never drive final execution. `caption_output_owner` is exactly one of `remotion` or `external_post`. SFX refs bind visible motion intervals or settle/hit events and become stale when their narration/timeline dependency changes. An intentional picture+narration+SFX intermediate may omit BGM when `bgm_output_owner: external_post`; this is not final-master audio acceptance.
- Character identity and per-Shot pose assets keep separate responsibilities. Every pose asset or atlas cell inherits applicable era/clothing, identity, facing, gesture, prop-contact, complete-silhouette, and destination-background requirements. Source silhouette completeness is checked separately from a declared final close-up crop.
- A reference-remake Clip may carry `reference_fidelity_trace_refs`, while Manifest-level
  `reference_fidelity` stores only the profile/version, current constraint hash, authoritative
  evidence ref, and critical requirement IDs. A constraint, evidence, or target-media hash change
  makes the prior assessment stale through existing lineage rules and does not consume retry.
- Timeline segments are serialized with one-decimal boundaries, join exactly, and end at Clip duration.
- `continuity_ledger` is the only source of actual observed state. A Clip and a continuity handshake carry only `state_record_id` references and may not duplicate or override `actual_end_state`.
- Every Scene derives `clip_ids`, reuse count, multi-angle status, and coverage requirement from its coverage plan; approved Scene Baselines are referenced by `baseline_id` and never copied as generated evidence.
- Every Clip may carry `video_prompt_spec`, `clip_performance_binding`, and `state_record_id` references. `executable_video_prompt` is null when a hard deterministic conflict exists; `unknown` is review routing, not failure or retry budget consumption.
- A v1.5, v1.6, or v1.7 input is read-only migration input. Recompilation writes a new v1.8 revision and never mutates the input file. Existing approved assets and baselines remain reusable when their lineage and current constraints still match.
- A BGM request remains independent from Video Clip Prompts and voice assets. Its prompt hash, provider/model, duration, output format, estimated credits, approval evidence, provider IDs, checksum, measured duration, and listening QA state must remain reviewable.
- Named-voice selection extends `audio_production` only: preserve requirement provenance, hard constraints, a maximum-three candidate shortlist, evidence URL, account availability, human decision, and provider-call authorization. Public catalog presence is not account entitlement; no candidate may become the approved Voice Profile automatically.
- A new pre-generation review stores the complete Review Result v2.1 in `qa.results`, bound to exact target/input/dependency hashes and evaluator policy version. This additive record does not grant a Cost Gate, mutate retry authority, or duplicate actual state.
