$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

$testRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$topicPath = Join-Path $testRoot 'fixtures\topic-hunter-cases.json'
$scriptPath = Join-Path $testRoot 'fixtures\script-engine-cases.json'

$topicCases = (Get-Content -LiteralPath $topicPath -Raw | ConvertFrom-Json).cases
$scriptCases = (Get-Content -LiteralPath $scriptPath -Raw | ConvertFrom-Json).cases

Assert-True ($topicCases.Count -ge 3) 'Topic Hunter requires at least three real content directions.'
Assert-True ($scriptCases.Count -ge 3) 'Script Engine requires at least three selected-topic scripts.'

$selectedTopicIds = @()
foreach ($case in $topicCases) {
    $output = $case.output
    Assert-True ($case.candidate_titles.Count -ge 20 -and $case.candidate_titles.Count -le 30) "$($case.case_id): candidate list must contain 20-30 topics."
    Assert-True ($output.candidate_count -eq $case.candidate_titles.Count) "$($case.case_id): candidate_count mismatch."
    Assert-True ($output.recommendations.Count -eq 3) "$($case.case_id): output must contain exactly Top 3."
    $ranks = @($output.recommendations | ForEach-Object { $_.rank })
    Assert-True (($ranks -join ',') -eq '1,2,3') "$($case.case_id): ranks must be 1,2,3."
    Assert-True ($output.selected_topic_id -eq $output.recommendations[0].topic_id) "$($case.case_id): selected topic must be rank 1."

    foreach ($rec in $output.recommendations) {
        $thesis = $rec.topic_thesis
        Assert-True (-not [string]::IsNullOrWhiteSpace($thesis.core_thesis)) "$($rec.topic_id): missing core_thesis."
        Assert-True (-not [string]::IsNullOrWhiteSpace($thesis.user_desire_or_need.primary)) "$($rec.topic_id): missing primary user driver."
        Assert-True (-not [string]::IsNullOrWhiteSpace($thesis.concrete_scenario)) "$($rec.topic_id): missing concrete scenario."
        Assert-True (-not [string]::IsNullOrWhiteSpace($thesis.intended_state_change.from) -and -not [string]::IsNullOrWhiteSpace($thesis.intended_state_change.to)) "$($rec.topic_id): missing state change."
        Assert-True (@('share','comment','save') -contains $thesis.propagation_motive.primary_action) "$($rec.topic_id): invalid propagation action."
        Assert-True (-not [string]::IsNullOrWhiteSpace($thesis.unique_supply)) "$($rec.topic_id): missing unique supply."
        Assert-True ($rec.gate_1.clear_dimensions -ge 4 -and $rec.gate_1.result -eq 'pass') "$($rec.topic_id): Top 3 must pass Gate 1."
        $score = $rec.content_potential_score
        $sum = $score.conflict + $score.curiosity + $score.reversal + $score.resonance + $score.extension
        Assert-True ($score.total -eq $sum -and $score.total -le 10) "$($rec.topic_id): score total must be transparent 10-point arithmetic."
        Assert-True (@('high','medium','low') -contains $rec.click_trigger) "$($rec.topic_id): invalid click trigger."
        Assert-True (@('high','medium','low') -contains $rec.ai_production_difficulty) "$($rec.topic_id): invalid production difficulty."
    }
    $selectedTopicIds += $output.selected_topic_id
}

$forbiddenDownstreamFields = @('audiovisual_beats', 'storyboard', 'model_prompts', 'generated_assets', 'audiovisual_direction_package')
foreach ($case in $scriptCases) {
    Assert-True ($selectedTopicIds -contains $case.selected_topic_id) "$($case.case_id): script topic was not selected by a Topic Hunter fixture."
    $result = $case.script_engine_output
    $input3 = $result.skill3_input
    Assert-True ($result.contract_version -eq '1.0') "$($case.case_id): wrong contract version."
    Assert-True ($input3.frozen_script.status -eq 'frozen') "$($case.case_id): script is not frozen."
    Assert-True ($input3.frozen_script.estimated_duration_seconds -ge 60 -and $input3.frozen_script.estimated_duration_seconds -le 90) "$($case.case_id): estimated duration outside 60-90 seconds."
    foreach ($section in @('hook','conflict','escalation','reveal','meaning')) {
        Assert-True (-not [string]::IsNullOrWhiteSpace($input3.frozen_script.sections.$section)) "$($case.case_id): missing H-C-E-R-M section $section."
    }
    Assert-True ($result.audit.hook_candidates.Count -ge 5) "$($case.case_id): requires at least five hook candidates."
    Assert-True ($result.audit.compression_checks.background_filler_removed -and $result.audit.compression_checks.duplicate_explanations_removed -and $result.audit.compression_checks.non_visual_abstractions_removed) "$($case.case_id): compression gate failed."
    Assert-True ($result.audit.retention_review.five_second_death_test -eq 'pass') "$($case.case_id): five-second death test failed."
    $manifest = $input3.production_handoff_manifest
    Assert-True ($manifest.major_character_count -ge 1 -and $manifest.major_character_count -le 3) "$($case.case_id): character count outside preferred MVP range."
    Assert-True ($manifest.core_scene_count -ge 3 -and $manifest.core_scene_count -le 6) "$($case.case_id): core scene count outside preferred MVP range."
    Assert-True ($manifest.visual_beat_count -ge 8 -and $manifest.visual_beat_count -le 12) "$($case.case_id): visual beat envelope outside preferred MVP range."
    Assert-True (@('low','medium','high') -contains $manifest.production_complexity) "$($case.case_id): invalid production complexity."
    $serialized = $result | ConvertTo-Json -Depth 20
    foreach ($field in $forbiddenDownstreamFields) {
        Assert-True ($serialized -notmatch ('"' + [regex]::Escape($field) + '"\s*:')) "$($case.case_id): upstream output crossed into downstream field '$field'."
    }
}

Write-Output "PASS: $($topicCases.Count) Topic Hunter directions and $($scriptCases.Count) Script Engine handoffs satisfy the Skill 1-2 contracts and downstream boundary checks."
