# VOX Poster Shot Planner

Use this module only for registry-ready `vox_transcript_driven_handmade_collage`. It projects high-level ADP Beats into independently readable VOX editorial Poster Shots inside the existing Scene/Shot/`local_assembly_plan` model. It does not create a new Manifest, Gate, state machine, approval, retry ledger, semantic owner, or actual-state owner.

## Inputs

Require the frozen Script, confirmed final narration semantic intervals, current ADP Beats, ready VOX Style Profile, current approved Visual Baselines, reusable-asset evidence, and existing Production Manifest revision. Missing or stale semantic/time/baseline evidence blocks only the affected planning action; do not invent it.

## Planning sequence

1. Preserve each ADP Beat's story/audiovisual function and absolute narration interval.
2. Split the Beat into one or more Poster Shots only when information density, reading time, evidence, map/detail, comparison, climax, or editorial rhythm requires it. Do not force Wide + Detail or a fixed shot count.
3. Give every Poster Shot one `information_goal`, one primary attention target at a time, one independently readable `stable_poster_state`, and an open-vocabulary `shot_role`/`poster_archetype`.
4. Define the poster before motion: visual hierarchy, reading path, protected critical-text region, paper layers, primary/secondary elements, and the exact approved stable-state reference.
5. Derive the minimum asset requirements used by at least one approved Poster Shot. Keep the ADP asset plan as Candidate Asset Plan; do not queue unused candidates.
6. Select a motion route only after Poster Readiness passes. Motion may enrich or transform the poster but may not rescue a failed composition.
7. Compare adjacent shots and record the intended difference. Three highly similar consecutive shots emit `editorial_repetition_warning`; material harm becomes a Review Result `must_fix`, not an automatic quota failure.

## Poster Shot Map

Each entry minimally contains:

```yaml
poster_shot_id: string
source_beat_id: string
time_range: {start_seconds: number, end_seconds: number}
information_goal: string
primary_attention_target: string
shot_role: string
poster_archetype: string
stable_poster_state: object
critical_text:
  owner: remotion
  generate_text_in_image: false
  items: [object]
asset_requirements: [string]
adjacent_shot_difference: string
motion_route: remotion_living_poster | remotion_precision_motion | generative_hero_clip
```

`shot_role` is descriptive and open. Suggested values are `establish`, `detail`, `comparison`, `evidence`, `map`, `number`, `relationship`, `transition`, `climax`, `symbolic_payoff`, and `custom`.

## Local assembly projection

Project, do not duplicate, the Poster Shot into the current Scene/Shot record:

```yaml
local_assembly_plan:
  poster_shot_id: string
  source_beat_id: string
  shot_role: string
  adjacent_shot_difference: string
  poster_spec:
    poster_archetype: string
    visual_hierarchy: object
    primary_subject: object
    secondary_elements: [object]
    background_system: object
    foreground_system: object
    reading_path: [string]
    text_safe_area: object
    critical_text_owner: remotion
    generate_text_in_image: false
    stable_poster_state_ref: string
    poster_readiness_review_ref: string
  motion_plan:
    route: remotion_living_poster | remotion_precision_motion | generative_hero_clip
    camera_motion: {intent: string, phases: [object]}
    element_motion: [{target: string, motion: string, timing: object, purpose: string}]
    why_not_remotion: string | null
```

`camera_motion.intent` is not a closed enum. Static, strong, compound, multi-phase, perspective-aware and layer-coordinated motion remain available when the material, coverage and reading constraints support them.

## Motion routing

- Default to `remotion_living_poster` for portraits, quotes, evidence, comparisons, conclusions and general editorial layouts.
- Use `remotion_precision_motion` when maps, routes, timelines, numbers, evidence relationships, controlled typography or deterministic geometry are the primary need.
- Use `generative_hero_clip` only when complex human/animal/crowd/environment physical performance is the value and local deterministic assembly is insufficient. Require a specific non-empty `why_not_remotion`; “more cinematic” is insufficient.
- `living_poster` and `element_assembly` are composable motion patterns on top of a completed poster, not alternate routes around Poster Readiness.

## Asset derivation

For each production-eligible asset add:

```yaml
reuse_count: integer
used_by_poster_shots: [string]
production_priority: high | medium | low
implementation_route: reuse_existing | generated_asset | remotion_svg | remotion_css | temporary_atlas | local_graphic
```

An asset is production-eligible only when `used_by_poster_shots` contains at least one Poster Shot whose current Review evidence permits asset derivation. Prefer high-reuse assets first and local SVG/CSS/graphics for one-off decoration. This eligibility does not grant a provider call or Cost Gate.

## Poster Readiness

Reuse Review Result `previsualization_storyboard` and its existing lineage/evidence rules. Review these checks: primary attention clarity, editorial hierarchy, paper-layer separation, critical-text protection, readability without motion, asset coverage, adjacent-composition distinction, Style Baseline consistency, and poster-to-motion feasibility.

Any unresolved `must_fix` blocks motion compilation for the affected Poster Shot. Missing/stale evidence maps to `UNKNOWN` without retry consumption. Fixture output proves only structure and routing, never composition quality or approval.
