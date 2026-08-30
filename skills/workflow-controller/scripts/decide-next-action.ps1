[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $InputPath -PathType Leaf)) { throw "Input not found: $InputPath" }
$inputState = Get-Content -LiteralPath $InputPath -Raw -Encoding UTF8 | ConvertFrom-Json
$unit = $inputState.unit
$assessmentProperty = $inputState.PSObject.Properties['assessment']
$reviewProperty = $inputState.PSObject.Properties['review_result']
$assessment = if ($null -ne $assessmentProperty) { $assessmentProperty.Value } else { $null }
$reviewResult = if ($null -ne $reviewProperty) { $reviewProperty.Value } else { $null }
$reviewGate = $null

if ($null -ne $reviewResult) {
    foreach ($field in @('schema_version', 'review_id', 'gate', 'target', 'lineage', 'provenance', 'findings', 'decision', 'controller_mapping', 'retry_snapshot')) {
        if ($null -eq $reviewResult.PSObject.Properties[$field] -or $null -eq $reviewResult.$field) { throw "review_result.$field is required." }
    }
    $reviewGate = [string]$reviewResult.gate
    if ([string]$reviewResult.schema_version -ne '2.1' -or $reviewGate -notin @('pre_generation_prompt', 'previsualization_storyboard')) {
        throw 'Only Review Result v2.1 pre_generation_prompt and previsualization_storyboard are implemented.'
    }
    foreach ($field in @('project_id', 'target_type', 'target_id', 'revision_id', 'content_hash', 'reviewed_at')) {
        if ([string]::IsNullOrWhiteSpace([string]$reviewResult.target.$field)) { throw "review_result.target.$field is required." }
    }
    foreach ($field in @('review_input_hash', 'dependency_hashes', 'evaluator_policy_id', 'evaluator_policy_version')) {
        if ($null -eq $reviewResult.lineage.PSObject.Properties[$field] -or $null -eq $reviewResult.lineage.$field) { throw "review_result.lineage.$field is required." }
    }
    $dependencyFields = if ($reviewGate -eq 'previsualization_storyboard') {
        @('frozen_script', 'audiovisual_direction_package', 'production_manifest', 'storyboard_plan', 'storyboard_prompt', 'storyboard_media')
    }
    else {
        @('frozen_script', 'audiovisual_direction_package', 'production_manifest', 'video_prompt_spec', 'executable_prompt')
    }
    foreach ($field in $dependencyFields) {
        if ([string]::IsNullOrWhiteSpace([string]$reviewResult.lineage.dependency_hashes.$field)) { throw "review_result.lineage.dependency_hashes.$field is required." }
    }
    if ($reviewGate -eq 'previsualization_storyboard') {
        if ([string]$unit.stage -ne 'storyboard') { throw 'previsualization_storyboard Review requires unit.stage=storyboard.' }
        if ([string]$reviewResult.target.target_type -ne 'storyboard_asset' -or [string]::IsNullOrWhiteSpace([string]$reviewResult.target.media_checksum)) {
            throw 'Storyboard Review requires target_type=storyboard_asset and media_checksum.'
        }
        $reviewContextProperty = $unit.PSObject.Properties['review_context']
        if ($null -eq $reviewContextProperty -or $null -eq $reviewContextProperty.Value) { throw 'Storyboard Review requires unit.review_context.' }
    }
    if (@($reviewResult.provenance.evidence_refs).Count -lt 1) { throw 'Review Result must contain provenance evidence_refs.' }

    $findingEvidence = @($reviewResult.findings | ForEach-Object { @($_.evidence) })
    $evidence = @($reviewResult.provenance.evidence_refs) + $findingEvidence
    $failureTypes = @($reviewResult.controller_mapping.failure_types | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
    $mappedVerdict = [string]$reviewResult.controller_mapping.verdict
    $fixtureOnly = [bool]$reviewResult.provenance.fixture_only
    $staleReview = $false

    if ($reviewGate -eq 'previsualization_storyboard') {
        $reviewContext = $unit.review_context
        foreach ($field in @('target_revision_id', 'target_content_hash', 'media_checksum', 'dependency_hashes')) {
            if ($null -eq $reviewContext.PSObject.Properties[$field] -or $null -eq $reviewContext.$field) { throw "unit.review_context.$field is required." }
        }
        if ([string]$reviewContext.target_revision_id -ne [string]$reviewResult.target.revision_id -or
            [string]$reviewContext.target_content_hash -ne [string]$reviewResult.target.content_hash -or
            [string]$reviewContext.media_checksum -ne [string]$reviewResult.target.media_checksum) {
            $staleReview = $true
        }
        foreach ($field in $dependencyFields) {
            if ([string]::IsNullOrWhiteSpace([string]$reviewContext.dependency_hashes.$field) -or
                [string]$reviewContext.dependency_hashes.$field -ne [string]$reviewResult.lineage.dependency_hashes.$field) {
                $staleReview = $true
            }
        }
    }

    if ($fixtureOnly -and [string]$reviewResult.decision.generation_gate_recommendation -ne 'withhold') {
        throw 'Fixture Review Result must withhold the Cost Gate recommendation.'
    }
    switch ([string]$reviewResult.decision.verdict) {
        'PASS' { if (-not $fixtureOnly -and $mappedVerdict -ne 'pass') { throw 'Review PASS must map to pass.' } }
        'WARNING' { if ($mappedVerdict -notin @('retry', 'human_review')) { throw 'Review WARNING must map to retry or human_review.' } }
        'FAIL' { if ($mappedVerdict -notin @('retry', 'human_review')) { throw 'Review FAIL must map to retry or human_review.' } }
        'UNKNOWN' { if ($mappedVerdict -ne 'blocked') { throw 'Review UNKNOWN must map to blocked.' } }
        'HUMAN_REVIEW' { if ($mappedVerdict -ne 'human_review') { throw 'Review HUMAN_REVIEW must map to human_review.' } }
        default { throw 'Unsupported Review Result decision verdict.' }
    }
    if ($fixtureOnly -and $mappedVerdict -eq 'pass') { $mappedVerdict = 'blocked' }
    if ([string]$reviewResult.decision.verdict -eq 'UNKNOWN') { $mappedVerdict = 'blocked' }
    if ([string]$reviewResult.decision.verdict -eq 'HUMAN_REVIEW') { $mappedVerdict = 'human_review' }
    if ($mappedVerdict -notin @('pass', 'retry', 'blocked', 'human_review')) { throw 'Unsupported Review Result controller mapping.' }
    if ($mappedVerdict -eq 'retry' -and $failureTypes.Count -lt 1) { throw 'Review retry requires a named failure.' }
    if ($mappedVerdict -eq 'pass' -and $reviewGate -eq 'pre_generation_prompt' -and ([string]$reviewResult.decision.verdict -ne 'PASS' -or [string]$reviewResult.decision.generation_gate_recommendation -ne 'eligible_for_separate_cost_gate')) {
        throw 'Only a pre-generation Review PASS may recommend entry to the separate Cost Gate.'
    }
    if ($mappedVerdict -eq 'pass' -and $reviewGate -eq 'previsualization_storyboard' -and ([string]$reviewResult.decision.verdict -ne 'PASS' -or [string]$reviewResult.decision.next_action -ne 'advance_to_prompt_planning' -or [string]$reviewResult.decision.generation_gate_recommendation -ne 'withhold')) {
        throw 'Storyboard Review PASS may advance only to Prompt planning and must withhold the Cost Gate.'
    }

    if ($staleReview) {
        $mappedVerdict = 'blocked'
        $evidence += 'Current Storyboard target or dependency hash does not match the reviewed revision.'
        $failureTypes = @()
    }

    $assessment = [pscustomobject]@{
        source = [string]$reviewResult.provenance.evaluator_source
        run_id = @($reviewResult.provenance.evaluator_run_ids) | Select-Object -First 1
        verdict = $mappedVerdict
        confidence = if ($mappedVerdict -eq 'pass') { 'high' } elseif ($mappedVerdict -eq 'human_review') { 'low' } else { 'medium' }
        evidence = @($evidence)
        failure_types = @($failureTypes)
        affects_semantics = [bool]$reviewResult.controller_mapping.affects_semantics
        requires_external_evidence = [bool]$reviewResult.controller_mapping.requires_external_evidence
        proposed_capability = $reviewResult.controller_mapping.proposed_capability
    }
}

if ($null -eq $assessment) { throw 'assessment or review_result is required.' }

foreach ($field in @('unit_id', 'stage', 'retry_count', 'max_retries')) {
    if ($null -eq $unit.$field) { throw "unit.$field is required." }
}
foreach ($field in @('source', 'verdict', 'confidence', 'evidence', 'failure_types', 'affects_semantics', 'requires_external_evidence')) {
    if ($null -eq $assessment.$field) { throw "assessment.$field is required." }
}
if (@($assessment.evidence).Count -lt 1) { throw 'Assessment must contain evidence.' }
if ($assessment.verdict -eq 'retry' -and @($assessment.failure_types).Count -lt 1) { throw 'Retry requires a named failure.' }
$repairAssessmentProperty = $assessment.PSObject.Properties['repair_assessment']
$repairAssessment = if ($null -ne $repairAssessmentProperty) { $repairAssessmentProperty.Value } else { $null }
if ($null -ne $repairAssessment -and [string]$unit.stage -ne 'production_qa') { throw 'repair_assessment is valid only for production_qa.' }
if ($null -ne $repairAssessment) {
    foreach ($field in @('severity', 'core_story_function_satisfied', 'can_edit_or_reuse', 'expected_improvement', 'target_revision_id', 'media_checksum')) {
        if ($null -eq $repairAssessment.PSObject.Properties[$field]) { throw "repair_assessment.$field is required." }
    }
    if ([string]$repairAssessment.severity -notin @('must_fix', 'optional', 'do_not_optimize')) { throw 'repair_assessment.severity is invalid.' }
    if ([string]$repairAssessment.expected_improvement -notin @('high', 'medium', 'low')) { throw 'repair_assessment.expected_improvement is invalid.' }
}

$decision = [ordered]@{
    unit_id = $unit.unit_id
    prior_stage = $unit.stage
    evaluator_source = $assessment.source
    evidence = @($assessment.evidence)
    failure_types = @($assessment.failure_types)
    state = $null
    selected_capability = $null
    next_action = $null
    retry_count = [int]$unit.retry_count
    reason = $null
}

$reviewStages = @('pre_generation_prompt_review', 'storyboard')
$requiresResearch = (($unit.stage -notin $reviewStages) -and $assessment.requires_external_evidence) -or (($unit.topic_type -in @('historical', 'science', 'health')) -and $unit.stage -in @('topic_selection', 'research'))
if ($assessment.affects_semantics -or $assessment.confidence -eq 'low' -or $assessment.verdict -eq 'human_review') {
    $decision.state = 'human_review'
    $decision.next_action = 'request_human_decision'
    $decision.reason = 'Semantic impact, low confidence, or explicit escalation prevents autonomous mutation.'
}
elseif ($unit.stage -eq 'production_qa' -and $null -ne $repairAssessment) {
    $missingMediaIdentity = [string]::IsNullOrWhiteSpace([string]$repairAssessment.target_revision_id) -or [string]::IsNullOrWhiteSpace([string]$repairAssessment.media_checksum)
    if ($missingMediaIdentity) {
        $decision.state = 'human_review'
        $decision.next_action = 'request_human_decision'
        $decision.reason = 'Production QA repair decision requires immutable target revision and media checksum.'
    }
    elseif ([bool]$repairAssessment.core_story_function_satisfied -and [string]$repairAssessment.severity -in @('optional', 'do_not_optimize')) {
        $decision.state = 'complete'
        $decision.selected_capability = 'video-production'
        $decision.next_action = 'accept_current_stop_optimizing'
        $decision.reason = 'Core story function is satisfied and remaining findings are non-blocking.'
    }
    elseif ([int]$unit.retry_count -ge [int]$unit.max_retries) {
        $decision.state = 'human_review'
        $decision.next_action = 'request_human_decision'
        $decision.reason = 'Retry budget exhausted.'
    }
    elseif ([bool]$repairAssessment.can_edit_or_reuse) {
        $decision.state = 'retry_scheduled'
        $decision.selected_capability = 'video-production'
        $decision.next_action = 'edit_or_reuse_failed_unit'
        $decision.retry_count = [int]$unit.retry_count + 1
        $decision.reason = 'Named defect can be repaired without another generation request.'
    }
    elseif ([string]$repairAssessment.severity -eq 'must_fix' -and [string]$repairAssessment.expected_improvement -in @('high', 'medium')) {
        $decision.state = 'retry_scheduled'
        $decision.selected_capability = 'video-production'
        $decision.next_action = 'request_separate_regeneration_cost_gate'
        $decision.retry_count = [int]$unit.retry_count + 1
        $decision.reason = 'Evidence-backed Must Fix is not locally editable and merits a separately authorized regeneration request.'
    }
    else {
        $decision.state = 'human_review'
        $decision.next_action = 'request_human_decision'
        $decision.reason = 'Expected improvement or repair evidence is insufficient for another attempt.'
    }
}
elseif ($requiresResearch) {
    $decision.state = 'blocked'
    $decision.selected_capability = 'research'
    $decision.next_action = 'collect_external_evidence'
    $decision.reason = 'Evidence-dependent topic cannot advance without current evidence.'
}
elseif ($assessment.verdict -eq 'skip') {
    if (-not $unit.required -and $unit.stage -eq 'storyboard' -and $unit.production_risk -eq 'low') {
        $decision.state = 'skipped'
        $decision.selected_capability = 'video-production'
        $decision.next_action = 'advance_to_keyframe_planning'
        $decision.reason = 'Low-risk Storyboard is optional by policy.'
    }
    else {
        $decision.state = 'human_review'
        $decision.next_action = 'request_human_decision'
        $decision.reason = 'A required or non-optional unit cannot be skipped.'
    }
}
elseif ($assessment.verdict -eq 'blocked') {
    $decision.state = 'blocked'
    $decision.selected_capability = if ($unit.stage -in @('pre_generation_prompt_review', 'storyboard')) { 'video-production' } else { $assessment.proposed_capability }
    $decision.next_action = 'collect_review_evidence'
    $decision.reason = 'Required Review evidence is missing, stale, or fixture-only; retry budget is unchanged.'
}
elseif ($assessment.verdict -eq 'retry') {
    if ([int]$unit.retry_count -ge [int]$unit.max_retries) {
        $decision.state = 'human_review'
        $decision.next_action = 'request_human_decision'
        $decision.reason = 'Retry budget exhausted.'
    }
    else {
        $decision.state = 'retry_scheduled'
        $decision.retry_count = [int]$unit.retry_count + 1
        if ($unit.stage -eq 'script_quality') { $decision.selected_capability = 'script-engine' }
        elseif ($unit.stage -in @('pre_generation_prompt_review', 'production_qa', 'storyboard')) { $decision.selected_capability = 'video-production' }
        else { $decision.selected_capability = $assessment.proposed_capability }
        if ([string]::IsNullOrWhiteSpace($decision.selected_capability)) {
            $decision.state = 'human_review'
            $decision.next_action = 'request_human_decision'
            $decision.reason = 'No permitted capability is mapped for this retry.'
        }
        else {
            $decision.next_action = 'rerun_failed_unit_only'
            $decision.reason = 'Named remediable failure within retry budget.'
        }
    }
}
elseif ($assessment.verdict -eq 'pass') {
    $decision.state = 'complete'
    switch ($unit.stage) {
        'topic_selection' { $decision.selected_capability = 'script-engine' }
        'script_quality' { $decision.selected_capability = 'audiovisual-director' }
        'audiovisual_direction' { $decision.selected_capability = 'video-production' }
        'lookdev' { $decision.selected_capability = 'video-production'; $decision.next_action = 'unlock_approved_domains_only' }
        'storyboard' { $decision.selected_capability = 'video-production'; $decision.next_action = 'advance_to_prompt_planning' }
        'pre_generation_prompt_review' { $decision.selected_capability = 'video-production'; $decision.next_action = 'request_separate_cost_gate' }
        'production_qa' { $decision.selected_capability = 'video-production'; $decision.next_action = 'record_actual_end_state_and_advance' }
        default { $decision.next_action = 'advance_to_next_policy_stage' }
    }
    if ($null -eq $decision.next_action) { $decision.next_action = 'advance_to_selected_capability' }
    $decision.reason = 'Assessment passed and policy permits advancement.'
}
else {
    $decision.state = 'human_review'
    $decision.next_action = 'request_human_decision'
    $decision.reason = 'Unsupported or blocked verdict requires human routing.'
}

$result = [ordered]@{
    decision_contract_version = '1.0'
    decision = [pscustomobject]$decision
}
$outputParent = Split-Path -Parent $OutputPath
if ($outputParent -and -not (Test-Path -LiteralPath $outputParent)) { New-Item -ItemType Directory -Force -Path $outputParent | Out-Null }
$result | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Output "PASS: Decision written for $($unit.unit_id): $($decision.state)"
