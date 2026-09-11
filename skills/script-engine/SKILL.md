---
name: script-engine
description: Draft, review, revise, and freeze a master script using an approved Topic Thesis Card and its Topic Hunter duration plan, then prepare a Skill 3 handoff. Use for bounded narrative Script work; do not use for full storyboards, model prompts, or media generation.
---

# Script Engine

Turn an approved Topic Thesis into a high-retention master script, then freeze the exact content semantics that Audiovisual Director may translate but not silently rewrite.

## Read first

- Read [contracts/input-contract.md](contracts/input-contract.md) before writing.
- Read [contracts/skill3-handoff-contract.md](contracts/skill3-handoff-contract.md) before freezing the result.
- Read [../workflow-controller/contracts/staged-approval-gates.md](../workflow-controller/contracts/staged-approval-gates.md) before starting an end-to-end run.
- Read [../workflow-controller/contracts/evaluator-result.md](../workflow-controller/contracts/evaluator-result.md) and [../workflow-controller/contracts/execution-state.md](../workflow-controller/contracts/execution-state.md) before assessing a complete Draft.
- Use [templates/script-package.md](templates/script-package.md) for the human-review package.

## Workflow

1. Read the complete Topic Thesis Card and its Topic Hunter duration recommendation/rationale. Reuse a current recommendation; if it is missing, return only the duration-planning gap to Topic Hunter through Controller. Restate one core thesis. If it conflicts with the intended state change or unique supply, stop and return it to topic design.
2. Generate at least five hooks. Compare directness to the primary user driver, curiosity gap, conflict, information density, context independence, and 3–5 second speakability. Select exactly one.
3. Build an H-C-E-R-M outline before prose: Hook, Conflict, Escalation, Reveal, Meaning. Meaning must first pay off the core conflict; add real-life mapping only when natural.
4. Stop and output the Stage 0 review package: `Topic Theses`, `Hook Selection`, and `H-C-E-R-M outline`. Include the inherited target duration and rationale within Topic Theses so the existing Stage 0 approval also covers that plan. Request explicit `确认第1点`/`批准脚本结构` and do not emit the full master script or any downstream visual/production material yet.
5. After valid Stage 0 approval, write a complete spoken, visualizable, information-dense master script Draft to the approved Topic Hunter duration plan. Estimate its spoken and visual-only timing, pauses, and ending holds; do not pad or truncate content to a built-in duration range. If a materially different duration is needed, return a reasoned proposal through Controller to Topic Hunter rather than silently changing the target. Keep its status unfrozen. Route each genuine pivotal choice or emotional turn through the `story_change_arc` completeness check; ordinary beats may explicitly use `pivotal_change=false` and must not be given invented hesitation.
6. Compress in three passes and run retention review sentence by sentence. Every sentence must perform one function: suspense, conflict, evidence, progression, reversal, or conclusion. Ensure a new stimulus at least every 10–15 seconds.
7. Run the Script Quality Review Policy below on the complete Draft. Route its evidence-backed assessment through the existing `script_quality` unit. The Reviewer diagnoses only; Script Engine remains the only writer.
8. If READY, stop optimizing and freeze the Draft. If a high-confidence local Must Fix routes to retry, repair only the named section once and recheck once. Any structural change, low-confidence or contradictory evidence, or remaining Must Fix after that recheck routes to human review.
9. Produce the lightweight Production Handoff Manifest. It constrains scale; it does not create scenes, shots, storyboards, audiovisual beats, or model prompts.
10. Pass the approved frozen handoff to Audiovisual Director. Do not advance the workflow merely because the script artifact is technically complete; the Stage 0 approval record and READY review are mandatory.

## Short-form legibility

The theme may be deep, but the audience-facing conflict and causality must be explicit enough to understand on first viewing.

- For every major conflict, turn, Reveal, and payoff, make the audience directly see or hear the `trigger -> immediate reaction -> choice/action -> visible result` chain.
- Use the strongest suitable combination of action, facial expression, concise dialogue, and prop or situation state change. Do not make a pivotal causal link depend on stacked glances, a subtly moved object, an unstated motive, or other weak cues that only become meaningful after explanation.
- If a causal link is still unclear without explanatory prose, replace it with a direct observable action or line. Route a genuinely unresolved semantic choice to human decision instead of hiding the gap in performance or camera direction.
- Camera language serves clarity: show cause, reaction, and consequence at readable shot scales; change shot scale or viewpoint at motivated action/reaction turns; avoid long static fixed coverage and unmotivated decorative cutting.
- Do not add dialogue merely to repeat an action that is already clear. Dialogue should clarify intent, conflict, choice, or reversal that the image alone cannot convey efficiently.

## Script Quality Review Policy

Run this policy automatically once for each new complete Draft after Stage 0 approval and before Freeze. Do not run it on an outline, an unchanged frozen Script, or a downstream visual, Prompt, media, or packaging issue. Read only the current Topic Thesis, selected Hook, Draft sections/full text, semantic locks, and existing `story_change_arc` entries.

Select one review mode, not a new stage or evaluator:

- `lite` for explainers, talking-head information, lists, and simple product/function content. Check Promise, Progression, and Payoff. Do not require conflict, twist, an emotional low point, or a complete dramatic arc.
- `full` only when the content promise genuinely depends on character goals and obstacles, relationship or emotional change, a key choice, Reveal, Setup/Payoff, suspense, story, or emotional experience. In mixed content, apply Full lenses only to narrative sections; visual complexity or generation cost never selects Full.

