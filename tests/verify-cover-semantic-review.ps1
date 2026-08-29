[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'helpers\publishing-packaging-test-helpers.ps1')
$python = Get-Skill5Python
$runtime = Join-Path $root 'publishing-packaging\scripts\publishing_packaging_runtime.py'
$fixture = Join-Path $root 'tests\fixtures\rainy-day-cover-semantic-review-cases.json'
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ('skill5-cover-semantic-' + [guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Force -Path $temp | Out-Null
    & $python (Join-Path $root 'tests\helpers\verify_cover_semantic_review.py') $runtime $fixture | Out-Null
    Assert-True ($LASTEXITCODE -eq 0) 'Rainy-day semantic regressions must all withhold visual approval without consuming retry authority.'

    $input = Get-Content -LiteralPath (Join-Path $root 'tests\fixtures\rainy-day-kitten-cover-prompt.input.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $run = Invoke-Skill5Compile -InputObject $input -TempRoot $temp -ProjectRoot $root -Name 'rainy-semantic-package'
    Assert-True ($run.ExitCode -eq 0) 'Semantic package fixture must compile independently of deliverables.'
    $xhs = Get-Content -LiteralPath (Join-Path $run.OutputPath 'xiaohongshu\publish-package.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $douyin = Get-Content -LiteralPath (Join-Path $run.OutputPath 'douyin\publish-package.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($package in @($xhs, $douyin)) {
        Assert-True ($package.cover.width -gt 0 -and $package.cover.height -gt 0) 'Final-size fixture preview dimensions must be recorded.'
        Assert-True ($package.review.cover_semantic_review.verdict -eq 'fail') 'Observed title occlusion and mechanical crop must be withheld by semantic review.'
        Assert-True ($package.readiness.status -ne 'ASSET_READY' -and $package.readiness.status -ne 'READY_FOR_MANUAL_UPLOAD') 'Semantic failure must not be overridden by file/checksum evidence.'
        Assert-True ($package.readiness.blocking_reasons -contains 'cover_semantic_review_fail') 'Semantic failure must remain visible in Package blockers.'
    }

    Write-Output 'PASS: Rainy-day regressions withhold missing subject, title occlusion, mechanical crop, and template residue; independently compiled final-size fixtures remain non-Ready.'
}
finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
