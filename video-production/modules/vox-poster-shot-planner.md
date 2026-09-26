# VOX Poster Shot Planner

Use this module only for registry-ready `vox_transcript_driven_handmade_collage`. It projects high-level ADP Beats into independently readable VOX editorial Poster Shots inside the existing Scene/Shot/`local_assembly_plan` model. It does not create a new Manifest, Gate, state machine, approval, retry ledger, semantic owner, or actual-state owner.

## Inputs

Require the frozen Script, confirmed final narration semantic intervals, current ADP Beats, ready VOX Style Profile, current approved Visual Baselines, reusable-asset evidence, and existing Production Manifest revision. Missing or stale semantic/time/baseline evidence blocks only the affected planning action; do not invent it.

## Planning sequence

1. Preserve each ADP Beat's story/audiovisual function and absolute narration interval.
2. Make a joint Beat–Shot–Poster use map. One Beat may have several Shots using different Posters, and one Poster source may be referenced by Shots in several Beats. Keep each use's scalar `source_beat_id`, absolute interval, purpose, source asset revision, static layout and Review scope. Do not force Wide + Detail, a fixed shot count, a visible cut at a Beat boundary, or another image merely because narration changes sentence.
3. Give every Poster Shot one `information_goal`, one primary attention target at a time, one independently readable `stable_poster_state`, and an open-vocabulary `shot_role`/`poster_archetype`.
4. Before Pilot design or image Prompt compilation, select exactly one `pilot_design_route`: `hero_key_art` or `production_reconstructable`. Use Hero for cover/climax/emotional/callback/Title Card/video-reference value where fusion matters more than element control. Use Production when text, map/route, data, relationships, staged reveals, independent entrances, or a Remotion precision reconstruction requires independent visual groups.
4a. For a historical Shot, optionally select one `historical_visual_mode`: `hero_cinematic`, `editorial_explainer`, or `atmospheric_historical`. Omit it or use `null` for non-historical Shots. This mode is independent of `pilot_design_route`, `decomposition_decision`, and `motion_route`; never infer one dimension from another.
5. Before any new image request, inspect bounded reusable Poster, Base, independent elements, text, route and plate candidates. Record scope, versions, suitability reasons and remaining gap on the owning Shot/Asset. Define layout intent now: visual hierarchy, reading path, text region, independently controlled groups, delayed information, framing allowance, separation and texture. Plan IDs are candidates, never approved media. Do not require an as-yet-unmade complete Poster approval before requesting an authorized design candidate.
6. For new `production_reconstructable`, reuse or obtain a clean scene Base under that layout intent and confirm its suitability. It may retain people/environment that need no independent control. Then reuse or request independent transparent design overlays, preferably one high-resolution asset per critical title, route, figure or frame. A Base approval permits overlay design only. Compose the complete Preview deterministically from the same assets and layout used by the later Remotion assembly; never ask an image model to redraw that final composite. Hero and already approved whole Posters may stay whole.
7. Review the actual complete Poster/Preview by route inside existing Poster Readiness / `previsualization_storyboard` Review Result. Hero checks visual impact, hierarchy, style, emotional value and motion feasibility. Production additionally requires `typography_split_test`, `context_separation_test`, `decorative_independence_test`, `rectangle_risk_test` and `motion_sequence_test`. Candidate lettering is not verified typography; Base suitability is not complete Poster PASS.
8. Only after complete Poster approval, draft detailed semantic motion: actual narration interval, attention targets, groups/anchors, entrances, handoffs, likely camera/element range and hidden-background exposure. This preplan informs minimum decomposition; it is not formal animation or a claim that geometry has passed.
9. Choose one minimum-sufficient `decomposition_decision` from actual exposure/editability/quality/cost/risk. Reuse native independent overlays directly; never flatten the approved Preview merely to extract them again. Recover only hidden regions that the detailed preplan exposes, including pre-entrance and extreme states. A full plate needs near-full exposure evidence.
10. Derive only missing assets for current uses. Keep unneeded ADP candidates ungenerated. Compare approved Poster with the same-implementation no-motion reconstruction, including applicable pre-entry, handoff, intermediate and extreme states. Missing/stale or unresolved `must_fix` evidence blocks formal Motion.
11. Compile and render formal Motion only after static/exposure checks. The route may be planned as intent earlier but is not an execution permission. Local Remotion does not require a generated Video Prompt or provider request.
12. Compare adjacent shots and record the intended difference. Three highly similar consecutive shots emit `editorial_repetition_warning`; material harm becomes a Review Result `must_fix`, not an automatic quota failure.

