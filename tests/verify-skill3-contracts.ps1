$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

$testRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$fixtureRoot = Join-Path $testRoot 'fixtures'

$soft = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'style-profile-soft-cute-3d.fixture.json') -Raw | ConvertFrom-Json)
$hand = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'style-profile-hand-drawn-growth.fixture.json') -Raw | ConvertFrom-Json)
$adp = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'audiovisual-director-xiyouji.fixture.json') -Raw | ConvertFrom-Json).audiovisual_direction_package
$scriptCases = (Get-Content -LiteralPath (Join-Path $fixtureRoot 'script-engine-cases.json') -Raw | ConvertFrom-Json).cases
$sourceScript = ($scriptCases | Where-Object { $_.selected_topic_id -eq 'xyj-001' }).script_engine_output.skill3_input

foreach ($fixture in @($soft, $hand)) {
    Assert-True $fixture.fixture_only 'Normalized Style Profile test inputs must be marked fixture_only.'
    $profile = $fixture.style_profile
    Assert-True (-not [string]::IsNullOrWhiteSpace($profile.style_id)) 'Style Profile missing style_id.'
    Assert-True (@($profile.pre_content_modules.PSObject.Properties).Count -gt 0) "$($profile.style_id): missing pre-content modules."
    Assert-True (@($profile.audiovisual_modules.PSObject.Properties).Count -gt 0) "$($profile.style_id): missing audiovisual modules."
    Assert-True (@($profile.production_modules.PSObject.Properties).Count -gt 0) "$($profile.style_id): missing production modules."
    Assert-True ($profile.provenance.source_documents.Count -gt 0) "$($profile.style_id): missing provenance."
}

Assert-True ($soft.style_profile.classification -eq 'hybrid_style_profile') 'Soft-cute source must normalize as hybrid_style_profile.'
Assert-True ($hand.style_profile.classification -eq 'narrative_style_bible') 'Hand-drawn source must normalize as narrative_style_bible.'

Assert-True ($adp.contract_version -eq '1.1') 'ADP must use downstream-compatible contract v1.1.'
Assert-True ($adp.meta.script_id -eq $sourceScript.frozen_script.script_id) 'ADP script_id does not match frozen upstream script.'
Assert-True ($adp.semantic_locks.core_thesis -eq $sourceScript.frozen_script.semantic_locks.core_thesis) 'ADP changed the frozen core thesis.'
Assert-True ($adp.semantic_locks.hook -eq $sourceScript.frozen_script.semantic_locks.hook) 'ADP changed the frozen Hook lock.'
Assert-True ($adp.semantic_locks.reveal -eq $sourceScript.frozen_script.semantic_locks.reveal) 'ADP changed the frozen Reveal lock.'
Assert-True ($adp.semantic_locks.core_conclusion -eq $sourceScript.frozen_script.semantic_locks.core_conclusion) 'ADP changed the frozen conclusion.'

$loadedExpected = @($hand.style_profile.audiovisual_modules.PSObject.Properties.Name)
$upstreamExpected = @($hand.style_profile.pre_content_modules.PSObject.Properties.Name)
$ignoredExpected = @($hand.style_profile.production_modules.PSObject.Properties.Name)
foreach ($name in $loadedExpected) { Assert-True ($adp.style_resolution.loaded_modules -contains $name) "Audiovisual Router failed to load '$name'." }
foreach ($name in $upstreamExpected) { Assert-True ($adp.style_resolution.routed_upstream_modules -contains $name) "Pre-Content Router failed to route '$name'." }
foreach ($name in $ignoredExpected) { Assert-True ($adp.style_resolution.ignored_production_modules -contains $name) "Production boundary failed to ignore '$name'." }
Assert-True ($adp.style_resolution.conflicts.code -contains 'UPSTREAM-CONSTRAINT-LATE') 'Late pre-content constraint must be flagged, not silently applied.'

Assert-True (@($adp.style_blueprint.global_visual_dna.PSObject.Properties).Count -gt 0) 'Skill 4 v1.1 compatibility requires global_visual_dna.'
Assert-True ($adp.style_blueprint.visual_domains.Count -ge 1) 'Skill 4 v1.1 compatibility requires visual_domains.'
Assert-True ($adp.character_voice_bible.Count -ge 1) 'ADP missing Character & Voice Bible.'
Assert-True ($adp.asset_plan.characters.Count -ge 1 -and $adp.asset_plan.scenes.Count -ge 1) 'ADP missing reusable asset plan.'
Assert-True ($adp.audiovisual_beats.Count -ge 8 -and $adp.audiovisual_beats.Count -le 12) 'ADP must contain 8-12 Audiovisual Beats for the first round.'

$requiredBeatFields = @('beat_id','script_reference','story_function','narration_or_dialogue','visual','performance','audio','music','assets','continuity','production')
foreach ($beat in $adp.audiovisual_beats) {
    foreach ($field in $requiredBeatFields) {
        Assert-True ($beat.PSObject.Properties.Name -contains $field) "$($beat.beat_id): missing field '$field'."
    }
    Assert-True (-not [string]::IsNullOrWhiteSpace($beat.continuity.expected_end_state)) "$($beat.beat_id): missing expected_end_state."
}

Assert-True ($adp.sound_cue_plan.Count -ge 1) 'ADP missing Sound Cue Plan.'
Assert-True (@($adp.music.music_brief.PSObject.Properties).Count -gt 0) 'ADP missing Music Brief.'
Assert-True (-not [string]::IsNullOrWhiteSpace($adp.music.suno_prompt)) 'ADP missing Suno Prompt.'
Assert-True (@($adp.continuity_plan.PSObject.Properties).Count -gt 0) 'ADP missing Continuity Plan.'
Assert-True (@($adp.template_bindings.PSObject.Properties).Count -gt 0) 'ADP missing semantic Template Bindings.'

$lookdev = $adp.production_handoff.lookdev_test_spec
Assert-True ($lookdev.anchor_count -ge 3 -and $lookdev.anchor_count -le 5) 'LookDev Test Spec must contain 3-5 anchors.'
Assert-True ($lookdev.anchor_count -eq $lookdev.anchors.Count) 'LookDev anchor_count mismatch.'
Assert-True $lookdev.human_approval_required 'First style/domain LookDev must require human approval.'
$requiredDimensions = @('global_style','domain_identity','world_scale','story_usability','reference_usability')
foreach ($dimension in $requiredDimensions) { Assert-True ($lookdev.validation_dimensions -contains $dimension) "LookDev missing '$dimension'." }

$serialized = $adp | ConvertTo-Json -Depth 30
foreach ($field in @('actual_end_state','generated_assets','executable_prompt','qa_results','retry_result','final_master')) {
    Assert-True ($serialized -notmatch ('"' + [regex]::Escape($field) + '"\s*:')) "Skill 3 crossed into Skill 4 field '$field'."
}
foreach ($productionSyntax in @('Seedance','GPT Image','Nano Banana','MultiModalToVideo','480p','<<<image_')) {
    Assert-True ($serialized -notmatch [regex]::Escape($productionSyntax)) "ADP leaked model-specific production syntax '$productionSyntax'."
}

Write-Output 'PASS: 2 source-normalized Style Profiles routed correctly; 1 real frozen-script ADP satisfies semantic locks, 8-12 Beat coverage, Skill 4 v1.1 handoff fields, and production boundaries.'
