[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$InputPath,
    [Parameter(Mandatory = $true)][string]$OutputDirectory,
    [string]$ProfileDirectory,
    [string]$PythonPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$skillRoot = Split-Path -Parent $PSScriptRoot
if (-not $ProfileDirectory) { $ProfileDirectory = Join-Path $skillRoot 'platform-profiles' }
if (-not $PythonPath) {
    $bundled = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
    if (Test-Path -LiteralPath $bundled) { $PythonPath = $bundled }
    else {
        $command = Get-Command python -ErrorAction SilentlyContinue
        if ($command) { $PythonPath = $command.Source }
    }
}
if (-not $PythonPath -or -not (Test-Path -LiteralPath $PythonPath)) { throw 'Python runtime not found. No dependency installation was attempted.' }

$runtime = Join-Path $PSScriptRoot 'publishing_packaging_runtime.py'
& $PythonPath $runtime compile --input $InputPath --output $OutputDirectory --profiles $ProfileDirectory
if ($LASTEXITCODE -ne 0) { throw "Publishing & Packaging compiler failed with exit code $LASTEXITCODE." }
