$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

$projectRoot = Split-Path -Parent $PSScriptRoot
$libraryRoot = Join-Path $projectRoot 'style-profiles'
$registryPath = Join-Path $libraryRoot 'registry.json'
$registry = Get-Content -LiteralPath $registryPath -Raw | ConvertFrom-Json
$entries = @($registry.profiles | Where-Object { $_.profile_id -eq 'vox_transcript_driven_handmade_collage' })

Assert-True ($entries.Count -eq 1) 'VOX profile must resolve to one stable registry entry.'
$entry = $entries[0]
Assert-True ($entry.source_file -eq 'Style_Profile_VOX编辑纸拼贴讲解动画_v1.6_镜头意图驱动.md') 'VOX registry source must be v1.6.'
Assert-True ($entry.normalized_file -eq 'transcript_driven_handmade_collage.v1.6-zh.json') 'VOX registry normalized file must be v1.6.'
Assert-True ($entry.normalized_version -eq 'v1.6-zh') 'VOX registry version must be v1.6-zh.'
Assert-True ($entry.status -eq 'ready') 'VOX registry status must remain ready.'

$sourcePath = Join-Path (Join-Path $libraryRoot 'source') $entry.source_file
$normalizedPath = Join-Path (Join-Path $libraryRoot 'normalized') $entry.normalized_file
Assert-True (Test-Path -LiteralPath $sourcePath) 'VOX v1.6 source file is missing.'
Assert-True (Test-Path -LiteralPath $normalizedPath) 'VOX v1.6 normalized file is missing.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'source\Style_Profile_VOX编辑纸拼贴讲解动画_v1.2_中文整合.md')) 'Historical VOX v1.2 source must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'normalized\transcript_driven_handmade_collage.v1.2-zh.json')) 'Historical VOX v1.2 normalized profile must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'source\Style_Profile_VOX编辑纸拼贴讲解动画_v1.3_教程与动效整合.md')) 'Historical VOX v1.3 source must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'normalized\transcript_driven_handmade_collage.v1.3-zh.json')) 'Historical VOX v1.3 normalized profile must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'source\Style_Profile_VOX编辑纸拼贴讲解动画_v1.4_真实生产经验整合.md')) 'Historical VOX v1.4 source must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'normalized\transcript_driven_handmade_collage.v1.4-zh.json')) 'Historical VOX v1.4 normalized profile must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'source\Style_Profile_VOX编辑纸拼贴讲解动画_v1.5_背景感知剪纸轮廓.md')) 'Historical VOX v1.5 source must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'normalized\transcript_driven_handmade_collage.v1.5-zh.json')) 'Historical VOX v1.5 normalized profile must be preserved.'
Assert-True ((Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash -eq $entry.source_sha256) 'VOX source hash does not match the registry.'

$source = Get-Content -LiteralPath $sourcePath -Raw
$normalized = Get-Content -LiteralPath $normalizedPath -Raw | ConvertFrom-Json
$profile = $normalized.style_profile

Assert-True ($profile.style_id -eq 'vox_transcript_driven_handmade_collage') 'VOX normalized stable ID changed.'
Assert-True ($profile.version -eq 'v1.6-zh') 'VOX normalized version must be v1.6-zh.'
Assert-True ($profile.production_modules.recommended_local_recipe.engine -eq 'remotion') 'VOX default local recipe must use Remotion.'
Assert-True ($profile.production_modules.recommended_local_recipe.narration_source -eq 'external_audio_tool_then_import_final_audio') 'VOX narration must support externally generated imported audio.'
Assert-True (-not $profile.production_modules.recommended_local_recipe.hyperframes_default) 'HyperFrames must not be the VOX default engine.'
Assert-True ($profile.audiovisual_modules.motion_discipline.attention_rule -match 'one_primary_attention_target' -and $profile.audiovisual_modules.motion_discipline.attention_rule -match 'not_one_action') 'VOX must coordinate motion by one primary attention target, not one action per Shot.'
Assert-True (-not $profile.audiovisual_modules.motion_vocabulary_policy.closed_set -and $null -eq $profile.audiovisual_modules.motion_vocabulary_policy.quota) 'VOX motion examples must remain open and quota-free.'
Assert-True (@($profile.audiovisual_modules.curated_motion_vocabulary.PSObject.Properties).Count -ge 6) 'VOX must retain the existing motion examples without treating six as a closed count.'
Assert-True ($profile.audiovisual_modules.motion_discipline.determinism -match 'fixed_seed') 'VOX procedural visuals must be deterministic.'
Assert-True ($profile.audiovisual_modules.sound_direction.narration -match 'externally_generated_imported_final_audio') 'Imported final narration must remain the timing spine.'
Assert-True ($profile.provenance.review_boundary.video_shotcraft_product_promo_workflow_is_not_a_vox_default) 'Product-promo workflow boundary must remain explicit.'
Assert-True ($profile.audiovisual_modules.motion_discipline.default_camera -match 'intent_selected_static_dynamic_or_compound' -and $profile.audiovisual_modules.motion_discipline.default_camera -match 'no_global_amplitude_default_or_cap') 'VOX camera must be intent-selected without a global static or micro-push default.'
Assert-True ($profile.audiovisual_modules.motion_routes.living_poster.priority -eq 'peer_optional_recipe' -and $profile.audiovisual_modules.motion_routes.element_assembly.priority -eq 'peer_optional_recipe' -and $profile.audiovisual_modules.motion_routes.composition.allowed) 'Living-poster and element-assembly routes must be peer and composable options.'
Assert-True ($profile.audiovisual_modules.layer_roles.policy -match 'not_fixed_three_or_four_layers') 'VOX must not require a fixed three- or four-layer layout.'
Assert-True ($profile.audiovisual_modules.spatial_layout.protected_regions -match 'intentional_crop_reason') 'VOX layout must distinguish protected regions from intentional crop.'
Assert-True ($profile.production_modules.recommended_local_recipe.generative_clip_exemption -match 'local_assembly_is_not_blocked_by_generative_6_to_14_second_clip') 'VOX Remotion local assembly must not inherit generative Clip duration or Prompt requirements.'
Assert-True ($profile.production_modules.recommended_local_recipe.timeline_policy -match 'integer_frames' -and $profile.production_modules.recommended_local_recipe.sfx_policy -match 'visible_motion_intervals') 'VOX final narration and visible-event SFX must project to the frame timeline.'
Assert-True ($profile.audiovisual_modules.motion_discipline.supporting_effect_lifecycle -match 'enter_hold_exit') 'Supporting effects require an explicit lifecycle.'
Assert-True ($profile.production_modules.recommended_local_recipe.engineering_canvas_default -match '720x1280' -and $profile.production_modules.recommended_local_recipe.engineering_canvas_default -match '480P') '720x1280 must remain an engineering default while 480P stays a legal current delivery choice.'
Assert-True ($profile.production_modules.recommended_local_recipe.asset_intake -match 'individual_PNG' -and $profile.production_modules.recommended_local_recipe.asset_intake -match 'RGBA') 'Remotion intake must require independently checked PNG assets.'
Assert-True ($profile.production_modules.recommended_local_recipe.transparent_png_generation -match 'chatgpt_web_existing_task_conversation' -and $profile.production_modules.recommended_local_recipe.transparent_png_generation -match 'verify_saved_file_alpha') 'Transparent PNG generation must use the existing ChatGPT Web conversation and verify saved-file Alpha.'
Assert-True ($profile.production_modules.recommended_local_recipe.small_element_atlas -match '2x2' -and $profile.production_modules.recommended_local_recipe.small_element_atlas -match '3x3' -and $profile.production_modules.recommended_local_recipe.small_element_atlas -match 'local_crop') 'Small elements must use the smallest 2x2 or 3x3 transparent atlas before local crop and independent intake.'
Assert-True ($profile.audiovisual_modules.cut_paper_outline_system.preferred_colors -contains 'paper_white' -and $profile.audiovisual_modules.cut_paper_outline_system.preferred_colors -contains 'warm_white') 'Paper white and warm white must remain preferred outline colors.'
Assert-True ($profile.audiovisual_modules.cut_paper_outline_system.selection_rule -match 'final_background' -and $profile.audiovisual_modules.cut_paper_outline_system.selection_rule -match 'clear_lightness_hue_or_temperature_separation') 'Cut-paper outline color must adapt to the bound final background.'
Assert-True ($profile.audiovisual_modules.cut_paper_outline_system.shadow_rule -match 'separate') 'Paper-layer shadow must stay separate from the cut-paper outline.'
Assert-True ($profile.audiovisual_modules.cut_paper_outline_system.project_asset_boundary -match 'era_clothing_identity_facing_pose_complete_limbs') 'Era, clothing, direction, pose, and complete-limb requirements must remain project-level asset constraints.'
Assert-True ($profile.production_modules.recommended_local_recipe.atlas_crop_tool -match 'split-transparent-atlas.ps1' -and $profile.production_modules.recommended_local_recipe.atlas_crop_tool -match 'split-transparent-atlas.py' -and $profile.production_modules.recommended_local_recipe.atlas_crop_tool -match 'no_background_removal_or_outline_invention') 'VOX must expose the bounded true-alpha crop wrapper and Python worker without background removal or outline invention.'
Assert-True ($profile.audiovisual_modules.failure_constraints -contains 'no_outline_color_hard_locked_to_white_when_the_bound_background_is_white_light_or_low_contrast') 'VOX must reject a white-only outline policy on light backgrounds.'

Assert-True ($source.Contains('https://www.youtube.com/watch?v=7wuYBfE131U')) 'Tutorial provenance URL is missing from the VOX source.'
Assert-True ($source.Contains('https://github.com/Vincentwei1021/video-shotcraft')) 'video-shotcraft provenance URL is missing from the VOX source.'
Assert-True ($source.Contains('推荐本地配方：Remotion + 外部旁白导入')) 'Remotion and imported narration recipe is missing from the VOX source.'
Assert-True ($source.Contains('静止、单一运动和相机／人物／标记／环境的复合协同运动都是常规可选项')) 'Intent-driven static, dynamic, and compound motion guidance is missing.'
Assert-True ($source.Contains('一个时刻只有一个主要注意力目标')) 'Primary-attention guidance is missing from the VOX source.'
Assert-True ($source.Contains('不是封闭白名单、每片配额或 QA 计数器')) 'Motion examples must not become a closed six-effect quota.'
Assert-True ($source.Contains('本节明确取代本活动版本中与之冲突的 v1.2–v1.5')) 'The active v1.6 source must explicitly supersede conflicting legacy restrictions.'
Assert-True ($source.Contains('不固定像素值或唯一算法')) 'Multi-card layout must not freeze a unique vertical-gap algorithm.'
Assert-True ($source.Contains('图集本身不成为正式素材或透明通道证明')) 'Atlas route must not become a production asset or Alpha proof.'
Assert-True ($source.Contains('既有 ChatGPT Web 同一对话')) 'Transparent PNG route must reuse the existing ChatGPT Web conversation.'
Assert-True ($source.Contains('最小 `2×2` 或 `3×3` 透明图集')) 'VOX small-element atlas must support the smallest sufficient 2x2 or 3x3 transparent grid.'
Assert-True ($source.Contains('下载后先核验真实 Alpha')) 'Saved atlas Alpha must be verified before local crop.'
Assert-True ($source.Contains('默认优先纸白或暖白')) 'Source must retain paper white or warm white as the preferred outline.'
Assert-True ($source.Contains('而不是固定使用白色')) 'Source must make the cut-paper outline background-aware rather than permanently white.'
Assert-True ($source.Contains('题材服饰、年代、人物身份、朝向、动作、完整手脚与道具属于项目级 Asset Requirement')) 'Project-specific character constraints must not become global VOX constants.'
Assert-True ($source.Contains('D4D14110DA3914495DBD81ADFE8CD8CECAB47EB2057D11BBE1F63C234E9B4FE0')) 'User-provided history tutorial archive provenance is missing.'

$videoRoot = Join-Path $projectRoot 'video-production'
$router = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\production-router.md') -Raw
$planner = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\scene-clip-planner.md') -Raw
$manifest = Get-Content -LiteralPath (Join-Path $videoRoot 'contracts\production-manifest.md') -Raw
$audioContract = Get-Content -LiteralPath (Join-Path $videoRoot 'contracts\audio-production-contract.md') -Raw
$qa = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\qa-retry.md') -Raw
Assert-True ($router.Contains('does not require a generative Video Clip Prompt, provider submission, or the 6–14 second generative Clip default')) 'Production Router does not expose the bounded VOX Remotion local-assembly exemption.'
Assert-True ($planner.Contains('primary/secondary/tertiary') -and $planner.Contains('never auto-assigns z-order, size, entrance, opacity, motion amplitude, or a shared Y coordinate')) 'Scene planner does not preserve intent-driven layout semantics.'
Assert-True ($manifest.Contains('local_assembly_plan') -and $manifest.Contains('final_narration_master') -and $manifest.Contains('caption_output_owner')) 'Manifest projection is missing VOX layout or final-timeline fields.'
Assert-True ($audioContract.Contains('integer frames') -and $audioContract.Contains('one continuous read-only timing spine')) 'Audio contract does not bind final narration to integer-frame assembly.'
Assert-True ($qa.Contains('Static, dynamic, and compound motion are all eligible') -and $qa.Contains('Duplicate caption burn-in') -and $qa.Contains('Missing Alpha')) 'QA does not preserve both creative freedom and required quality failures.'

$mirrorPairs = @(
    'SKILL.md',
    'contracts\production-manifest.md',
    'contracts\audio-production-contract.md',
    'modules\production-router.md',
    'modules\scene-clip-planner.md',
    'modules\audio-production.md',
    'modules\asset-prompt-compiler.md',
    'modules\qa-retry.md'
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

$fixture = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'fixtures\vox-remotion-shot-intent-cases.json') -Raw | ConvertFrom-Json
$cases = @($fixture.cases)
Assert-True (($cases | Where-Object { $_.case_id -eq 'quiet-comparison-static' }).expected_contract_outcome -eq 'eligible') 'Static comparison positive case is missing.'
Assert-True (($cases | Where-Object { $_.case_id -eq 'relationship-build-dynamic' }).historical_zoom_reference_exceeded) 'Dynamic case must prove historical zoom guidance is not a cap.'
$compound = $cases | Where-Object { $_.case_id -eq 'evidence-reveal-compound' }
Assert-True ($compound.expected_contract_outcome -eq 'eligible' -and @($compound.camera_phases).Count -gt 1 -and @($compound.layer_events).Count -gt 1 -and -not $compound.curated_motion_example_membership) 'Compound case must allow multi-phase non-whitelisted motion.'
Assert-True (($cases | Where-Object { $_.case_id -eq 'intentional-closeup-crop' }).expected_contract_outcome -eq 'eligible') 'Intentional protected close-up crop positive case is missing.'
Assert-True (($cases | Where-Object { $_.case_id -eq 'missing-alpha-and-face-occlusion' }).expected_contract_outcome -eq 'must_fix') 'Alpha/occlusion negative case is missing.'
Assert-True (($cases | Where-Object { $_.case_id -eq 'duplicate-caption-and-stale-sfx' }).expected_contract_outcome -eq 'must_fix') 'Caption/SFX negative case is missing.'

Write-Output 'PASS: VOX v1.6 active source/normalized/registry contract, intent-driven static-dynamic-compound motion, open motion examples, flexible layout, pose inheritance, Remotion local-assembly route, final narration frame timeline, caption/SFX ownership, required alpha/occlusion failures, affected entry parity, history, provenance, and structural review fixtures are valid. Media quality is not proven.'
