[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FixturePath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-Value {
    param([object]$Object, [string]$Name, [object]$Default = $null)
    if ($null -eq $Object) { return $Default }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property -or $null -eq $property.Value) { return $Default }
    return $property.Value
}

function Add-Validator {
    param(
        [System.Collections.ArrayList]$Results,
        [string]$CheckId,
        [string]$Status,
        [string[]]$Evidence,
        [string]$Owner,
        [string[]]$Failures = @(),
        [string[]]$RepairTargets = @(),
        [string]$Confidence = 'high',
        [string]$ValidatorType = 'deterministic'
    )
    [void]$Results.Add([pscustomobject]@{
        check_id = $CheckId
        status = $Status
        validator_type = $ValidatorType
        evidence = @($Evidence)
        confidence = $Confidence
        owner = $Owner
        failures = @($Failures)
        repair_targets = @($RepairTargets)
    })
}

function Get-Overlap {
    param([object]$Left, [object]$Right)
    return ([double]$Left.start_seconds -lt [double]$Right.end_seconds -and [double]$Right.start_seconds -lt [double]$Left.end_seconds)
}

function Get-CompactCharacterCount {
    param([object]$Value)
    if ($null -eq $Value) { return 0 }
    return (($Value | ConvertTo-Json -Depth 20 -Compress).Length)
}

function Get-SixModulePrompt {
    param([string]$ClipId)
    return @"
【规格与参考】
$ClipId；Fixture-only preview；不包含生成引用或人工批准。

【起始状态】
使用通过结构检查的起始状态引用；若为 Planned/Unobserved，不得声称真实承接。

【时间轴】
使用输入中已验证的连续时间段；不由动作数量推断复杂度或拆 Clip。

【镜头与表演】
只编译已有的结构化镜头、表演和 performance binding 证据。

【结束状态】
使用冻结的预期结束状态；实际结束状态只来自 continuity_ledger。

【连续性与禁止项】
不改写冻结语义；不新增姿势、支撑、道具转换、角色或生成证据。
"@
}

