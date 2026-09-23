$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

$projectRoot = Split-Path -Parent $PSScriptRoot
$libraryRoot = Join-Path $projectRoot 'style-profiles'
$registry = Get-Content -LiteralPath (Join-Path $libraryRoot 'registry.json') -Raw | ConvertFrom-Json
$entries = @($registry.profiles | Where-Object { $_.profile_id -eq 'vox_transcript_driven_handmade_collage' })

Assert-True ($entries.Count -eq 1) 'VOX profile must resolve to one stable registry entry.'
$entry = $entries[0]
Assert-True ($entry.source_file -eq 'Style_Profile_VOX编辑纸拼贴讲解动画_v1.11_Beat生产方法.md') 'VOX registry source must be v1.11 Historical VOX.'
Assert-True ($entry.normalized_file -eq 'transcript_driven_handmade_collage.v1.11-zh.json') 'VOX registry normalized file must be v1.11.'
Assert-True ($entry.normalized_version -eq 'v1.11-zh') 'VOX registry version must be v1.11-zh.'
Assert-True ($entry.status -eq 'ready') 'VOX registry status must remain ready.'

$sourcePath = Join-Path (Join-Path $libraryRoot 'source') $entry.source_file
$normalizedPath = Join-Path (Join-Path $libraryRoot 'normalized') $entry.normalized_file
$changelogPath = Join-Path $libraryRoot 'references\vox-changelog.md'
Assert-True (Test-Path -LiteralPath $sourcePath) 'VOX v1.11 source file is missing.'
Assert-True (Test-Path -LiteralPath $normalizedPath) 'VOX v1.11 normalized file is missing.'
Assert-True (Test-Path -LiteralPath $changelogPath) 'VOX changelog is missing.'
foreach ($version in @('1.2', '1.3', '1.4', '1.5', '1.6', '1.7', '1.8', '1.9')) {
    Assert-True (@(Get-ChildItem -LiteralPath (Join-Path $libraryRoot 'source') -Filter "*v$version*.md").Count -ge 1) "Historical VOX v$version source must be preserved."
    Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot "normalized\transcript_driven_handmade_collage.v$version-zh.json")) "Historical VOX v$version normalized profile must be preserved."
}
$sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash
Assert-True ($sourceHash -eq $entry.source_sha256) 'VOX source hash does not match the registry.'

$source = Get-Content -LiteralPath $sourcePath -Raw
$changelog = Get-Content -LiteralPath $changelogPath -Raw
$normalized = Get-Content -LiteralPath $normalizedPath -Raw | ConvertFrom-Json
$profile = $normalized.style_profile

Assert-True ($normalized.normalized_from_source -eq $entry.source_file) 'Normalized Profile must name the active v1.11 source.'
Assert-True ($profile.style_id -eq 'vox_transcript_driven_handmade_collage') 'VOX normalized stable ID changed.'
Assert-True ($profile.version -eq 'v1.11-zh') 'VOX normalized version must be v1.11-zh.'
Assert-True ($profile.provenance.source_sha256 -eq $sourceHash) 'Normalized Profile provenance hash must match the active source.'
Assert-True (($profile.provenance.source_documents | Where-Object { $_.file -eq $entry.source_file }).sha256 -eq $sourceHash) 'Normalized source-document hash must match the active source.'

# Poster-first planning and routing.
$poster = $profile.poster_first_planning
Assert-True ($poster.required_before_batch_asset_generation) 'Poster Shot Map must be required before batch asset generation.'
Assert-True ($poster.planning_unit -match 'existing_scene_shot_local_assembly_plan') 'Poster Shot must project into existing Scene/Shot/local assembly ownership.'
Assert-True (@($poster.required_fields) -contains 'stable_poster_state') 'Stable poster state is missing from the Poster Shot contract.'
Assert-True (@($poster.required_fields) -contains 'source_beat_id') 'Poster Shot must retain the ADP Beat reference.'
Assert-True (@($poster.optional_fields) -contains 'historical_visual_mode' -and -not (@($poster.required_fields) -contains 'historical_visual_mode')) 'Historical visual mode must remain optional and non-historical behavior must not change.'
Assert-True ($poster.wide_detail_rule -match 'without_forcing_two_shots_per_beat') 'Wide/detail planning must remain optional.'
Assert-True ($poster.poster_readiness.failure_rule -match 'blocks_motion_compilation') 'Failed Poster Readiness must block motion compilation.'
Assert-True ($poster.poster_readiness.owner -match 'existing_review_result') 'Poster Readiness must reuse the existing Review Result owner.'
$pilotRouting = $poster.pilot_design_routing
Assert-True ((@($pilotRouting.allowed) -join '|') -eq 'hero_key_art|production_reconstructable') 'Pilot design routes are incomplete or reordered.'
Assert-True (-not $pilotRouting.hero_key_art.reconstructability_required -and @($pilotRouting.hero_key_art.review_focus) -contains 'emotional_value') 'Hero route must allow fusion and skip reconstructability requirements.'
$productionPilot = $pilotRouting.production_reconstructable
Assert-True ($productionPilot.design_constraints.rectangle_crop_fallback_forbidden -and $productionPilot.design_constraints.context_group_separability -and $productionPilot.design_constraints.preserve_negative_space) 'Production route design constraints are incomplete.'
Assert-True ((@($productionPilot.required_reviews) -join '|') -eq 'visual_quality|poster_readiness|production_reconstructability') 'Production route must require visual quality, Poster Readiness, and reconstructability.'
$reconstructability = $pilotRouting.production_reconstructability
Assert-True ((@($reconstructability.checks) -join '|') -eq 'typography_split_test|context_separation_test|decorative_independence_test|rectangle_risk_test|motion_sequence_test') 'Production Reconstructability checks are incomplete or reordered.'
Assert-True (@($reconstructability.rectangle_must_fix_signals) -contains 'full_width_context_strip' -and @($reconstructability.rectangle_must_fix_signals) -contains 'title_plus_background_rectangular_crop') 'Rectangle must-fix signals are incomplete.'
Assert-True ($reconstructability.reclassification_rule -match 'hero_key_art' -and $reconstructability.reclassification_rule -match 'v1_8_salvage_reuse') 'Production-to-Hero reclassification must preserve the v1.8 salvage/reuse path.'
Assert-True ((@($poster.decomposition_decision.allowed) -join '|') -eq 'keep_whole|partial_decomposition|full_element_assembly|rebuild_locally') 'Poster decomposition decisions are incomplete or reordered.'
Assert-True ($poster.decomposition_decision.selection_rule -match 'minimum_sufficient') 'Poster decomposition must use a minimum-sufficient decision.'
Assert-True ($poster.static_reconstruction_check.owner -match 'previsualization_storyboard_review_result') 'Static Reconstruction Check must reuse the existing Review Result owner.'
Assert-True (@($poster.static_reconstruction_check.preserve) -contains 'focal_weight' -and @($poster.static_reconstruction_check.preserve) -contains 'negative_space' -and @($poster.static_reconstruction_check.preserve) -contains 'typography_character') 'Static Reconstruction preservation criteria are incomplete.'
Assert-True ($poster.static_reconstruction_check.tolerance -match 'not_pixel_perfect') 'Static Reconstruction must not require pixel-perfect equality.'

