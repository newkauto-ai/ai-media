[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ManifestPath,
    [Parameter(Mandatory = $true)][string]$PosterShotId,
    [Parameter(Mandatory = $true)]
    [ValidateSet('request_base', 'request_overlay', 'compose_preview', 'plan_motion', 'render', 'intake')]
    [string]$Action,
    [string]$AssetId,
    [string]$OutputPath,
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
    throw 'Cannot resolve the ai-media plugin root.'
}
if (-not (Test-Path -LiteralPath $PythonPath -PathType Leaf)) {
    throw "Pinned image-validation Python runtime is missing: $PythonPath"
}
$scriptPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'validate-vox-production.py'
$arguments = @($scriptPath, '--manifest', $ManifestPath, '--shot-id', $PosterShotId, '--action', $Action)
if ($AssetId) { $arguments += @('--asset-id', $AssetId) }
if ($OutputPath) { $arguments += @('--output', $OutputPath) }
$env:PYTHONUTF8 = '1'
& $PythonPath @arguments
exit $LASTEXITCODE
