---
name: publishing-packaging
description: Compile approved references into Cover Prompt Packages and completed media into local manual-upload packages plus Notion Projection Dry Runs, while keeping package readiness distinct from actual publication. Use only for selected platforms; do not publish, upload, write Notion, save remote drafts, or generate paid media.
---

# Publishing & Packaging

Build a local Package-only v1.2 deliverable. Skill 5 owns platform title, cover title, platform composition, final copy, timing window, and package readiness. Skill 2 `platform_packaging` remains readable only as legacy/provisional hints. Cover Prompt compilation may run before final media when approved checksum-bound references exist.

## Required order

1. Read [Input Contract](contracts/input-contract.md), [Publish Package Contract](contracts/publish-package-contract.md), [Cover Prompt Package Contract](contracts/cover-prompt-package-contract.md), [Notion Projection Contract](contracts/notion-projection-contract.md), and the selected platform profile JSON files.
2. Require an explicit non-empty platform selection. For Cover Prompt-only work, bind approved visual references by path, version, role, approval, rights, and SHA-256; final media remains required for Publish Package readiness.
3. Normalize frozen upstream facts without changing Topic, Core Promise, Hook, factual claims, ADP intent, or production facts.
4. Treat supplied `platform_copy` as a candidate, not an approved answer. Before accepting it, run one Thesis-first editorial pass using `topic`, `core_promise`, `story_hook`, `key_points`, `audience`, `audience_need`, `search_intent`, and `share_save_reason`: the title must express the concrete topic/event in platform-native language; the body must connect scenario/action to the Core Promise and audience payoff; Topics/Hashtags must serve platform discovery and the audience's search/share reason; the cover title and visual thesis must carry the same promise rather than a generic mood.
5. Resolve fields in this order: current platform hard specs, compatible approved Series variant, episode signal, field-level fallback. Never replace a complete Series design with a generic template.
6. Prefer an approved dedicated cover, then compatible approved Key Frames/Scene/character references, then a Cover Prompt Package, then supplied rights-cleared assets; final-video frames are optional candidates. Reuse the Video Production image Prompt compiler with `cover_visual`; this Skill never calls a provider.
   It never calls a model; every real image generation remains a separate authorization Gate.
7. Keep `story_hook`, `platform_title`, and `cover_title` separate. Generate no exact Chinese in the background; use a programmatic overlay spec. Run deterministic technical QA separately from checksum-bound semantic visual review. Missing evidence stays `unknown`, not PASS.
8. Set `promise_match=pass` only when title, body, and cover express the frozen Topic/Core Promise/Hook-Reveal with declared evidence. Set `metadata_relevance=pass` only when title, body, Topics/Hashtags fit the selected platform audience and discovery/share intent with declared evidence. Either unresolved value, or missing editorial evidence, withholds `COPY_READY`. Qualitative performance remains advisory and cannot repair a failed gate.
9. Build only the selected platform overlays, an evidence-based publish window, Compliance Decision, Promise Match, and qualitative Performance Advisory.
10. Validate the package and stop at `READY_FOR_MANUAL_UPLOAD`. This state means local manual-upload preparation only.
11. A Notion Projection Dry Run may emit local JSON/Markdown from a read-only live snapshot. It never calls Notion or uploads an attachment. Any later authorized writer must write `page_body_snapshot` as the managed `## Publish Package Snapshot` section and read that full section back; it must not substitute a handwritten summary.

## Runtime

- `scripts/compile-publish-package.ps1` compiles one Package per selected platform.
- `scripts/validate-publish-package.ps1` re-reads package hashes and local asset bindings.
- The scripts use local FFmpeg/FFprobe and Pillow when available. They do not install dependencies or access the network.
- `fixture_only` and `shadow_only` runs can exercise real files but can never produce `READY_FOR_MANUAL_UPLOAD`.
- `scripts/prepare-notion-projection.ps1` produces a local idempotency decision and two reviewable artifacts with zero network writes.

## Review boundary

Persist deterministic checks and any supplied evaluator projection inside `publish_package.review`. Existing Review Result v2.1 entries are upstream references only. Do not create `pre_publish_package` Review Result entries, modify Execution State retry counts, implement Gate 2/3, or create another reviewer/database/retry ledger.

## External action boundary

Do not call platform APIs, browsers, CAPTCHA/MFA flows, remote draft endpoints, Notion, or paid image/video/audio generation. Manual UI checklists are instructions for a later user action, not authorization or evidence that the action occurred.

## Controller return

Use this Skill directly for one bounded Cover Prompt, platform package, validation, or local Notion dry-run task. Any project package or formal readiness result must populate the logical `controller_return` envelope defined by Workflow Controller. Include local artifact refs/version/hash/status, selected platform scope, Review refs, unresolved evidence, and the complete external-action boundary. Follow the Controller's user-facing rendering rule: do not append raw `controller_return` YAML/JSON unless the user explicitly requests machine-readable or debug details, or a destination tool requires it. `READY_FOR_MANUAL_UPLOAD` is package readiness only; actual upload, publication, Notion write, and business outcome remain unperformed unless separately evidenced. Stop after the envelope and do not call an uploader, publisher, Notion writer, or another Specialist. If reliable Controller re-entry is unavailable, use `awaiting_controller_resume`.
