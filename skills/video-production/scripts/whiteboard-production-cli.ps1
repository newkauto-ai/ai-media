param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('map-style', 'compile-source', 'select-pilot', 'plan-render', 'plan-board-cut', 'execute-plan')]
    [string]$Action,
    [Parameter(Mandatory = $true)]
    [string]$Request,
    [Parameter(Mandatory = $true)]
    [string]$Output,
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
if (-not (Test-Path -LiteralPath $PythonPath)) { throw "Whiteboard Animator runtime is missing: $PythonPath" }
$env:PYTHONUTF8 = '1'
$cli = Join-Path $cursor 'video-production\runtime\whiteboard-animator\production_planner.py'
& $PythonPath $cli $Action --input $Request --output $Output
exit $LASTEXITCODE
