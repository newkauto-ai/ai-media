# Topic Hunter Input Contract v1.1

## Required

```yaml
topic_hunter_input:
  content_domain: string
  target_audience: string
  primary_platforms: [string]
  production_constraints:
    target_duration_seconds: integer | null # optional explicit user target; never a built-in default
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

Topic Hunter determines the recommended total video duration for each candidate from the Topic Thesis, audience, information or performance needs, selected format, evidenced platform constraints, and production cost. An explicit user duration takes precedence. An absent duration constraint is null, not a reason to require the user to choose or to apply a fixed range. A generation Adapter's per-Clip duration limit does not cap the total video.

Do not fabricate missing history, trend data, or Series Bible rules. Treat missing optional inputs as `null` and state the limitation when it affects the decision.

Pre-content style constraints may contain compatibility, themes, worldview, story direction, character archetypes, dialogue style, narration style, and series content constraints. They constrain candidates but do not own the Content Thesis.
