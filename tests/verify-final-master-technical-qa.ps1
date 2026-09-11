[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
function Assert-True([bool]$Condition, [string]$Message) { if (-not $Condition) { throw "ASSERTION FAILED: $Message" } }
$root = Split-Path -Parent $PSScriptRoot
$fixture = Join-Path $root 'tests\fixtures\final-master-technical-cases.json'
$probe = Join-Path $root 'video-production\scripts\probe-final-master-technical.ps1'
$out = Join-Path ([System.IO.Path]::GetTempPath()) ('final-master-qa-' + [guid]::NewGuid().ToString('N') + '.json')
try {
    & $probe -FixturePath $fixture -OutputPath $out
    $result = Get-Content -LiteralPath $out -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-True ($result.fixture_only -and $result.probe -eq 'final-master-technical') 'Probe must remain a fixture-only deterministic technical check.'
    foreach ($case in @($result.cases)) { Assert-True ($case.result.assessment.verdict -eq $case.expected_verdict) "$($case.case_id): unexpected verdict."; Assert-True ($case.result.assessment.proposed_capability -eq 'video-production') "$($case.case_id): must stay with the existing owner." }
    $timing = $result.cases | Where-Object case_id -eq 'audio-stream-duration-mismatch'; Assert-True ($timing.result.assessment.failure_types -contains 'timing_failure') 'Audio-stream duration mismatch must map to timing_failure.'
    $artifact = $result.cases | Where-Object case_id -eq 'missing-audio-and-bad-tail'; Assert-True ($artifact.result.assessment.failure_types -contains 'artifact') 'Missing audio or undecodable tail must map to artifact.'
    $spec = $result.cases | Where-Object case_id -eq 'spec-mismatch'; Assert-True ($spec.result.assessment.failure_types -contains 'output_spec_mismatch') 'Current delivery spec mismatch must map to output_spec_mismatch.'
    Write-Output 'PASS: Final Master technical QA fixture returns existing Evaluator Result mappings for current 480P delivery, audio-stream timing, artifact, and output-spec checks without Final Cut Review.'
} finally { if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Force } }
