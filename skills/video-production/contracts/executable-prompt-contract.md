# Executable Prompt Contract v1.3

An Executable Prompt is the smallest self-contained generation instruction that preserves every decision needed for the intended result and its acceptance test. It must pass both tests:

- **Coverage:** source locks, visible decisions, output parameters, continuity dependencies, and failure-preventing constraints are in prompt text or its reviewable request envelope.
- **Deletion:** every retained sentence changes expected pixels, preserves an approved lock, sets an Adapter parameter, or prevents a named QA failure. Remove vague praise, duplicate style tags, and non-discriminating clauses.

The seven image dimensions below are an internal decision matrix, not seven mandatory external headings. Compile only the frozen type-specific template for the chosen asset and variant.

## Image Prompt Spec

`production_manifest.json` stores one `image_prompt_spec` per image asset and one video feasibility result per Clip. It is the internal source of truth; the model receives only `executable_prompt` plus the reviewable `call_package`.

```yaml
image_prompt_spec:
  contract_version: "1.1" # v1.2 only when prompt_variant=cover_visual
  asset_id: string
  asset_type: character_identity | scene | prop | graphic | keyframe
  prompt_variant: default | story_prop | product_evidence | cover_visual
  pilot_design_route: hero_key_art | production_reconstructable | null # required only for a declared VOX Pilot
  source_locks: [{field, value, provenance}]
  decisions:
    subject_action: {status, value, inherited_from, reason}
    context: {status, value, inherited_from, reason}
    composition_camera: {status, value, inherited_from, reason}
    lighting_outcome: {status, value, inherited_from, reason}
    style_aesthetic: {status, value, inherited_from, reason}
    optics: {status, value, inherited_from, reason}
    color: {status, identity_palette, product_true_color, grade, inherited_from, reason}
  material_texture: {status, value, inherited_from, reason}
  text_handling: {status, value, inherited_from, reason}
  consistency_locks: [object]
  allowed_variation: [object]
  reference_bindings: [object]
  negative_constraints: [object]
  output_spec: {aspect_ratio, size, quality, background, output_format, status}
  clause_decision_map: [{clause_id, decision_paths, acceptance_effect}]
  executable_prompt: string
  qa: {status, failures}
```

Every decision dimension uses exactly one status: `explicit`, `inherited`, or `not_applicable`. `explicit` needs a usable value and provenance; `inherited` needs `inherited_from` and must copy the approved value rather than paraphrase it; `not_applicable` needs a reason. Empty/null is never a resolved decision.

## Mandatory-by-Type rules

- Every asset resolves subject/production task and composition/format decision. The first effective natural-language sentence (after headings, IDs, and request parameters) maps to `subject_action`.
- Context is explicit or inherited when an environment matters. Its absence must explicitly select `transparent`, `solid_color`, `neutral_studio`, `inherit_reference`, or justified `not_applicable`; `null` blocks a ready call package.
- Character Identity uses neutral pose/view tasks, never an invented current-scene action. Scene preserves foreground, midground action space, background, and future character positions. Graphic treats the information goal and main visual as its subject.
- `optics` cannot be `not_applicable` for `product_evidence`, `photorealistic`, `perspective_sensitive`, protected geometry/ports/edges, or acceptance criteria involving depth, distortion, compression, or macro detail. Prefer visible behavior (low distortion, normal perspective, full subject focus) and use focal-length tokens only when the selected Adapter documents support.
- Graphic does not receive focal-length, depth-of-field, or photography-lighting filler unless a declared condition actually triggers it.
- Material, exact text handling, identity locks, and output parameters remain Mandatory-by-Type whenever acceptance depends on them.
- `cover_visual` uses `asset_type=keyframe`, inherits Key Frame current-action and reference-responsibility rules, and inherits Graphic title-safe-zone/text handling. It requires platform, platform-native composition, title-safe zone, UI avoidance, thumbnail priority, `generate_text_in_image=false`, and checksum-bound reference roles. Xiaohongshu and Douyin requests must not differ only by size or crop.
- A declared VOX Pilot requires `pilot_design_route`. `hero_key_art` keeps reconstructability out of its acceptance requirements. `production_reconstructable` automatically compiles a clause requiring a coherent editorial poster whose major typography, directional, decorative, and context groups remain visually separable and independently reconstructable, with negative space and without cross-element texture entanglement, full-width context strips, or rectangular screenshot-crop dependency. The compiler must not inject fixed layer counts, layouts, palettes, or project-specific constants.

## Truth, color, and conflict rules

Separate immutable `identity_palette` / `product_true_color` from lighting cast and optional `grade`. A grade may not rewrite a frozen character palette or inspected product color. Fail closed when any of the following conflict:

- grade changes identity or product true color;
- a generic negative rule removes an approved authentic product logo;
- allowed variation changes a locked keyboard, port, mark, wear item, costume, or identity color;
- transparent output conflicts with a demanded real-world background;
- a hard trigger is marked not applicable;
- an uninspected source gains a product feature, mark, defect, or specification.

For product evidence, lock inspected keyboard layout, ports, logo geometry/position, chassis proportions, color, and existing wear as applicable. Preserve approved identity-bearing marks; mask serial numbers unless the user explicitly authorizes their use. Prohibit redesign, keyboard/port changes, moved logos, repair of visible damage, and unverified embellishment.

## Call Package boundary

