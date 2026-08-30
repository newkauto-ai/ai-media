[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'helpers\publishing-packaging-test-helpers.ps1')
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ('skill5-notion-projection-' + [guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Force -Path $temp | Out-Null
    $python = Get-Skill5Python
    $runtime = Join-Path $root 'publishing-packaging\scripts\publishing_packaging_runtime.py'
    $input = Get-Content -LiteralPath (Join-Path $root 'tests\fixtures\rainy-day-kitten-cover-prompt.input.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $run = Invoke-Skill5Compile -InputObject $input -TempRoot $temp -ProjectRoot $root -Name 'notion-projection-package'
    Assert-True ($run.ExitCode -eq 0) 'Projection Package fixture must compile independently of deliverables.'
    $packageRoot = $run.OutputPath
    $samplePackage = Join-Path $packageRoot 'xiaohongshu\publish-package.json'
    & $python (Join-Path $root 'tests\helpers\verify_notion_projection_cases.py') $runtime $samplePackage | Out-Null
    Assert-True ($LASTEXITCODE -eq 0) 'Projection decision matrix must require both hash and managed Snapshot for NO_CHANGE and degrade on body drift.'

    $snapshot = Join-Path $root 'tests\fixtures\notion-publishing-schema-missing-v1.2.snapshot.json'
    & (Join-Path $root 'publishing-packaging\scripts\prepare-notion-projection.ps1') -PackageRoot $packageRoot -LiveSnapshot $snapshot -OutputPath $temp | Out-Null
    $result = Get-Content -LiteralPath (Join-Path $temp 'notion-projection.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-True ($result.projection_count -eq 2) 'Live-snapshot Dry Run must produce exactly Xiaohongshu and Douyin projections.'
    Assert-True ($result.external_action_audit.notion_write -eq 0 -and $result.external_action_audit.upload -eq 0) 'Dry Run must perform zero Notion writes and uploads.'
    foreach ($projection in $result.projections) {
        Assert-True ($projection.row_decision -eq 'CREATE' -and $projection.execution_status -eq 'DEGRADED') 'Current live schema lacks the four approved fields, so CREATE candidates must remain DEGRADED.'
        Assert-True (@($projection.missing_schema_delta).Count -eq 4) 'Exact four-field schema delta must be visible.'
        Assert-True ($projection.target_row -eq $null) 'Existing blank rows without a stable key must not be overwritten.'
        Assert-True ($projection.attachment.status -eq 'degraded_local_binary_upload_unavailable') 'Local PNG must not be claimed as uploaded.'
        $owned = @($projection.properties_candidate.PSObject.Properties.Name | Sort-Object)
        $expected = @('Name', 'Package Hash', 'Platform', '准备状态', '投影键', '阶段', '项目') | Sort-Object
        Assert-True (($owned -join '|') -eq ($expected -join '|')) 'Only projection-owned properties may be proposed.'
    }
    Write-Output 'PASS: Notion Projection Dry Run is idempotent/conflict-safe, preserves manual fields, emits two DEGRADED CREATE candidates, and performs zero Notion writes/uploads.'
}
finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