$criticalText = $profile.audiovisual_modules.critical_text_policy
Assert-True ($criticalText.owner -eq 'remotion' -and -not $criticalText.generate_text_in_image) 'Critical text must default to Remotion ownership and stay out of generated images.'
Assert-True (@($criticalText.protected_categories) -contains 'person_names' -and @($criticalText.protected_categories) -contains 'historical_evidence') 'Critical text categories are incomplete.'
Assert-True ((@($criticalText.allowed_realizations) -join '|') -eq 'remotion_native_text|verified_typography_svg|verified_typography_png') 'Critical text realizations are incomplete.'
Assert-True ($criticalText.hero_typography_rule -match 'ordinary_css_font') 'Hero Typography must not silently fall back to ordinary CSS.'

$numerals = $profile.audiovisual_modules.historical_cultural_numeral_localization
Assert-True ($numerals.historical_cultural_hero_default -eq 'locale_appropriate_written_numerals') 'Historical/cultural hero numerals must default to locale-appropriate written forms.'
Assert-True ($numerals.modern_data_visualization -eq 'arabic_numerals_allowed') 'Modern data visualization must allow Arabic numerals.'
Assert-True ($numerals.semantic_rule -match 'must_not_change') 'Numeral display conversion must preserve source fact semantics.'

$historicalVox = $profile.audiovisual_modules.historical_vox
Assert-True ($historicalVox.version -eq 'v1.0-zh' -and $historicalVox.field -eq 'historical_visual_mode') 'Historical VOX module identity is missing.'
Assert-True ((@($historicalVox.allowed_modes) -join '|') -eq 'hero_cinematic|editorial_explainer|atmospheric_historical') 'Historical VOX modes are incomplete or reordered.'
Assert-True ((@($historicalVox.orthogonal_dimensions) -join '|') -eq 'historical_visual_mode|pilot_design_route|decomposition_decision|motion_route') 'Historical, Pilot, decomposition, and motion decisions must stay orthogonal.'
Assert-True ((@($historicalVox.visual_grammar.required_structure) -join '|') -eq 'historical_subject|evidence_or_context|editorial_explanation') 'Historical VOX visual grammar is incomplete.'
Assert-True ((@($historicalVox.visual_grammar.palette_roles) -join '|') -eq 'substrate|anchor_dark|persistent_accent|restrained_optional_secondary') 'Historical VOX palette roles are incomplete.'
Assert-True ($historicalVox.visual_grammar.character_rule -match 'not_stickers' -and $historicalVox.visual_grammar.character_rule -match 'runtime_outline_only_when_needed' -and $historicalVox.visual_grammar.character_rule -match 'preserve_approved_source_outline' -and $historicalVox.visual_grammar.character_rule -match 'no_new_outline_when_natural_separation_suffices') 'Historical subjects must preserve approved contours without requiring a new outline.'
Assert-True (@($historicalVox.visual_grammar.map_route_timeline_questions) -contains 'distance' -and @($historicalVox.visual_grammar.map_route_timeline_questions) -contains 'change_over_time' -and $historicalVox.visual_grammar.map_label_owner -eq 'remotion') 'Historical map/route/timeline explanation contract is incomplete.'
Assert-True ((@($historicalVox.visual_grammar.critical_text_realizations) -join '|') -eq 'remotion_native_text|verified_typography_svg|verified_typography_png') 'Historical VOX must reuse the three existing critical-text realizations.'
Assert-True (@($historicalVox.project_visual_bible_owns) -contains 'historical_person_identity' -and @($historicalVox.project_visual_bible_owns) -contains 'exact_palette_values') 'Project Visual Bible ownership is incomplete.'
Assert-True (@($historicalVox.anti_patterns) -contains 'overloaded_scrapbook' -and @($historicalVox.anti_patterns) -contains 'project_specific_constants_leaking_into_style_core') 'Historical VOX anti-patterns are incomplete.'
Assert-True ($historicalVox.new_owner_policy -match 'no_new_profile_registry_id_gate_manifest_state_machine_retry_or_planner') 'Historical VOX must not create new owners or a new profile.'

