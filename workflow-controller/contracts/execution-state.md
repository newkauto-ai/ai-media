# Execution State Contract v1.0

Each work unit must serialize:

```yaml
unit:
  unit_id: string
  stage: topic_selection | research | script_quality | audiovisual_direction | lookdev | pre_generation_prompt_review | production_qa | storyboard | script_architecture_review | visual_test_review | full_production_projection
  required: boolean
  retry_count: integer
  max_retries: integer # script_quality must be 1; otherwise default 2
  topic_type: explainer | historical | science | health | business | fiction
  production_risk: low | medium | high
  semantic_locked: boolean
  status: planned | evaluated | retry_scheduled | skipped | blocked | human_review | complete
```

The controller appends a decision record with `observed_at`, evaluator source, evidence references, failure types, selected capability, next action, reason, and retry count. Start/resume reconciliation stays a turn-level observation and writes only its artifact checks, drift, and evidence references into this existing decision evidence; it does not create a second state object or change this contract version. This is the machine state required for a loop; prose plans alone are insufficient.

`script_quality` is the existing Script Engine Freeze review unit, not a new stage. Set `max_retries: 1`: the first high-confidence, named, non-semantic local Must Fix may schedule one targeted Script Engine repair; a remaining Must Fix at `retry_count: 1`, any structural/semantic change, or low/contradictory confidence routes to `human_review` without incrementing the count. Optional-only findings must be assessed as `pass` and cannot consume retry budget. User-requested re-review/revise records its request and target revision as decision evidence but runs one round only and does not reset prior retry history.

`storyboard` is optional only when production risk is low. Topic selection, script-architecture review, visual-test review, script-quality freeze, required research, LookDev, and production QA cannot be skipped when their policy prerequisites apply. `full_production_projection` is incomplete until the Stage 1 visual-test confirmation is recorded and the Notion read-back succeeds or is explicitly marked `DEGRADED`.

For a Review Result v2.1 `previsualization_storyboard` unit, serialize `review_context` with the current target revision/content hash/media checksum and current dependency hashes. The Controller compares these values before routing. A mismatch is stale evidence: `blocked`, no retry increment. READY/REVISE are projections of this state plus Review Result; they are not Execution State values.

`pre_generation_prompt_review` is required for a new complete Video Prompt. Its `PASS` state recommends only entry to the separate Cost Gate. The Review Result retry snapshot never increments or overrides this Execution State.
