[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

function New-StoryboardReviewInput {
    param(
        [string]$Decision,
        [string]$MappedVerdict,
        [bool]$AffectsSemantics = $false,
        [bool]$Stale = $false,
        [string[]]$FailureTypes = @()
    )
    $recommendation = 'withhold'
    $nextAction = if ($Decision -eq 'PASS') { 'advance_to_prompt_planning' } elseif ($Decision -eq 'UNKNOWN') { 'hold_for_evidence' } elseif ($Decision -eq 'HUMAN_REVIEW') { 'human_review' } else { 'targeted_repair' }
    $dependencies = [pscustomobject]@{
        frozen_script = 'hash-script'
        audiovisual_direction_package = 'hash-adp'
        production_manifest = 'hash-manifest'
        storyboard_plan = 'hash-plan'
        storyboard_prompt = 'hash-prompt'
        storyboard_media = 'hash-media'
    }
    $currentDependencies = [pscustomobject]@{
        frozen_script = 'hash-script'
        audiovisual_direction_package = 'hash-adp'
        production_manifest = 'hash-manifest'
        storyboard_plan = if ($Stale) { 'hash-plan-new' } else { 'hash-plan' }
        storyboard_prompt = 'hash-prompt'
        storyboard_media = 'hash-media'
    }
    $failureType = if ($FailureTypes.Count) { $FailureTypes[0] } else { $null }
    return [pscustomobject]@{
        unit = [pscustomobject]@{
            unit_id = 'storyboard-review-01'
            stage = 'storyboard'
            required = $true
            retry_count = 0
            max_retries = 2
            topic_type = 'fiction'
            production_risk = 'medium'
            semantic_locked = $true
            review_context = [pscustomobject]@{
                target_revision_id = 'storyboard-r1'
                target_content_hash = 'hash-target'
                media_checksum = 'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'
                dependency_hashes = $currentDependencies
            }
        }
        review_result = [pscustomobject]@{
            schema_version = '2.1'
            review_id = "review-$Decision-$MappedVerdict-$Stale"
            gate = 'previsualization_storyboard'
            target = [pscustomobject]@{
                project_id = 'P-STORYBOARD'
                target_type = 'storyboard_asset'
                target_id = 'contact-sheet-01'
                revision_id = 'storyboard-r1'
                content_hash = 'hash-target'
                media_checksum = 'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'
                reviewed_at = '2026-08-30T00:00:00Z'
            }
            lineage = [pscustomobject]@{
                review_input_hash = 'hash-review-input'
                dependency_hashes = $dependencies
                evaluator_policy_id = 'storyboard-review-policy'
                evaluator_policy_version = '1.0'
            }
            provenance = [pscustomobject]@{
                manifest_version = '1.8'
                evaluator_source = 'fixture'
                evaluator_run_ids = @('fixture-storyboard-review')
                evidence_refs = @('Declared fixture evidence; not a real asset approval.')
                fixture_only = $true
            }
            findings = @([pscustomobject]@{
                finding_id = 'SB-F1'
                check_id = 'storyboard-visual-variety'
                category = 'editability'
                severity = if ($FailureTypes.Count) { 'must_fix' } else { 'optional' }
                status = 'confirmed'
                confidence = 'high'
                evidence = @('Fixture routing evidence only.')
                failure_type = $failureType
                affects_semantics = $AffectsSemantics
                repair_target = if ($FailureTypes.Count) { 'previsualization.panel.E2' } else { $null }
                owner = if ($AffectsSemantics) { 'human_decision' } else { 'video_production' }
            })
            decision = [pscustomobject]@{
                verdict = $Decision
                next_action = $nextAction
                generation_gate_recommendation = $recommendation
                reason = 'Fixture validates Storyboard routing only.'
            }
            controller_mapping = [pscustomobject]@{
                verdict = $MappedVerdict
                failure_types = @($FailureTypes)
                affects_semantics = $AffectsSemantics
                requires_external_evidence = $false
                proposed_capability = if ($MappedVerdict -eq 'retry') { 'video-production' } else { $null }
            }
            retry_snapshot = [pscustomobject]@{
                retry_count = 0
                max_retries = 2
                execution_state_ref = 'STATE-SB-01'
                prior_review_id = $null
                supersedes_review_id = $null
            }
        }
    }
}

$root = Split-Path -Parent $PSScriptRoot
$fixturePath = Join-Path $root 'tests\fixtures\storyboard-previsualization-cases.json'
$compilerPath = Join-Path $root 'video-production\scripts\compile-storyboard-fixture.ps1'
$productionCompilerPath = Join-Path $root 'video-production\scripts\compile-production-fixture.ps1'
$productionFixturePath = Join-Path $root 'tests\fixtures\audiovisual-director-v1.2-minimal.fixture.json'
$controllerPath = Join-Path $root 'workflow-controller\scripts\decide-next-action.ps1'
$templatePath = Join-Path $root 'video-production\templates\storyboard-contact-sheet-prompt.md'
$plannerPath = Join-Path $root 'video-production\modules\storyboard-keyframe-planner.md'
$manifestContractPath = Join-Path $root 'video-production\contracts\production-manifest.md'
$reviewContractPath = Join-Path $root 'video-production\contracts\review-result-contract.md'
$qaPath = Join-Path $root 'video-production\modules\qa-retry.md'
$tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ('storyboard-previsualization-' + [guid]::NewGuid().ToString('N'))
$compiledPath = Join-Path $tempDirectory 'compiled-storyboards.json'
$previsualizationPath = Join-Path $tempDirectory 'previsualization.json'
$manifestPath = Join-Path $tempDirectory 'production-manifest.json'

try {
    & $compilerPath -FixturePath $fixturePath -OutputPath $compiledPath
    $compiled = Get-Content -LiteralPath $compiledPath -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-True ($compiled.fixture_only -and -not $compiled.external_generation_called -and -not $compiled.human_approval_written -and -not $compiled.actual_state_written -and -not $compiled.cost_gate_granted) 'Storyboard compiler must remain local, fixture-only, and non-authorizing.'

    $low = $compiled.cases | Where-Object { $_.case_id -eq 'low-risk-single-scene' } | Select-Object -First 1
    Assert-True ($low.previsualization.applicability.decision -eq 'skip' -and $low.previsualization.storyboard_plan -eq $null -and $low.contact_sheet_prompt -eq $null) 'Low-risk/no-trigger case must skip without fake Storyboard fields.'

    foreach ($caseId in @('medium-risk-parent-child', 'high-risk-multi-character-blocking', 'ajiao-cake-direction-projection', 'fast-coherent-multishot', 'repeated-composition-repair')) {
        $case = $compiled.cases | Where-Object { $_.case_id -eq $caseId } | Select-Object -First 1
        Assert-True ($case.previsualization.applicability.decision -eq 'retain') "$caseId must retain Storyboard."
        Assert-True ($case.previsualization.generation_status -eq 'planned_awaiting_cost_gate' -and $case.previsualization.cost_gate.state -eq 'awaiting_user_approval' -and $case.previsualization.cost_gate.approval_evidence -eq $null) "$caseId must stop at the separate Storyboard Cost Gate."
        Assert-True ($case.previsualization.asset_ref -eq $null -and $case.previsualization.review_result_ref -eq $null) "$caseId fixture must not fabricate real media or Review approval."
        Assert-True ($case.previsualization.storyboard_plan.content_hash -match '^[a-f0-9]{64}$' -and $case.previsualization.prompt_ref.content_hash -match '^[a-f0-9]{64}$') "$caseId must bind Plan and Prompt hashes."
        Assert-True ($case.contact_sheet_prompt.Contains('previsualization') -and $case.contact_sheet_prompt.Contains('Do not invent plot') -and $case.contact_sheet_prompt.Contains('no variants or automatic regeneration')) "$caseId Contact Sheet prompt must preserve scope and stopping condition."
        Assert-True ($case.contact_sheet_prompt -notmatch '(?i)--ar|seedance|kling|runway') "$caseId Contact Sheet prompt must remain provider-neutral."
    }

    $medium = $compiled.cases | Where-Object { $_.case_id -eq 'medium-risk-parent-child' } | Select-Object -First 1
    Assert-True (@($medium.previsualization.storyboard_plan.panel_refs).Count -eq 3) 'Medium narrative must use the risk-selected Panel count rather than a fixed grid enum.'
    Assert-True (@($medium.previsualization.storyboard_plan.panels | Where-Object { $_.assigned_turning_point }).Count -eq 1 -and @($medium.previsualization.storyboard_plan.panels | Where-Object { $_.assigned_payoff }).Count -eq 1) 'Turning Point and Payoff must remain distinct upstream-assigned roles.'

    $ajiao = $compiled.cases | Where-Object { $_.case_id -eq 'ajiao-cake-direction-projection' } | Select-Object -First 1
    $directionLabels = @('Dramatic task:', 'Visual progression:', 'Emotional progression:', 'Interpretation guardrails:')
    Assert-True ($ajiao.contact_sheet_prompt.Contains('Identity/space: 同一位女性') -and $ajiao.contact_sheet_prompt.Contains('Project anchors:')) 'Ajiao fixture must retain its identity/space anchor in existing Project anchors.'
    foreach ($label in $directionLabels) {
        Assert-True (([regex]::Matches($ajiao.contact_sheet_prompt, [regex]::Escape($label))).Count -eq 1) "Ajiao fixture must project $label exactly once."
        Assert-True (-not (($ajiao.previsualization.storyboard_plan.panels | ConvertTo-Json -Depth 20) -match [regex]::Escape($label))) "Ajiao fixture must not copy $label into Panel blocks."
    }
    Assert-True ($medium.contact_sheet_prompt -notmatch 'Visual progression:') 'A retained case without Visual progression must remain valid and unblocked.'

    $fast = $compiled.cases | Where-Object { $_.case_id -eq 'fast-coherent-multishot' } | Select-Object -First 1
    Assert-True (@($fast.previsualization.storyboard_plan.panel_refs).Count -eq 3) 'Fast coherent action must retain risk coverage without a maximum-shots rejection.'

    $repair = ($compiled.cases | Where-Object { $_.case_id -eq 'repeated-composition-repair' } | Select-Object -First 1).single_panel_repair
    Assert-True ($repair.panel_id -eq 'E2' -and $repair.failure_type -eq 'visual_repetition' -and @($repair.preserved_panel_refs).Count -eq 1 -and $repair.preserved_panel_refs[0] -eq 'E1') 'Single Panel repair must target only the named failed Panel and preserve all others.'
    Assert-True ($repair.generation_status -eq 'planned_awaiting_cost_gate' -and $repair.executable_prompt_preview.Contains('new separate Cost Gate')) 'Single Panel repair must require a new Cost Gate.'

    [pscustomobject]@{ previsualization = $medium.previsualization } | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $previsualizationPath -Encoding UTF8
    & $productionCompilerPath -FixturePath $productionFixturePath -OutputPath $manifestPath -AspectRatio '9:16' -VideoResolution '1080x1920' -PrevisualizationPath $previsualizationPath
    $production = (Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json).production_manifest
    Assert-True ($production.contract_version -eq '1.8' -and $production.previsualization.applicability.decision -eq 'retain') 'Production Manifest v1.8 must carry the previsualization subtree.'
    Assert-True (@($production.clips | Where-Object { $_.generation_status -ne 'blocked_by_storyboard_review' }).Count -eq 0) 'Retained fixture Storyboard must block every downstream generation unit until current real-media Review evidence exists.'
    Assert-True (@($production.continuity_ledger | Where-Object { $_.actual_end_state -ne $null }).Count -eq 0) 'Storyboard integration must not write actual continuity state.'

    $reviewScenarios = @(
        [pscustomobject]@{ name = 'fixture-pass-withheld'; input = (New-StoryboardReviewInput -Decision 'PASS' -MappedVerdict 'pass'); state = 'blocked'; next = 'collect_review_evidence'; retry = 0 },
        [pscustomobject]@{ name = 'unknown-blocked'; input = (New-StoryboardReviewInput -Decision 'UNKNOWN' -MappedVerdict 'blocked'); state = 'blocked'; next = 'collect_review_evidence'; retry = 0 },
        [pscustomobject]@{ name = 'named-panel-repair'; input = (New-StoryboardReviewInput -Decision 'FAIL' -MappedVerdict 'retry' -FailureTypes @('visual_repetition')); state = 'retry_scheduled'; next = 'rerun_failed_unit_only'; retry = 1 },
        [pscustomobject]@{ name = 'semantic-human'; input = (New-StoryboardReviewInput -Decision 'HUMAN_REVIEW' -MappedVerdict 'human_review' -AffectsSemantics $true); state = 'human_review'; next = 'request_human_decision'; retry = 0 },
        [pscustomobject]@{ name = 'stale-blocked'; input = (New-StoryboardReviewInput -Decision 'PASS' -MappedVerdict 'pass' -Stale $true); state = 'blocked'; next = 'collect_review_evidence'; retry = 0 }
    )
    foreach ($scenario in $reviewScenarios) {
        $inputPath = Join-Path $tempDirectory "$($scenario.name)-input.json"
        $outputPath = Join-Path $tempDirectory "$($scenario.name)-output.json"
        $scenario.input | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $inputPath -Encoding UTF8
        & $controllerPath -InputPath $inputPath -OutputPath $outputPath | Out-Null
        $decision = (Get-Content -LiteralPath $outputPath -Raw -Encoding UTF8 | ConvertFrom-Json).decision
        Assert-True ($decision.state -eq $scenario.state -and $decision.next_action -eq $scenario.next -and $decision.retry_count -eq $scenario.retry) "$($scenario.name): Storyboard Review routing mismatch."
        if ($scenario.name -eq 'stale-blocked') { Assert-True (($decision.evidence -join ' ').Contains('does not match the reviewed revision')) 'Stale Storyboard Review must record the mismatch evidence.' }
    }

    $template = Get-Content -LiteralPath $templatePath -Raw -Encoding UTF8
    $planner = Get-Content -LiteralPath $plannerPath -Raw -Encoding UTF8
    $manifestContract = Get-Content -LiteralPath $manifestContractPath -Raw -Encoding UTF8
    $reviewContract = Get-Content -LiteralPath $reviewContractPath -Raw -Encoding UTF8
    $qa = Get-Content -LiteralPath $qaPath -Raw -Encoding UTF8
    Assert-True ($template.Contains('previsualization only') -and $template.Contains('separate Cost Gate')) 'Storyboard template must preserve its non-production and authorization boundary.'
    Assert-True ($planner.Contains('Do not require one Panel per Shot') -and $planner.Contains('never create a Creative Handoff Snapshot')) 'Existing Storyboard Planner must own the lean extension without a new state owner.'
    Assert-True ($planner.Contains('Preserve the selected Panels') -and $planner.Contains('optional (`0–4`)') -and $planner.Contains('non-duplicative') -and $planner.Contains('no reliable upstream evidence') -and $planner.Contains('do not rewrite Hook') -and $planner.Contains('Keep Panel-specific constraints')) 'Planner must keep original anchors first, append only evidence-bounded non-duplicate directions, preserve frozen semantics, and retain Panel-specific constraints locally.'
    Assert-True ($manifestContract.Contains('Contract v1.8') -and $manifestContract.Contains('previsualization') -and $manifestContract.Contains('second approval state')) 'Manifest v1.8 must preserve the lightweight previsualization subtree and existing ownership.'
    Assert-True ($reviewContract.Contains('previsualization_storyboard') -and $reviewContract.Contains('not Production Clip Review Gate 2')) 'Review Result v2.1 must namespace Storyboard without implementing Gate 2/3.'
    Assert-True ($qa.Contains('accept_current_stop_optimizing') -and $qa.Contains('request_separate_regeneration_cost_gate') -and $qa.Contains('Do not create a separate Regeneration Gate')) 'QA must merge regeneration advice into existing retry authority.'

    Write-Output 'PASS: Storyboard previsualization validates low-risk skip, risk-based Contact Sheet planning, Single Panel repair, real-evidence withholding, stale Review blocking, shared Review/Execution State routing, Manifest v1.8 integration, and zero external generation.'
}
finally {
    if (Test-Path -LiteralPath $tempDirectory) { Remove-Item -LiteralPath $tempDirectory -Recurse -Force }
}
