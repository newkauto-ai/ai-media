$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

$projectRoot = Split-Path -Parent $PSScriptRoot
$libraryRoot = Join-Path $projectRoot 'style-profiles'
$registry = Get-Content -LiteralPath (Join-Path $libraryRoot 'registry.json') -Raw | ConvertFrom-Json
$entries = @($registry.profiles | Where-Object profile_id -eq 'oriental_pastoral_cinematic_lifestyle')
Assert-True ($entries.Count -eq 1) 'Pastoral Style Profile must resolve to one stable registry entry.'
$entry = $entries[0]
Assert-True ($entry.source_file -eq 'Style_Profile_田园风_v1.2_诗意工艺蒙太奇.md') 'Pastoral registry source must be v1.2 poetic craft montage.'
Assert-True ($entry.normalized_file -eq 'oriental_pastoral_cinematic_lifestyle.v1.2-zh.json' -and $entry.normalized_version -eq 'v1.2-zh') 'Pastoral registry must route to normalized v1.2-zh.'
Assert-True ($entry.status -eq 'pending_review') 'Pastoral must remain pending_review until real LookDev/Pilot acceptance.'

$sourcePath = Join-Path (Join-Path $libraryRoot 'source') $entry.source_file
$normalizedPath = Join-Path (Join-Path $libraryRoot 'normalized') $entry.normalized_file
Assert-True (Test-Path -LiteralPath $sourcePath) 'Pastoral v1.2 source is missing.'
Assert-True (Test-Path -LiteralPath $normalizedPath) 'Pastoral v1.2 normalized profile is missing.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'source\Style_Profile_田园风_v1.1_中文解析.md')) 'Pastoral v1.1 source history must be retained.'
Assert-True (Test-Path -LiteralPath (Join-Path $libraryRoot 'normalized\oriental_pastoral_cinematic_lifestyle.v1.1-zh.json')) 'Pastoral v1.1 normalized history must be retained.'
$sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourcePath).Hash
Assert-True ($sourceHash -eq $entry.source_sha256) 'Pastoral source hash must match registry provenance.'

$source = Get-Content -LiteralPath $sourcePath -Raw
$normalized = Get-Content -LiteralPath $normalizedPath -Raw | ConvertFrom-Json
$profile = $normalized.style_profile
$av = $profile.audiovisual_modules
$production = $profile.production_modules
Assert-True ($normalized.normalized_from_source -eq $entry.source_file) 'Pastoral normalized source binding is stale.'
Assert-True ($profile.style_id -eq 'oriental_pastoral_cinematic_lifestyle' -and $profile.version -eq 'v1.2-zh') 'Pastoral stable identity or v1.2 version is invalid.'
Assert-True ($profile.provenance.source_sha256 -eq $sourceHash) 'Pastoral normalized provenance hash must match the source.'
Assert-True (($profile.provenance.source_documents | Where-Object version -eq 'v1.1-zh').Count -eq 1 -and ($profile.provenance.source_documents | Where-Object version -eq 'v1.2-zh').Count -eq 1) 'Pastoral provenance must retain v1.1 and add v1.2.'

Assert-True ($profile.pre_content_modules.story_direction.value -match '局部动作.*意境呼吸.*成果递进') 'Pastoral v1.2 story direction must use poetic craft montage progression.'
Assert-True ((@($av.shot_design.craft_shot_types) -join '|') -eq 'atmosphere_shot|process_detail_shot|progression_shot') 'Pastoral v1.2 craft shot types are incomplete or reordered.'
Assert-True ($null -eq $av.shot_design.non_craft_default) 'Non-craft pastoral shots must not be forced into the craft montage classification.'
Assert-True (-not $av.process_detail.single_shot_tutorial_closure_required -and $av.process_detail.value -match '跨镜头') 'Pastoral process detail must allow bounded local action and cross-shot process truth.'
Assert-True ($av.process_continuity.value -eq 'previous_result_equals_next_input' -and $av.process_continuity.may_span_multiple_shots) 'Pastoral process continuity must stay truthful across shots.'
Assert-True (@($av.process_continuity.prohibit) -contains 'magic_growth' -and @($av.process_continuity.prohibit) -contains 'full_frame_morph') 'Pastoral progression must prohibit magic growth and full-frame morph.'
Assert-True ($av.editing_rhythm.decision_mode -eq 'adaptive_sequence_design' -and $null -eq $av.editing_rhythm.fixed_pattern -and $null -eq $av.editing_rhythm.fixed_ratio) 'Pastoral rhythm must be adaptive without a fixed pattern or ratio.'
Assert-True ((@($av.editing_rhythm.decision_inputs) -join '|') -eq 'narrative_intent|process_complexity|material_state_change|information_density|human_space_relationship|music_emotional_arc|breathing_need|visible_completion_delta') 'Pastoral adaptive rhythm inputs are incomplete.'
Assert-True ($av.editing_rhythm.atmosphere_insertion -eq 'only_when_it_has_a_specific_narrative_function' -and $av.editing_rhythm.character_process_interleaving -eq 'optional_when_it_serves_the_story') 'Pastoral rhythm must not force atmosphere insertion or human/process alternation.'
Assert-True ($av.editing_rhythm.atmosphere_is_formal_story_node) 'Pastoral atmosphere shots must be formal story nodes.'
Assert-True (@($av.content_guardrails.avoid) -contains 'beauty_environment_product_shell' -and @($av.content_guardrails.avoid) -contains 'precise_tutorial_reconstruction') 'Pastoral content guardrails must reject empty beauty shells and precise tutorial reconstruction.'

