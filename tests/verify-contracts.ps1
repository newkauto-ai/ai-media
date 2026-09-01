$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}

$testRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$topicPath = Join-Path $testRoot 'fixtures\topic-hunter-cases.json'
$scriptPath = Join-Path $testRoot 'fixtures\script-engine-cases.json'

$topicCases = (Get-Content -LiteralPath $topicPath -Raw | ConvertFrom-Json).cases
$scriptFixture = Get-Content -LiteralPath $scriptPath -Raw | ConvertFrom-Json
$scriptCases = $scriptFixture.cases
$scriptQualityCases = $scriptFixture.script_quality_review_cases

$controllerSkill = Get-Content -LiteralPath (Join-Path $testRoot '..\workflow-controller\SKILL.md') -Raw -Encoding UTF8
$specialistSkills = @(
    'topic-hunter\SKILL.md',
    'script-engine\SKILL.md',
    'audiovisual-director\SKILL.md',
    'video-production\SKILL.md',
    'publishing-packaging\SKILL.md'
)
$pluginManifest = Get-Content -LiteralPath (Join-Path $testRoot '..\.codex-plugin\plugin.json') -Raw -Encoding UTF8 | ConvertFrom-Json

Assert-True ($topicCases.Count -ge 3) 'Topic Hunter requires at least three real content directions.'
Assert-True ($scriptCases.Count -ge 3) 'Script Engine requires at least three selected-topic scripts.'
Assert-True ($scriptQualityCases.Count -ge 8) 'Script Quality Review Policy requires the eight minimum behavior fixtures.'

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

$allowedMustFix = @(
    'promise_unclear_or_mismatched', 'progression_missing', 'same_function_repetition',
    'causal_payoff_gap', 'promise_not_paid_off', 'conflict_not_functional',
    'tension_not_escalating', 'resolution_overpredictable', 'reveal_unsupported_or_random',
    'climax_without_build_or_release', 'emotional_turn_unearned', 'critical_dialogue_dependency'
)
$forbiddenReviewFields = @('tension_score', 'emotional_waveform', 'attention_budget', 'emotion_budget', 'comedy_budget', 'atmosphere_timeline', 'resonance_score', 'audience_prediction_score', 'beat_map', 'production_feasibility')
foreach ($case in $scriptQualityCases) {
    $review = $case.script_quality_review
    $assessment = $case.assessment
    Assert-True ($case.review_input.stage_0_approved -and $case.review_input.complete_draft) "$($case.case_id): Review requires Stage 0 approval and a complete Draft."
    Assert-True ($case.review_input.draft_status -eq 'draft' -and $case.review_input.review_position -eq 'before_freeze') "$($case.case_id): Review must run on an unfrozen Draft immediately before Freeze."
    Assert-True (@('lite','full') -contains $review.mode) "$($case.case_id): invalid Review mode."
    Assert-True (@('READY','REVISE') -contains $review.decision) "$($case.case_id): invalid human Review decision."
    Assert-True (@('none','local','structural') -contains $review.revision_scope) "$($case.case_id): invalid revision scope."
    Assert-True (@($review.must_fix).Count -le 3) "$($case.case_id): more than three Must Fix findings."
    Assert-True ($case.routing_expectation.max_retries -eq 1) "$($case.case_id): script_quality must use one automatic local-repair attempt."

    foreach ($finding in @($review.must_fix)) {
        Assert-True ($allowedMustFix -contains $finding.failure_type) "$($case.case_id): unsupported Must Fix type '$($finding.failure_type)'."
        Assert-True (-not [string]::IsNullOrWhiteSpace($finding.evidence)) "$($case.case_id): Must Fix requires specific evidence."
        Assert-True (-not [string]::IsNullOrWhiteSpace($finding.repair_target)) "$($case.case_id): Must Fix requires a repair target."
        Assert-True (@('script_engine','human_decision') -contains $finding.owner) "$($case.case_id): invalid Must Fix owner."
    }

    if (@($review.must_fix).Count -eq 0) {
        Assert-True ($review.decision -eq 'READY' -and $review.revision_scope -eq 'none') "$($case.case_id): no Must Fix must project READY/none."
        Assert-True ($assessment.verdict -eq 'pass' -and @($assessment.failure_types).Count -eq 0) "$($case.case_id): Optional-only or clean Review must map to pass, never retry."
        Assert-True ($review.stop_reason -eq 'STOP SCRIPT OPTIMIZATION') "$($case.case_id): READY must stop optimization."
    }
    if ($review.revision_scope -eq 'local') {
        Assert-True (@($review.must_fix).Count -gt 0) "$($case.case_id): local revise requires a Must Fix."
    }
    if ($review.revision_scope -eq 'structural') {
        Assert-True ($assessment.verdict -eq 'human_review' -and $assessment.affects_semantics) "$($case.case_id): structural revise must route to semantic human review."
        Assert-True (@($review.must_fix | Where-Object owner -eq 'human_decision').Count -gt 0) "$($case.case_id): structural revise requires human ownership."
    }

    $reviewSerialized = $review | ConvertTo-Json -Depth 10
    foreach ($field in $forbiddenReviewFields) {
        Assert-True ($reviewSerialized -notmatch ('"' + [regex]::Escape($field) + '"\s*:')) "$($case.case_id): Review persisted forbidden field '$field'."
    }
}

