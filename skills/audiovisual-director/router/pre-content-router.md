# Pre-Content Router

Route only content-affecting modules to Topic Hunter / Script Engine:

```text
compatibility, topic_direction, themes, story_direction, worldview,
character_archetypes, series_content_constraints, dialogue_style,
narration_style, theme_expression_rules, reference_compatibility,
preservation_constraints, replacement_mapping
```

If the script is already frozen and a newly loaded content rule conflicts with it, record `UPSTREAM-CONSTRAINT-LATE` and request a decision. Do not retroactively rewrite the script.

The Router supplies compatibility and series constraints. It never owns the Content Thesis.

The three reference-remake modules route only to Script Engine and are active only for the selected
`reference_video_structural_remake` Profile. They carry the current constraint/evidence references;
they do not create a second state record or rewrite a frozen Script.
