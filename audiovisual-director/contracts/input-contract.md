# Audiovisual Director Input Contract v1.0

## Required input

```yaml
audiovisual_director_input:
  topic_thesis:
    topic: string
    core_thesis: string
    user_desire_or_need: object
    concrete_scenario: string
    intended_state_change: object
    propagation_motive: object
    unique_supply: string
  frozen_script:
    script_id: string
    version: string
    status: frozen
    estimated_duration_seconds: integer
    selected_hook: string
    sections: {hook, conflict, escalation, reveal, meaning}
    full_text: string
    semantic_locks:
      core_thesis: string
      hook: string
      reveal: string
      core_conclusion: string
      factual_claims: [string]
  production_handoff_manifest:
    major_character_count: integer
    core_scene_count: integer
    visual_beat_count: integer
    consistency_risks: [string]
    reusable_assets: [string]
    production_complexity: low | medium | high
    over_budget_notes: string
```

Reject a title-only input, a non-frozen script, or a handoff missing any required field.

## Optional input

```yaml
  style_profile: object | null
  series_bible: object | null
  current_user_overrides: object | null
  production_adapter_reference: object | null
  reference_fidelity: object | null
```

The optional `reference_fidelity` value is accepted only from the frozen Script handoff for the
selected ready `reference_video_structural_remake` Profile. It references the authoritative evidence
record and current `constraint_hash`; it must not embed a second copy of observations. Missing motion
or sound evidence leaves only those dimensions `UNKNOWN`.

`production_adapter_reference` may inform capability constraints but remains owned by Skill 4. Never copy its model syntax into the ADP's permanent style identity.

## Field authority

- Topic Thesis: current user instruction > explicit Series Bible > Topic Hunter > soft style constraint.
- Script semantics: current user instruction > frozen script > Script Engine > narrative style constraint.
- Visual, voice, and BGM: current user override > Series Canon > selected Style Profile > runtime recommendation.
- Final model syntax: Skill 4 current adapter > stored template > style reference.
