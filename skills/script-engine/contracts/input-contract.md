# Script Engine Input Contract v1.0

## Required

```yaml
script_engine_input:
  selected_topic_id: string
  topic_thesis:
    topic: string
    core_thesis: string
    user_desire_or_need:
      primary: string
      secondary: string | null
    concrete_scenario: string
    intended_state_change:
      type: cognition | viewpoint | emotion | behavior | identity
      from: string
      to: string
    propagation_motive:
      primary_action: share | comment | save
      reason: string
    unique_supply: string
  target_duration_seconds: [60, 90]
```

## Optional

```yaml
  source_evidence: [object]
  historical_hook_data: object | null
  pre_content_style_constraints: object | null
  series_bible_constraints: object | null
  current_user_overrides: object | null
```

Reject title-only input. If any required Topic Thesis field is missing or if the core thesis cannot be stated as one coherent claim, return `NEEDS_TOPIC_REWORK` instead of drafting.
