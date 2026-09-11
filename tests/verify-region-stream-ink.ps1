[CmdletBinding()]
param(
    [string]$PythonPath = "$env:LOCALAPPDATA\Codex\runtimes\ai-media-region-stream-ink\0.1.0\Scripts\python.exe"
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $PythonPath)) { throw "Region Stream Ink isolated runtime is missing: $PythonPath" }
$pluginRoot = Split-Path -Parent $PSScriptRoot
$testTemp = Join-Path $pluginRoot '.test-tmp'
$resolvedRoot = [System.IO.Path]::GetFullPath($pluginRoot)
$resolvedTemp = [System.IO.Path]::GetFullPath($testTemp)
if (-not $resolvedTemp.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe test temp path.' }
if (Test-Path -LiteralPath $resolvedTemp) { Remove-Item -LiteralPath $resolvedTemp -Recurse -Force }
try {
    & $PythonPath -m unittest discover -s (Join-Path $PSScriptRoot '.') -p 'test_region_stream_ink.py' -v
    if ($LASTEXITCODE -ne 0) { throw "Region Stream Ink tests failed with exit code $LASTEXITCODE" }
} finally {
    if (Test-Path -LiteralPath $resolvedTemp) { Remove-Item -LiteralPath $resolvedTemp -Recurse -Force }
}
Write-Output 'PASS: Region Stream Ink contract, renderer, encoding, merge, and structured-report fixtures passed. Fixture success is not real-media quality or user approval.'
