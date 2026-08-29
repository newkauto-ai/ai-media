# Execution State Contract v1.0

Each work unit must serialize:

```yaml
unit:
  unit_id: string
  stage: topic_selection | research | script_quality | audiovisual_direction | lookdev | pre_generation_prompt_review | production_qa | storyboard | script_architecture_review | visual_test_review | full_production_projection
  required: boolean
  retry_count: integer
  max_retries: integer # default 2
  topic_type: explainer | historical | science | health | business | fiction
  production_risk: low | medium | high
  semantic_locked: boolean
  status: planned | evaluated | retry_scheduled | skipped | blocked | human_review | complete
```

The controller appends a decision record with `observed_at`, evaluator source, evidence references, failure types, selected capability, next action, reason, and retry count. This is the machine state required for a loop; prose plans alone are insufficient.

`storyboard` is optional only when production risk is low. Topic selection, script-architecture review, visual-test review, script-quality freeze, required research, LookDev, and production QA cannot be skipped when their policy prerequisites apply. `full_production_projection` is incomplete until the Stage 1 visual-test confirmation is recorded and the Notion read-back succeeds or is explicitly marked `DEGRADED`.

`pre_generation_prompt_review` is required for a new complete Video Prompt. Its `PASS` state recommends only entry to the separate Cost Gate. The Review Result retry snapshot never increments or overrides this Execution State.
