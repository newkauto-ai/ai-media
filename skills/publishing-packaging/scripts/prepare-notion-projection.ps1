[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PackageRoot,

    [Parameter(Mandatory = $true)]
    [string]$LiveSnapshot,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$runtime = Join-Path $PSScriptRoot 'publishing_packaging_runtime.py'
$bundled = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$python = if (Test-Path -LiteralPath $bundled) { $bundled } else { (Get-Command python -ErrorAction Stop).Source }

& $python $runtime project-notion --package-root $PackageRoot --snapshot $LiveSnapshot --output $OutputPath
if ($LASTEXITCODE -ne 0) { throw 'Local Notion Projection Dry Run failed.' }

Write-Output 'PASS: Notion Projection Dry Run generated JSON and Markdown with zero Notion writes or uploads.'
