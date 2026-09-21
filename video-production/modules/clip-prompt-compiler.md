# Clip Prompt Compiler and Timeline Validator

## External Prompt Fast Path

When `workflow_mode: external_prompt_only`, output one compact `seedance_prompt_package` instead of the frozen six-module Clip Prompt: `package_version`, `strategy`, `operation`, `copy_ready_prompt`, `reference_bindings`, `request_parameters`, at most three `must_hold`, `creative_freedom`, `unresolved`, and `status`. The self-contained prompt states the hook/goal, subject, visible change and ending, only necessary beat or timestamp progression, reference responsibilities, must-hold constraints, delegated creative freedom, sound intent, and a small failure-driven negative set. Keep unknown duration, aspect ratio, resolution, or UI parameter visibly `UNKNOWN`; do not invent them. `request_parameters` is a readback projection of the actual execution surface: each value is confirmed, `UNKNOWN`, or `not_applicable`; a local package hash does not prove what was submitted.

Select exactly one operation: `timestamp_edit` for a named time window in an existing video, `extend_video` to continue accepted video, `reference_based_generation` to re-express supplied multimodal references, or `new_master_take` when no valid base should be reused. `local_post_note` is information only and never a provider action. For named styles requested for personal study/interest, retain the requested name alongside observable Style DNA (material, line, palette, composition, light, performance, and motion); do not alter Style Profile source/normalized/registry records or claim endorsement. Only after an observed provider rejection may the output visibly fall back to `descriptive_only`.

Run exactly one bounded Feed-first `pre_generation_prompt` check using the existing feasibility, continuity, and story-function meanings: opening viewing motive, first-pass subject/event/claim clarity, visible change, ending payoff, sound intent, story-breaking identity/product/prop/physics risk, and Duration Fit. Duration Fit examines the visible start/change/result/ending hold at the declared current duration; it does not count actions or prescribe a fixed duration. Return at most three Must Fix items. Automatically repair once only for named, local, non-semantic issues; factual unknowns, core-message changes, low confidence, or contradiction return to the Controller. PASS means `prompt_ready_for_external_use`, not Cost-Gate eligibility, generation, or media QA.

Follow the [Executable Prompt Contract](../contracts/executable-prompt-contract.md). Compile three logical layers plus a read-only `clip_performance_binding` into the frozen six-module Video Clip Prompt:

- `global_shared`: whole-project visual, color, output, text/subtitle, and audio-routing rules. Store once, but deliver the applicable values to every independent call as prompt text or Adapter parameters.
- `identity_invariants`: exact frozen text for each present character or product. Reuse it verbatim across independently generated Clips unless the Adapter proves persistent identity context; include voice only for verified native-speech generation.
- `clip_variables`: actual start state, this Clip's action and micro-expression/emotional beat, exact native dialogue when applicable, camera, timeline, intended end state, and Clip-specific constraints.

When the selected Style Profile is `oriental_pastoral_cinematic_lifestyle` and the current Shot carries `pastoral_craft_shot_type`, compile only the applicable intent into `clip_variables`:

- `atmosphere_shot`: state its formal breathing, regional, emotional, contrast, visual-echo, or aftertaste function. Do not render it as generic tourism scenery or an unmotivated beauty cutaway.
- `process_detail_shot`: state one credible bounded local action and observable contact/material response. Explicitly allow the Shot to end without a complete teaching loop; do not ask the model to close complex needlework, weaving, mechanical repetition, or multi-step cooking inside one Shot.
- `progression_shot`: state `prior_process_state_ref`, `current_process_state`, and the specific visible `completion_delta`. A match cut or visual echo may connect evidenced stages, but never request magic growth, full-frame morphing, unsupported instant completion, or plastic 3D transformation.

Keep the montage truthful across calls: the previous result remains the next input, and each independent prompt receives the required state reference. The two-process/one-atmosphere pattern is planning guidance and is not serialized as a literal action count. Project-grounded relationships such as “the real exterior and the crafted image echo one another” are allowed only when both elements are confirmed by the current project; do not automatically inject Jiangnan, Hanfu, embroidery, tea, or a female subject.

`clip_performance_binding` may only cite an existing ADP `performance_plan`; it supplies timeline evidence references and does not create a new choice, motive, or resulting action. The binding provenance is `story_change_arc -> performance_plan -> clip_performance_binding`.

Record `duration_seconds`, `aspect_ratio`, `resolution`, and `native_audio_mode` in the Clip `output_spec`, and expose them in the reviewable call package. Unresolved aspect ratio or resolution blocks `ready_for_generation`. Compile the approved baseline, selected references, actual start state, timeline, camera/performance, intended end state, and continuity constraints. Do not ask the video model to generate BGM.

