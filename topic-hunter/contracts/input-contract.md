# Topic Hunter Input Contract v1.0

## Required

```yaml
topic_hunter_input:
  content_domain: string
  target_audience: string
  primary_platforms: [string]
  production_constraints:
    target_duration_seconds: [60, 90]
    preferred_character_range: [1, 3]
    preferred_scene_range: [3, 6]
    cost_limit: string
```

## Optional

```yaml
  tested_topics: [string]
  historical_content_data: object | null
  pre_content_style_constraints: object | null
  series_bible_constraints: object | null
  current_user_overrides: object | null
```

Do not fabricate missing history, trend data, or Series Bible rules. Treat missing optional inputs as `null` and state the limitation when it affects the decision.

Pre-content style constraints may contain compatibility, themes, worldview, story direction, character archetypes, dialogue style, narration style, and series content constraints. They constrain candidates but do not own the Content Thesis.
