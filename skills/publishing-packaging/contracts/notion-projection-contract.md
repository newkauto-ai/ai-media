# Notion Publish Package Projection Contract v1.0

This contract produces a local Dry Run only. `publish-package.json` remains authoritative; Notion is a human-readable projection and cannot change Package readiness, authorize generation, or authorize publication.

## Stable identity and owned fields

`projection_key = project_id:content_id:platform`.

The projection may propose only `Name`, `Platform`, `项目`, `阶段`, `投影键`, `Package Hash`, and `准备状态`. It must never propose changes to publication date, URL, duration, performance metrics, `7日信号`, `决策`, or unknown/manual properties.

The minimal schema delta is exactly:

- `阶段`: Select with `准备` and `已发布`.
- `投影键`: Rich text.
- `Package Hash`: Rich text.
- `准备状态`: Select whose values preserve local readiness.

## Decisions

```text
projection_key missing                 -> BLOCKED
0 matching rows                        -> CREATE candidate
1 matching row + same hash             -> NO_CHANGE
1 matching row + changed hash          -> UPDATE candidate
more than 1 matching row               -> CONFLICT / HOLD
project/platform mismatch              -> CONFLICT / HOLD
schema drift or required field missing -> DEGRADED / HOLD
```

The Dry Run records both the row decision and execution status. A valid CREATE or UPDATE candidate remains `DEGRADED` when the four schema fields do not yet exist.

## Snapshot body

The page body candidate contains exactly one `## Publish Package Snapshot` section with Package, Source Binding, 文案, Cover Prompt, 封面, 发布窗口, Review & Gate, Manual Upload, and Projection History subsections. A missing section may be appended. Multiple matching headings are CONFLICT; no whole-page replacement is proposed.

Local PNG paths are never emitted as `file://` or claimed as uploaded. When no callable local-binary upload capability has been verified, attachment status is `degraded_local_binary_upload_unavailable`, with path, checksum, and dimensions only.

Every Dry Run emits JSON and Markdown, records zero Notion writes, and includes a schema hash plus the read-only live snapshot timestamp.