For a successor of an accepted Clip, make the predecessor endpoint a named Adapter binding, not background prose. Prefer the terminal frame as `first_frame`; if that is unavailable but image-reference input exists, bind it as `predecessor_endpoint_continuity` and state that its responsibility is only the opening pose, blocking, props, and grade. The `【起始状态】` must name any story-critical left/right hand, screen direction, and prop contact exactly; the first timeline segment must preserve them for a brief opening hold before any stated change. The `【连续性与禁止项】` must separately repeat the predecessor lighting signature: key/fill direction, white balance, exposure, contrast, saturation, palette, and warm/cool relation. Do not freeze the entire successor Clip: a later pose or lighting change is permitted only when declared as a causal event in the timeline. If no endpoint image can be bound through the current Adapter, mark that pixel-level continuity unknown and withhold a continuity-preserving claim.

For a native-audio route, compile only frozen dialogue/narration and assigned ambience/Foley/SFX. Never invent narration or extra lines. When the project prioritizes less post-production, retain native dialogue and action sound unless the Adapter lacks the capability or current QA rejects that layer. Repeat each recurring speaker's approved voice label verbatim across independent Clips and attach the same approved per-character audio reference whenever the Adapter supports it and rights are verified. Expose the audio reference role in the call package. A native-audio Clip cannot pass audio QA without evidence for exact text, correct speaker, voice continuity, lip sync, distortion, and balance; failed audio routes to independent replacement or human decision rather than automatic video regeneration.

## Preflight before rendering

Do not render a complete or copy-ready six-module prompt directly from the draft. Run this bounded sequence first:

1. Run the deterministic Scene Continuity and Video Prompt Feasibility checks. A hard conflict stops compilation.
2. Build the compact `semantic_preflight.risk_packet` from only the Clip Scene, start state, timeline, end state, involved characters, prop state changes, metaphorical clauses, declared current duration, required visible state changes, ending hold, and Adapter duration evidence. Do not reload the full Brief, Manifest, project history, or unrelated locks for this review.
3. Obtain one declared semantic/human evaluator result for physical common sense, setting/prop compatibility, action causality, literalization risk, story function, and Duration Fit. Enforce 1200 input characters, 250 output characters, and at most three findings.
4. Render the external prompt only when both layers pass with evidence and high confidence. Missing/unknown results route to `needs_semantic_review`; semantic impact, low confidence, or contradictory evidence routes to `needs_human_review`.

One targeted repair and one recheck are allowed only for a named failure whose evaluator records `affects_semantics=false`. Never use keyword or regex matching as a common-sense Gate, never loop self-critique, and never claim that a Fixture supplied a real semantic judgment. Keep the Gate summary outside the frozen six modules.

## Notion projection and copy-ready fields

The staged workflow must already be at Stage 2. A Clip prompt, asset prompt, or production page
must not be written to Notion while the run is waiting for `确认第1点` or `确认第2点`.

When a Clip is written to Notion, the `Video Prompt` property receives only the rendered executable prompt. It must be independently usable when copied into another video tool: include the output specification, reference responsibilities, global style, current start state, a continuous timeline, camera/performance direction, intended end state, and a compact negative set. Do not write acceptance notes, QA summaries, cost approvals, file paths, or phrases such as `已接受片段`, `正文另见`, `承接上一条后再编译`, or `Clip Brief` as a substitute for the prompt.

For a planned Clip whose real predecessor has not been generated, write the frozen planned start state as a provisional prompt while keeping the database `Status` as `Planned` and `实际结束状态` empty. Never promote a planned state to observed continuity. Every project-specific Notion prompt view must filter the `项目` relation by the exact project page ID; project names and broad text search are not sufficient isolation.

Internally store every segment as numeric `start_seconds` and `end_seconds` rounded to one decimal. Validate: first start is `0.0`; each end equals the next start; each end is greater than its start; no segment overlaps; final end equals both the Clip duration and `output_spec.duration_seconds`; each segment states action, camera change, and any critical state change. Timing is a planning constraint, not a claim of frame-exact model compliance.

Use a compact, failure-driven negative set. Default to no generated subtitles, screen text, watermark, or background music only when those layers are produced separately. Add no unintended bystanders or unrelated third-party marks only when required by the approved scene; never use that rule to erase an authentic, approved product identity.

For `reference_video_structural_remake`, a critical timeline item may reference `requirement_id`,
`source_timing`, `target_timing`, `timing_basis`, and `tolerance`. Bind semantic reveals to the
target line/event; bind music beats, physical contact, and user-locked sync points to their evidence
basis. Never copy a source timestamp into the target merely because the source used it, and never
populate `observed_timing` or claim synchronization before inspecting bound real media. Include only
necessary action phases, camera-relative motion, composition/occlusion, text/graphic holds, and sound
landing constraints.
