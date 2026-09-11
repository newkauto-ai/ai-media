# QA and Targeted Retry

QA checks semantic fidelity, prompt coverage and discriminative power, identity and style consistency, Domain identity, spatial/action/camera/performance accuracy, output-spec compliance, unintended text/branding, artifacts, and end-state continuity. Classify failures only as: `prompt_under_specified`, `prompt_non_discriminating`, `consistency_lock_violation`, `output_spec_mismatch`, `unintended_text_or_brand`, `identity_drift`, `duplicate_or_extra_character`, `false_visual_leak`, `style_drift`, `domain_identity_failure`, `environment_drift`, `prop_drift`, `motion_failure`, `camera_failure`, `timing_failure`, `multishot_failure`, `expression_overacting`, `expression_underacting`, `continuity_mismatch`, `text_render_failure`, or `artifact`.

For the bounded VOX technical route: cut-off subject, false transparency, missing Alpha, unsafe edge, or decode failure maps to `artifact`; an unbound or semantically orphaned halo/ring/arrow maps to `motion_failure` (or `artifact` when it is a render defect); a Master audio-stream duration mismatch maps to `timing_failure`; and a current delivery resolution/frame rate/sample rate mismatch maps to `output_spec_mismatch`. Prefer a local repair for a bounded removable defect. These mappings remain ordinary `production_qa`; they do not implement Final Cut Review or a new retry authority.

Pre-generation feasibility results additionally use the structural failure codes from the Feasibility Contract. `unknown` is a review route, not a failure and never consumes retry budget; no retry or Clip split is proposed before real repeated generation evidence.

Retry only the failed asset or Clip and the responsible layer. Repair under-specification by adding the missing decision; repair non-discriminating prompts by deleting or replacing clauses that do not affect the acceptance target. For a lock violation, restore the frozen anchor rather than rewriting identity across all Clips. For Domain failure, repair spatial grammar, architecture, composition, light field, scale, and Domain DNA rather than merely recoloring. For text failure, route to a Graphic Asset plus typesetting. For repeated multi-shot failure, reduce complexity, then split into continuous Clips with a Resume Keyframe. Stop at the approved Gate's stopping condition.

## Regeneration decision policy

Do not create a separate Regeneration Gate. For an evidence-bound `production_qa` assessment, use the existing Execution State retry authority and project one next action:

- core story function is satisfied and findings are only `optional` / `do_not_optimize` -> `accept_current_stop_optimizing`;
- a named defect can be reliably repaired locally -> `edit_or_reuse_failed_unit`;
- an evidence-backed `must_fix` cannot be edited, expected improvement is medium/high, and retry budget remains -> `request_separate_regeneration_cost_gate`;
- media revision/checksum is missing, semantics would change, ownership is unclear, expected improvement is low, or retry budget is exhausted -> `request_human_decision`.

“感觉还能更好”, “再试一版”, and “也许更漂亮” are not sufficient evidence. Requesting the separate regeneration Cost Gate never authorizes a provider call. Increment retry count only through Execution State when a repair/regeneration attempt is scheduled.
