# Prompt Story Function Conformance

Compose this check into the existing bounded semantic preflight after deterministic Feasibility and Continuity pass. It is one additional assessment category in the same evaluator call, not a second semantic reviewer or a replacement QA engine.

## Input

Use only the exact prompt revision and compact upstream assignments:

```yaml
story_function_packet:
  target_revision_id: string
  content_hash: string
  frozen_script_refs: [string]
  adp_refs: [string]
  story_change_arc_refs: [string]
  performance_plan_refs: [string]
  clip_performance_binding_refs: [string]
  intended_clip_function: string
  expected_start_state: string
  expected_end_state: string
  assigned_hook: boolean
  assigned_turning_point: boolean
  assigned_payoff: boolean
  expected_new_information: string
  planned_entry_and_exit: string
  duration_fit: {current_duration_seconds: number | null, visible_state_changes: [string], ending_hold: string | null, adapter_extension_or_split_evidence: string | null}
```

## Review boundary

Judge only whether the executable prompt preserves and can express the assigned upstream function:

- referenced frozen assignments exist and form the approved authority chain;
- the prompt preserves the intended start state, visible change, expected end state, and new information;
- Hook, Turning Point, or Payoff is checked only when upstream explicitly assigns that role;
- entry, development, and exit/hold are usable for later editing without requiring the full generated duration;
- Duration Fit checks whether the assigned visible state changes and ending hold are legible at the declared current duration. It does not count actions, impose a universal duration, or infer extension/split capability when execution-surface evidence is absent.
- camera, performance, and action instructions serve the assigned function rather than add new plot or spectacle.

Do not count actions, enforce universal density or three-second rules, rewrite frozen semantics, invent a Hook/Turning Point/Payoff, or infer conformance from keywords. Complex action is allowed when evidence shows coherent resources, causality, continuity, and function.

Return at most three evidence-backed findings under `story_function_conformance`, including `duration_legibility_risk` when duration makes a required visible state change or ending hold not legible. High-confidence conformance may contribute to Review Result `PASS`. Missing assignments/evidence are `UNKNOWN`; a proposed semantic change is `HUMAN_REVIEW`; a confirmed prompt-to-assignment mismatch is `FAIL` with the owning upstream repair target. When a non-semantic local simplification is evidenced, recommend only that owning Prompt revision and one recheck; longer duration, split, or new master is `UNKNOWN` unless current execution-surface evidence supports it.