```yaml
call_package:
  executable_prompt: string
  reference_bindings: [object]
  request_parameters: {size, quality, background, output_format}
  adapter_id: string
  unresolved_fields: [string]
  generation_status: ready | blocked
```

Aspect ratio, size, background, quality, and format may live in Adapter request parameters rather than natural language, but must be adjacent to the prompt in this package. A required transparent PNG defaults to the existing ChatGPT Web conversation for the current Work/Codex task; this route does not prove conversation availability, saved-file Alpha, or an exposed model version. Every real call remains blocked pending its separate cost Gate. For a compiled Cover Prompt, the caller may relabel this local result as `generation_status=not_authorized`; this is stricter than `blocked` and does not authorize a provider call.

### Temporary atlas prompt projection

An existing one-element image plan may additionally be projected locally as a VOX `manual_crop_from_named_transparent_atlas` package. It reuses the same `image_prompt_spec` and `call_package` field meanings and must retain `call_package.generation_status=blocked`. Use the smallest grid that fits: `2x2` for one to four compatible small elements, or `3x3` for five to nine. Group only elements sharing one evidenced destination-background and runtime-outline validation basis:

```yaml
atlas_prompt_projection:
  projection_type: manual_crop_from_named_transparent_atlas
  source_asset_ids: [string] # 1-9 existing planned asset IDs
  grid: 2x2 | 3x3
  destination_background: string
  cells: [{cell_id: A..I, element_name_zh: string, state_or_pose: string, asset_constraints: string, suggested_filename: string}]
  outline_policy: {owner: remotion_runtime_style, bake_into_new_source_png: false, goal: clear_continuous_cut_paper_separation, selection_inputs: [element_role, bound_background, delivery_resolution, edge_complexity], global_width_constants: [], shadow_separate: true, validation: real_frame_at_bound_delivery_size_plus_human_review}
  layout_constraints: {one_complete_subject_per_cell: true, wide_gutter: true, full_subject_inside_safe_area: true, no_in_image_labels: true, no_grid_lines: true, no_checkerboard: true, no_complex_scene: true}
  background: {type: transparent}
  handoff: {generation: chatgpt_web_existing_conversation, crop: split-transparent-atlas.ps1_wrapper_to_python_named_row_major_true_alpha_only, alpha_verification: required_before_crop_binding, runtime_outline_validation: required_against_bound_destination_background_at_delivery_resolution, remotion_input: individual_clean_alpha_rgba_png_only}
  call_package: {executable_prompt, reference_bindings, request_parameters, adapter_id, unresolved_fields, generation_status: blocked}
```

The projection is ephemeral compiler output. Do not persist it into `production_manifest.json`, designate the atlas as a Production Asset, use `prompt_ready_for_external_use`, add a new state/Gate, or claim transparency before inspecting the saved PNG. `asset_constraints` carries project-specific era/clothing, identity, direction, pose, complete-limb, and prop requirements when applicable; it does not add them to global VOX style. Request clean Alpha without baking a new outline by default. After verified Alpha, use `scripts/split-transparent-atlas.ps1` to resolve the approved Pillow runtime and invoke the Python named crop. Each independent PNG remains an existing-asset intake problem, not an atlas slice; Remotion applies and validates the background-aware, role-based, delivery-resolution-aware outline with separate shadow. The crop tool does not remove solid backgrounds, invent/recolor outlines, call a provider, or authorize overwrite without its explicit flag.

## Clause map and QA gate

Each rendered sentence gets a `clause_decision_map` entry that points to a visible decision, approved lock/continuity fact, Adapter parameter, or named QA risk. Otherwise classify it `prompt_non_discriminating` and delete or rewrite it. Before a call, validate resolved decisions, source provenance, Adapter self-containment, lock/variation compatibility, output requirements, and every clause mapping.

Classify failures as `prompt_under_specified`, `prompt_non_discriminating`, `consistency_lock_violation`, `output_spec_mismatch`, or `unintended_text_or_brand` before targeted repair. Fixtures and local compiler results are non-generative and never evidence of model quality or human approval.

## Video prompt layers

Video continues to compile three logical layers into its frozen six-module template: Manifest-level global values, exact frozen identity anchors copied into every independent request, and Clip-specific variables. Each Clip exposes `duration_seconds`, `aspect_ratio`, `resolution`, and `native_audio_mode`; unresolved required output parameters block generation.

Video Prompt Feasibility is an internal v1.0 structure, not a seventh external Prompt module. It may carry deterministic validator results, semantic/human review results, provenance, evidence, confidence, owner, and `executable_rewrite: null` when no approved rewrite exists. The external prompt remains exactly six modules.

## Notion copy-ready projection

When a Clip prompt is projected into Notion, the `Video Prompt` field must contain the complete external prompt, not a workflow state. The copied text must stand alone and include:

- output specification and reference responsibilities;
- global style and exact identity invariants;
- the current start state;
- a continuous timeline with camera and performance direction;
- the intended end state and continuity constraints;
- only the negative constraints needed to prevent named failures.

Acceptance, QA, cost, file, and human-approval evidence belong in database properties or review pages. Placeholder text such as `已接受片段`, `正文为 Clip Brief`, `承接上一条后再编译`, or `正文另见` fails the copy-ready contract. A planned prompt may use a frozen provisional start state, but its database status and observed end state must remain explicitly planned/unobserved.
