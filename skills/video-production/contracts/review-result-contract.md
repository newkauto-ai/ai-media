# Review Result Contract v2.1

This additive contract records an evidence-bound review without replacing Workflow Controller `Evaluator Result` or `Execution State`. V2.1 currently enables only `pre_generation_prompt`; post-generation Clip and Final Cut review remain unimplemented.

```yaml
review_result:
  schema_version: "2.1"
  review_id: string
  gate: pre_generation_prompt
  target:
    project_id: string
    target_type: video_prompt
    target_id: string
    revision_id: string
    content_hash: string
    reviewed_at: datetime
  lineage:
    review_input_hash: string
    dependency_hashes:
      frozen_script: string
      audiovisual_direction_package: string
      production_manifest: string
      video_prompt_spec: string
      executable_prompt: string
    evaluator_policy_id: string
    evaluator_policy_version: string
  provenance:
    manifest_version: string
    evaluator_source: deterministic | llm | human | mixed | fixture
    evaluator_run_ids: [string]
    evidence_refs: [string]
    fixture_only: boolean
  findings:
    - finding_id: string
      check_id: string
      category: feasibility | continuity | story_function_conformance | editability
      severity: must_fix | optional | do_not_optimize
      status: confirmed | suspected | unknown | not_applicable
      confidence: high | medium | low
      evidence: [string]
      failure_type: string | null
      affects_semantics: boolean
      repair_target: string | null
      owner: script_engine | audiovisual_director | video_production | human_decision
  decision:
    verdict: PASS | WARNING | FAIL | UNKNOWN | HUMAN_REVIEW
    next_action: advance_to_separate_cost_gate | targeted_repair | hold_for_evidence | human_review
    generation_gate_recommendation: eligible_for_separate_cost_gate | withhold
    reason: string
  controller_mapping:
    verdict: pass | retry | blocked | human_review
    failure_types: [string]
    affects_semantics: boolean
    requires_external_evidence: boolean
    proposed_capability: video-production | null
  retry_snapshot:
    retry_count: integer
    max_retries: integer
    execution_state_ref: string
    prior_review_id: string | null
    supersedes_review_id: string | null
```

## Invariants

- Persist the complete result in `production_manifest.qa.results`; Markdown and Notion remain projections.
- All hashes, policy identity/version, exact target revision, and at least one evidence reference are required. A material dependency or target change makes the decision stale and routes to `UNKNOWN` until reviewed again.
- `generation_gate_recommendation` is only a recommendation to enter the independent Cost Gate. It never contains or grants paid-generation approval.
- `Execution State` remains authoritative for retry count. `retry_snapshot` is an auditable snapshot and may not update the budget.
- A fixture may validate structure and routing, but `fixture_only=true` always withholds the Cost Gate recommendation at runtime.
- `PASS` requires high-confidence evidence for feasibility, continuity, and assigned story-function checks with no unresolved `must_fix`.
- `WARNING` maps to `retry` only for one named non-semantic repair; otherwise it maps to `human_review`.
- `FAIL` maps to `retry` only when a named non-semantic repair target exists and budget remains. Semantic impact maps to `human_review`.
- `UNKNOWN` maps to `blocked` and does not consume retry budget. Missing or contradictory evidence never becomes `FAIL` or `PASS`.
- Gate 2 and Gate 3 values are deliberately invalid until their real-media contracts and evidence paths are separately implemented.
