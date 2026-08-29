# Progress

## Current Goal

Maintain the complete `ai-media` plugin as a private, reproducible GitHub backup while retaining auditable image/video prompts and the verified Seed Audio V3 route.

## Completed & Key Decisions

- Added Executable Prompt Contract v1.0: a prompt must pass both coverage and deletion tests. The seven image dimensions are a review checklist, not a universal field cap or a reason to expand every type-specific template.
- Image Prompt Specs now require explicit `consistency_locks`, `allowed_variation`, output specifications, references, and failure-driven negative constraints. Truth-preserving product work locks observed keyboard layout, ports, authentic marks, chassis features, and wear; a generic no-logo rule must not falsify the product.
- Video prompts retain the six-module external format while compiling three logical layers: one Manifest-level global layer delivered to every independent request, exact frozen identity anchors copied without paraphrase, and Clip-specific variables.
- Every Clip now records and displays `duration_seconds`, `aspect_ratio`, `resolution`, and `native_audio_mode`. Missing aspect ratio or resolution remains visible and blocks generation.
- Separate-track video prompts explicitly prohibit generated subtitles, screen text, watermarks, and background music. Unintended bystanders or unrelated third-party marks remain conditional constraints, not universal defaults.
- Production Manifest and Skill 4 Input Contract advanced to v1.3. Prompt under-specification, non-discriminating text, lock violations, output mismatch, and unintended text/brand output are now targeted QA failure classes.
- The source and `skills/` mirrors are synchronized. The personal plugin source was backed up before deployment and reinstalled as `ai-media@personal` version `0.1.0+codex.20260823093856`.
- Seed Audio V3 remains the verified active Volcengine generation route. The retired legacy App ID/Access Token path remains removed, and the non-secret Voice_Type registry remains separate for future provider-specific mapping.
- Created private repository `newkauto-ai/ai-media` and pushed the complete source package at initial commit `351cb97` on `master`. The package includes the Codex manifest, skills, contracts, tests, and style-profile library; machine environments and credential-file patterns are ignored.
- Updated legacy Manifest test expectations and the v1.2 minimal fixture required for independent source-package verification. This changed tests/fixtures only; it did not invoke media generation, Notion writes, uploads, or other external production actions.

## Core Files

- `video-production/contracts/executable-prompt-contract.md`
- `video-production/contracts/input-contract.md`
- `video-production/contracts/production-manifest.md`
- `video-production/modules/asset-prompt-compiler.md`
- `video-production/modules/clip-prompt-compiler.md`
- `video-production/templates/`
- `video-production/scripts/compile-production-fixture.ps1`
- `tests/verify-skill4-contracts.ps1`
- `video-production/adapters/seed-audio-v3-adapter.md`
- `video-production/scripts/invoke-seed-audio-v3.ps1`
- `.codex-plugin/plugin.json`
- `skills/video-production/`

## Verification

- All six project regression suites passed: Topic/Script contracts, Skill 3 contracts, Style Profile library, Skill 4 contracts, Audio Production, and Workflow Controller.
- Skill 4 v1.3 Fixture tests verify explicit image lock slots, self-contained global layers, exact cross-Clip identity anchors, per-Clip output specifications, unresolved-spec blocking, continuous 0.1-second timelines, and the expanded prompt QA taxonomy.
- Root and mirrored `video-production` files have matching SHA-256 hashes. Both Skill copies passed the skill validator.
- The workspace plugin, personal plugin source, and installed cache passed the plugin validator. Selected deployed files match the workspace hashes.
- The installed-cache Skill 4 regression test passed. `codex plugin list` reports `ai-media@personal` installed and enabled at `0.1.0+codex.20260823093856`.
- Deployment rollback copy: `C:\Users\Roy\plugins\ai-media.backups\20260823T093957Z`.
- The earlier real Seed Audio V3 smoke asset remains file-QA-passed: provider duration `20.6s`; local MP3 duration `20.640000`; SHA-256 `f2832228840d6862cce8d9b6ac3b95db27cd76393b1065bf21b3dd9e7776b70e`.
- Before the GitHub backup, all 16 source-package regression scripts and the plugin manifest validator passed locally.

## Known Issues

- The new prompt policy is structurally and behaviorally verified with local Fixtures, but it has not yet been A/B tested against real image or video generations. Do not claim lower drift or higher visual quality until a small real run is inspected.
- No image or video model is configured by default. Adapter-specific prompt syntax, persistent-context behavior, supported resolutions, and cost still require current declaration plus user approval before a paid call.
- Seed Audio V3 output has not received human listening approval or ASR confirmation. Its combined dialogue/music/SFX result is not final-production-ready.
- The Voice_Type recommendation is not yet mapped to the V3 prompt-only route.
- GitHub backup is source evidence, not evidence that the currently installed plugin cache has been reinstalled or revalidated at this commit.

## Next

1. For a new local plugin deployment, use the bounded cachebuster/reinstall flow and validate the installed cache against this repository commit.
2. On the next real production, run only 1–3 representative image/Clip calls and compare lock adherence, output specifications, and clause deletion impact before scaling.
3. Complete human listening or ASR/editorial review for the Seed Audio V3 smoke asset if that route will be used in a final video.
