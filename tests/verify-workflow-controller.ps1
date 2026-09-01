[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

$root = Split-Path -Parent $PSScriptRoot
$controller = Join-Path $root 'workflow-controller\scripts\decide-next-action.ps1'
$routePolicyPath = Join-Path $root 'workflow-controller\policies\route-policy.md'
$scenarios = Get-Content -LiteralPath (Join-Path $root 'tests\fixtures\workflow-controller-scenarios.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$tempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ('workflow-controller-' + [guid]::NewGuid().ToString('N'))

try {
    foreach ($scenario in $scenarios) {
        $inputPath = Join-Path $tempDirectory "$($scenario.name).input.json"
        $outputPath = Join-Path $tempDirectory "$($scenario.name).output.json"
        New-Item -ItemType Directory -Force -Path $tempDirectory | Out-Null
        [pscustomobject]@{ unit = $scenario.unit; assessment = $scenario.assessment } | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $inputPath -Encoding UTF8
        & $controller -InputPath $inputPath -OutputPath $outputPath
        $result = (Get-Content -LiteralPath $outputPath -Raw -Encoding UTF8 | ConvertFrom-Json).decision
        foreach ($field in @('state', 'selected_capability', 'next_action', 'retry_count')) {
            Assert-True ($result.$field -eq $scenario.expected.$field) "$($scenario.name): expected $field '$($scenario.expected.$field)', got '$($result.$field)'."
        }
        Assert-True (@($result.evidence).Count -gt 0) "$($scenario.name): decision must preserve evidence."
        Assert-True ($result.next_action -notmatch '_and_advance$') "$($scenario.name): a decision must return before advancing to another action."
    }
    $routePolicy = Get-Content -LiteralPath $routePolicyPath -Raw -Encoding UTF8
    Assert-True ($routePolicy -match '^# Route Policy v1\.2') 'Route Policy must be v1.2.'
    Assert-True ($routePolicy -notmatch '`audiovisual-director` then `video-production`') 'Stage 0 must not select two owners in one decision.'
    Assert-True ($routePolicy -match 'one owning capability and one atomic next action') 'Route Policy must freeze the one-action rule.'
    Write-Output 'PASS: Workflow controller validates bounded retry, activation routing, one-action return, evidence blocking, production QA, Gate preservation, and retry-budget authority.'
}
finally {
    if (Test-Path -LiteralPath $tempDirectory) { Remove-Item -LiteralPath $tempDirectory -Recurse -Force }
}
