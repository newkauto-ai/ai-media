[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

$root = Split-Path -Parent $PSScriptRoot
$fixturePath = Join-Path $root 'tests\fixtures\video-prompt-feasibility-structural-cases.json'
$compilerPath = Join-Path $root 'video-production\scripts\compile-video-prompt-fixture.ps1'
$contract = Get-Content -Raw -LiteralPath (Join-Path $root 'video-production\contracts\video-prompt-feasibility-contract.md') -Encoding UTF8
$gateModule = Get-Content -Raw -LiteralPath (Join-Path $root 'video-production\modules\prompt-feasibility-gate.md') -Encoding UTF8
$compilerEntry = Get-Content -Raw -LiteralPath (Join-Path $root 'video-production\modules\clip-prompt-compiler.md') -Encoding UTF8
$skillEntry = Get-Content -Raw -LiteralPath (Join-Path $root 'video-production\SKILL.md') -Encoding UTF8
$template = Get-Content -Raw -LiteralPath (Join-Path $root 'video-production\templates\video-clip-prompt.md') -Encoding UTF8
$tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ('video-prompt-feasibility-' + [guid]::NewGuid().ToString('N'))
$outputPath = Join-Path $tempDirectory 'compiled.json'

try {
    & $compilerPath -FixturePath $fixturePath -OutputPath $outputPath
    $result = Get-Content -Raw -LiteralPath $outputPath -Encoding UTF8 | ConvertFrom-Json
    Assert-True ($result.fixture_only -and -not $result.external_generation_called) 'Feasibility Fixture must remain local and non-generative.'
    Assert-True ($result.contract_version -eq '1.1' -and $result.validator_layer -eq 'deterministic_then_bounded_semantic') 'Feasibility compiler must declare the v1.1 two-layer Gate.'
    Assert-True ($contract.Contains('required_for_copy_ready: true') -and $contract.Contains('input_character_limit: 1200') -and $contract.Contains('output_character_limit: 250') -and $contract.Contains('max_findings: 3') -and $contract.Contains('max_automatic_rechecks: 1')) 'Feasibility contract must bound the required semantic preflight.'
    Assert-True ($contract.Contains('unknown') -and $contract.Contains('executable_rewrite: string | null') -and $contract.Contains('literalization_risk')) 'Feasibility contract must preserve open semantic routing and nullable rewrites.'
    Assert-True ($gateModule.Contains('Do not render or label a prompt copy-ready') -and $gateModule.Contains('keyword or regex matching')) 'Gate module must withhold copy-ready output and reject pseudo-semantic keyword checks.'
    Assert-True ($compilerEntry.Contains('Preflight before rendering') -and $compilerEntry.Contains('1200 input characters') -and $compilerEntry.Contains('one recheck')) 'Compiler entry must run the bounded semantic preflight before rendering.'
    Assert-True ($skillEntry.Contains("required bounded semantic preflight") -and $skillEntry.Contains('Only an evidence-backed high-confidence pass')) 'Skill entry must invoke the semantic preflight for complete prompts.'
    Assert-True ((@($template | Select-String -Pattern '【' -AllMatches).Matches).Count -eq 6) 'External Video Prompt must remain six modules.'

    foreach ($case in $result.cases) {
        Assert-True ($case.actual_result -eq $case.expected_result) "$($case.case_id): expected $($case.expected_result), got $($case.actual_result)."
        Assert-True (-not $case.retry_budget_consumed) "$($case.case_id): unknown or structural evaluation must not consume retry budget."
        Assert-True (-not $case.actual_end_state_written -and -not $case.generated_reference_written -and -not $case.human_approval_written) "$($case.case_id): Fixture must not write actual/generation/approval evidence."
        if ($case.actual_result -ne 'passed') { Assert-True ($case.executable_prompt -eq $null) "$($case.case_id): any non-pass Gate state must withhold executable_prompt." }
        if ($case.actual_result -eq 'passed') {
            Assert-True ($case.executable_prompt -ne $null -and ((@($case.executable_prompt | Select-String -Pattern '【' -AllMatches).Matches).Count -eq 6)) "$($case.case_id): passed case must compile six-module preview."
            $semanticPass = @($case.feasibility_gate.validator_results | Where-Object { $_.check_id -eq 'bounded-semantic-preflight' -and $_.status -eq 'passed' })
            Assert-True ($semanticPass.Count -eq 1) "$($case.case_id): copy-ready output requires exactly one declared semantic preflight pass."
        }
    }

    $complex = $result.cases | Where-Object { $_.case_id -eq 'complex-but-consistent-sequence' } | Select-Object -First 1
    Assert-True ($complex.actual_result -eq 'passed') 'Complex but logically consistent multi-step action must pass; no action-density gate is allowed.'
    $axis = $result.cases | Where-Object { $_.case_id -eq 'same-axis-size-change' } | Select-Object -First 1
    Assert-True (-not $axis.scene_setting_trigger) 'Same-axis shot-size change must not trigger a new Scene Setting asset.'
    $coverage = $result.cases | Where-Object { $_.case_id -eq 'shared-scene-approved-coverage' } | Select-Object -First 1
    Assert-True $coverage.scene_setting_trigger 'Approved multi-Clip, multi-angle coverage must trigger the Scene Setting logic.'
    $unknown = $result.cases | Where-Object { $_.case_id -eq 'unknown-routes' } | Select-Object -First 1
    Assert-True ($unknown.actual_result -eq 'unknown' -and @($unknown.feasibility_gate.failures).Count -eq 0) 'unknown must remain review routing rather than failure.'
    $literal = $result.cases | Where-Object { $_.case_id -eq 'literalization-open-review' } | Select-Object -First 1
    Assert-True ($literal.actual_result -eq 'unknown') 'Open metaphor/literalization risk must remain unknown without a semantic decision.'
    $missingSemantic = $result.cases | Where-Object { $_.case_id -eq 'semantic-preflight-missing' } | Select-Object -First 1
    Assert-True ($missingSemantic.actual_result -eq 'needs_semantic_review' -and $missingSemantic.executable_prompt -eq $null) 'Missing semantic preflight must withhold copy-ready output.'
    $commonSense = $result.cases | Where-Object { $_.case_id -eq 'semantic-common-sense-blocked' } | Select-Object -First 1
    Assert-True ($commonSense.actual_result -eq 'blocked' -and $commonSense.feasibility_gate.failures -contains 'physical_common_sense_violation') 'Evidence-backed physical common-sense failure must block the prompt with a repair target.'
    $overBudget = $result.cases | Where-Object { $_.case_id -eq 'semantic-output-over-budget' } | Select-Object -First 1
    Assert-True ($overBudget.actual_result -eq 'blocked' -and $overBudget.feasibility_gate.failures -contains 'semantic_preflight_invalid_or_over_budget') 'Semantic evidence plus summary over 250 characters must be rejected.'
    $semanticImpact = $result.cases | Where-Object { $_.case_id -eq 'semantic-impact-routes-human' } | Select-Object -First 1
    Assert-True ($semanticImpact.actual_result -eq 'needs_human_review' -and $semanticImpact.executable_prompt -eq $null) 'A semantic-impacting proposal must route to human review even when an evaluator labels it passed.'

    Write-Output 'PASS: Video Prompt Feasibility v1.1 validates deterministic-first routing, bounded semantic preflight, common-sense blocking, unknown withholding, complex actions, six-module output, and no semantic keyword gate.'
}
finally {
    if (Test-Path -LiteralPath $tempDirectory) { Remove-Item -LiteralPath $tempDirectory -Recurse -Force }
}
