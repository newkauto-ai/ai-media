# QA and Targeted Retry

QA checks semantic fidelity, prompt coverage and discriminative power, identity and style consistency, Domain identity, spatial/action/camera/performance accuracy, output-spec compliance, unintended text/branding, artifacts, and end-state continuity. Classify failures only as: `prompt_under_specified`, `prompt_non_discriminating`, `consistency_lock_violation`, `output_spec_mismatch`, `unintended_text_or_brand`, `identity_drift`, `duplicate_or_extra_character`, `false_visual_leak`, `style_drift`, `domain_identity_failure`, `environment_drift`, `prop_drift`, `motion_failure`, `camera_failure`, `timing_failure`, `multishot_failure`, `expression_overacting`, `expression_underacting`, `continuity_mismatch`, `text_render_failure`, or `artifact`.

For the bounded VOX technical route: cut-off subject, false transparency, missing Alpha, unsafe edge, or decode failure maps to `artifact`; an unbound or semantically orphaned halo/ring/arrow maps to `motion_failure` (or `artifact` when it is a render defect); a Master audio-stream duration mismatch maps to `timing_failure`; and a current delivery resolution/frame rate/sample rate mismatch maps to `output_spec_mismatch`. Prefer a local repair for a bounded removable defect. These mappings remain ordinary `production_qa`; they do not implement Final Cut Review or a new retry authority.

For VOX Remotion local assembly, QA evaluates the declared information goal, primary attention target, key layouts, protected regions, semantic end state, and narration/event bindings—not motion count, historical zoom amplitude, a fixed layer count, a six-effect list, or mandatory poster restoration/global freeze. Static, dynamic, and compound motion are all eligible. Flag unintended occlusion or crop of a currently protected face, hand, prop, evidence text, or caption safe region as `artifact` or `camera_failure`; a declared close-up crop that preserves its protected target is not a source-completeness failure. Duplicate caption burn-in is `text_render_failure`. An SFX with no matching visible motion interval or settle/hit event, or one made stale by a timeline revision, is `timing_failure`. Missing Alpha and false transparency remain failures. A stronger perspective, fold, rotate, shake, deform, or dissolve is not a failure by category, but missing required back/side/occluded-region assets, identity/text/fact change, paper-medium break, or unreadability is.

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