$liteCase = $scriptQualityCases | Where-Object case_id -eq 'lite-explainer-ready'
Assert-True (($liteCase.required_lenses -join ',') -eq 'promise,progression,payoff') 'Lite Review must not require dramatic or emotional lenses.'
$repetitionCase = $scriptQualityCases | Where-Object case_id -eq 'full-same-function-repetition'
Assert-True ($repetitionCase.script_quality_review.must_fix[0].failure_type -eq 'same_function_repetition' -and $repetitionCase.script_quality_review.revision_scope -eq 'local') 'Same-function repetition must target a local Script Engine repair.'
$slowCase = $scriptQualityCases | Where-Object case_id -eq 'full-slow-healing-ready'
Assert-True ($slowCase.script_quality_review.decision -eq 'READY') 'Slow healing content must not fail because action frequency is low.'
$emotionalCase = $scriptQualityCases | Where-Object case_id -eq 'full-emotional-promise-unpaid'
Assert-True ($emotionalCase.script_quality_review.must_fix[0].failure_type -eq 'emotional_turn_unearned') 'An uncaused emotional payoff must be identifiable.'
$exhaustedCase = $scriptQualityCases | Where-Object case_id -eq 'full-auto-retry-exhausted'
Assert-True ($exhaustedCase.routing_expectation.next -eq 'human_review' -and $exhaustedCase.routing_expectation.expected_retry_count -eq 1) 'A failed recheck must escalate without incrementing retry history.'

foreach ($requiredField in @('source_skill','task_scope','outcome','artifact_refs','review_refs','approval_state','unresolved_evidence','external_actions','recommended_next_action','controller_reobserve_required')) {
    Assert-True ($controllerSkill -match [regex]::Escape($requiredField)) "Controller Return Envelope is missing '$requiredField'."
}
Assert-True ($controllerSkill -match 'Start and resume reconciliation') 'Controller must define bounded start/resume reconciliation.'
Assert-True ($controllerSkill -match 'media-intake') 'Controller must define reported-media intake before Production QA.'
Assert-True ($controllerSkill -match 'one owning capability and one action') 'Controller must select only one owner and action.'
foreach ($relativePath in $specialistSkills) {
    $skillText = Get-Content -LiteralPath (Join-Path $testRoot ('..\' + $relativePath)) -Raw -Encoding UTF8
    Assert-True ($skillText -match '## Controller return') "$relativePath must define its return boundary."
    Assert-True ($skillText -match 'controller_return') "$relativePath must use the shared Controller Return Envelope."
    Assert-True ($skillText -match 'awaiting_controller_resume') "$relativePath must stop when Controller cannot be re-entered."
    Assert-True ($skillText -match 'Stop after the envelope') "$relativePath must not progress across Skills after returning."
}
Assert-True ($pluginManifest.interface.defaultPrompt.Count -eq 3) 'Plugin manifest must expose exactly the three UI-supported activation prompts.'
Assert-True ((@($pluginManifest.interface.defaultPrompt) -join "`n") -match '唯一下一步') 'Plugin manifest must expose a resume/next-action prompt.'
Assert-True ((@($pluginManifest.interface.defaultPrompt) -join "`n") -match '新 Clip') 'Plugin manifest must expose a reported-media Review prompt.'
Assert-True ((@($pluginManifest.interface.defaultPrompt) -join "`n") -match '上游剧本改版') 'Plugin manifest must expose a dependency-change prompt.'

Write-Output "PASS: $($topicCases.Count) Topic Hunter directions, $($scriptCases.Count) Script Engine handoffs, $($scriptQualityCases.Count) Script Quality Review cases, and five Specialist Controller-return boundaries satisfy the contracts."
