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
Assert-True ($entry.source_file -eq 'Style_Profile_VOX编辑纸拼贴讲解动画_v1.7_Poster_First.md') 'VOX registry source must be v1.7 Poster First.'
Assert-True ($entry.normalized_file -eq 'transcript_driven_handmade_collage.v1.7-zh.json') 'VOX registry normalized file must be v1.7.'
Assert-True ($entry.normalized_version -eq 'v1.7-zh') 'VOX registry version must be v1.7-zh.'
Assert-True ($entry.status -eq 'ready') 'VOX registry status must remain ready.'

$sourcePath = Join-Path (Join-Path $libraryRoot 'source') $entry.source_file
$normalizedPath = Join-Path (Join-Path $libraryRoot 'normalized') $entry.normalized_file
$changelogPath = Join-Path $libraryRoot 'references\vox-changelog.md'
Assert-True (Test-Path -LiteralPath $sourcePath) 'VOX v1.7 source file is missing.'
Assert-True (Test-Path -LiteralPath $normalizedPath) 'VOX v1.7 normalized file is missing.'
Assert-True (Test-Path -LiteralPath $changelogPath) 'VOX changelog is missing.'
foreach ($version in @('1.2', '1.3', '1.4', '1.5', '1.6')) {
    Assert-True (@(Get-ChildItem -LiteralPath (Join-Path $libraryRoot 'source') -Filter "*v$version*.md").Count -ge 1) "Historical VOX v$version source must be preserved."
    Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot "normalized\transcript_driven_handmade_collage.v$version-zh.json")) "Historical VOX v$version normalized profile must be preserved."
}
$sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash
Assert-True ($sourceHash -eq $entry.source_sha256) 'VOX source hash does not match the registry.'

$source = Get-Content -LiteralPath $sourcePath -Raw
$changelog = Get-Content -LiteralPath $changelogPath -Raw
$normalized = Get-Content -LiteralPath $normalizedPath -Raw | ConvertFrom-Json
$profile = $normalized.style_profile

Assert-True ($normalized.normalized_from_source -eq $entry.source_file) 'Normalized Profile must name the active v1.7 source.'
Assert-True ($profile.style_id -eq 'vox_transcript_driven_handmade_collage') 'VOX normalized stable ID changed.'
Assert-True ($profile.version -eq 'v1.7-zh') 'VOX normalized version must be v1.7-zh.'
Assert-True ($profile.provenance.source_sha256 -eq $sourceHash) 'Normalized Profile provenance hash must match the active source.'
Assert-True (($profile.provenance.source_documents | Where-Object { $_.file -eq $entry.source_file }).sha256 -eq $sourceHash) 'Normalized source-document hash must match the active source.'

# Poster-first planning and routing.
$poster = $profile.poster_first_planning
Assert-True ($poster.required_before_batch_asset_generation) 'Poster Shot Map must be required before batch asset generation.'
Assert-True ($poster.planning_unit -match 'existing_scene_shot_local_assembly_plan') 'Poster Shot must project into existing Scene/Shot/local assembly ownership.'
Assert-True (@($poster.required_fields) -contains 'stable_poster_state') 'Stable poster state is missing from the Poster Shot contract.'
Assert-True (@($poster.required_fields) -contains 'source_beat_id') 'Poster Shot must retain the ADP Beat reference.'
Assert-True ($poster.wide_detail_rule -match 'without_forcing_two_shots_per_beat') 'Wide/detail planning must remain optional.'
Assert-True ($poster.poster_readiness.failure_rule -match 'blocks_motion_compilation') 'Failed Poster Readiness must block motion compilation.'
Assert-True ($poster.poster_readiness.owner -match 'existing_review_result') 'Poster Readiness must reuse the existing Review Result owner.'

$criticalText = $profile.audiovisual_modules.critical_text_policy
Assert-True ($criticalText.owner -eq 'remotion' -and -not $criticalText.generate_text_in_image) 'Critical text must default to Remotion ownership and stay out of generated images.'
Assert-True (@($criticalText.protected_categories) -contains 'person_names' -and @($criticalText.protected_categories) -contains 'historical_evidence') 'Critical text categories are incomplete.'

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

