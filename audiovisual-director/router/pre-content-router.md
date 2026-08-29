# Pre-Content Router

Route only content-affecting modules to Topic Hunter / Script Engine:

```text
compatibility, topic_direction, themes, story_direction, worldview,
character_archetypes, series_content_constraints, dialogue_style,
narration_style, theme_expression_rules
```

If the script is already frozen and a newly loaded content rule conflicts with it, record `UPSTREAM-CONSTRAINT-LATE` and request a decision. Do not retroactively rewrite the script.

The Router supplies compatibility and series constraints. It never owns the Content Thesis.