function Invoke-Case {
    param([object]$Case)
    $input = $Case.input
    $results = [System.Collections.ArrayList]::new()
    $failures = [System.Collections.ArrayList]::new()
    $repairTargets = [System.Collections.ArrayList]::new()
    $openReview = $false
    $needsSemanticReview = $false
    $humanReview = $false

    $timeline = @((Get-Value $input 'timeline' @()))
    $cursor = 0.0
    $timelineOk = $true
    foreach ($segment in $timeline) {
        if ([math]::Round([double]$segment.start_seconds, 1) -ne [math]::Round($cursor, 1) -or [double]$segment.end_seconds -le [double]$segment.start_seconds) { $timelineOk = $false }
        $cursor = [double]$segment.end_seconds
    }
    if (-not $timelineOk) {
        [void]$failures.Add('timeline_invalid')
        [void]$repairTargets.Add('video_production.timeline')
        Add-Validator $results 'timeline' 'blocked' @('Timeline segments do not join at one-decimal boundaries.') 'video_production' @('timeline_invalid') @('video_production.timeline')
    } else { Add-Validator $results 'timeline' 'passed' @('Timeline starts at 0.0, has positive segments, and joins exactly.') 'video_production' }

    $continuity = Get-Value $input 'continuity' ([pscustomobject]@{})
    $predecessor = Get-Value $continuity 'predecessor_clip_id'
    $sourceType = [string](Get-Value $continuity 'source_state_type' 'first_clip')
    $stateRecordId = Get-Value $continuity 'state_record_id'
    $ledger = @((Get-Value $continuity 'ledger' @()))
    $ledgerRecord = $ledger | Where-Object { $_.state_record_id -eq $stateRecordId } | Select-Object -First 1
    if ($null -eq $predecessor -and $sourceType -ne 'first_clip') {
        [void]$failures.Add('continuity_state_mismatch'); [void]$repairTargets.Add('video_production.continuity_handshake')
        Add-Validator $results 'continuity-handshake' 'blocked' @('First Clip must use source_state_type first_clip.') 'video_production' @('continuity_state_mismatch') @('video_production.continuity_handshake')
    } elseif ($null -ne $predecessor -and $sourceType -eq 'ledger_actual_end_state' -and ($null -eq $stateRecordId -or $null -eq $ledgerRecord -or $null -eq (Get-Value $ledgerRecord 'actual_end_state'))) {
        [void]$failures.Add('continuity_source_missing'); [void]$repairTargets.Add('video_production.continuity_ledger')
        Add-Validator $results 'continuity-handshake' 'blocked' @('Ledger actual source was declared but no actual state record is available.') 'video_production' @('continuity_source_missing') @('video_production.continuity_ledger')
    } elseif ($null -ne $predecessor -and $sourceType -eq 'frozen_planned_end_state' -and $null -ne $ledgerRecord -and $null -ne (Get-Value $ledgerRecord 'actual_end_state')) {
        [void]$failures.Add('continuity_state_mismatch'); [void]$repairTargets.Add('video_production.continuity_handshake')
        Add-Validator $results 'continuity-handshake' 'blocked' @('A planned predecessor state attempted to override an observed Ledger state.') 'video_production' @('continuity_state_mismatch') @('video_production.continuity_handshake')
    } elseif ($null -ne $predecessor -and $sourceType -eq 'frozen_planned_end_state') {
        $openReview = $true
        Add-Validator $results 'continuity-handshake' 'unknown' @('Only a frozen planned state is available; no actual state is claimed.') 'video_production' @() @() 'low'
    } else { Add-Validator $results 'continuity-handshake' 'passed' @('Continuity source is structurally valid.') 'video_production' }

    $resources = @((Get-Value $input 'body_resource_timeline' @()))
    $resourceConflict = $false
    for ($i = 0; $i -lt $resources.Count; $i++) {
        for ($j = $i + 1; $j -lt $resources.Count; $j++) {
            $left = $resources[$i]; $right = $resources[$j]
            if ($left.character_id -ne $right.character_id -or -not (Get-Overlap $left $right)) { continue }
            foreach ($limb in @('left_hand_or_limb','right_hand_or_limb')) {
                $leftTask = [string](Get-Value $left $limb '')
                $rightTask = [string](Get-Value $right $limb '')
                if ($leftTask -eq $rightTask -and $leftTask -ne '') { continue }
                if ($leftTask -ne '' -and $rightTask -ne '' -and $leftTask -ne 'free' -and $rightTask -ne 'free') { $resourceConflict = $true }
            }
        }
        foreach ($limb in @('left_hand_or_limb','right_hand_or_limb')) {
            $task = [string](Get-Value $resources[$i] $limb '')
            if ($task -match '(?i)\band\b|、|同时') { $resourceConflict = $true }
        }
    }
    if ($resourceConflict) { [void]$failures.Add('body_resource_conflict'); [void]$repairTargets.Add('video_production.body_resource_timeline'); Add-Validator $results 'body-resource' 'blocked' @('Overlapping structured limb tasks are mutually exclusive.') 'video_production' @('body_resource_conflict') @('video_production.body_resource_timeline') } else { Add-Validator $results 'body-resource' 'passed' @('No structured body-resource overlap conflict.') 'video_production' }

    $propTransitions = @((Get-Value $input 'prop_state_transitions' @()))
    $propOk = $true
    $byProp = $propTransitions | Group-Object prop_id
    foreach ($group in $byProp) {
        $previousTo = $null
        foreach ($transition in @($group.Group)) {
            if ([string]::IsNullOrWhiteSpace([string]$transition.from_state) -or [string]::IsNullOrWhiteSpace([string]$transition.to_state) -or @($transition.required_resources).Count -eq 0 -or [string]$transition.transition_action -match '(?i)direct|直接') { $propOk = $false }
            if ($null -ne $previousTo -and [string]$transition.from_state -ne [string]$previousTo) { $propOk = $false }
            $previousTo = $transition.to_state
        }
    }
    if ($propOk) { Add-Validator $results 'prop-state-machine' 'passed' @('Structured prop transitions contain explicit states and resources.') 'video_production' } else { [void]$failures.Add('prop_state_transition_invalid'); [void]$repairTargets.Add('video_production.prop_state_transitions'); Add-Validator $results 'prop-state-machine' 'blocked' @('A prop state changed without a valid structured transition.') 'video_production' @('prop_state_transition_invalid') @('video_production.prop_state_transitions') }

    $scene = Get-Value $input 'scene' ([pscustomobject]@{})
    $coverage = @((Get-Value $scene 'coverage' @()))
    $axes = @($coverage | ForEach-Object { $_.axis_group_id } | Sort-Object -Unique)
    $revealsNewSpace = @($coverage | Where-Object { $_.reveals_new_space -eq $true }).Count -gt 0
    $triggered = @($scene.clip_ids).Count -ge 2 -and (($axes.Count -ge 2) -or ($revealsNewSpace -and $coverage.Count -ge 2))
    $required = (Get-Value $scene 'coverage_required' $false) -or $triggered
    $bindings = @((Get-Value $scene 'coverage_bindings' @()))
    $requiredCoverageIds = @((Get-Value $scene 'required_coverage_ids' @()))
    $boundCoverageIds = @($bindings | ForEach-Object { @($_.coverage_ids) })
    $coverageOk = -not $required -or ($requiredCoverageIds.Count -gt 0 -and @($requiredCoverageIds | Where-Object { $boundCoverageIds -notcontains $_ }).Count -eq 0 -and @($bindings | Where-Object { $_.status -eq 'approved_baseline_ready' }).Count -gt 0)
    $sceneEvidence = if ($triggered) { @('At least two Clips use materially different reviewed coverage.') } else { @('No materially different reviewed coverage trigger.') }
    if (-not $coverageOk) { [void]$failures.Add('scene_coverage_binding_missing'); [void]$repairTargets.Add('video_production.scene_continuity'); Add-Validator $results 'scene-setting-coverage' 'blocked' $sceneEvidence 'video_production' @('scene_coverage_binding_missing') @('video_production.scene_continuity') } else { Add-Validator $results 'scene-setting-coverage' 'passed' $sceneEvidence 'video_production' }

    foreach ($assessment in @((Get-Value $input 'semantic_assessments' @()))) {
        if ([string]$assessment.status -eq 'unknown') { $openReview = $true; Add-Validator $results ([string]$assessment.check_id) 'unknown' @($assessment.evidence) ([string](Get-Value $assessment 'owner' 'human_decision')) @() @() ([string](Get-Value $assessment 'confidence' 'low')) 'semantic' }
        elseif ([string]$assessment.status -eq 'needs_human_review') { $humanReview = $true; Add-Validator $results ([string]$assessment.check_id) 'needs_human_review' @($assessment.evidence) ([string](Get-Value $assessment 'owner' 'human_decision')) @() @() ([string](Get-Value $assessment 'confidence' 'low')) 'semantic' }
    }
    foreach ($scan in @((Get-Value $input 'literalization_scan' @()))) {
        if ([string]$scan.status -eq 'unknown') { $openReview = $true; Add-Validator $results 'literalization' 'unknown' @('Open semantic literalization risk remains review-only; rewrite may be null.') 'human_decision' @() @() 'low' 'semantic' }
    }

    if ($failures.Count -eq 0 -and -not $openReview -and -not $humanReview) {
        $preflight = Get-Value $input 'semantic_preflight'
        if ($null -eq $preflight) {
            $needsSemanticReview = $true
            Add-Validator $results 'bounded-semantic-preflight' 'needs_semantic_review' @('A copy-ready prompt requires a declared bounded semantic evaluator result.') 'video_production' @() @('video_production.semantic_preflight') 'low' 'semantic'
        } else {
            $inputLimit = [int](Get-Value $preflight 'input_character_limit' 1200)
            $outputLimit = [int](Get-Value $preflight 'output_character_limit' 250)
            $maxFindings = [int](Get-Value $preflight 'max_findings' 3)
            $riskPacket = Get-Value $preflight 'risk_packet'
            $evaluation = Get-Value $preflight 'evaluator_result'
            $packetLength = Get-CompactCharacterCount $riskPacket
            $summary = [string](Get-Value $evaluation 'summary' '')
            $evaluationEvidence = @((Get-Value $evaluation 'evidence' @()))
            $evaluationFailures = @((Get-Value $evaluation 'failures' @()))
            $evaluationRepairs = @((Get-Value $evaluation 'repair_targets' @()))
            $evaluationStatus = [string](Get-Value $evaluation 'status' 'unknown')
            $evaluationConfidence = [string](Get-Value $evaluation 'confidence' 'low')
            $evaluationSource = [string](Get-Value $evaluation 'source' '')
            $affectsSemantics = [bool](Get-Value $evaluation 'affects_semantics' $false)
            $semanticOutputLength = $summary.Length + (($evaluationEvidence -join '').Length)
            $packetFields = @('clip_id','scene','start_state','timeline','end_state','characters_involved','props_and_state_changes','metaphorical_clauses')
            $missingPacketFields = @($packetFields | Where-Object { $null -eq $riskPacket -or $null -eq $riskPacket.PSObject.Properties[$_] })
            $budgetOk = $packetLength -le $inputLimit -and $semanticOutputLength -le $outputLimit -and $evaluationEvidence.Count -le $maxFindings -and $evaluationFailures.Count -le $maxFindings
            $evaluationShapeOk = $null -ne $evaluation -and $evaluationSource -in @('llm','human') -and $evaluationEvidence.Count -gt 0 -and $missingPacketFields.Count -eq 0

            if (-not $budgetOk -or -not $evaluationShapeOk) {
                [void]$failures.Add('semantic_preflight_invalid_or_over_budget')
                [void]$repairTargets.Add('video_production.semantic_preflight')
                Add-Validator $results 'bounded-semantic-preflight' 'blocked' @("Risk packet length=$packetLength; semantic output length=$semanticOutputLength; findings=$($evaluationEvidence.Count).") 'video_production' @('semantic_preflight_invalid_or_over_budget') @('video_production.semantic_preflight') 'high' 'mixed'
            } elseif ($affectsSemantics -or $evaluationConfidence -eq 'low' -or $evaluationStatus -eq 'needs_human_review') {
                $humanReview = $true
                Add-Validator $results 'bounded-semantic-preflight' 'needs_human_review' $evaluationEvidence 'human_decision' $evaluationFailures $evaluationRepairs $evaluationConfidence 'semantic'
            } elseif ($evaluationStatus -eq 'passed' -and $evaluationConfidence -eq 'high' -and $evaluationFailures.Count -eq 0) {
                $durationFit = Get-Value $riskPacket 'duration_fit'
                $durationStatus = [string](Get-Value $evaluation 'duration_fit_status' '')
                if ($null -ne $durationFit -and $durationStatus -eq 'blocked') {
                    [void]$failures.Add('timing_failure'); [void]$repairTargets.Add('video_production.duration_fit')
                    Add-Validator $results 'duration-fit' 'blocked' @('Declared evaluator evidence says required visible state changes or ending hold are not legible at the current duration.') 'video_production' @('timing_failure') @('video_production.duration_fit') 'high' 'semantic'
                } elseif ($null -ne $durationFit -and $durationStatus -eq 'unknown') {
                    $needsSemanticReview = $true
                    Add-Validator $results 'duration-fit' 'unknown' @('Duration Fit evidence is unavailable for the affected story-function finding.') 'video_production' @() @('video_production.duration_fit') 'low' 'semantic'
                } else {
                    Add-Validator $results 'bounded-semantic-preflight' 'passed' $evaluationEvidence 'video_production' @() @() 'high' 'semantic'
                    if ($null -ne $durationFit) { Add-Validator $results 'duration-fit' 'passed' @('Declared evaluator evidence found the required visible state changes and ending hold legible at the current duration.') 'video_production' @() @() 'high' 'semantic' }
                }
            } elseif ($evaluationStatus -eq 'blocked' -and $evaluationConfidence -eq 'high' -and $evaluationFailures.Count -gt 0 -and $evaluationRepairs.Count -gt 0) {
                foreach ($failure in $evaluationFailures) { if (-not $failures.Contains([string]$failure)) { [void]$failures.Add([string]$failure) } }
                foreach ($target in $evaluationRepairs) { if (-not $repairTargets.Contains([string]$target)) { [void]$repairTargets.Add([string]$target) } }
                Add-Validator $results 'bounded-semantic-preflight' 'blocked' $evaluationEvidence 'video_production' $evaluationFailures $evaluationRepairs $evaluationConfidence 'semantic'
            } else {
                $needsSemanticReview = $true
                Add-Validator $results 'bounded-semantic-preflight' 'needs_semantic_review' $evaluationEvidence 'video_production' $evaluationFailures $evaluationRepairs $evaluationConfidence 'semantic'
            }
        }
    }

    $status = if ($failures.Count -gt 0) { 'blocked' } elseif ($humanReview) { 'needs_human_review' } elseif ($needsSemanticReview) { 'needs_semantic_review' } elseif ($openReview) { 'unknown' } else { 'passed' }
    $prompt = if ($status -eq 'passed') { Get-SixModulePrompt -ClipId $Case.case_id } else { $null }
    [pscustomobject]@{
        case_id = $Case.case_id
        expected_result = $Case.expected_result
        actual_result = $status
        feasibility_gate = [pscustomobject]@{ status = $status; validator_results = @($results); failures = @($failures); repair_targets = @($repairTargets) }
        executable_prompt = $prompt
        scene_setting_trigger = $triggered
        retry_budget_consumed = $false
        actual_end_state_written = $false
        generated_reference_written = $false
        human_approval_written = $false
    }
}

if (-not (Test-Path -LiteralPath $FixturePath -PathType Leaf)) { throw "Fixture not found: $FixturePath" }
$fixture = Get-Content -LiteralPath $FixturePath -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $fixture.fixture_only) { throw 'Only fixture-only input is accepted.' }
$compiledCases = @($fixture.cases | ForEach-Object { Invoke-Case -Case $_ })
$output = [pscustomobject]@{
    fixture_only = $true
    external_generation_called = $false
    contract_version = '1.1'
    validator_layer = 'deterministic_then_bounded_semantic'
    cases = $compiledCases
}
$outputParent = Split-Path -Parent $OutputPath
if ($outputParent -and -not (Test-Path -LiteralPath $outputParent)) { New-Item -ItemType Directory -Force -Path $outputParent | Out-Null }
$output | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Output "PASS: Video Prompt Feasibility Fixture compiled without external generation: $OutputPath"
