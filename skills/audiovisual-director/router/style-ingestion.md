# Style Document Ingestion

Use this when a style document is supplied or the project Style Profile scanner reports `pending_normalization` or `source_changed`.

## Library discovery

Users may manually save `.md` files under `style-profiles/source/`. On the next Audiovisual Director run:

1. Run `scripts/scan-style-profiles.ps1`.
2. Leave `ready` profiles unchanged.
3. Fully read each `pending_normalization` or `source_changed` source document.
4. Normalize it according to [../contracts/unified-style-profile.md](../contracts/unified-style-profile.md).
5. Validate classification, module routing, authority, conflicts, and provenance.
6. Write a stable versioned file under `style-profiles/normalized/` and update `registry.json` only after validation.

Do not overwrite source files. Do not silently overwrite an existing ready normalized version. This is on-run discovery, not a background watcher.

Normalize in this order: classify document, extract modules, assign field authority, detect conflicts, normalize profile, validate profile, preserve provenance.

Supported classifications:

```text
pure_visual_style
audiovisual_style_profile
hybrid_style_profile
narrative_style_bible
series_bible
production_playbook
mixed
```

A normalized Style Profile should separate `pre_content_modules`, `audiovisual_modules`, and `production_modules`. Preserve source file/version and label extraction as `direct`, `normalized`, or `inferred_structure_only`.

Do not treat examples as Canon. Do not invent missing source rules. Missing fields stay `null`; a current-video recommendation must be labeled `runtime_recommended`.
