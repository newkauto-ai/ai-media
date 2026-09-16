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

For `reference_video_structural_remake`, validation must also confirm that every declared module name
is consumed by the actual pre-content, audiovisual, or production contract; the Profile must remain
`pending_review` or `blocked` when a critical mapping is absent. A label such as
`reference_transferred` alone is not evidence of decomposition, constraint propagation, or QA.

## Viral Feed named-style resolution

For `workflow_mode: external_prompt_only`, resolve these exact user-visible names before the existing Style Profile selection step:

| Exact user-visible name | Registry profile ID |
| --- | --- |
| `迷你厨房烹饪` | `miniature_kitchen_cooking` |
| `纸板制作任意物品` | `cardboard_make_anything` |
| `美女跳舞卡点变装` | `female_dance_beat_outfit_transition` |

The match is exact and maps to one profile only. Bind it through the existing `selected_style_profiles` field as exactly one `{id, registry_status: ready}` value. Do not add a routing field, family identifier, tag, or parent Profile. If the name is not exact, resolves to more than one profile, or the registry entry is not `ready`, do not guess: return the existing style-confirmation or missing-content route. Do not auto-stack a second Profile. The selected Profile may supply only its normalized required inputs, compatibility, visible state change, payoff, composition, material/subject locks, physical progression, continuity, sound direction, failure constraints, and replaceable production modules; current Adapter facts remain authoritative for model and execution parameters.
