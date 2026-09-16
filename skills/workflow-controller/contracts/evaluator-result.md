# Evaluator Result Contract v1.1

An LLM evaluator must return structured output rather than prose-only self-critique:

```yaml
assessment:
  source: llm | deterministic_check | human | fixture
  run_id: string | null
  verdict: pass | retry | skip | blocked | human_review
  confidence: high | medium | low
  evidence: [string] # artifact fields, test names, or observed result references
  failure_types: [string]
  affects_semantics: boolean
  requires_external_evidence: boolean
  proposed_capability: string | null
```

Minimum validity: at least one evidence item; `retry` has at least one failure type; and `pass`/`skip` has no unresolved failure. `affects_semantics`, low confidence, or a missing/contradictory result must escalate instead of auto-rewriting. The controller validates this result; it does not infer that an LLM has run.

Review Result v2.1 is an accepted richer input for `pre_generation_prompt_review`. The controller validates its hashes, evidence, gate, fixture boundary, and explicit `controller_mapping`, then normalizes it to this assessment shape. It does not accept Gate 2 or Gate 3 results until their real-media implementations exist. Evaluator Result remains the compatibility input; it is not a second persisted Review authority.

Review Result v2.1 `previsualization_storyboard` is also accepted for the existing `storyboard` stage. It requires immutable media identity and a current `unit.review_context`; PASS advances only to Prompt planning and never recommends a Cost Gate. This bounded target is not Gate 2 or Gate 3.

For evidence-bound `production_qa`, an optional `repair_assessment` may add `severity`, `core_story_function_satisfied`, `can_edit_or_reuse`, `expected_improvement`, `target_revision_id`, and `media_checksum`. It selects the existing accept/edit/request-Cost-Gate/human route; it does not create a new state or retry authority.

For `reference_video_structural_remake`, the same `production_qa` result may add an optional
`reference_fidelity_assessment` with `profile_version`, `constraint_hash`, `reference_media_hash`,
`target_media_hash`, and per-requirement `{requirement_id, status, reference_evidence_refs,
target_evidence_refs, approved_difference_refs, function_preserved, findings}`. Status is
`pass | fail | unknown | stale`. Missing real target media or unreadable/insufficient evidence makes
only affected items `unknown`; a dependency/hash change makes the assessment `stale`. Neither state
consumes retry or creates a new verdict, Gate, similarity score, or state owner.

Recommended evaluator instruction: assess only the named unit against its contract; cite observable evidence; choose one verdict; enumerate failures using the owning Skill taxonomy; never revise frozen semantic locks.
