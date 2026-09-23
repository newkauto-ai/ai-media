# QA and Targeted Retry

QA checks semantic fidelity, prompt coverage and discriminative power, identity and style consistency, Domain identity, spatial/action/camera/performance accuracy, output-spec compliance, unintended text/branding, artifacts, and end-state continuity. Classify failures only as: `prompt_under_specified`, `prompt_non_discriminating`, `consistency_lock_violation`, `output_spec_mismatch`, `unintended_text_or_brand`, `identity_drift`, `duplicate_or_extra_character`, `false_visual_leak`, `style_drift`, `domain_identity_failure`, `environment_drift`, `prop_drift`, `motion_failure`, `camera_failure`, `timing_failure`, `multishot_failure`, `expression_overacting`, `expression_underacting`, `continuity_mismatch`, `text_render_failure`, or `artifact`.

For the bounded VOX technical route: cut-off subject, false transparency, missing Alpha, unsafe edge, or decode failure maps to `artifact`; an unbound or semantically orphaned halo/ring/arrow maps to `motion_failure` (or `artifact` when it is a render defect); a Master audio-stream duration mismatch maps to `timing_failure`; and a current delivery resolution/frame rate/sample rate mismatch maps to `output_spec_mismatch`. Prefer a local repair for a bounded removable defect. These mappings remain ordinary `production_qa`; they do not implement Final Cut Review or a new retry authority.

For VOX Remotion local assembly, QA evaluates the declared information goal, primary attention target, key layouts, protected regions, semantic end state, and narration/event bindings—not motion count, historical zoom amplitude, a fixed layer count, a six-effect list, or mandatory poster restoration/global freeze. Static, dynamic, and compound motion are all eligible. Flag unintended occlusion or crop of a currently protected face, hand, prop, evidence text, or caption safe region as `artifact` or `camera_failure`; a declared close-up crop that preserves its protected target is not a source-completeness failure. Duplicate caption burn-in is `text_render_failure`. An SFX with no matching visible motion interval or settle/hit event, or one made stale by a timeline revision, is `timing_failure`. Missing Alpha and false transparency remain failures. A stronger perspective, fold, rotate, shake, deform, or dissolve is not a failure by category, but missing required back/side/occluded-region assets, identity/text/fact change, paper-medium break, or unreadability is.

For VOX decomposition/reconstruction, reuse the current Poster Readiness / `previsualization_storyboard` Review Result before motion. A static reconstruction that materially changes composition, hierarchy, focal weight, negative space, palette, or typography character is `style_drift`, `text_render_failure`, or `artifact` according to the observed defect; pixel non-identity alone is not failure. A plate that invents hidden facts or expands materially beyond approved motion-exposure regions is `artifact` or `environment_drift`. A baked duplicate outline, background/role/resolution-inappropriate runtime outline, or outline-shadow substitution is `artifact`. Hero Typography downgraded to ordinary CSS or an unverified SVG/PNG is `text_render_failure`. A numeral display that changes value, unit, scale, date meaning, or historical/cultural fact is `text_render_failure` and may also require human review for semantic impact.

When a real generated asset is unsuitable for its original Shot, prefer bounded salvage within the existing asset/QA record before regeneration: check `later_beat`, `hero_poster`, `cover`, `title_card`, `detail_crop`, `background`, and `transition`, then `reject`. Preserve the original media checksum and record reviewed uses, selected target, crop/text limits, Review ref, and rationale. Salvage cannot change facts, identity, era, composition locks, rights, or authorization.

For an intended `production_reconstructable` Pilot, do not repair over-fusion with visible rectangular screenshot crops. Horizontal/vertical crop lines, background halo, full-width context strips, title-plus-background rectangles, or adjacent-element fragments remain `must_fix`. If visual quality is high, recommend `hero_key_art` and preserve the result through the same salvage/reuse record; otherwise target SVG/text rebuild, verified typography, an independent asset, or human review.