Assert-True ($production.prompt_compilation.require_pastoral_craft_shot_type -eq 'when_craft_montage_applies') 'Pastoral Prompt compilation must bind the craft shot type when applicable.'
Assert-True ($production.prompt_compilation.require_breathing_shot_note -eq 'when_atmosphere_shot') 'Pastoral atmosphere Prompt must bind its breathing function.'
Assert-True ($production.prompt_compilation.require_completion_delta -eq 'when_progression_shot') 'Pastoral progression Prompt must bind a completion delta.'
Assert-True ($production.prompt_compilation.allow_match_cut_or_visual_echo -eq 'when_grounded_by_project_states') 'Pastoral match cut/visual echo must remain project-grounded.'
Assert-True ($production.prompt_compilation.prohibit_magic_growth_or_full_frame_morph) 'Pastoral Prompt compilation must prohibit magic growth and full-frame morph.'
Assert-True ($production.storyboard_planning.rhythm_decision_mode -eq 'adaptive_sequence_design' -and $null -eq $production.storyboard_planning.fixed_pattern -and $null -eq $production.storyboard_planning.fixed_ratio) 'Pastoral Storyboard rhythm must remain adaptive without a fixed pattern or ratio.'
Assert-True ((@($production.storyboard_planning.output_fields) -join '|') -eq 'pastoral_craft_shot_type|breathing_shot_note|prior_process_state_ref|current_process_state|completion_delta|match_cut_or_visual_echo') 'Pastoral output template fields are incomplete.'

Assert-True ($source.Contains('意境镜头、工艺镜头、成果递进镜头共同承担叙事')) 'Pastoral source must define the three-way montage structure.'
Assert-True ($source.Contains('adaptive_sequence_design') -and $source.Contains('不采用固定镜头比例、固定排序或默认交替公式')) 'Pastoral source must define adaptive rhythm design.'
Assert-True (-not $source.Contains('suggested_pattern') -and -not $source.Contains('two_process_detail_then_one_atmosphere')) 'Pastoral source must not retain a removed fixed rhythm default.'
Assert-True ($source.Contains('不要求一个 Shot 复现复杂工序闭环') -and $source.Contains('不得用整图 morph 代替工艺过程')) 'Pastoral source must bound single-shot process detail and progression effects.'
Assert-True ($source.Contains('不是通用 Style Core 的硬编码默认值')) 'Pastoral source must not hard-code Jiangnan/Hanfu/craft examples into Style Core.'

$videoRoot = Join-Path $projectRoot 'video-production'
$planner = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\scene-clip-planner.md') -Raw
$storyboard = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\storyboard-keyframe-planner.md') -Raw
$clipCompiler = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\clip-prompt-compiler.md') -Raw
$assetCompiler = Get-Content -LiteralPath (Join-Path $videoRoot 'modules\asset-prompt-compiler.md') -Raw
$manifest = Get-Content -LiteralPath (Join-Path $videoRoot 'contracts\production-manifest.md') -Raw
Assert-True ($planner.Contains('pastoral_craft_shot_type') -and $planner.Contains('breathing_shot_note') -and $planner.Contains('completion_delta')) 'Scene planner is missing the Pastoral craft output projection.'
Assert-True ($planner.Contains('Design the rhythm adaptively') -and $planner.Contains('Do not apply a fixed shot ratio, default sequence, or mandatory') -and $planner.Contains('keywords alone are examples, not proof')) 'Scene planner must preserve adaptive-rhythm and evidence boundaries.'
Assert-True ($storyboard.Contains('beauty + environment + finished product') -and $storyboard.Contains('no fixed ratio, default sequence, or mandatory alternation')) 'Storyboard review lacks adaptive Pastoral rhythm checks.'
Assert-True ($clipCompiler.Contains('credible bounded local action') -and $clipCompiler.Contains('full-frame morphing') -and $clipCompiler.Contains('without encoding or inventing any fixed shot ratio')) 'Clip Prompt Compiler lacks Pastoral process/progression or adaptive-rhythm guidance.'
Assert-True ($assetCompiler.Contains('pastoral_craft_shot_type') -and $assetCompiler.Contains('universal Style constant')) 'Asset Prompt Compiler lacks Pastoral craft routing or project-grounding boundary.'
Assert-True ($manifest.Contains('pastoral_craft_montage projection') -and $manifest.Contains('no fixed ratio, default sequence, mandatory alternation')) 'Production Manifest lacks the optional adaptive Pastoral Scene/Shot projection boundary.'

