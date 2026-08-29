# Audiovisual Direction Package Contract v1.2

Version 1.2 adds read-only visible-performance translation while retaining the v1.1 LookDev fields.

```yaml
audiovisual_direction_package:
  contract_version: "1.2"
  meta:
    project_id: string
    topic_id: string
    script_id: string
    script_version: string
    selected_style_profiles: [string]
    series_bible: string | null
    current_overrides: object | null

  semantic_locks:
    core_thesis: string
    hook: string
    reveal: string
    core_conclusion: string
    factual_claims: [string]

  style_resolution:
    classification: string
    compatibility: {result, reasons, risks, recommendation}
    loaded_modules: [string]
    routed_upstream_modules: [string]
    ignored_production_modules: [string]
    conflicts: [object]
    resolved_by: [string]
    provenance: object

  style_blueprint:
    visual_identity: object
    camera_language: object
    performance_language: object
    sound_identity: object
    voice_identity: object
    music_identity: object
    global_visual_dna: object
    visual_domains: [object]

  character_voice_bible: [object]
  asset_plan: {characters, scenes, props, special_assets}
  audiovisual_beats: [object] # usually 8-12; Beat is not Shot or Clip
  performance_plans: [performance_plan]
  sound_cue_plan: [object]
  music: {music_brief, suno_prompt}
  continuity_plan: object
  template_bindings: object

  production_handoff:
    complexity: low | medium | high
    highest_risk_beats: [string]
    reusable_assets: [string]
    generation_priority: [string]
    recommended_validation_order: [string]
    lookdev_test_spec:
      purpose: string
      anchor_count: integer # 3-5
      anchors: [object]
      validation_dimensions: [global_style, domain_identity, world_scale, story_usability, reference_usability]
      human_approval_required: true
      domain_blocking_policy: string
```

## Audiovisual Beat minimum

Each Beat must include `beat_id`, `script_reference`, `story_function`, `narration_or_dialogue`, `visual`, `performance`, `audio`, `music`, `assets`, `continuity`, and `production`.

`continuity.expected_end_state` is Skill 3 intent. Do not emit `actual_end_state`.

```yaml
performance_plan:
  contract_version: "1.0"
  performance_plan_id: string
  source_arc_id: string
  adp_beat_ids: [string]
  visible_trigger: [string]
  initial_visible_evidence: [string]
  deliberation_visible_evidence: [string]
  decision_signal_visible_evidence: [string]
  resulting_action_visible_evidence: [string]
  end_visible_evidence: [string]
  performance_style:
    intensity: restrained | natural | heightened
    forbidden_overacting: [string]
  gate:
    status: passed | blocked | needs_semantic_review | needs_human_review | not_required
    evaluator_source: deterministic | llm | human
    evidence: [string]
    failures: [string]
```

Each `performance_plan` is a translation, not a second editable story. It must cite an existing Script arc and may not add a motive, choice, or resulting action.

## Forbidden output

The ADP must not contain executable image/video prompts, generated asset paths, actual generation results, production QA results, retry decisions, edit timelines, or final-master claims.