Pre-generation feasibility results additionally use the structural failure codes from the Feasibility Contract. `unknown` is a review route, not a failure and never consumes retry budget; no retry or Clip split is proposed before real repeated generation evidence.

Retry only the failed asset or Clip and the responsible layer. Repair under-specification by adding the missing decision; repair non-discriminating prompts by deleting or replacing clauses that do not affect the acceptance target. For a lock violation, restore the frozen anchor rather than rewriting identity across all Clips. For Domain failure, repair spatial grammar, architecture, composition, light field, scale, and Domain DNA rather than merely recoloring. For text failure, route to a Graphic Asset plus typesetting. For repeated multi-shot failure, reduce complexity, then split into continuous Clips with a Resume Keyframe. Stop at the approved Gate's stopping condition.

## Regeneration decision policy

Do not create a separate Regeneration Gate. For an evidence-bound `production_qa` assessment, use the existing Execution State retry authority and project one next action:

- core story function is satisfied and findings are only `optional` / `do_not_optimize` -> `accept_current_stop_optimizing`;
- a named defect can be reliably repaired locally -> `edit_or_reuse_failed_unit`;
- an evidence-backed `must_fix` cannot be edited, expected improvement is medium/high, and retry budget remains -> `request_separate_regeneration_cost_gate`;
- media revision/checksum is missing, semantics would change, ownership is unclear, expected improvement is low, or retry budget is exhausted -> `request_human_decision`.

“感觉还能更好”, “再试一版”, and “也许更漂亮” are not sufficient evidence. Requesting the separate regeneration Cost Gate never authorizes a provider call. Increment retry count only through Execution State when a repair/regeneration attempt is scheduled.

For `reference_video_structural_remake`, run the optional reference comparison inside this same
`production_qa` owner. Check each critical requirement against its reference function, bound target
media evidence, approved differences, and current hashes. Missing, unreadable, or expired evidence is
`UNKNOWN` or `stale`, never PASS and never a retry. A bounded subtitle, graphic, or sound defect
prefers `edit_or_reuse_failed_unit`; do not regenerate unrelated video. When required functions are
preserved and all remaining differences are optional, use `accept_current_stop_optimizing`. Do not
emit a total similarity score or new failure taxonomy.

Whiteboard 1.3 segment execution remains ordinary `production_qa`: render and technically check one immutable Job before starting the next; on failure retain passed segments, stop downstream, and route only the named failed unit through existing Execution State. A continuous-canvas merge checks non-overlapping logical frame ranges, exact total frames/duration, no boundary duplicate/gap/flash/state loss, hidden tip at the boundary, full decode, and SHA-256. A board cut must be declared. Technical success and merge parity remain `success_pending_human_review` until continuous human viewing.

## Natural layers and micro-animation QA

For VOX, use actual evidence in existing `production_qa`, not a new Gate. A clipped approved source outline, visible hard crop, neighbor fragment, stamp/text ghost, hole or broken contact edge is `artifact` (or `camera_failure` for an unintended framing cause); displaced/unreadable critical text is `text_render_failure`. No added outline is valid when natural separation already reads; preserve approved intrinsic outlines without doubling them. A recovered background never proves hidden anatomy complete.

When perceptible layered parallax is the declared goal, inspect relative movement at target viewing size in final encoded continuous playback. Insufficient or incoherent relative movement that defeats that goal is `motion_failure`; a purely static Shot or a purposeful shared camera move does not fail for lacking parallax. Check margins, all contact/occlusion edges, text and temporal texture. With `continue_to_last_visible_frame` intent, early stopping or an ease-out visual stall in the tail is `timing_failure`; an intentional reading hold is valid. A still independent label does not require the environment to stop.

Transform changes, coverage calculations and non-identical last frames only support the review. They cannot prove perceptible parallax, coordination or continuous human viewing. Missing media/viewing evidence stays `UNKNOWN` and does not consume retry. Report natural boundaries/fused limitations, exposure/extreme evidence and observed parallax/tail behavior in existing findings. Preserve accepted outputs; repair only the evidenced defect.
