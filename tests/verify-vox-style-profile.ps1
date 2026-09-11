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
Assert-True ($entry.source_file -eq 'Style_Profile_VOX编辑纸拼贴讲解动画_v1.4_真实生产经验整合.md') 'VOX registry source must be v1.4.'
Assert-True ($entry.normalized_file -eq 'transcript_driven_handmade_collage.v1.4-zh.json') 'VOX registry normalized file must be v1.4.'
Assert-True ($entry.normalized_version -eq 'v1.4-zh') 'VOX registry version must be v1.4-zh.'
Assert-True ($entry.status -eq 'ready') 'VOX registry status must remain ready.'

$sourcePath = Join-Path (Join-Path $libraryRoot 'source') $entry.source_file
$normalizedPath = Join-Path (Join-Path $libraryRoot 'normalized') $entry.normalized_file
Assert-True (Test-Path -LiteralPath $sourcePath) 'VOX v1.4 source file is missing.'
Assert-True (Test-Path -LiteralPath $normalizedPath) 'VOX v1.4 normalized file is missing.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'source\Style_Profile_VOX编辑纸拼贴讲解动画_v1.2_中文整合.md')) 'Historical VOX v1.2 source must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'normalized\transcript_driven_handmade_collage.v1.2-zh.json')) 'Historical VOX v1.2 normalized profile must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'source\Style_Profile_VOX编辑纸拼贴讲解动画_v1.3_教程与动效整合.md')) 'Historical VOX v1.3 source must be preserved.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'normalized\transcript_driven_handmade_collage.v1.3-zh.json')) 'Historical VOX v1.3 normalized profile must be preserved.'
Assert-True ((Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash -eq $entry.source_sha256) 'VOX source hash does not match the registry.'

$source = Get-Content -LiteralPath $sourcePath -Raw
$normalized = Get-Content -LiteralPath $normalizedPath -Raw | ConvertFrom-Json
$profile = $normalized.style_profile

Assert-True ($profile.style_id -eq 'vox_transcript_driven_handmade_collage') 'VOX normalized stable ID changed.'
Assert-True ($profile.version -eq 'v1.4-zh') 'VOX normalized version must be v1.4-zh.'
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

Assert-True ($source.Contains('https://www.youtube.com/watch?v=7wuYBfE131U')) 'Tutorial provenance URL is missing from the VOX source.'
Assert-True ($source.Contains('https://github.com/Vincentwei1021/video-shotcraft')) 'video-shotcraft provenance URL is missing from the VOX source.'
Assert-True ($source.Contains('推荐本地配方：Remotion + 外部旁白导入')) 'Remotion and imported narration recipe is missing from the VOX source.'
Assert-True ($source.Contains('一个镜头只让一种动效当主角')) 'One-hero-motion guidance is missing from the VOX source.'
Assert-True ($source.Contains('默认镜头是静止')) 'Static-default camera guidance is missing from the VOX source.'
Assert-True ($source.Contains('不固定像素值或唯一算法')) 'Multi-card layout must not freeze a unique vertical-gap algorithm.'
Assert-True ($source.Contains('不自动裁切、不自动抠图')) 'Atlas route must stop before automatic cutting or alpha claims.'

Write-Output 'PASS: VOX v1.4 source, normalized contract, v1.2/v1.3 history, stable routing ID, Remotion recipe, manual-cutout boundary, static camera, flexible card alignment, and provenance are valid.'
