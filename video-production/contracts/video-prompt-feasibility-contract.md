# Video Prompt Feasibility Contract v1.1

This contract runs a bounded two-layer pre-generation Gate. The deterministic layer validates structured facts without judging free-text semantics. A required compact semantic preflight then checks only physical common sense, setting/prop compatibility, action causality, and literalization risk before a copy-ready Video Prompt may be rendered.

```yaml
video_prompt_spec:
  contract_version: "1.0"
  clip_id: string
  continuity_handshake:
    predecessor_clip_id: string | null
    source_state_type: first_clip | ledger_actual_end_state | approved_resume_frame | frozen_planned_end_state
    state_record_id: string | null
    source_reference: string | null
    scene_id: string
    scene_baseline_ids: [string]
    camera_coverage_id: string
    status: passed | blocked | unknown
  body_resource_timeline: [object]
  spatial_relations: [object]
  prop_state_transitions: [object]
  physical_causality_assessments: [object]
  literalization_scan:
    - source_clause: string
      risk_type: metaphor | anthropomorphic | ambiguous_negative | impossible_visual
      executable_rewrite: string | null
      source: llm | human
      confidence: high | medium | low
      status: resolved | blocked | needs_human_review | unknown
  semantic_preflight:
    required_for_copy_ready: true
    mode: bounded_risk_packet
    input_character_limit: 1200
    output_character_limit: 250
    max_findings: 3
    max_automatic_rechecks: 1
    risk_packet:
      clip_id: string
      scene: string
      start_state: string
      timeline: [object]
      end_state: string
      characters_involved: [string]
      props_and_state_changes: [object]
      metaphorical_clauses: [string]
      duration_fit: {current_duration_seconds: number | null, visible_state_changes: [string], ending_hold: string | null, adapter_duration_evidence: string | null}
    evaluator_result:
      source: llm | human
      run_id: string | null
      status: passed | blocked | needs_human_review | unknown
      confidence: high | medium | low
      evidence: [string]
      failures: [string]
      repair_targets: [string]
      affects_semantics: boolean
      summary: string
  feasibility_gate:
    status: passed | blocked | needs_semantic_review | needs_human_review | unknown
    validator_results: [validator_result]
    failures: [string]
    repair_targets: [string]
  executable_prompt: string | null

validator_result:
  check_id: string
  status: passed | blocked | needs_semantic_review | needs_human_review | unknown | not_applicable
  validator_type: deterministic | semantic | human | mixed
  evidence: [string]
  confidence: high | medium | low
  owner: script_engine | audiovisual_director | video_production | human_decision | post_generation_qa
  failures: [string]
  repair_targets: [string]
```

## Deterministic checks

The local validator may check only IDs, versions, required references, legal enum values, non-overlapping timelines, one-decimal joins, structured body-resource occupancy, explicit prop transitions, coverage bindings, and actual-state authority. A hard contradiction returns `blocked` with a concrete failure code and repair target.

The six failure families are `continuity_source_missing`, `continuity_state_mismatch`, `scene_coverage_binding_missing`, `body_resource_conflict`, `posture_reach_conflict`, `prop_state_transition_invalid`, `physical_causality_violation`, and `literalization_risk` as applicable. The visible-performance structural failures are `internal_state_not_visualized`, `emotion_transition_missing`, `decision_signal_missing`, and `performance_state_mismatch`.

Natural reach, posture quality, physical common sense not explicitly encoded, metaphor quality, psychological meaning, restraint, and overacting are never inferred by the deterministic layer. They stay `unknown`, `needs_semantic_review`, or `needs_human_review` until supported by a declared semantic/human evaluator result. `unknown` is not a failure and never consumes retry budget. `literalization_scan.executable_rewrite` may be `null`.

## Required bounded semantic preflight

Every request for a complete, copy-ready Video Prompt must run the semantic preflight after deterministic checks pass and before the six-module prompt is rendered. The evaluator receives only the compact risk packet above, not the full Brief, Manifest, project history, or unrelated identity/style text. The serialized packet is limited to 1200 characters; the combined human-readable summary and evidence are limited to 250 characters and at most three findings.

The semantic preflight checks only:

- physical common sense and material consequences;
- setting/prop compatibility and a complete prop lifecycle;
- visible action causality from start state through end state;
- metaphor, anthropomorphism, or symbolic language that could be literalized into an implausible image.
- Duration Fit: whether the declared current duration makes each required visible state transition and ending hold legible. This is a story-function finding, not action counting, a fixed-seconds rule, or an automatic split instruction. `duration_legibility_risk` maps through the existing `timing_failure` meaning; absent current duration or Adapter duration capability evidence remains `unknown` only for the affected conclusion.

A high-confidence `blocked` result must cite observable evidence, a named failure, and a repair target. One targeted repair and one recheck are allowed only when `affects_semantics=false`; otherwise route to human review. Missing, low-confidence, contradictory, `unknown`, or `needs_human_review` results cannot produce a copy-ready prompt. A Fixture may test routing with declared evaluator data, but it never proves that a real semantic evaluation occurred.

The external Video Prompt remains the six modules in `templates/video-clip-prompt.md`; this internal contract must not add a seventh module or automatically rewrite frozen semantics. A one-line Gate summary may be displayed adjacent to the prompt, but it is not part of the executable prompt.

Visible performance provenance is `story_change_arc -> performance_plan -> clip_performance_binding`; each downstream object stores references, not a mutable copy of the Script arc.

For a new pre-generation Review v2.1, extend the same bounded evaluator packet with the compact fields required by [Prompt Story Function Conformance](../modules/prompt-story-function-review.md). Store the resulting [Review Result](review-result-contract.md) in `production_manifest.qa.results`. This is an additive review record; it does not change Feasibility v1.1 legacy input semantics or create a second evaluator call.