Assert-True ($source.Contains('先把每一镜设计成值得停下来看的编辑海报')) 'Poster-first runtime principle is missing.'
Assert-True ($source.Contains('Motion compilation 必须停止')) 'Source must block motion after failed Poster Readiness.'
Assert-True ($source.Contains('critical_text_owner: remotion') -and $source.Contains('generate_text_in_image: false')) 'Source critical-text invariant is missing.'
Assert-True ($source.Contains('why_not_remotion') -and $source.Contains('“更电影感”不是充分理由')) 'Source generative routing boundary is missing.'
Assert-True ($source.Contains('不是封闭白名单、配额或 QA 计数器')) 'Motion examples must stay open and quota-free.'
Assert-True ($source.Contains('既有 ChatGPT Web 同一对话') -and $source.Contains('下载后先核验真实 Alpha')) 'Transparent-asset routing boundary regressed.'
Assert-True (-not $source.Contains('## v1.6：') -and $changelog.Contains('## v1.6-zh') -and $changelog.Contains('## v1.7-zh')) 'Runtime Profile must exclude version-history sections and changelog must preserve them.'

$videoRoot = Join-Path $projectRoot 'video-production'
$router = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\production-router.md') -Raw
$planner = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\scene-clip-planner.md') -Raw
$posterPlanner = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\vox-poster-shot-planner.md') -Raw
$storyboard = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\storyboard-keyframe-planner.md') -Raw
$lookdev = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\lookdev-calibration.md') -Raw
$manifest = Get-Content -LiteralPath (Join-Path $videoRoot 'contracts\production-manifest.md') -Raw
$review = Get-Content -LiteralPath (Join-Path $videoRoot 'contracts\review-result-contract.md') -Raw
$audioContract = Get-Content -LiteralPath (Join-Path $videoRoot 'contracts\audio-production-contract.md') -Raw
$qa = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\qa-retry.md') -Raw
Assert-True ($router.Contains('VOX Poster Shot Planner') -and $router.Contains('motion cannot rescue the layout')) 'Production Router is missing Poster-first sequencing.'
Assert-True ($planner.Contains('poster_spec') -and $planner.Contains('motion_plan') -and $planner.Contains('used_by_poster_shots')) 'Scene planner is missing Poster projection or asset derivation.'
Assert-True ($posterPlanner.Contains('Poster Shot Map') -and $posterPlanner.Contains('generative_hero_clip') -and $posterPlanner.Contains('why_not_remotion')) 'VOX Poster Shot Planner is incomplete.'
Assert-True ($storyboard.Contains('VOX Poster Contact Sheet') -and $storyboard.Contains('editorial_repetition_warning')) 'Storyboard planner is missing VOX rhythm review.'
Assert-True ($lookdev.Contains('vox_style_bakeoff') -and $lookdev.Contains('no applicable approved VOX or Series Baseline')) 'LookDev optional VOX bake-off is missing.'
Assert-True ($manifest.Contains('Contract v1.8') -and $manifest.Contains('stable_poster_state') -and $manifest.Contains('No Poster Gate')) 'Manifest v1.8 Poster projection or ownership boundary is missing.'
Assert-True ($review.Contains('vox_poster_contact_sheet') -and $review.Contains('poster_readiness') -and $review.Contains('editorial_rhythm')) 'Review Result VOX extensions are missing.'
Assert-True ($audioContract.Contains('integer frames') -and $audioContract.Contains('one continuous read-only timing spine')) 'Audio timing spine regressed.'
Assert-True ($qa.Contains('Static, dynamic, and compound motion are all eligible') -and $qa.Contains('Missing Alpha')) 'Existing QA creative freedom or required failures regressed.'

$mirrorPairs = @(
    'SKILL.md',
    'contracts\production-manifest.md',
    'contracts\review-result-contract.md',
    'contracts\audio-production-contract.md',
    'modules\production-router.md',
    'modules\scene-clip-planner.md',
    'modules\vox-poster-shot-planner.md',
    'modules\storyboard-keyframe-planner.md',
    'modules\lookdev-calibration.md',
    'modules\audio-production.md',
    'modules\asset-prompt-compiler.md',
    'modules\qa-retry.md',
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
$derived = @($fixture.short_explainer.poster_shots | Where-Object { $_.approved_for_asset_derivation } | ForEach-Object { $_.asset_requirements } | Sort-Object -Unique)
$expected = @($fixture.asset_derivation.expected_production_asset_set | Sort-Object -Unique)
Assert-True (($derived -join '|') -eq ($expected -join '|')) 'Production Asset Set must derive only from approved Poster Shots.'
Assert-True ($fixture.migration.input_read_only -and $fixture.migration.output_manifest_version -eq '1.8' -and $fixture.migration.stable_profile_id -eq 'vox_transcript_driven_handmade_collage') 'v1.6/v1.7 migration fixture is invalid.'

Write-Output 'PASS: VOX v1.7 Poster-first Profile, Poster Shot planning, stable-poster readiness block, minimum-asset derivation, critical-text ownership, open camera freedom, Remotion/generative routing, Contact Sheet/rhythm review, Manifest v1.8 migration, source/mirror parity, provenance, and structural fixtures are valid. Visual quality, provider execution, runtime loading, and human approval are not proven.'
