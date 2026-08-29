# Publishing & Packaging Input Contract v1.2

The machine input is JSON with the same field meanings as the Brief. Paths must resolve to local files. HTTP(S), platform URLs, credentials, and remote object references are rejected by the V1 runtime.

```yaml
publishing_packaging_input:
  schema_version: "1.2"
  project:
    project_id: string
    content_id: string
  source_artifact: # nullable only for cover_prompt_only
    artifact_id: string
    artifact_version: string
    path_or_uri: local_path
    checksum_sha256: string
    file_size_bytes: integer
    duration_seconds: number
    width: integer
    height: integer
    aspect_ratio: string
    language: string
    final_qa_status: accepted | provisional | blocked
    inspected_at: datetime
  upstream_refs:
    frozen_script_id: string
    frozen_script_hash: string
    audiovisual_direction_id: string
    audiovisual_direction_hash: string
    production_manifest_id: string
    production_manifest_version: string
    production_manifest_hash: string
    upstream_review_result_ids: [string]
  content_core:
    topic: string
    core_promise: string
    audience: string
    audience_need: string | null
    story_hook: string
    hook: string | null # v1.1 compatibility alias only
    platform_titles:
      xiaohongshu: string | null
      douyin: string | null
      youtube_shorts: string | null
      youtube_long: string | null
    approved_cover_titles:
      xiaohongshu: string | null
      douyin: string | null
      youtube_shorts: string | null
      youtube_long: string | null
    key_points: [string]
    factual_claims: [string]
    search_intent: string | null
    share_save_reason: string | null
    content_type: string
    ai_generation_profile: object
  series_context:
    series_id: string | null
    series_name: string | null
    packaging_visual_rules_ref: local_path | null
    packaging_visual_rules_version: string | null
    source_status: ready | pending_review | missing
    approved_exceptions: [object]
    run_local_constraints: object | null
  publishing_context:
    target_platforms: [xiaohongshu | douyin | youtube_shorts | youtube_long]
    publish_goal: awareness | search | save_share | subscriber_growth | other
    account_profiles: [object]
    historical_performance_refs: [object]
    requested_publish_date: date | null
    primary_audience_timezone: string | null
  platform_copy: object | null
  cover_inputs:
    approved_assets: [object]
    approved_keyframes: [object]
    visual_thesis: string
    required_subjects: [string]
    required_action: string | null
    forbidden_elements: [string]
    identity_locks: [string]
    style_locks: [string]
    platform_composition_overrides: [object]
  cover_sources: # v1.1 compatibility reader
    approved_keyframes: [object]
    supplied_assets: [object]
  rights_and_disclosure: object
  review_inputs:
    promise_match: pass | fail | unknown | human_review
    performance_assessment: object | null
    evaluator_result: object | null
    cover_semantic_review_by_platform: object | null
  execution_mode:
    cover_prompt_only: boolean
    allow_real_generation: false
  runtime_context:
    fixture_only: boolean
    shadow_only: boolean
    as_of: datetime | null
```

## Hard gates

- Missing `target_platforms` returns `BLOCKED / ask_user` with zero packages.
- Missing/non-local source, missing artifact version, missing checksum, or checksum mismatch returns `SOURCE_BLOCKED`, except that `cover_prompt_only=true` may compile Prompt Packages without final media and can never exceed `PACKAGE_DRAFT`.
- Cover Prompt compilation requires at least one approved, checksum-bound visual reference. Missing references return `COVER_SOURCE_BLOCKED`; blocked rights or conflicting locks return HOLD.
- `final_qa_status=blocked` cannot advance beyond `SOURCE_BLOCKED`; `provisional` cannot advance beyond `PACKAGE_DRAFT`.
- A current file or Manifest hash mismatch makes the binding stale. The caller must rebind; the runtime does not rewrite an upstream hash.
- A missing Series rule file uses field-level fallback. A referenced but mismatched Series version is not silently accepted.
- `legacy_packaging` may be supplied for compatibility. It is a hint source only and never owns final output.
- v1.1 input remains readable. Historical files are never rewritten in place. The `hook` field is read only as a compatibility fallback for `story_hook`.
- `fixture_only` and `shadow_only` are explicit safety flags. Either flag withholds runtime Ready.

Secrets, tokens, cookies, account credentials, remote upload URLs, and external-action authorization must not appear in this input.
