---
name: audiovisual-director
description: Translate a frozen Topic Thesis, master script, production handoff, and newly frozen character, genre, or style semantics into a model-independent Audiovisual Direction Package, returning conflicts upstream. Use after Script Engine; do not generate media or model-specific prompts.
---

# Audiovisual Director

Own SEE + HEAR + PERFORM. Translate frozen content semantics into a unified, model-independent director package that Video Production can compile and execute.

## Read first

1. Read [contracts/input-contract.md](contracts/input-contract.md) and reject incomplete required inputs.
2. Read [../workflow-controller/contracts/staged-approval-gates.md](../workflow-controller/contracts/staged-approval-gates.md). Do not run before the Stage 0 script-architecture approval is recorded.
3. Read [contracts/unified-style-profile.md](contracts/unified-style-profile.md), then run `scripts/scan-style-profiles.ps1` when the project Style Profile library exists. Read [router/style-ingestion.md](router/style-ingestion.md) when a new, changed, raw, or normalized style document is present.
4. Read [router/pre-content-router.md](router/pre-content-router.md) when a style contains content constraints that should have applied before script freeze.
5. Read [router/audiovisual-router.md](router/audiovisual-router.md) and [router/conflict-resolver.md](router/conflict-resolver.md) for every run.
6. Read the seven module guides relevant to the output, then validate against [contracts/audiovisual-direction-package.md](contracts/audiovisual-direction-package.md).
7. Use [templates/output-package-template.md](templates/output-package-template.md) for human review.

## Workflow

1. Validate `topic_thesis`, `frozen_script`, and `production_handoff_manifest`. The script must be frozen.
2. Scan `style-profiles/source/`. Normalize or validate every new/changed selected Style Profile into `style-profiles/normalized/`, preserve provenance, distinguish source-defined from runtime-recommended values, and update `style-profiles/registry.json` only after validation.
3. Route content modules upstream and audiovisual modules into this Skill. Record ignored production modules for Skill 4.
   For `reference_video_structural_remake`, accept the frozen `reference_fidelity` handoff only when
   its profile version, evidence reference, and `constraint_hash` are current. Keep one authoritative
   `reference_evidence_record`; the ADP stores references and target mappings, not copied observations.
4. Apply style compatibility and domain-specific authority rules. Flag conflicts; never silently rewrite content.
5. Produce, in order: Style Blueprint, Character & Voice Bible, Asset Plan, Audiovisual Beats, Sound Cue Plan, Music Brief and Suno Prompt, Continuity Plan, Template Bindings, and Skill 4 handoff. Generic projects normally use 8–12 Beats. A structure-locked reference remake preserves the validated reference-unit order and count instead of padding to 8–12; reference unit, Beat, Shot, and Clip remain different units.
6. For every frozen `story_change_arc` with `pivotal_change=true`, create a read-only `performance_plan` that cites the arc and translates it into visible trigger, initial evidence, deliberation, decision signal, resulting action, and end evidence. Do not copy or rewrite the arc's internal semantics.
7. Include Global / Domain Visual DNA and a model-independent LookDev Test Spec because Skill 4 v1.1 requires them. After Stage 0 approval, provide the Global visual DNA to the Stage 1 review package; do not output more than the three required LookDev test prompts before the next confirmation.
8. For each critical reference preservation requirement, emit a `reference_fidelity_trace` from the
   evidence/function reference to the target Script/ADP position and planned production responsibility.
   Record only critical motion phases, camera-to-subject relations, composition/occlusion,
   text/graphic holds, and sound landing points. Separate `source_timing` from `target_timing`; leave
   `observed_timing` for Video Production after real-media inspection.
   This consumes `reference_evidence_record`, `reference_structure_mapping`,
   `dynamic_relationship_plan`, and `sound_timing_basis` from the selected Profile.
9. Output one structured ADP and one concise human-readable director package without duplicating the same detail only after the staged workflow is allowed to produce the full package.

## Hard boundaries

- Do not change the Topic Thesis, Hook, Reveal, factual claims, or core conclusion without an explicit conflict flag and upstream/user decision.
- `performance_plan` owns only SEE/HEAR/PERFORM translation. Its provenance must be `story_change_arc -> performance_plan`; a conflict returns upstream and is never silently repaired.
- Do not emit Global visual DNA or image prompts before Stage 0 approval. Stage 1 must expose exactly three image-test targets: `主角`, `场景`, and `Key Frame`.
- Do not call image, video, TTS, or music-generation models.
- Do not write current-model executable prompts. Template bindings are identifiers plus semantic bindings only.
- Keep BGM independent from video prompt planning.
- Do not record actual generation state, perform production QA, retry assets, edit, mix, publish, or create a Final Master.
- Do not split this Skill into Agents.

## Controller return

Use this Skill directly for a bounded ADP explanation, read-only Review, or explicitly scoped direction artifact that does not advance Stage. Any new/revised ADP, semantic conflict, or Stage 1 package must populate the logical `controller_return` envelope defined by Workflow Controller. Include the ADP artifact/version/hash/status, semantic-lock refs, unresolved conflicts, Stage 1 approval state, external-action boundary, and one recommended next action. Follow the Controller's user-facing rendering rule: do not append raw `controller_return` YAML/JSON unless the user explicitly requests machine-readable or debug details, or a destination tool requires it. Stage 1 readiness records `awaiting_user_confirmation`; conflicts record `blocked` or `human_review`. Stop after the envelope and never invoke Video Production directly. If reliable Controller re-entry is unavailable, use `awaiting_controller_resume`.

## Completion gate

Deliver only when every Beat has story function, visual direction, performance, audio, music state, assets, continuity start/end intent, complexity, and risk; all semantic locks remain unchanged; production complexity honors the upstream Manifest; and the Skill 4 handoff contains no generated assets or executable model prompts.
