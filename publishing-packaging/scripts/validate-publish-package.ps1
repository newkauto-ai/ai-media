[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$PackagePath,
    [string]$ReportPath,
    [string]$PythonPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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
$arguments = @($runtime, 'validate', '--path', $PackagePath)
if ($ReportPath) { $arguments += @('--report', $ReportPath) }
& $PythonPath @arguments
if ($LASTEXITCODE -ne 0) { throw "Publish Package validation failed with exit code $LASTEXITCODE." }