## Poster Shot Map

Each entry minimally contains:

```yaml
poster_shot_id: string
source_beat_id: string
poster_source_asset_ref: {asset_id, revision_id, sha256} | planned_candidate_id # resolve before formal Motion
time_range: {start_seconds: number, end_seconds: number}
information_goal: string
primary_attention_target: string
shot_role: string
poster_archetype: string
stable_poster_state: object
critical_text:
  owner: remotion
  generate_text_in_image: false
  realization: remotion_native_text | verified_typography_svg | verified_typography_png
  items: [object]
asset_requirements: [string]
pilot_design_route: hero_key_art | production_reconstructable
decomposition_decision: keep_whole | partial_decomposition | full_element_assembly | rebuild_locally | null # null for design candidate until complete Poster Review
adjacent_shot_difference: string
motion_route: remotion_living_poster | remotion_precision_motion | generative_hero_clip | null # plan intent early, execute only after static evidence
historical_visual_mode: hero_cinematic | editorial_explainer | atmospheric_historical | null
```

`shot_role` is descriptive and open. Suggested values are `establish`, `detail`, `comparison`, `evidence`, `map`, `number`, `relationship`, `transition`, `climax`, `symbolic_payoff`, and `custom`.

Multiple use rows may reference one `poster_source_asset_ref` while retaining their own `source_beat_id`, layout, text visibility, crop, time and Review. A long Beat may likewise contain several rows with distinct source assets. Asset reuse does not copy approval for changed uses. The existing `local_assembly_plan.poster_spec.production_design` may carry layout intent, Base/Overlay IDs, deterministic Preview input fingerprint, Review refs and later motion preplan; the existing `assets` carry each request's reuse/authorization evidence and exact media revision. These are compatible projections, not another Manifest or approval owner.

## Local assembly projection

Project, do not duplicate, the Poster Shot into the current Scene/Shot record:

```yaml
local_assembly_plan:
  poster_shot_id: string
  source_beat_id: string
  shot_role: string
  adjacent_shot_difference: string
  poster_spec:
    poster_archetype: string
    pilot_design_route: hero_key_art | production_reconstructable
    historical_visual_mode: hero_cinematic | editorial_explainer | atmospheric_historical | null
    visual_hierarchy: object
    primary_subject: object
    secondary_elements: [object]
    background_system: object
    foreground_system: object
    reading_path: [string]
    text_safe_area: object
    critical_text_owner: remotion
    critical_text_realization: remotion_native_text | verified_typography_svg | verified_typography_png
    generate_text_in_image: false
    decomposition_decision: keep_whole | partial_decomposition | full_element_assembly | rebuild_locally
    background_plate_strategy:
      mode: none | reuse_existing | recover_motion_exposure_regions | full_plate_evidenced
      motion_exposure_regions: [object]
      safety_margin_rationale: string | null
      plate_asset_refs: [string]
    cut_paper_outline_runtime_style:
      owner: remotion_runtime_style
      bake_into_new_source_png: false
      role: string
      bound_background_ref: string
      delivery_resolution_ref: string
      width_rationale: string
      shadow_style_ref: string | null
    stable_poster_state_ref: string
    poster_readiness_review_ref: string
    static_reconstruction_evidence_ref: string | null
  motion_plan:
    route: remotion_living_poster | remotion_precision_motion | generative_hero_clip
    camera_motion: {intent: string, phases: [object]}
    element_motion: [{target: string, motion: string, timing: object, purpose: string}]
    why_not_remotion: string | null
```

`camera_motion.intent` is not a closed enum. Static, strong, compound, multi-phase, perspective-aware and layer-coordinated motion remain available when the material, coverage and reading constraints support them.

## Historical VOX projection

