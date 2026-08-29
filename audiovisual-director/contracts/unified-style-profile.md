# Unified Style Profile Library Contract v1.0

## Project library

```text
style-profiles/
├── source/       # user-maintained original Markdown; never silently rewrite
├── normalized/   # validated machine-readable profiles
└── registry.json # source hash, normalized target, classification and status
```

Users may manually add `.md` files to `source/`. Discovery occurs the next time Audiovisual Director runs or when the scanner is invoked explicitly. There is no background watcher.

## Normalized file minimum

```yaml
fixture_only: false
library_status: ready | pending_review | blocked
normalized_from_source: string
style_profile:
  style_id: string
  version: string
  classification: string
  pre_content_modules: object
  audiovisual_modules: object
  production_modules: object
  provenance:
    source_documents: [object]
    extracted_modules: [object]
```

## Registry status

- `ready`: source hash matches, normalized file exists, schema/router validation passed.
- `pending_normalization`: new source exists but no normalized profile exists.
- `source_changed`: registered source hash changed; existing normalized profile stays usable only as the prior version and must not be presented as current.
- `pending_review`: normalization exists but authority/conflict review is incomplete.
- `blocked`: parsing or contract validation failed.

New or changed source documents must not silently overwrite a `ready` normalized file. Write a new normalized version or obtain explicit approval before replacement. Preserve the original source file and provenance.