$routing = $profile.audiovisual_modules.motion_route_decision
Assert-True ($routing.default -eq 'remotion_living_poster') 'VOX motion routing must default to Remotion living poster.'
Assert-True ($routing.remotion_precision_motion -match 'maps_routes') 'Precision motion route must cover map/route work.'
Assert-True ($routing.generative_requirement -match 'why_not_remotion') 'Generative hero clips must require why_not_remotion.'
Assert-True ($routing.insufficient_reason -eq 'more_cinematic') 'Cinematic preference alone must remain insufficient.'
Assert-True ($routing.camera_motion -match 'without_global_amplitude_cap') 'Poster-first routing must not reduce camera freedom.'
Assert-True ($profile.audiovisual_modules.motion_routes.living_poster.priority -eq 'peer_optional_recipe' -and $profile.audiovisual_modules.motion_routes.element_assembly.priority -eq 'peer_optional_recipe') 'Living-poster and element-assembly patterns must remain peer options.'

$assetDerivation = $profile.production_modules.asset_derivation
Assert-True ($assetDerivation.production_asset_set_rule -match 'approved_poster_shot') 'Production assets must derive from approved Poster Shots.'
Assert-True (@($assetDerivation.required_fields) -contains 'used_by_poster_shots') 'Asset derivation must retain Poster Shot usage refs.'
Assert-True (@($assetDerivation.implementation_routes) -contains 'remotion_svg' -and @($assetDerivation.implementation_routes) -contains 'generated_asset') 'Asset implementation routes are incomplete.'
Assert-True ($assetDerivation.authorization_boundary -match 'does_not_grant') 'Asset eligibility must not grant a provider call or Cost Gate.'
$salvage = $profile.production_modules.generated_asset_salvage
Assert-True ((@($salvage.decision_order) -join '|') -eq 'later_beat|hero_poster|cover|title_card|detail_crop|background|transition|reject') 'Generated-asset salvage order is incomplete.'
Assert-True ($salvage.reject_rule -match 'only_after_every_prior') 'Reject must be the last salvage disposition.'
$plate = $profile.production_modules.background_plate_strategy
Assert-True ($plate.default -eq 'recover_only_motion_exposure_regions' -and $plate.no_exposure_rule -match 'do_not_generate') 'Background plate strategy must be exposure-bounded.'

# Preserve valid v1.6 capabilities and production boundaries.
Assert-True ($profile.production_modules.recommended_local_recipe.engine -eq 'remotion') 'VOX default local recipe must use Remotion.'
Assert-True ($profile.production_modules.recommended_local_recipe.narration_source -eq 'external_audio_tool_then_import_final_audio') 'VOX narration must support externally generated imported audio.'
Assert-True (-not $profile.production_modules.recommended_local_recipe.hyperframes_default) 'HyperFrames must not be the VOX default engine.'
Assert-True ($profile.audiovisual_modules.motion_discipline.attention_rule -match 'one_primary_attention_target' -and $profile.audiovisual_modules.motion_discipline.attention_rule -match 'not_one_action') 'VOX must coordinate motion by attention target, not one action per Shot.'
Assert-True (-not $profile.audiovisual_modules.motion_vocabulary_policy.closed_set -and $null -eq $profile.audiovisual_modules.motion_vocabulary_policy.quota) 'VOX motion examples must remain open and quota-free.'
Assert-True (@($profile.audiovisual_modules.curated_motion_vocabulary.PSObject.Properties).Count -ge 6) 'Existing open motion examples must remain available.'
Assert-True ($profile.audiovisual_modules.motion_discipline.default_camera -match 'intent_selected_static_dynamic_or_compound' -and $profile.audiovisual_modules.motion_discipline.default_camera -match 'no_global_amplitude_default_or_cap') 'VOX camera freedom regressed.'
Assert-True ($profile.audiovisual_modules.layer_roles.policy -match 'not_fixed_three_or_four_layers') 'VOX must not require fixed layer count.'
Assert-True ($profile.production_modules.recommended_local_recipe.generative_clip_exemption -match 'local_assembly_is_not_blocked_by_generative_6_to_14_second_clip') 'Local assembly must not inherit generative Clip defaults.'
Assert-True ($profile.production_modules.recommended_local_recipe.transparent_png_generation -match 'chatgpt_web_existing_task_conversation' -and $profile.production_modules.recommended_local_recipe.transparent_png_generation -match 'verify_saved_file_alpha') 'Transparent PNG generation must reuse the existing ChatGPT Web conversation and verify Alpha.'
Assert-True ($profile.production_modules.recommended_local_recipe.small_element_atlas -match '2x2' -and $profile.production_modules.recommended_local_recipe.small_element_atlas -match '3x3') 'Bounded small-element atlas handling regressed.'
Assert-True ($profile.audiovisual_modules.cut_paper_outline_system.selection_rule -match 'final_background' -and $profile.audiovisual_modules.cut_paper_outline_system.selection_rule -match 'clear_lightness_hue_or_temperature_separation') 'Cut-paper outline must remain background-aware.'
Assert-True ($profile.audiovisual_modules.cut_paper_outline_system.shadow_rule -match 'separate') 'Outline and paper shadow must remain separate.'
Assert-True ($profile.audiovisual_modules.cut_paper_outline_system.default_owner -eq 'remotion_runtime_style' -and -not $profile.audiovisual_modules.cut_paper_outline_system.bake_into_new_source_png) 'Cut-paper outline must default to a Remotion runtime style over clean source PNGs.'
Assert-True ($profile.audiovisual_modules.cut_paper_outline_system.width_rule -match 'element_role' -and $profile.audiovisual_modules.cut_paper_outline_system.width_rule -match 'delivery_resolution' -and $profile.audiovisual_modules.cut_paper_outline_system.width_rule -match 'no_global_10px_8px_6px') 'Runtime outline width must be role- and delivery-aware without global pixel constants.'

