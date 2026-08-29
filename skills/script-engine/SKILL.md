---
name: script-engine
description: Convert an approved Topic Thesis Card into a frozen 60-90 second short-video master script and a Skill 3 production handoff. Use after topic selection; do not use for full storyboards, model prompts, or media generation.
---

# Script Engine

Turn an approved Topic Thesis into a high-retention master script, then freeze the exact content semantics that Audiovisual Director may translate but not silently rewrite.

## Read first

- Read [contracts/input-contract.md](contracts/input-contract.md) before writing.
- Read [contracts/skill3-handoff-contract.md](contracts/skill3-handoff-contract.md) before freezing the result.
- Read [../workflow-controller/contracts/staged-approval-gates.md](../workflow-controller/contracts/staged-approval-gates.md) before starting an end-to-end run.
- Use [templates/script-package.md](templates/script-package.md) for the human-review package.

## Workflow

1. Read the complete Topic Thesis Card. Restate one core thesis. If it conflicts with the intended state change or unique supply, stop and return it to topic design.
2. Generate at least five hooks. Compare directness to the primary user driver, curiosity gap, conflict, information density, context independence, and 3–5 second speakability. Select exactly one.
3. Build an H-C-E-R-M outline before prose: Hook, Conflict, Escalation, Reveal, Meaning. Meaning must first pay off the core conflict; add real-life mapping only when natural.
4. Stop and output the Stage 0 review package: `Topic Theses`, `Hook Selection`, and `H-C-E-R-M outline`. Request explicit `确认第1点`/`批准脚本结构` and do not emit the full master script or any downstream visual/production material yet.
5. After valid Stage 0 approval, write and freeze the spoken, visualizable, information-dense 60–90 second master script, targeting about 75 seconds. Before freezing, route each genuine pivotal choice or emotional turn through the `story_change_arc` completeness check; ordinary beats may explicitly use `pivotal_change=false` and must not be given invented hesitation.
6. Compress in three passes and run retention review sentence by sentence. Every sentence must perform one function: suspense, conflict, evidence, progression, reversal, or conclusion. Ensure a new stimulus at least every 10–15 seconds.
7. Produce the lightweight Production Handoff Manifest. It constrains scale; it does not create scenes, shots, storyboards, audiovisual beats, or model prompts.
8. Pass the approved frozen handoff to Audiovisual Director. Do not advance the workflow merely because the script artifact is technically complete; the Stage 0 approval record is mandatory.

## Boundaries

- Own SAY: final information order, Hook, Reveal, Meaning, and exact semantic content.
- Do not modify the Topic Thesis silently.
- Do not bypass Stage 0 by presenting a full script, Global visual DNA, image prompts, or Notion projection in the first response.
- Do not perform fact verification unless the task explicitly includes evidence gathering; never present unverified claims as verified.
- Do not create a full storyboard, audiovisual direction, Seedance prompt, asset prompt, voice plan, BGM plan, or generated media.
- Visual beat count in the manifest is only an estimated production envelope. Skill 3 owns Audiovisual Beat design.
- `story_change_arc` is Script authority. Script Engine alone freezes `pivotal_change`, motive, choice, resulting action, and semantic locks; downstream Skills may only reference the frozen arc or return a proposal/缺口.
- Platform adaptation here is a low-cost legacy/provisional handoff only: title, caption, tags, and an existing-frame cover hint. When Publishing & Packaging v1.1 is available, Skill 5 is the final authority for platform copy, actual cover assets, publish windows, compliance projection, and Package readiness. Do not create a separate Xiaohongshu edit.

## Freeze gate

Set `frozen_script.status` to `frozen` only after duration, H-C-E-R-M structure, compression, sentence-function audit, retention stimulus, and handoff manifest checks pass. Once frozen, downstream skills may translate presentation but may not silently delete the Hook, alter Reveal, change facts, or change the core conclusion.
