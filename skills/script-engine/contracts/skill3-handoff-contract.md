# Skill 2 to Skill 3 Handoff Contract v1.1

## Compatibility decision

The three implementation briefs have no blocking semantic conflict at this boundary. Canonical names resolve wording differences:

- Final Script / 母剧本 becomes `frozen_script` with `status: frozen`.
- Topic Thesis Card uses the canonical Skill 3 snake_case fields below.
- Script-level Visual Beat count remains an estimate; no beat content is emitted here.

## Required production payload

Skill 3 consumes only `skill3_input`. Audit and `platform_packaging` fields remain available to humans and upstream calibration, but are not Skill 3 requirements. `platform_packaging` is a legacy/provisional hint source; Publishing & Packaging v1.1 owns final platform copy, cover, timing, and Package readiness.

```yaml
script_engine_output:
  contract_version: "1.1"
  skill3_input:
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
    frozen_script:
      script_id: string
      version: string
      status: frozen
      target_duration_seconds: integer # inherit the approved Topic Hunter total duration; no fixed range
      estimated_duration_seconds: integer
      selected_hook: string
      sections:
        hook: string
        conflict: string
        escalation: string
        reveal: string
        meaning: string
      full_text: string
      semantic_locks:
        core_thesis: string
        hook: string
        reveal: string
        core_conclusion: string
        factual_claims: [string]
      story_change_arcs: [story_change_arc]
    production_handoff_manifest:
      major_character_count: integer
      core_scene_count: integer
      visual_beat_count: integer # production envelope only; usually 8-12
      consistency_risks: [string]
      reusable_assets: [string]
      production_complexity: low | medium | high
      over_budget_notes: string
    reference_fidelity: object | null # optional; current reference-remake constraint and mapping refs
  audit:
    hook_candidates: [string] # at least 5
    selected_hook_reason: string
    hcerm_outline: object
    compression_checks:
      background_filler_removed: boolean
      duplicate_explanations_removed: boolean
      non_visual_abstractions_removed: boolean
    retention_review:
      five_second_death_test: pass | fail
      stimulus_intervals_seconds: [integer]
      notes: [string]
  platform_packaging:
    authority: legacy_provisional_skill2
    final_owner: publishing_packaging
    douyin: object
    xiaohongshu: object
    youtube_shorts: object

story_change_arc:
  contract_version: "1.1"
  arc_id: string
  script_reference: string
  character_id: string
  pivotal_change: true | false
  trigger_event: string | null
  initial_internal_state: string | null
  conflict_or_deliberation: string | null
  choice_or_change: string | null
  resulting_action: string
  end_internal_state: string | null
  semantic_locks: [string]
  authority: script_engine
```

## Downstream authority lock

The handoff preserves the approved Topic Hunter `target_duration_seconds` and separately records the Script Engine estimate. Estimate spoken pacing, visual-only performance, pauses, and ending holds against this topic-specific plan; if the draft needs a materially different duration, return a reasoned proposal through the existing Controller to Topic Hunter rather than silently changing the target. This does not add a Gate or promise that every downstream format can execute an arbitrary duration.

Skill 3 may split the script into audiovisual expression, decide narration/dialogue/visual evidence, and merge visual treatments. It must flag a conflict before changing the Topic Thesis, deleting the Hook, altering the Reveal, changing facts, or changing the core conclusion.

For every `pivotal_change=true` arc, the handoff must preserve trigger, initial state, deliberation, decision/choice, resulting action, and end state. A `pivotal_change=false` arc is allowed for a non-choice beat and does not require a fabricated psychological arc.

Skill 4 receives downstream ADP and owns model-specific prompts and actual production. No Skill 4 business logic belongs in this handoff.

For `reference_video_structural_remake`, `reference_fidelity` carries only the current
`profile_id`, `profile_version`, `primary_goal`, `content_structure_lock`, `constraint_hash`,
`reference_evidence_ref`, `reference_structure_mapping`, and preservation requirement IDs. It does
not duplicate the evidence record. Any constraint/evidence hash change invalidates downstream
reference-fidelity conclusions through existing lineage rules. Reference units remain distinct from
ADP Beats and generation Clips.
