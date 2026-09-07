# Video Prompt Feasibility Gate

This module runs two bounded layers: deterministic structural validation, then a required compact semantic preflight for any copy-ready Video Prompt. It never treats keyword or regex matching as evidence of natural reach, common sense, psychology, restraint, metaphor quality, or action meaning.

The six risk families are continuity handshake, body-resource occupancy, posture/distance/touch geometry, prop state transitions, physical causality, and literalization risk. Deterministic checks cover IDs, versions, references, enum values, timeline joins, structured resource intervals, structured prop transitions, coverage bindings, and state authority. Open semantic inputs remain `unknown`, `needs_semantic_review`, or `needs_human_review` with `evaluator_source`, `evidence`, `confidence`, and `owner`.

After deterministic checks pass, build one risk packet containing only `clip_id`, Scene, start state, timeline, end state, involved characters, prop state changes, and metaphorical clauses. Keep the serialized packet at or below 1200 characters. A semantic or human evaluator checks physical common sense, setting/prop compatibility, action causality, and literalization risk, returning at most three findings whose combined human-readable summary and evidence stay at or below 250 characters.

Do not render or label a prompt copy-ready when the semantic preflight is absent, over budget, `unknown`, low confidence, contradictory, `blocked`, or `needs_human_review`. Permit at most one targeted repair and one recheck when the evaluator records `affects_semantics=false`; otherwise stop for human review. Do not load the full project merely to perform this preflight.

For new Review Result v2.1 runs, the same compact evaluator call also applies [Prompt Story Function Conformance](prompt-story-function-review.md) to the explicit upstream role assignment and Duration Fit. Add only the declared current duration, required visible state changes, ending hold, and any Adapter duration evidence to the compact packet. A high-confidence `duration_legibility_risk` blocks copy-ready output through the existing `timing_failure` meaning; missing duration evidence is `unknown` for that item, not a reason to skip unrelated checks. Do not launch a second reviewer, count actions, impose universal timing, or treat a keyword match as story evidence. Persist the result through [Review Result v2.1](../contracts/review-result-contract.md); legacy Feasibility v1.1 fixtures remain read-only compatibility inputs.

Every validator result uses:

```yaml
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

Hard deterministic conflicts or evidence-backed semantic failures set the Clip feasibility status to `blocked` and the executable prompt to `null`. Missing semantic evaluation routes to `needs_semantic_review`; `unknown` never becomes `passed` and never consumes retry budget. No action-count, action-density, complexity, or automatic Clip-splitting rule belongs here.
