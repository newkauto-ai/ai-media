# Publish Package Contract v1.2

One selected platform produces one `publish_package`. The runtime emits JSON plus a Markdown manual-upload projection. JSON is authoritative.

Required Common Package fields:

```yaml
publish_package:
  schema_version: "1.2"
  package_id: string
  package_version: string
  package_hash: sha256
  generated_at: datetime
  identity: {project_id, content_id, platform, account_or_channel_id, locale}
  source_binding:
    artifact_id: string
    artifact_version: string
    artifact_path: local_path
    artifact_checksum_sha256: sha256
    frozen_script_hash: sha256
    adp_hash: sha256
    production_manifest_hash: sha256
  profile_snapshot:
    platform_profile_id: string
    platform_profile_version: string
    rules_hash: sha256
    critical_rules_status: current | stale | unknown
    evidence_refs: [string]
    evaluated_rules: [object]
  strategy: object
  titles: {story_hook, platform_title, cover_title}
  cover_prompt: object
  cover: object
  copy: object
  rights_and_disclosure: object
  timing: object
  review: object
  readiness:
    status: SOURCE_BLOCKED | PACKAGE_DRAFT | COPY_READY | ASSET_READY | REVIEW_HOLD | READY_FOR_MANUAL_UPLOAD
    blocking_reasons: [string]
    stale: boolean
  manual_upload:
    media_path: local_path
    cover_path: local_path
    copy_ready_text: string
    platform_ui_checklist: [string]
  platform_overlay: object
  safety:
    fixture_only: boolean
    shadow_only: boolean
    external_actions_called: false
    paid_generation_called: false
    notion_write_called: false
    browser_automation_called: false
```

## Hash and stale rules

`package_hash` is canonical SHA-256 over source binding, profile snapshot, title split, Cover Prompt hash, cover checksum, copy, rights/disclosure, timing, review policy version, platform overlay, and safety flags. It excludes `package_hash`, generated timestamps, and projection paths that do not alter content.

Any change to the source artifact checksum/version, cover checksum, copy, critical profile rules, disclosure, timing, Promise Match, compliance decision, or review policy invalidates the prior package hash and readiness.

Existing Review Result v2.1 identifiers remain `review.upstream_review_refs`. They cannot replace the package review projection and cannot grant publishing or generation authorization.

## Readiness invariants

- `COPY_READY`: final copy exists; `promise_match=pass`, `metadata_relevance=pass`, and editorial `evidence_refs` are present; cover may be absent.
- `ASSET_READY`: actual local media and cover exist, checksums match, deterministic asset QA passes, and checksum-bound semantic visual review is `pass` or has traceable human approval. Prompt review never substitutes for actual-cover review.
- `REVIEW_HOLD`: critical profile, compliance, Promise Match, rights/disclosure, OCR/watermark, or other required evidence is HOLD/UNKNOWN.
- `READY_FOR_MANUAL_UPLOAD`: accepted non-fixture/non-shadow source, current bindings, copy ready, actual media and cover files, current checksums, current critical rules, deterministic QA PASS, compliance PASS/WARN, Promise Match `pass`, metadata relevance `pass`, editorial evidence, and a manual UI checklist.
- No V1 state may be named `PUBLISH_AUTHORIZED`, `SCHEDULED`, or `PUBLISHED`.
- Without final media, Cover Prompt and even an independently supplied cover may exist, but Publish Package readiness remains `PACKAGE_DRAFT`.
- A v1.1 Package remains readable; the runtime does not mutate it to v1.2 in place.