Assert-True ($source.Contains('先把每一镜设计成值得停下来看的编辑海报')) 'Poster-first runtime principle is missing.'
Assert-True ($source.Contains('Motion compilation 必须停止')) 'Source must block motion after failed Poster Readiness.'
Assert-True ($source.Contains('critical_text_owner: remotion') -and $source.Contains('generate_text_in_image: false')) 'Source critical-text invariant is missing.'
Assert-True ($source.Contains('pilot_design_route: hero_key_art | production_reconstructable') -and $source.Contains('Route Before Generation')) 'Source Pilot route decision is missing.'
Assert-True ($source.Contains('typography_split_test') -and $source.Contains('context_separation_test') -and $source.Contains('decorative_independence_test') -and $source.Contains('rectangle_risk_test') -and $source.Contains('motion_sequence_test')) 'Source Production Reconstructability checks are incomplete.'
Assert-True ($source.Contains('full-width context strip') -and $source.Contains('title + background rectangular crop') -and $source.Contains('不是元素拆分 fallback')) 'Source rectangle-crop prohibition is incomplete.'
Assert-True ($source.Contains('recommended_reclassification: hero_key_art') -and $source.Contains('v1.8 既有 salvage／reuse')) 'Source reclassification and v1.8 reuse handoff are missing.'
Assert-True ($source.Contains('keep_whole') -and $source.Contains('partial_decomposition') -and $source.Contains('full_element_assembly') -and $source.Contains('rebuild_locally')) 'Source decomposition decision is incomplete.'
Assert-True ($source.Contains('Static Reconstruction Check') -and $source.Contains('不要求 pixel-perfect')) 'Source Static Reconstruction boundary is missing.'
Assert-True ($source.Contains('later_beat') -and $source.Contains('hero_poster') -and $source.Contains('title_card') -and $source.Contains('transition') -and $source.Contains('reject')) 'Source salvage/reuse disposition is incomplete.'
Assert-True ($source.Contains('motion_exposure_regions') -and $source.Contains('不得机械地为每张海报补整张空背景')) 'Source background plate strategy is incomplete.'
Assert-True ($source.Contains('verified_typography_svg') -and $source.Contains('verified_typography_png') -and $source.Contains('不得静默降级为普通 CSS 字体')) 'Source typography realization or Hero Typography boundary is missing.'
Assert-True ($source.Contains('Historical/Cultural Numeral Localization') -and $source.Contains('八百') -and $source.Contains('Arabic numerals')) 'Source numeral localization policy is missing.'
Assert-True ($source.Contains('Historical VOX 可选模块') -and $source.Contains('historical_visual_mode: hero_cinematic | editorial_explainer | atmospheric_historical | null')) 'Source Historical VOX mode projection is missing.'
Assert-True ($source.Contains('historical subject + evidence/context + editorial explanation') -and $source.Contains('Project Visual Bible')) 'Source Historical VOX grammar or project boundary is missing.'
Assert-True ($source.Contains('互相正交') -and $source.Contains('拥挤 scrapbook') -and $source.Contains('archival clutter')) 'Source Historical VOX orthogonality or anti-pattern policy is missing.'
Assert-True ($source.Contains('Remotion 在运行时施加') -and $source.Contains('10px/8px/6px') -and $source.Contains('投影保持低饱和')) 'Source runtime outline policy is missing.'
Assert-True ($source.Contains('VOX editorial 为主体') -and $source.Contains('少量高质量 hero poster')) 'Source editorial-plus-hero-poster mix is missing.'
Assert-True ($source.Contains('why_not_remotion') -and $source.Contains('“更电影感”不是充分理由')) 'Source generative routing boundary is missing.'
Assert-True ($source.Contains('不是封闭白名单、配额或 QA 计数器')) 'Motion examples must stay open and quota-free.'
Assert-True ($source.Contains('既有 ChatGPT Web 同一对话') -and $source.Contains('下载后先核验真实 Alpha')) 'Transparent-asset routing boundary regressed.'
Assert-True (-not $source.Contains('## v1.8：') -and $changelog.Contains('## v1.8-zh') -and $changelog.Contains('## v1.9-zh')) 'Runtime Profile must exclude version-history sections and changelog must preserve them.'

