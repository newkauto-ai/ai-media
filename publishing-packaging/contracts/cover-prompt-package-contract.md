# Cover Prompt Package Contract v1.0

One selected platform produces one local `cover_prompt_package`. The package is compiled before final media when approved, rights-bounded visual references are available. It is prompt evidence only and never an image approval.

```yaml
cover_prompt_package:
  contract_version: "1.0"
  prompt_package_id: string
  prompt_package_version: string
  prompt_package_hash: sha256
  platform: xiaohongshu | douyin | youtube_shorts | youtube_long
  source_request_hash: sha256
  image_prompt_spec: object
  executable_prompt: string
  reference_bindings:
    - asset_id: string
      asset_type: character_identity | scene | prop | graphic | keyframe
      path: local_path
      checksum_sha256: sha256
      version: string
      approval_status: approved
      rights_status: cleared | unknown
      reference_role: identity | scene | style | action | composition | prop
  call_package:
    executable_prompt: string
    reference_bindings: [object]
    request_parameters: object
    adapter_id: string
    unresolved_fields: [string]
    generation_status: not_authorized
  overlay_spec:
    cover_title: string
    generate_text_in_image: false
    reserve_clean_title_space: true
    overlay_title_after_generation: true
  prompt_review:
    deterministic_status: PASS | HOLD
    semantic_status: pass | fail | unknown | human_review
    findings: [object]
  readiness:
    status: PROMPT_DRAFT | PROMPT_READY | GENERATION_HOLD
    blocking_reasons: [string]
```

`cover_visual` must be compiled by the existing Video Production image Prompt compiler. Skill 5 owns the request, platform composition, title-safe zone, and overlay spec; it must not copy the compiler's decision matrix, clause map, or Adapter logic.

Hard gates:

- No approved checksum-bound visual reference returns `COVER_SOURCE_BLOCKED`.
- `rights_status=blocked`, a missing checksum/version/path/role, or conflicting required identity/scene locks returns HOLD.
- `rights_status=unknown` may produce a review draft but cannot authorize generation or Package readiness.
- Xiaohongshu and Douyin must have distinct composition specs and prompt hashes. Resizing or cropping one composition does not satisfy this contract.
- Exact Chinese is never generated in the image. It is reserved and applied through the overlay spec.
- A compiled Prompt, fixture, or PASS from deterministic prompt validation is not evidence that a real cover exists or passed visual review.