For both modes, identify the opening promise, test whether each major section contributes new information or a real state change, and verify that the ending pays off the established question. Treat surface-varied events with no change in obstacle, information, relationship, choice, or audience judgment as `same_function_repetition`. A temporary function/state-change breakdown may support a finding but must not be persisted as a Beat Map.

In either mode, an essential cause, turn, or payoff that depends on stacked implicit cues instead of an observable causal chain is not presentation polish. Diagnose it with the closest existing failure type, usually `progression_missing`, `causal_payoff_gap`, `emotional_turn_unearned`, or `critical_dialogue_dependency`; do not create a new taxonomy.

For `full`, additionally check:

- dramatic tension: a functional conflict, meaningful escalation, an active audience question, at least one supported change/choice/reveal, and a climax or release with sufficient build;
- audience impact: a caused emotional change, atmosphere that serves a narrative/emotional function when the promise depends on it, and resonance grounded in a concrete situation, recognizable desire or fear, real choice or cost, and meaning produced by action.

Do not require a strong Twist, faster action, more spectacle, or a larger climax when the current promise is already paid off. Slow healing content may be READY when relationship, expectation, or emotion keeps changing and the ending releases that change.

### Findings, decision, and ownership

Return the existing Evaluator Result assessment plus the minimal human projection in the template. A Must Fix must use one of: `promise_unclear_or_mismatched`, `progression_missing`, `same_function_repetition`, `causal_payoff_gap`, `promise_not_paid_off`, `conflict_not_functional`, `tension_not_escalating`, `resolution_overpredictable`, `reveal_unsupported_or_random`, `climax_without_build_or_release`, `emotional_turn_unearned`, or `critical_dialogue_dependency`.

- Return at most three Must Fix findings. Every finding cites a specific sentence, paragraph, or section, names one repair target, and assigns `owner: script_engine | human_decision`.
- Reviewer output is read-only. It must not provide a rewritten full Script, silently change Topic Thesis/Hook/Reveal/facts/conclusion, or design downstream audiovisual execution.
- Preferences such as “more emotional,” “add a joke/twist,” “stronger Memory Image,” “more stylized,” or “larger climax” are Optional or Do Not Optimize, not Must Fix.
- No Must Fix means `READY`, `revision_scope: none`, assessment `pass`, and `STOP SCRIPT OPTIMIZATION`; Optional never causes retry.
- Only a high-confidence, non-semantic finding localized to one or a few sections may be `REVISE`, `revision_scope: local`, assessment `retry`, and `owner: script_engine`.
- A change to the approved Topic Thesis, core Hook, Reveal, facts, conclusion, or Stage 0 architecture is `REVISE`, `revision_scope: structural`, assessment `human_review`, and `owner: human_decision`; never rewrite it automatically.

The existing Execution State is retry authority. For `script_quality`, set `max_retries: 1`. After one targeted local repair, the recheck must be READY or route to `human_review`; do not create another counter or loop.

An explicit user request may reopen one read-only Review, one focused Review using only named lenses, or one authorized targeted revision of the current version. One request performs one round and stops. Preserve prior retry history; a user request does not restore an automatic loop, and structural semantic changes still require an explicit user decision.

## Boundaries

- Own SAY: final information order, Hook, Reveal, Meaning, and exact semantic content.
- Do not modify the Topic Thesis silently.
- Do not bypass Stage 0 by presenting a full script, Global visual DNA, image prompts, or Notion projection in the first response.
- Do not perform fact verification unless the task explicitly includes evidence gathering; never present unverified claims as verified.
- Do not create a separate Script Preflight Skill/module, Review Result gate, Review Core, retry ledger, Rewrite Engine, Beat Map schema, or Production Manifest field for this policy.
- Do not create a full storyboard, audiovisual direction, Seedance prompt, asset prompt, voice plan, BGM plan, or generated media.
- Visual beat count in the manifest is only an estimated production envelope. Skill 3 owns Audiovisual Beat design.
- `story_change_arc` is Script authority. Script Engine alone freezes `pivotal_change`, motive, choice, resulting action, and semantic locks; downstream Skills may only reference the frozen arc or return a proposal/缺口.
- Platform adaptation here is a low-cost legacy/provisional handoff only: title, caption, tags, and an existing-frame cover hint. When Publishing & Packaging v1.1 is available, Skill 5 is the final authority for platform copy, actual cover assets, publish windows, compliance projection, and Package readiness. Do not create a separate Xiaohongshu edit.

## Controller return

Use this Skill directly for a bounded Script explanation, read-only Review, or explicitly scoped Draft/revision that does not itself advance the project. Any Stage 0 package, frozen Script, formal Script Quality Review, version change, or downstream-lineage impact must return the `controller_return` envelope defined by Workflow Controller. Include the Script artifact/version/hash/status, Review refs, Stage 0 evidence, unresolved conflicts, external-action boundary, and one recommended next action. A Stage 0 proposal returns `awaiting_user_confirmation`; a semantic or structural conflict returns `human_review`; a completed frozen Script still requires Controller re-observation. Stop after the envelope and never invoke Audiovisual Director directly. If reliable Controller re-entry is unavailable, use `awaiting_controller_resume`.

## Freeze gate

Set `frozen_script.status` to `frozen` only after Stage 0 approval, complete Draft, fit to the approved Topic Hunter duration plan with a separate actual estimate, H-C-E-R-M structure, compression, sentence-function audit, retention stimulus, Script Quality Review READY, and handoff manifest checks pass. Once frozen, downstream skills may translate presentation but may not silently delete the Hook, alter Reveal, change facts, or change the core conclusion.
