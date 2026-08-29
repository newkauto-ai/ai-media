# Audiovisual Router

Load into Skill 3:

```text
visual_identity, character_visual, character_voice, environment, props,
cinematography, performance, editing_rhythm, sound_design, voice_system,
music_direction, continuity_schema, template_bindings
```

Route production-only modules to Skill 4 without executing them:

```text
asset_prompt_templates, first_frame_templates, end_frame_templates,
video_prompt_templates, negative_constraints, model_adapter_reference,
asset_binding_rules, generation_workflow
```

Record loaded, routed-upstream, and ignored-production modules in `style_resolution` so no style document is silently applied as one undifferentiated block.