Historical VOX is an optional module of the same stable profile, not a separate profile, planner, Gate, Manifest, state machine, or retry owner. Use `hero_cinematic` for a dignified person/event turning-point composition, `editorial_explainer` for map/route/time/relationship/institution/data/causality explanation, and `atmospheric_historical` for place/era/environmental-pressure establishment with a clear narrative focus.

Compose **historical subject + evidence/context + editorial explanation** with palette roles `substrate`, `anchor_dark`, `persistent_accent`, and restrained optional secondary. Materials must be coherent with meaning and period, not generic archival clutter. Historical people remain narrative subjects: independent moving elements need clean visible Alpha; fused/whole groups remain valid. Natural separation needs no added outline; preserve approved source outlines, and use Remotion-owned runtime outline only when needed. Maps, routes and timelines must answer `where`, `from_to`, `distance`, `territory`, `sequence`, `relationship`, or `change_over_time`; their labels remain Remotion-owned. Critical text keeps the existing three realizations and numeral display keeps the existing localization bindings.

Era, region, identity, costume/armor, hair/props, architecture/terrain, formation, exact palette, project typography and recurring project symbols come from the Project Visual Bible. Do not hard-code a particular person, campaign, dynasty, costume, color or prop into this reusable module.

## Pilot route review and reclassification

For `production_reconstructable`, major typography groups must be independently realizable as native text, verified SVG, or verified PNG; arrows/routes/links must be discrete directional objects; ink, seals, color blocks, and labels must be independent decorations; and context must resolve to a few meaningful groups rather than one continuous screenshot strip. Preserve negative space for information build, motion, subtitle safety, and reconstruction adjustment. Avoid cross-element texture entanglement.

Visible horizontal or vertical crop lines, a background halo, a full-width context strip, a title-plus-background rectangle, or adjacent-element fragments in a Production asset are `must_fix`. A visible rectangular screenshot crop is never a decomposition fallback. Route to `rebuild_svg`, `rebuild_text`, `verified_typography_asset`, `generate_independent_asset`, or human review instead.

If an intended Production Pilot has high visual quality but fails reconstructability because the image is strongly fused, the existing Review may set `recommended_reclassification: hero_key_art`. Retain the image through the existing v1.8 salvage/reuse path, then plan a separate Production Pilot. Reclassification is not a Production PASS, does not change Script/ADP semantics, and does not authorize generation.

`keep_whole` may explicitly set `static_reconstruction_evidence_ref: null` only when the approved composition, crop, typography and layout remain unchanged. A changed whole-poster crop or overlay is reviewed like other reconstruction. Runtime outline width is derived from element role, frame occupancy, edge complexity, bound background and delivery resolution; never author global `10px/8px/6px` Style constants. Paper shadow stays a separate style/effect.

Critical text ownership always remains `remotion`. `verified_typography_svg` and `verified_typography_png` are controlled Remotion assets, not image-generation ownership. Verify glyphs, order, fact text, Alpha, delivery-size readability and rights. Hero Typography may not silently fall back to an ordinary CSS font when that loses the approved display character.

For historical/cultural hero visuals, bind `source_fact_value`, locale-appropriate `display_value`, `locale`, and `display_mode: written_numeral` by default. Modern data visualization may use `display_mode: arabic_numeral`. The display conversion may not change value, unit, order of magnitude, date meaning, or other source-fact semantics.

## Static Reconstruction Check

Reuse `previsualization_storyboard` Review Result and `poster_readiness` findings; do not create a Reconstruction Gate, Manifest, Typography Manifest, approval, retry ledger, or state machine. Compare the approved source/stable poster with the no-motion reconstruction and preserve:

- composition;
- hierarchy;
- focal weight;
- negative space;
- palette;
- typography character.

The target is perceptual and editorial equivalence, not pixel-perfect reproduction. A pixel diff may be supporting evidence but cannot be the sole verdict. Any unresolved `must_fix` blocks motion compilation.

## Background plate strategy

Compute exposure from the approved translation, rotation, scale, perspective, crop and occlusion changes. Use `none` when nothing hidden becomes visible, `reuse_existing` when an approved plate already covers it, and `recover_motion_exposure_regions` for only the exposed bounds plus an evidenced safety margin. `full_plate_evidenced` is exceptional. When hidden content cannot be recovered without invention, reduce motion, change the decomposition decision, or request human review.


