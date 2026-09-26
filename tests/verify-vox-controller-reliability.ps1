[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$controllers = @(
    (Join-Path $root 'workflow-controller/scripts/decide-next-action.ps1'),
    (Join-Path $root 'skills/workflow-controller/scripts/decide-next-action.ps1')
)
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('vox-controller-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempRoot | Out-Null

function Assert-Equal([object]$Actual, [object]$Expected, [string]$Label) {
    if ($Actual -ne $Expected) { throw "$Label expected $Expected, got $Actual" }
}

function New-Input([string]$TargetType = 'vox_poster_shot', [string]$Route = 'production_reconstructable') {
    $hashes = [ordered]@{
        frozen_script = 'script-1'
        audiovisual_direction_package = 'adp-1'
        production_manifest = 'manifest-inputs-1'
        poster_shot_map = 'map-1'
        poster_media = 'poster-1'
    }
    $checks = @('visual_quality', 'poster_readiness')
    if ($Route -eq 'production_reconstructable' -and $TargetType -eq 'vox_poster_shot') {
        $checks += @('typography_split_test', 'context_separation_test', 'decorative_independence_test', 'rectangle_risk_test', 'motion_sequence_test')
    }
    $findings = @($checks | ForEach-Object {
        [ordered]@{ finding_id = $_; check_id = $_; category = 'poster_readiness'; severity = 'optional';
            status = 'confirmed'; check_result = 'pass'; resolution = 'not_applicable'; confidence = 'high';
            evidence = @('synthetic-test-evidence'); failure_type = $null; affects_semantics = $false;
            repair_target = $null; owner = 'video_production' }
    })
    return [ordered]@{
        unit = [ordered]@{
            unit_id = 'synthetic-vox-shot'; stage = 'storyboard'; vox_managed = $true; required = $true;
            retry_count = 0; max_retries = 2; topic_type = 'historical'; production_risk = 'medium';
            review_context = [ordered]@{
                target_revision_id = 'r1'; target_content_hash = 'target-1'; media_checksum = ('a' * 64);
                dependency_hashes = $hashes
            }
        }
        review_result = [ordered]@{
            schema_version = '2.2'; review_id = 'synthetic-review'; gate = 'previsualization_storyboard'
            target = [ordered]@{
                project_id = 'synthetic-project'; target_type = $TargetType; target_id = 'shot-1';
                revision_id = 'r1'; content_hash = 'target-1'; media_checksum = ('a' * 64);
                reviewed_at = '2026-09-25T00:00:00Z'; pilot_design_route = $Route
            }
            lineage = [ordered]@{
                review_input_hash = 'input-1'; dependency_hashes = $hashes;
                evaluator_policy_id = 'vox-poster'; evaluator_policy_version = '2.2'
            }
            provenance = [ordered]@{
                manifest_version = '1.8'; evaluator_source = 'human'; evaluator_run_ids = @('synthetic-test');
                evidence_refs = @('synthetic-test-evidence'); fixture_only = $false
            }
            findings = $findings
            decision = [ordered]@{
                verdict = 'PASS'; next_action = 'continue_poster_preparation';
                generation_gate_recommendation = 'withhold'; reason = 'Synthetic routing test only.'
            }
            controller_mapping = [ordered]@{
                verdict = 'pass'; failure_types = @(); affects_semantics = $false;
                requires_external_evidence = $false; proposed_capability = $null
            }
            retry_snapshot = [ordered]@{
                retry_count = 0; max_retries = 2; execution_state_ref = 'synthetic-state';
                prior_review_id = $null; supersedes_review_id = $null
            }
        }
    }
}

function Invoke-Case([string]$Controller, [object]$InputState, [string]$Label) {
    $inputPath = Join-Path $tempRoot ($Label + '.json')
    $outputPath = Join-Path $tempRoot ($Label + '.out.json')
    $InputState | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $inputPath -Encoding UTF8
    & $Controller -InputPath $inputPath -OutputPath $outputPath | Out-Null
    return (Get-Content -LiteralPath $outputPath -Raw -Encoding UTF8 | ConvertFrom-Json).decision
}

try {
    foreach ($controller in $controllers) {
        $tag = if ($controller -match '[\\/]skills[\\/]') { 'published' } else { 'source' }
        $good = New-Input
        $decision = Invoke-Case $controller $good "$tag-good"
        Assert-Equal $decision.state 'complete' "$tag valid VOX target"
        Assert-Equal $decision.next_action 'continue_poster_preparation' "$tag local route"

        $sheet = New-Input -TargetType 'vox_poster_contact_sheet' -Route 'hero_key_art'
        $decision = Invoke-Case $controller $sheet "$tag-sheet"
        Assert-Equal $decision.state 'complete' "$tag contact sheet"

        $missing = New-Input
        $missing.review_result.findings = @($missing.review_result.findings | Where-Object { $_.check_id -ne 'motion_sequence_test' })
        $decision = Invoke-Case $controller $missing "$tag-missing"
        Assert-Equal $decision.state 'blocked' "$tag missing check"
        Assert-Equal $decision.retry_count 0 "$tag missing check retry"

        $unfixed = New-Input
        $unfixed.review_result.findings[0].severity = 'must_fix'
        $unfixed.review_result.findings[0].resolution = 'unresolved'
        $decision = Invoke-Case $controller $unfixed "$tag-unfixed"
        Assert-Equal $decision.state 'blocked' "$tag unresolved must_fix"

        $unknown = New-Input
        $unknown.review_result.findings[0].check_result = 'unknown'
        $decision = Invoke-Case $controller $unknown "$tag-unknown"
        Assert-Equal $decision.state 'blocked' "$tag unknown result"

        $noOutcome = New-Input
        $noOutcome.review_result.findings[0].Remove('check_result')
        $decision = Invoke-Case $controller $noOutcome "$tag-confirmed-not-pass"
        Assert-Equal $decision.state 'blocked' "$tag confirmed finding is not a passing check"

        $noEvidence = New-Input
        $noEvidence.review_result.findings[0].evidence = @()
        $decision = Invoke-Case $controller $noEvidence "$tag-no-evidence"
        Assert-Equal $decision.state 'blocked' "$tag missing check evidence"

        $old = New-Input
        $old.review_result.schema_version = '2.1'
        $old.review_result.decision.next_action = 'advance_to_prompt_planning'
        $old.review_result.lineage.dependency_hashes.Remove('poster_shot_map')
        $old.review_result.lineage.dependency_hashes.Remove('poster_media')
        $old.unit.review_context.dependency_hashes.Remove('poster_shot_map')
        $old.unit.review_context.dependency_hashes.Remove('poster_media')
        $decision = Invoke-Case $controller $old "$tag-old"
        Assert-Equal $decision.state 'blocked' "$tag legacy VOX Review"

        $assessment = [ordered]@{
            unit = $good.unit
            assessment = [ordered]@{
                source = 'synthetic'; verdict = 'pass'; confidence = 'high'; evidence = @('synthetic');
                failure_types = @(); affects_semantics = $false; requires_external_evidence = $false
            }
        }
        $decision = Invoke-Case $controller $assessment "$tag-assessment"
        Assert-Equal $decision.state 'blocked' "$tag legacy assessment bypass"

        $fixture = New-Input
        $fixture.review_result.provenance.fixture_only = $true
        $fixture.review_result.provenance.evaluator_source = 'fixture'
        $decision = Invoke-Case $controller $fixture "$tag-fixture"
        Assert-Equal $decision.state 'blocked' "$tag fixture"
    }
    Write-Output 'PASS: synthetic VOX Controller routing and negative cases (source and published entrypoint).'
}
finally {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
}
