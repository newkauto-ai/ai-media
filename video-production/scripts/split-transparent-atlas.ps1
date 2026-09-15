[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,
    [Parameter(Mandatory = $true)]
    [string]$OutputDir,
    [Parameter(Mandatory = $true)]
    [ValidateSet('2x2', '3x3')]
    [string]$Grid,
    [Parameter(Mandatory = $true)]
    [string]$Names,
    [string]$Report,
    [double]$PaddingRatio = 0.04,
    [double]$EdgeClearanceRatio = 0.02,
    [ValidateRange(0, 254)]
    [int]$AlphaThreshold = 1,
    [switch]$Overwrite,
    [string]$PythonPath = "$env:LOCALAPPDATA\Codex\runtimes\ai-media-whiteboard-animator\0.1.0\Scripts\python.exe"
)

$ErrorActionPreference = 'Stop'
$cursor = Split-Path -Parent $MyInvocation.MyCommand.Path
while ($cursor -and -not (Test-Path -LiteralPath (Join-Path $cursor '.codex-plugin\plugin.json'))) {
    $parent = Split-Path -Parent $cursor
    if ($parent -eq $cursor) { break }
    $cursor = $parent
}
if (-not $cursor -or -not (Test-Path -LiteralPath (Join-Path $cursor '.codex-plugin\plugin.json'))) {
    throw 'Could not resolve plugin root from the manifest-declared Skill entry.'
}
if (-not (Test-Path -LiteralPath $PythonPath -PathType Leaf)) {
    throw "Atlas crop Python runtime is missing or lacks Pillow; pass -PythonPath explicitly: $PythonPath"
}

$scriptPath = Join-Path $cursor 'video-production\scripts\split-transparent-atlas.py'
$arguments = @(
    $scriptPath,
    '--input', $InputPath,
    '--output-dir', $OutputDir,
    '--grid', $Grid,
    '--names', $Names,
    '--padding-ratio', ([string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0}', $PaddingRatio)),
    '--edge-clearance-ratio', ([string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0}', $EdgeClearanceRatio)),
    '--alpha-threshold', [string]$AlphaThreshold
)
if ($Report) { $arguments += @('--report', $Report) }
if ($Overwrite) { $arguments += '--overwrite' }

$env:PYTHONUTF8 = '1'
& $PythonPath @arguments
exit $LASTEXITCODE
