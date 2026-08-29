# Clip Prompt Compiler and Timeline Validator

Follow the [Executable Prompt Contract](../contracts/executable-prompt-contract.md). Compile three logical layers plus a read-only `clip_performance_binding` into the frozen six-module Video Clip Prompt:

- `global_shared`: whole-project visual, color, output, text/subtitle, and audio-routing rules. Store once, but deliver the applicable values to every independent call as prompt text or Adapter parameters.
- `identity_invariants`: exact frozen text for each present character or product. Reuse it verbatim across independently generated Clips unless the Adapter proves persistent identity context; include voice only for verified native-speech generation.
- `clip_variables`: actual start state, this Clip's action and micro-expression/emotional beat, exact native dialogue when applicable, camera, timeline, intended end state, and Clip-specific constraints.

`clip_performance_binding` may only cite an existing ADP `performance_plan`; it supplies timeline evidence references and does not create a new choice, motive, or resulting action. The binding provenance is `story_change_arc -> performance_plan -> clip_performance_binding`.

Record `duration_seconds`, `aspect_ratio`, `resolution`, and `native_audio_mode` in the Clip `output_spec`, and expose them in the reviewable call package. Unresolved aspect ratio or resolution blocks `ready_for_generation`. Compile the approved baseline, selected references, actual start state, timeline, camera/performance, intended end state, and continuity constraints. Do not ask the video model to generate BGM.

## Preflight before rendering

Do not render a complete or copy-ready six-module prompt directly from the draft. Run this bounded sequence first:

1. Run the deterministic Scene Continuity and Video Prompt Feasibility checks. A hard conflict stops compilation.
2. Build the compact `semantic_preflight.risk_packet` from only the Clip Scene, start state, timeline, end state, involved characters, prop state changes, and metaphorical clauses. Do not reload the full Brief, Manifest, project history, or unrelated locks for this review.
3. Obtain one declared semantic/human evaluator result for physical common sense, setting/prop compatibility, action causality, and literalization risk. Enforce 1200 input characters, 250 output characters, and at most three findings.
4. Render the external prompt only when both layers pass with evidence and high confidence. Missing/unknown results route to `needs_semantic_review`; semantic impact, low confidence, or contradictory evidence routes to `needs_human_review`.

One targeted repair and one recheck are allowed only for a named failure whose evaluator records `affects_semantics=false`. Never use keyword or regex matching as a common-sense Gate, never loop self-critique, and never claim that a Fixture supplied a real semantic judgment. Keep the Gate summary outside the frozen six modules.

## Notion projection and copy-ready fields

The staged workflow must already be at Stage 2. A Clip prompt, asset prompt, or production page
must not be written to Notion while the run is waiting for `确认第1点` or `确认第2点`.

When a Clip is written to Notion, the `Video Prompt` property receives only the rendered executable prompt. It must be independently usable when copied into another video tool: include the output specification, reference responsibilities, global style, current start state, a continuous timeline, camera/performance direction, intended end state, and a compact negative set. Do not write acceptance notes, QA summaries, cost approvals, file paths, or phrases such as `已接受片段`, `正文另见`, `承接上一条后再编译`, or `Clip Brief` as a substitute for the prompt.

For a planned Clip whose real predecessor has not been generated, write the frozen planned start state as a provisional prompt while keeping the database `Status` as `Planned` and `实际结束状态` empty. Never promote a planned state to observed continuity. Every project-specific Notion prompt view must filter the `项目` relation by the exact project page ID; project names and broad text search are not sufficient isolation.

Internally store every segment as numeric `start_seconds` and `end_seconds` rounded to one decimal. Validate: first start is `0.0`; each end equals the next start; each end is greater than its start; no segment overlaps; final end equals both the Clip duration and `output_spec.duration_seconds`; each segment states action, camera change, and any critical state change. Timing is a planning constraint, not a claim of frame-exact model compliance.

Use a compact, failure-driven negative set. Default to no generated subtitles, screen text, watermark, or background music only when those layers are produced separately. Add no unintended bystanders or unrelated third-party marks only when required by the approved scene; never use that rule to erase an authentic, approved product identity.
