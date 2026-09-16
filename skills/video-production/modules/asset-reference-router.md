# Asset Reference Router

Apply the Nearest Useful Reference Principle in this order: Clip/Resume Keyframe, Scene or Clip Production Asset, Variant Asset, Identity Asset, then approved Style Reference. Give multi-reference models distinct roles: primary visual reference, identity reference, and optional Style Baseline. Do not replace a nearer valid state reference with a generic identity image.

For `external_prompt_only`, emit a compact `continuity_package` rather than copying ledger state: choose one main operation (`timestamp_edit`, `extend_video`, `reference_based_generation`, or `new_master_take`); bind every supplied image, video, or audio reference to exactly one role (`base_video`, `identity`, `scene_light`, `action_camera`, `audio`, or `predecessor_endpoint_continuity`); and list preserve/change-only constraints. `predecessor_endpoint_continuity` is the only added Fast Path role: it binds the readable predecessor terminal frame or an approved Resume Frame and is responsible only for the opening pose, blocking, prop contact, and grade. It does not require or create `state_record_id`, and it never copies `actual_end_state`. Prefer a clean endpoint reference for an independent new segment, and do not chain low-quality tail frames. Without a readable endpoint reference, say that pixel continuity is `UNKNOWN` and express only planned continuity constraints.

For `reference_video_structural_remake`, every bound reference has exactly one responsibility:
`identity`, `action_camera`, `scene_light`, `audio`, `base_video`, or
`predecessor_endpoint_continuity`. Do not let identity become motion/camera evidence, or let a
reference face, logo, dialogue, or factual claim contaminate the replacement subject. Bind asset
identity/SHA plus the current constraint hash; still-only or unreadable evidence leaves unsupported
dimensions `UNKNOWN`.
This is the existing owner for the Profile module `reference_asset_binding`.