$mirrorPairs = @(
    'modules\scene-clip-planner.md',
    'modules\storyboard-keyframe-planner.md',
    'modules\clip-prompt-compiler.md',
    'modules\asset-prompt-compiler.md',
    'contracts\production-manifest.md'
)
foreach ($relativePath in $mirrorPairs) {
    $rootText = (Get-Content -LiteralPath (Join-Path $videoRoot $relativePath) -Raw).Replace("`r`n", "`n")
    $skillText = (Get-Content -LiteralPath (Join-Path (Join-Path $projectRoot 'skills\video-production') $relativePath) -Raw).Replace("`r`n", "`n")
    Assert-True ($rootText -eq $skillText) "Pastoral affected entry mirror drift: $relativePath"
}

$fixture = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'fixtures\pastoral-craft-montage-cases.json') -Raw | ConvertFrom-Json
Assert-True ($fixture.fixture_only) 'Pastoral craft fixtures must remain fixture-only.'
$caseA = @($fixture.cases | Where-Object case_id -eq 'A-embroidery-poetic-montage')[0]
$caseB = @($fixture.cases | Where-Object case_id -eq 'B-five-consecutive-craft-macros')[0]
$caseC = @($fixture.cases | Where-Object case_id -eq 'C-single-shot-complex-tutorial-loop')[0]
$caseD = @($fixture.cases | Where-Object case_id -eq 'D-stage-progression-without-morph')[0]
$caseE = @($fixture.cases | Where-Object case_id -eq 'E-beauty-environment-finished-product-shell')[0]
$caseF = @($fixture.cases | Where-Object case_id -eq 'F-non-craft-pastoral')[0]
$caseG = @($fixture.cases | Where-Object case_id -eq 'G-process-led-no-atmosphere-needed')[0]
Assert-True ($caseA.expected -eq 'valid' -and (@($caseA.shots.pastoral_craft_shot_type | Sort-Object -Unique) -join '|') -eq 'atmosphere_shot|process_detail_shot|progression_shot') 'Valid Pastoral three-way montage fixture is incomplete.'
Assert-True ($caseB.expected -eq 'must_fix_repetitive_craft_macro' -and -not $caseB.human_atmosphere_or_progression_present) 'Consecutive craft macro regression fixture is invalid.'
Assert-True ($caseC.expected -eq 'must_fix_single_shot_tutorial_overreach' -and $caseC.tutorial_closure) 'Single-shot tutorial overreach fixture is invalid.'
Assert-True ($caseD.expected -eq 'valid' -and $caseD.completion_delta -and -not $caseD.magic_growth -and -not $caseD.full_frame_morph) 'Stage progression fixture is invalid.'
Assert-True ($caseE.expected -eq 'must_fix_empty_craft_shell' -and -not $caseE.credible_process_detail_present -and -not $caseE.progression_evidence_present) 'Beauty/environment/product shell fixture is invalid.'
Assert-True ($caseF.expected -eq 'valid_non_craft_unchanged' -and $null -eq $caseF.pastoral_craft_shot_type -and -not $caseF.craft_montage_required) 'Non-craft Pastoral behavior must remain unchanged.'
Assert-True ($caseG.expected -eq 'valid_adaptive_sequence' -and -not $caseG.atmosphere_function_needed -and -not $caseG.fixed_pattern_applied -and -not (@($caseG.shots.pastoral_craft_shot_type) -contains 'atmosphere_shot')) 'Adaptive Pastoral rhythm must allow a grounded sequence without a forced atmosphere shot.'

Write-Output 'PASS: Pastoral v1.2 poetic craft montage, three shot types, adaptive rhythm without a fixed pattern, truthful cross-shot progression, prompt/storyboard projection, non-craft compatibility, provenance, mirrors, and structural fixtures are valid. Visual quality, craft-fact accuracy, provider execution, runtime loading, and human approval are not proven.'