## Conditional Beat production method v2.0

Bind actual Profile/version, project output geometry, Master Audio/time source, locale/subtitle strategy, Visual Bible, approved Poster and reusable assets before choosing a Shot method. For each Beat record information goal, absolute semantic events, primary attention, grouping and asset choice, text roles, camera/motion intent, exposure or result handoff, static evidence, output and feedback in the existing Scene/Shot/Review records. Relationship, comparison, geography/process, quotation, hero atmosphere and symbolic result are conditional options, not a mandatory sequence. Preserve approved Poster quality and label whole image, fused source region and clean independent Alpha accurately. Complete subjects reveal as coherent silhouettes when appropriate; routes may reveal along their path. A baked-result handoff requires aligned coordinates, anchor, scale, direction, occlusion and mutually exclusive same-frame switching; if a truthful intermediate state is required, do not use the handoff.

## Motion routing

- Default to `remotion_living_poster` for portraits, quotes, evidence, comparisons, conclusions and general editorial layouts.
- Use `remotion_precision_motion` when maps, routes, timelines, numbers, evidence relationships, controlled typography or deterministic geometry are the primary need.
- Use `generative_hero_clip` only when complex human/animal/crowd/environment physical performance is the value and local deterministic assembly is insufficient. Require a specific non-empty `why_not_remotion`; “more cinematic” is insufficient.
- `living_poster` and `element_assembly` are composable motion patterns on top of a completed poster, not alternate routes around Poster Readiness.

## Asset derivation

For each production-eligible asset add:

```yaml
reuse_count: integer
used_by_poster_shots: [string]
production_priority: high | medium | low
implementation_route: reuse_existing | generated_asset | remotion_svg | remotion_css | temporary_atlas | local_graphic
```

An asset is production-eligible only when `used_by_poster_shots` contains at least one Poster Shot whose current Review evidence permits asset derivation. Prefer high-reuse assets first and local SVG/CSS/graphics for one-off decoration. This eligibility does not grant a provider call or Cost Gate.

If a generated asset is unsuitable for its original Shot, record one existing asset/QA `salvage_disposition` after checking candidates in this order: `later_beat`, `hero_poster`, `cover`, `title_card`, `detail_crop`, `background`, `transition`, then `reject`. Record every reviewed candidate, the selected target/use, crop or text limits, Review ref, and rationale. Reject is legal only after the earlier uses are evidenced unsuitable. Salvage does not relax facts, identity, era, approved composition, rights, intake, or Cost Gate boundaries.

## Poster Readiness

Reuse Review Result `previsualization_storyboard` and its existing lineage/evidence rules. Review these checks: primary attention clarity, editorial hierarchy, paper-layer separation, critical-text protection, readability without motion, asset coverage, adjacent-composition distinction, Style Baseline consistency, applicable Static Reconstruction fidelity, and poster-to-motion feasibility. For Historical VOX also review mobile-size subject identity, primary title, direction/sequence and primary evidence; reject overloaded scrapbook, decorative archival clutter, unexplained maps/arrows/timelines, sticker-like people, competing persistent accents, material/period mismatch, baked critical text, and project-specific Core leakage.

Any unresolved `must_fix` blocks motion compilation for the affected Poster Shot. Missing/stale evidence maps to `UNKNOWN` without retry consumption. Fixture output proves only structure and routing, never composition quality or approval.

## Natural-boundary reuse

A Poster without torn-paper edges or character outlines need not be redesigned. Assess natural contours, gaps and contrast before local adaptation; adapt only for a real separation, exposure-repair or assembly-coherence failure. Tightening excludes background/neighbor fragments, never visible hair, robes, cape, props or approved source outlines. Keep maps/terrain semantically whole, and label fused regions honestly. No new outline is valid when separation already reads. Define required exposure before extraction; recovery and contour drafts may iterate, but static before/handoff/intermediate/extreme/final states must pass before formal motion. Record these decisions in the existing Shot/asset/Review, not a new checklist owner.
