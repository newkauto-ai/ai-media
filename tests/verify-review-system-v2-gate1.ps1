[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

function New-ReviewResult {
    param(
        [string]$Decision,
        [string]$MappedVerdict,
        [bool]$FixtureOnly,
        [bool]$AffectsSemantics = $false,
        [string[]]$FailureTypes = @()
    )
    $recommendation = if ($Decision -eq 'PASS' -and -not $FixtureOnly) { 'eligible_for_separate_cost_gate' } else { 'withhold' }
    return [pscustomobject]@{
        schema_version = '2.1'
        review_id = "REVIEW-$Decision-$FixtureOnly"
        gate = 'pre_generation_prompt'
        target = [pscustomobject]@{ project_id = 'fixture-project'; target_type = 'video_prompt'; target_id = 'C01'; revision_id = 'PROMPT-v2'; content_hash = 'sha256:target'; reviewed_at = '2026-08-28T00:00:00Z' }
        lineage = [pscustomobject]@{
            review_input_hash = 'sha256:input'
            dependency_hashes = [pscustomobject]@{ frozen_script = 'sha256:script'; audiovisual_direction_package = 'sha256:adp'; production_manifest = 'sha256:manifest'; video_prompt_spec = 'sha256:spec'; executable_prompt = 'sha256:prompt' }
            evaluator_policy_id = 'prompt-story-function-conformance'
            evaluator_policy_version = '1.0'
        }
        provenance = [pscustomobject]@{ manifest_version = '1.6'; evaluator_source = if ($FixtureOnly) { 'fixture' } else { 'human' }; evaluator_run_ids = @('fixture-routing-run'); evidence_refs = @('fixture:evidence:1'); fixture_only = $FixtureOnly }
        findings = @([pscustomobject]@{ finding_id = 'F1'; check_id = 'story-function-conformance'; category = 'story_function_conformance'; severity = if ($FailureTypes.Count) { 'must_fix' } else { 'optional' }; status = 'confirmed'; confidence = 'high'; evidence = @('Declared routing evidence only.'); failure_type = if ($FailureTypes.Count) { $FailureTypes[0] } else { $null }; affects_semantics = $AffectsSemantics; repair_target = if ($FailureTypes.Count) { 'video_production.video_prompt_spec' } else { $null }; owner = 'video_production' })
        decision = [pscustomobject]@{ verdict = $Decision; next_action = if ($Decision -eq 'PASS') { 'advance_to_separate_cost_gate' } elseif ($Decision -eq 'UNKNOWN') { 'hold_for_evidence' } else { 'targeted_repair' }; generation_gate_recommendation = $recommendation; reason = 'Fixture validates routing only.' }
        controller_mapping = [pscustomobject]@{ verdict = $MappedVerdict; failure_types = @($FailureTypes); affects_semantics = $AffectsSemantics; requires_external_evidence = ($Decision -eq 'UNKNOWN'); proposed_capability = if ($MappedVerdict -eq 'retry') { 'video-production' } else { $null } }
        retry_snapshot = [pscustomobject]@{ retry_count = 0; max_retries = 2; execution_state_ref = 'STATE-C01'; prior_review_id = $null; supersedes_review_id = $null }
    }
}

$root = Split-Path -Parent $PSScriptRoot
$controller = Join-Path $root 'workflow-controller\scripts\decide-next-action.ps1'
$contract = Get-Content -LiteralPath (Join-Path $root 'video-production\contracts\review-result-contract.md') -Raw -Encoding UTF8
$module = Get-Content -LiteralPath (Join-Path $root 'video-production\modules\prompt-story-function-review.md') -Raw -Encoding UTF8
$skill = Get-Content -LiteralPath (Join-Path $root 'video-production\SKILL.md') -Raw -Encoding UTF8
$tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ('review-v2-gate1-' + [guid]::NewGuid().ToString('N'))

try {
    Assert-True ($contract.Contains('schema_version: "2.1"') -and $contract.Contains('dependency_hashes:') -and $contract.Contains('eligible_for_separate_cost_gate')) 'Review Result must bind exact dependencies and separate Cost Gate recommendation.'
    Assert-True ($contract.Contains('remains authoritative for retry count') -and $contract.Contains('fixture_only=true')) 'Review Result must preserve retry and fixture boundaries.'
    Assert-True ($module.Contains('not a second semantic reviewer') -and $module.Contains('Do not count actions') -and $module.Contains('keywords')) 'Story-function review must compose with the existing semantic preflight and reject pseudo-semantic checks.'
    Assert-True ($skill.Contains('Prompt Story Function Conformance') -and $skill.Contains('Review Result v2.1')) 'Video Production must invoke the minimum Review increment.'

    $scenarios = @(
        [pscustomobject]@{ name = 'declared-human-pass'; review = (New-ReviewResult -Decision PASS -MappedVerdict pass -FixtureOnly $false); expected_state = 'complete'; expected_action = 'request_separate_cost_gate'; expected_retry = 0 },
        [pscustomobject]@{ name = 'fixture-pass-withheld'; review = (New-ReviewResult -Decision PASS -MappedVerdict pass -FixtureOnly $true); expected_state = 'blocked'; expected_action = 'collect_review_evidence'; expected_retry = 0 },
        [pscustomobject]@{ name = 'unknown-withheld'; review = (New-ReviewResult -Decision UNKNOWN -MappedVerdict blocked -FixtureOnly $true); expected_state = 'blocked'; expected_action = 'collect_review_evidence'; expected_retry = 0 },
        [pscustomobject]@{ name = 'bounded-repair'; review = (New-ReviewResult -Decision WARNING -MappedVerdict retry -FixtureOnly $true -FailureTypes @('story_function_mismatch')); expected_state = 'retry_scheduled'; expected_action = 'rerun_failed_unit_only'; expected_retry = 1 },
        [pscustomobject]@{ name = 'semantic-change'; review = (New-ReviewResult -Decision HUMAN_REVIEW -MappedVerdict human_review -FixtureOnly $true -AffectsSemantics $true -FailureTypes @('frozen_semantics_change')); expected_state = 'human_review'; expected_action = 'request_human_decision'; expected_retry = 0 }
    )

    foreach ($scenario in $scenarios) {
        $inputPath = Join-Path $tempDirectory "$($scenario.name).input.json"
        $outputPath = Join-Path $tempDirectory "$($scenario.name).output.json"
        New-Item -ItemType Directory -Force -Path $tempDirectory | Out-Null
        $unit = [pscustomobject]@{ unit_id = 'C01-review'; stage = 'pre_generation_prompt_review'; required = $true; retry_count = 0; max_retries = 2; topic_type = 'fiction'; production_risk = 'medium'; semantic_locked = $true }
        [pscustomobject]@{ unit = $unit; review_result = $scenario.review } | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $inputPath -Encoding UTF8
        & $controller -InputPath $inputPath -OutputPath $outputPath | Out-Null
        $decision = (Get-Content -LiteralPath $outputPath -Raw -Encoding UTF8 | ConvertFrom-Json).decision
        Assert-True ($decision.state -eq $scenario.expected_state) "$($scenario.name): state mismatch."
        Assert-True ($decision.next_action -eq $scenario.expected_action) "$($scenario.name): action mismatch."
        Assert-True ($decision.retry_count -eq $scenario.expected_retry) "$($scenario.name): retry mismatch."
    }

    Write-Output 'PASS: Review Result v2.1 Gate 1 preserves hashes, fixture withholding, bounded repair, semantic escalation, and the independent Cost Gate boundary.'
}
finally {
    if (Test-Path -LiteralPath $tempDirectory) { Remove-Item -LiteralPath $tempDirectory -Recurse -Force }
}
