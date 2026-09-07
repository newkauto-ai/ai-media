---
name: topic-hunter
description: Generate, screen, score, and rank short-video topics into a Top 3 with complete Topic Thesis Cards. Use for content-topic selection before script writing; do not use for scripting, storyboarding, or production.
---

# Topic Hunter

Turn one content direction into a forced Top 3 decision and a single recommended topic. Optimize for topic quality and production economics, not idea volume.

## Read first

- Read [contracts/input-contract.md](contracts/input-contract.md) for required inputs.
- Read [contracts/output-contract.md](contracts/output-contract.md) before producing the final result.
- Use [templates/topic-shortlist.md](templates/topic-shortlist.md) for the human-readable output.

## Workflow

1. Generate 20–30 genuinely distinct candidates spanning counterintuitive, Why, conflict, character, real-life mapping, and long-form-extension angles.
2. Quickly reject candidates that are broad, conflict-free, question-free, exhausted without a new angle, economically unrealistic, meaningless beyond a short gimmick, or unable to support 5–10 minutes.
3. For every deep-screen candidate, create a Topic Thesis Card with exactly one primary user driver and at most one secondary driver.
4. Apply Gate 1:
   - 4–5 clear thesis dimensions: continue.
   - 3 clear dimensions: retain only after improving the angle.
   - 0–2 clear dimensions: reject.
   User driver and intended state change are mandatory core dimensions.
5. Score only Gate 1 pass candidates on five independent 0–2 dimensions: conflict, curiosity, reversal, resonance, extension. The total must equal their sum and remain a transparent 10-point score.
6. Record click trigger and AI production difficulty separately as high, medium, or low. Never blend them into the 10-point score.
7. Apply production economics: prefer one core character, one core question, 3–6 core scenes, and one conclusion. High difficulty triggers angle simplification before rejection.
8. Output only Top 3 and force a Top 1 recommendation with a specific reason.

## Short-form legibility

A topic may carry a nuanced or deep thesis, but its short-form expression route must be direct and quickly legible.

- During deep screening, require the core conflict, immediate cause, audience question, and intended state change to be expressible through observable actions, reactions, concise dialogue, or object/situation state changes in the concrete scenario.
- Improve or reject a candidate when its pivotal turn depends mainly on an unstated motive, an off-screen event, abstract symbolism, or several weak cues that viewers must combine before the causal link makes sense.
- Record the simplest visible `trigger -> response -> change` route in `concrete_scenario` or `unique_supply` without writing Script prose, shots, or audiovisual beats.
- Direct expression does not require a shallow thesis. Keep the depth in the idea and meaning; make the audience-facing conflict and causality easy to grasp on first viewing.

## Boundaries

- Own WHAT: topic choice and why the audience cares.
- Do not write a full script, storyboard, prompt, audiovisual beat, or production asset.
- Do not invent live trend evidence. If current market evidence is required, obtain or request it and label its date and source.
- Do not change score weights from fewer than five valid published samples.
- Style constraints may filter compatibility, but may not silently replace the Content Thesis.

## Controller return

Use this Skill directly for bounded topic generation, comparison, or explanation. When it creates or selects a project Topic Thesis, return the `controller_return` envelope defined by Workflow Controller with the Topic Thesis artifact/ref, evidence gaps, approval state, external-action boundary, and one recommended next action. Use `awaiting_user_confirmation` until the topic is explicitly approved. Stop after the envelope: do not call Script Engine or cross Stage 0 unless Controller has re-observed the artifact and selected that action. If Controller cannot be re-entered reliably, use `awaiting_controller_resume`.

## Quality gate

Before delivery, verify that every Top 3 entry has all Topic Thesis fields, a score arithmetic check, click trigger, production difficulty, long-form extension, and recommendation. The Top 1 must be unambiguous.
