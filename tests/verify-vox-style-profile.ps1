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
Assert-True ($entry.source_file -eq 'Style_Profile_VOX编辑纸拼贴讲解动画_v1.5_背景感知剪纸轮廓.md') 'VOX registry source must be v1.5.'
Assert-True ($entry.normalized_file -eq 'transcript_driven_handmade_collage.v1.5-zh.json') 'VOX registry normalized file must be v1.5.'
Assert-True ($entry.normalized_version -eq 'v1.5-zh') 'VOX registry version must be v1.5-zh.'
Assert-True ($entry.status -eq 'ready') 'VOX registry status must remain ready.'

$sourcePath = Join-Path (Join-Path $libraryRoot 'source') $entry.source_file
$normalizedPath = Join-Path (Join-Path $libraryRoot 'normalized') $entry.normalized_file
Assert-True (Test-Path -LiteralPath $sourcePath) 'VOX v1.5 source file is missing.'
Assert-True (Test-Path -LiteralPath $normalizedPath) 'VOX v1.5 normalized file is missing.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'source\Style_Profile_VOX编辑纸拼贴讲解动画_v1.2_中文整合.md')) 'Historical VOX v1.2 source must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'normalized\transcript_driven_handmade_collage.v1.2-zh.json')) 'Historical VOX v1.2 normalized profile must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'source\Style_Profile_VOX编辑纸拼贴讲解动画_v1.3_教程与动效整合.md')) 'Historical VOX v1.3 source must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'normalized\transcript_driven_handmade_collage.v1.3-zh.json')) 'Historical VOX v1.3 normalized profile must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'source\Style_Profile_VOX编辑纸拼贴讲解动画_v1.4_真实生产经验整合.md')) 'Historical VOX v1.4 source must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'normalized\transcript_driven_handmade_collage.v1.4-zh.json')) 'Historical VOX v1.4 normalized profile must be preserved.'
Assert-True ((Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash -eq $entry.source_sha256) 'VOX source hash does not match the registry.'

$source = Get-Content -LiteralPath $sourcePath -Raw
$normalized = Get-Content -LiteralPath $normalizedPath -Raw | ConvertFrom-Json
$profile = $normalized.style_profile

Assert-True ($profile.style_id -eq 'vox_transcript_driven_handmade_collage') 'VOX normalized stable ID changed.'
Assert-True ($profile.version -eq 'v1.5-zh') 'VOX normalized version must be v1.5-zh.'
Assert-True ($profile.production_modules.recommended_local_recipe.engine -eq 'remotion') 'VOX default local recipe must use Remotion.'
Assert-True ($profile.production_modules.recommended_local_recipe.narration_source -eq 'external_audio_tool_then_import_final_audio') 'VOX narration must support externally generated imported audio.'
Assert-True (-not $profile.production_modules.recommended_local_recipe.hyperframes_default) 'HyperFrames must not be the VOX default engine.'
Assert-True ($profile.audiovisual_modules.motion_discipline.hero_rule -eq 'one_primary_motion_language_per_shot') 'VOX must retain the one-hero-motion rule.'
Assert-True (@($profile.audiovisual_modules.curated_motion_vocabulary.PSObject.Properties).Count -eq 6) 'VOX must expose the six curated paper-print motion families.'
Assert-True ($profile.audiovisual_modules.motion_discipline.determinism -match 'fixed_seed') 'VOX procedural visuals must be deterministic.'
Assert-True ($profile.audiovisual_modules.sound_direction.narration -match 'externally_generated_imported_final_audio') 'Imported final narration must remain the timing spine.'
Assert-True ($profile.provenance.review_boundary.video_shotcraft_product_promo_workflow_is_not_a_vox_default) 'Product-promo workflow boundary must remain explicit.'
Assert-True ($profile.audiovisual_modules.motion_discipline.default_camera -match 'static_by_default') 'VOX camera must default to static rather than a full-frame push-in.'
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
Assert-True ($source.Contains('一个镜头只让一种动效当主角')) 'One-hero-motion guidance is missing from the VOX source.'
Assert-True ($source.Contains('默认镜头是静止')) 'Static-default camera guidance is missing from the VOX source.'
Assert-True ($source.Contains('不固定像素值或唯一算法')) 'Multi-card layout must not freeze a unique vertical-gap algorithm.'
Assert-True ($source.Contains('图集本身不成为正式素材或透明通道证明')) 'Atlas route must not become a production asset or Alpha proof.'
Assert-True ($source.Contains('既有 ChatGPT Web 同一对话')) 'Transparent PNG route must reuse the existing ChatGPT Web conversation.'
Assert-True ($source.Contains('最小 `2×2` 或 `3×3` 透明图集')) 'VOX small-element atlas must support the smallest sufficient 2x2 or 3x3 transparent grid.'
Assert-True ($source.Contains('下载后先核验真实 Alpha')) 'Saved atlas Alpha must be verified before local crop.'
Assert-True ($source.Contains('默认优先纸白或暖白')) 'Source must retain paper white or warm white as the preferred outline.'
Assert-True ($source.Contains('而不是固定使用白色')) 'Source must make the cut-paper outline background-aware rather than permanently white.'
Assert-True ($source.Contains('题材服饰、年代、人物身份、朝向、动作、完整手脚与道具属于项目级 Asset Requirement')) 'Project-specific character constraints must not become global VOX constants.'
Assert-True ($source.Contains('D4D14110DA3914495DBD81ADFE8CD8CECAB47EB2057D11BBE1F63C234E9B4FE0')) 'User-provided history tutorial archive provenance is missing.'

Write-Output 'PASS: VOX v1.5 source, normalized contract, v1.2-v1.4 history, stable routing ID, background-aware cut-paper outline, Remotion recipe, ChatGPT Web transparent 2x2/3x3 atlas boundary, bounded crop tool, static camera, flexible card alignment, and provenance are valid.'