$videoRoot = Join-Path $projectRoot 'video-production'
$router = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\production-router.md') -Raw
$planner = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\scene-clip-planner.md') -Raw
$posterPlanner = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\vox-poster-shot-planner.md') -Raw
$storyboard = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\storyboard-keyframe-planner.md') -Raw
$assetCompiler = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\asset-prompt-compiler.md') -Raw
$promptContract = Get-Content -LiteralPath (Join-Path $videoRoot 'contracts\executable-prompt-contract.md') -Raw
$lookdev = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\lookdev-calibration.md') -Raw
$manifest = Get-Content -LiteralPath (Join-Path $videoRoot 'contracts\production-manifest.md') -Raw
$review = Get-Content -LiteralPath (Join-Path $videoRoot 'contracts\review-result-contract.md') -Raw
$audioContract = Get-Content -LiteralPath (Join-Path $videoRoot 'contracts\audio-production-contract.md') -Raw
$qa = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\qa-retry.md') -Raw
Assert-True ($router.Contains('VOX Poster Shot Planner') -and $router.Contains('motion cannot rescue the layout')) 'Production Router is missing Poster-first sequencing.'
Assert-True ($planner.Contains('poster_spec') -and $planner.Contains('motion_plan') -and $planner.Contains('used_by_poster_shots')) 'Scene planner is missing Poster projection or asset derivation.'
Assert-True ($posterPlanner.Contains('Poster Shot Map') -and $posterPlanner.Contains('generative_hero_clip') -and $posterPlanner.Contains('why_not_remotion')) 'VOX Poster Shot Planner is incomplete.'
Assert-True ($posterPlanner.Contains('Static Reconstruction Check') -and $posterPlanner.Contains('recover_motion_exposure_regions') -and $posterPlanner.Contains('verified_typography_svg')) 'VOX Poster planner lacks reconstruction, plate, or typography routing.'
Assert-True ($posterPlanner.Contains('pilot_design_route') -and $posterPlanner.Contains('typography_split_test') -and $posterPlanner.Contains('recommended_reclassification: hero_key_art')) 'VOX Poster planner lacks v1.9 Pilot route, reconstructability checks, or reclassification.'
Assert-True ($posterPlanner.Contains('Historical VOX projection') -and $posterPlanner.Contains('historical_visual_mode') -and $posterPlanner.Contains('Project Visual Bible')) 'VOX Poster planner lacks Historical VOX projection or project boundary.'
Assert-True ($planner.Contains('four independent decisions') -and $planner.Contains('Non-historical Shots omit the field')) 'Scene planner must preserve Historical VOX orthogonality and non-historical behavior.'
Assert-True ($storyboard.Contains('VOX Poster Contact Sheet') -and $storyboard.Contains('editorial_repetition_warning')) 'Storyboard planner is missing VOX rhythm review.'
Assert-True ($storyboard.Contains('rectangle_risk_test') -and $storyboard.Contains('full-width context strip') -and $storyboard.Contains('preserve it through existing salvage/reuse')) 'Storyboard review lacks route-specific rectangle risk and reclassification handling.'
Assert-True ($storyboard.Contains('At mobile size') -and $storyboard.Contains('overloaded scrapbook') -and $storyboard.Contains('adds no Historical Gate')) 'Storyboard review lacks Historical VOX mobile readability or ownership boundary.'
Assert-True ($assetCompiler.Contains('one visually strong, coherent editorial poster') -and $assetCompiler.Contains('independently reconstructable') -and $assetCompiler.Contains('fixed layer count')) 'Asset Prompt Compiler lacks Production Pilot auto-clause semantics or non-prescription boundary.'
Assert-True ($promptContract.Contains('pilot_design_route') -and $promptContract.Contains('rectangular screenshot-crop dependency')) 'Executable Prompt Contract lacks VOX Pilot route projection.'
Assert-True ($lookdev.Contains('vox_style_bakeoff') -and $lookdev.Contains('no applicable approved VOX or Series Baseline')) 'LookDev optional VOX bake-off is missing.'
Assert-True ($manifest.Contains('Contract v1.8') -and $manifest.Contains('stable_poster_state') -and $manifest.Contains('No Poster Gate')) 'Manifest v1.8 Poster projection or ownership boundary is missing.'
Assert-True ($review.Contains('vox_poster_contact_sheet') -and $review.Contains('poster_readiness') -and $review.Contains('editorial_rhythm')) 'Review Result VOX extensions are missing.'
Assert-True ($review.Contains('Static Reconstruction') -and $review.Contains('without requiring pixel-perfect equality')) 'Review Result must reuse Poster Readiness for Static Reconstruction.'
Assert-True ($review.Contains('production_reconstructability') -and $review.Contains('recommended_reclassification') -and $review.Contains('rectangle_risk_test')) 'Review Result lacks v1.9 route-specific findings or Hero reclassification.'
Assert-True ($audioContract.Contains('integer frames') -and $audioContract.Contains('one continuous read-only timing spine')) 'Audio timing spine regressed.'
Assert-True ($qa.Contains('Static, dynamic, and compound motion are all eligible') -and $qa.Contains('Missing Alpha')) 'Existing QA creative freedom or required failures regressed.'
Assert-True ($qa.Contains('later_beat') -and $qa.Contains('hero_poster') -and $qa.Contains('transition') -and $qa.Contains('then `reject`')) 'QA must attempt salvage before reject.'

$mirrorPairs = @(
    'SKILL.md',
    'contracts\production-manifest.md',
    'contracts\review-result-contract.md',
    'contracts\audio-production-contract.md',
    'contracts\executable-prompt-contract.md',
    'modules\production-router.md',
    'modules\scene-clip-planner.md',
    'modules\vox-poster-shot-planner.md',
    'modules\storyboard-keyframe-planner.md',
    'modules\lookdev-calibration.md',
    'modules\audio-production.md',
    'modules\asset-prompt-compiler.md',
    'modules\qa-retry.md',
    'scripts\compile-image-prompt-fixture.ps1',
    'scripts\compile-production-fixture.ps1'
)
foreach ($relativePath in $mirrorPairs) {
    $rootPath = Join-Path $videoRoot $relativePath
    $skillsPath = Join-Path (Join-Path $projectRoot 'skills\video-production') $relativePath
    $rootText = Get-Content -LiteralPath $rootPath -Raw
    $skillsText = Get-Content -LiteralPath $skillsPath -Raw
    if ($relativePath -eq 'SKILL.md') {
        $rootText = $rootText.Replace('(adapters/whiteboard-animator-adapter.md)', '(../../video-production/adapters/whiteboard-animator-adapter.md)').Replace('(contracts/whiteboard-animator-render-contract.md)', '(../../video-production/contracts/whiteboard-animator-render-contract.md)')
    }
    $rootText = $rootText.Replace("`r`n", "`n")
    $skillsText = $skillsText.Replace("`r`n", "`n")
    Assert-True ($rootText -eq $skillsText) "VOX affected entry mirror drift: $relativePath"
}

