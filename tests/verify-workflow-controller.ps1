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
    }
    Write-Output 'PASS: Workflow controller validates bounded script retry, evidence routing, optional-step skip, production accept/edit/regeneration-cost-gate policy, semantic escalation, and retry-budget authority.'
}
finally {
    if (Test-Path -LiteralPath $tempDirectory) { Remove-Item -LiteralPath $tempDirectory -Recurse -Force }
}