$fixture = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'fixtures\vox-poster-first-cases.json') -Raw | ConvertFrom-Json
Assert-True ($fixture.fixture_only) 'VOX Poster fixtures must remain explicitly fixture-only.'
Assert-True (@($fixture.short_explainer.poster_shots | Where-Object { $_.source_beat_id -eq 'B01' }).Count -gt 1) 'One ADP Beat must be able to project to multiple Poster Shots.'
Assert-True ($fixture.long_historical_explainer.poster_shot_count -gt $fixture.long_historical_explainer.adp_beats -and -not $fixture.long_historical_explainer.uses_fixed_two_shots_per_beat) 'Long VOX must support denser visual units without fixed two-shot splitting.'
Assert-True (($fixture.motion_routes | Where-Object { $_.case_id -eq 'quote-portrait' }).expected_route -eq 'remotion_living_poster') 'Living-poster route fixture is missing.'
Assert-True (($fixture.motion_routes | Where-Object { $_.case_id -eq 'campaign-map' }).expected_route -eq 'remotion_precision_motion') 'Precision-motion route fixture is missing.'
$hero = $fixture.motion_routes | Where-Object { $_.case_id -eq 'cavalry-charge' }
Assert-True ($hero.expected_route -eq 'generative_hero_clip' -and $hero.eligible -and $hero.why_not_remotion.Length -gt 20) 'Valid generative hero fixture must document a concrete why_not_remotion.'
Assert-True (-not ($fixture.motion_routes | Where-Object { $_.case_id -eq 'cinematic-only' }).eligible) 'Cinematic preference alone must not authorize a generative route.'
Assert-True (($fixture.poster_readiness | Where-Object { $_.case_id -eq 'weak-layout-with-motion-plan' }).expected_motion_compilation -eq 'blocked_must_fix_poster') 'Motion must not bypass failed Poster Readiness.'
Assert-True (($fixture.editorial_rhythm | Where-Object { $_.case_id -eq 'three-similar-but-purposeful' }).expected -eq 'editorial_repetition_warning') 'Repetition warning fixture is missing.'
Assert-True (($fixture.editorial_rhythm | Where-Object { $_.case_id -eq 'three-similar-and-harmful' }).expected -eq 'must_fix') 'Materially harmful repetition must be reviewable as must_fix.'
Assert-True ($fixture.critical_text.default_owner -eq 'remotion' -and -not $fixture.critical_text.generate_text_in_image) 'Critical text fixture defaults regressed.'
$productionTypography = $fixture.pilot_design_routes | Where-Object { $_.case_id -eq 'pilot01b-production-typography' }
Assert-True ($productionTypography.pilot_design_route -eq 'production_reconstructable' -and $productionTypography.visual_quality -eq 'pass' -and $productionTypography.poster_readiness -eq 'pass') 'Production Typography Pilot route fixture is invalid.'
Assert-True ($productionTypography.production_reconstructability.typography_split_test -eq 'pass' -and $productionTypography.production_reconstructability.context_separation_test -eq 'pass' -and $productionTypography.production_reconstructability.decorative_independence_test -eq 'pass' -and $productionTypography.production_reconstructability.rectangle_risk_test -eq 'pass' -and $productionTypography.production_reconstructability.motion_sequence_test -eq 'pass') 'Production Typography Pilot must pass all five reconstructability checks.'
$heroCallback = $fixture.pilot_design_routes | Where-Object { $_.case_id -eq 'hero-poster-callback' }
Assert-True ($heroCallback.pilot_design_route -eq 'hero_key_art' -and -not $heroCallback.reconstructability_required -and $heroCallback.production_reconstructability -eq 'not_applicable' -and @($heroCallback.recommended_motion) -contains 'micro_animation') 'Hero route must not be forced through reconstructability.'
$reclassification = $fixture.pilot_design_routes | Where-Object { $_.case_id -eq 'beautiful-but-entangled' }
Assert-True ($reclassification.intended_route -eq 'production_reconstructable' -and $reclassification.visual_quality -eq 'pass' -and $reclassification.rectangle_risk -eq 'fail' -and -not $reclassification.forced_decomposition_allowed -and $reclassification.recommended_reclassification -eq 'hero_key_art' -and $reclassification.downstream -eq 'existing_v1_8_salvage_reuse') 'Production-to-Hero reclassification fixture is invalid.'
$badRectangle = $fixture.pilot_design_routes | Where-Object { $_.case_id -eq 'full-width-context-strip' }
Assert-True ($badRectangle.pilot_design_route -eq 'production_reconstructable' -and $badRectangle.visible_rectangular_crop -and $badRectangle.full_width_context_strip -and -not $badRectangle.rectangle_crop_fallback_allowed -and $badRectangle.expected -eq 'must_fix') 'Rectangle crop must-fix fixture is invalid.'
$typographyRebuild = $fixture.poster_decomposition | Where-Object { $_.case_id -eq 'pilot01-typography-rebuild' }
Assert-True ($typographyRebuild.decomposition_decision -eq 'rebuild_locally' -and $typographyRebuild.critical_text_realization -eq 'verified_typography_svg' -and -not $typographyRebuild.hero_typography_css_fallback_allowed) 'Pilot01 typography rebuild fixture is invalid.'
Assert-True (-not $typographyRebuild.static_reconstruction_check.pixel_perfect_required -and @($typographyRebuild.static_reconstruction_check.preserve) -contains 'typography_character') 'Pilot01 Static Reconstruction fixture is invalid.'
$heroSalvage = $fixture.asset_salvage | Where-Object { $_.case_id -eq 'hero-poster-salvage' }
Assert-True ($heroSalvage.selected_disposition -eq 'hero_poster' -and -not $heroSalvage.reject_allowed -and $heroSalvage.review_order[-1] -eq 'reject') 'Hero poster salvage fixture is invalid.'
$historicalNumeral = $fixture.numeral_localization | Where-Object { $_.case_id -eq '800-cavalry-historical-numerals' }
$modernNumeral = $fixture.numeral_localization | Where-Object { $_.case_id -eq 'modern-chart-numerals' }
Assert-True ($historicalNumeral.source_fact_value -eq 800 -and $historicalNumeral.display_value -eq '八百' -and $historicalNumeral.semantic_equivalence) 'Historical numeral fixture is invalid.'
Assert-True ($modernNumeral.display_value -eq '800' -and $modernNumeral.display_mode -eq 'arabic_numeral' -and $modernNumeral.semantic_equivalence) 'Modern chart numeral fixture is invalid.'
$partialBackground = $fixture.background_plate | Where-Object { $_.case_id -eq 'partial-background-recovery' }
Assert-True ($partialBackground.strategy -eq 'recover_motion_exposure_regions' -and -not $partialBackground.full_plate_generated -and @($partialBackground.approved_motion_exposure_regions).Count -gt 0) 'Partial background recovery fixture is invalid.'
$runtimeOutline = $fixture.runtime_outline | Where-Object { $_.case_id -eq 'runtime-outline' }
Assert-True ($runtimeOutline.owner -eq 'remotion_runtime_style' -and -not $runtimeOutline.bake_into_new_source_png -and @($runtimeOutline.global_width_constants).Count -eq 0 -and $runtimeOutline.shadow_separate) 'Runtime outline fixture is invalid.'
$historicalHero = $fixture.historical_visual_modes | Where-Object { $_.case_id -eq 'historical-hero-introduction' }
$historicalRoute = $fixture.historical_visual_modes | Where-Object { $_.case_id -eq 'historical-campaign-route' }
$historicalAtmosphere = $fixture.historical_visual_modes | Where-Object { $_.case_id -eq 'historical-frontier-establish' }
$historicalOrthogonal = $fixture.historical_visual_modes | Where-Object { $_.case_id -eq 'historical-hero-with-controlled-relationship' }
$historicalScrapbook = $fixture.historical_visual_modes | Where-Object { $_.case_id -eq 'historical-overloaded-scrapbook' }
$historicalLeak = $fixture.historical_visual_modes | Where-Object { $_.case_id -eq 'historical-core-project-leak' }
Assert-True ($historicalHero.historical_visual_mode -eq 'hero_cinematic' -and $historicalHero.pilot_design_route -eq 'hero_key_art' -and $historicalHero.expected -eq 'valid') 'Historical hero introduction fixture is invalid.'
Assert-True ($historicalRoute.historical_visual_mode -eq 'editorial_explainer' -and $historicalRoute.pilot_design_route -eq 'production_reconstructable' -and $historicalRoute.motion_route -eq 'remotion_precision_motion' -and @($historicalRoute.explains) -contains 'distance' -and $historicalRoute.label_owner -eq 'remotion') 'Historical campaign route fixture is invalid.'
Assert-True ($historicalAtmosphere.historical_visual_mode -eq 'atmospheric_historical' -and $historicalAtmosphere.pilot_design_route -eq 'hero_key_art' -and $historicalAtmosphere.expected -eq 'valid') 'Historical atmospheric establish fixture is invalid.'
Assert-True ($historicalOrthogonal.historical_visual_mode -eq 'hero_cinematic' -and $historicalOrthogonal.pilot_design_route -eq 'production_reconstructable' -and $historicalOrthogonal.orthogonality_proven) 'Historical orthogonality fixture is invalid.'
Assert-True ($historicalScrapbook.expected -eq 'must_fix' -and @($historicalScrapbook.anti_patterns) -contains 'decorative_archival_clutter') 'Historical overloaded scrapbook must be must_fix.'
Assert-True ($historicalLeak.expected -eq 'invalid_project_specific_leak' -and @($historicalLeak.style_core_contains).Count -gt 0) 'Historical project-specific Core leak fixture is invalid.'
$derived = @($fixture.short_explainer.poster_shots | Where-Object { $_.approved_for_asset_derivation } | ForEach-Object { $_.asset_requirements } | Sort-Object -Unique)
$expected = @($fixture.asset_derivation.expected_production_asset_set | Sort-Object -Unique)
Assert-True (($derived -join '|') -eq ($expected -join '|')) 'Production Asset Set must derive only from approved Poster Shots.'
Assert-True ($fixture.migration.input_read_only -and @($fixture.migration.input_profile_versions) -contains 'v1.9-zh' -and $fixture.migration.output_profile_version -eq 'v1.11-zh' -and $fixture.migration.output_manifest_version -eq '1.8' -and $fixture.migration.stable_profile_id -eq 'vox_transcript_driven_handmade_collage') 'v1.6-v1.9 to v1.11 migration fixture is invalid.'


# Conditional Beat method remains in existing owners and does not claim real-media acceptance.
Assert-True ($profile.poster_first_planning.information_goal_method -match 'absolute_narration_events') 'VOX Beat method must bind information goal and absolute narration events.'
Assert-True ($profile.poster_first_planning.grouping_and_reveal -match 'clean_alpha_fused_region_and_whole_poster') 'VOX group semantics must distinguish clean Alpha and fused regions.'
Assert-True ($profile.audiovisual_modules.motion_choreography.vox_beat_method -match 'speed_curve_by_meaning') 'VOX motion speed must follow semantic intent.'
Assert-True ($profile.audiovisual_modules.critical_text_policy.text_role_timing -match 'prevent_early_conclusion_reveal') 'VOX text roles must prevent early conclusion reveal.'
Assert-True ($profile.production_modules.background_plate_strategy.result_handoff -match 'mutually_exclusive_switch') 'VOX result handoff must be mutually exclusive.'
Assert-True ($profile.production_modules.temporal_texture_validation -match 'continuous_motion_review') 'VOX temporal texture needs continuous final-encoded review.'
foreach ($goal in @('关系', '比较', '地理过程', '文字阅读', '人物氛围', '象征接合')) {
    Assert-True ($source.Contains($goal)) "VOX Beat method is missing conditional information goal: $goal"
}
Assert-True ($source.Contains('B19/B33 是项目案例') -and $source.Contains('其他信息类型在真实小样前不宣称实测通过')) 'VOX examples must not be promoted into general validation.'
foreach ($module in @('vox-poster-shot-planner.md', 'scene-clip-planner.md', 'storyboard-keyframe-planner.md', 'asset-prompt-compiler.md')) {
    $top = Join-Path $projectRoot "video-production\modules\$module"
    $mirror = Join-Path $projectRoot "skills\video-production\modules\$module"
    Assert-True ((Get-FileHash $top).Hash -eq (Get-FileHash $mirror).Hash) "VOX module mirror mismatch: $module"
}
# B24-derived conditional contracts: structural regression, not a semantic/media evaluator.
$skillEntry = Get-Content -LiteralPath (Join-Path $projectRoot 'skills\video-production\SKILL.md') -Raw
Assert-True ($skillEntry.Contains('For natural-contour reuse and layered micro-animation') -and $skillEntry.Contains('verify perceptible parallax and tail behavior through `qa-retry.md`')) 'Skill entrypoint must route to natural-contour and actual-media motion review.'
$natural = $profile.poster_first_planning.natural_boundary_decomposition
$micro = $profile.audiovisual_modules.motion_discipline.layered_micro_animation
Assert-True ($natural.poster_adaptation -match 'do_not_uniformly_add_torn_paper_or_outline' -and $natural.contour_preservation -match 'approved_source_outline' -and $natural.contour_preservation -match 'semantically_complete_map') 'Natural reuse must not force redesign, clip original outlines, or cut maps.'
Assert-True ($natural.source_completeness -match 'does_not_complete_hidden_anatomy') 'Recovered background cannot authorize motion of incomplete anatomy.'
Assert-True ($profile.audiovisual_modules.cut_paper_outline_system.applicability -match 'no_new_outline_when_natural_separation_suffices' -and $profile.audiovisual_modules.cut_paper_outline_system.applicability -match 'without_double_outline') 'Outline applicability must preserve no-outline and original-outline routes.'
Assert-True ($plate.repair_rule -match 'contiguous_occluded_regions_not_only_colored_stamp_or_text_strokes' -and $plate.exposure_sources -match 'before_element_entrance') 'Background repair must include pre-entrance ghosts and full required occlusion.'
Assert-True ($micro.relative_motion -match 'perceptible_parallax_at_target_viewing_size' -and $micro.relative_motion -match 'not_only_global_zoom') 'Differential motion must be perceptible rather than a common zoom proxy.'
Assert-True ($micro.connections -match 'one_fixed_point_does_not_validate_entire_contact_edge' -and $micro.coverage -match 'intermediate_handoff_and_extreme') 'A pivot alone cannot validate contacts or motion exposure.'
Assert-True ($micro.ending -match 'continue_to_last_visible_frame' -and $micro.ending -match 'ease_out_visual_stall' -and $micro.ending -match 'holds_remain_valid_when_intended') 'Continuous-tail and intentional-hold routes must both survive.'
Assert-True ($micro.validation -match 'last_frame_differences_are_supporting_not_visual_acceptance' -and $micro.validation -match 'missing_evidence_is_unknown') 'Numerical checks cannot substitute for actual viewing.'
Assert-True ($posterPlanner.Contains('## Natural-boundary reuse') -and $assetCompiler.Contains('contiguous occluded region') -and $assetCompiler.Contains('Atlas cropping remains a separate')) 'Extraction/recovery consumers must carry the conditional policy.'
Assert-True ($planner.Contains('## Layered micro-animation') -and $planner.Contains('continue_to_last_visible_frame') -and $storyboard.Contains('final encoded playback in existing production QA')) 'Planner/Storyboard must route tail and perceptual review to actual-media QA.'
Assert-True ($qa.Contains('## Natural layers and micro-animation QA') -and $qa.Contains('`motion_failure`') -and $qa.Contains('ease-out visual stall') -and $qa.Contains('`timing_failure`') -and $qa.Contains('Missing media/viewing evidence stays `UNKNOWN`')) 'Existing QA must cover observable parallax/tail failures without fabricated PASS.'
Assert-True ($review.Contains('actual-media owner remains existing `production_qa`') -and $manifest.Contains('not new required fields') -and $promptContract.Contains('not a requirement to add one to every subject')) 'Review, Manifest and Prompt consumers must preserve ownership and optional outline.'
$motionFixture = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'fixtures\vox-remotion-shot-intent-cases.json') -Raw | ConvertFrom-Json
Assert-True ($motionFixture.fixture_only) 'Natural/motion cases are review scenarios, not media evidence.'
$reviewCases = @($motionFixture.natural_layer_motion_review_cases)
foreach ($id in @('natural-edge-no-outline','approved-source-outline','plate-with-hidden-anatomy','stamp-ghost-before-entrance','common-zoom-is-not-parallax','continuous-tail-early-stop','continuous-tail-ease-out-stall','intentional-reading-hold','no-playback-evidence')) {
    $case = @($reviewCases | Where-Object { $_.case_id -eq $id })
    Assert-True ($case.Count -eq 1 -and $case[0].given.Length -gt 20 -and $case[0].expected.Length -gt 20) "Missing or duplicate bounded review scenario: $id"
}
Assert-True (@($reviewCases.case_id | Sort-Object -Unique).Count -eq $reviewCases.Count) 'Review scenarios must have unique IDs.'


Write-Output 'PASS: VOX v1.11 Historical VOX Profile, stable ID/v1.9 history, optional historical modes, orthogonal routing, visual grammar, Project Visual Bible boundary, mobile readability review, source/mirror parity, provenance, and structural fixtures are valid. Visual quality, provider execution, runtime loading, and human approval are not proven.'
