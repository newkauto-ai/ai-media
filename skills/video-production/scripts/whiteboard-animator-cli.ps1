param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('preflight', 'render')]
    [string]$Action,
    [Parameter(Mandatory = $true)]
    [string]$Job,
    [string]$Report,
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
$cli = Join-Path $cursor 'video-production\runtime\whiteboard-animator\renderer_cli.py'
$arguments = @($cli, $Action, '--job', $Job)
if ($Report) { $arguments += @('--report', $Report) }
& $PythonPath @arguments
exit $LASTEXITCODE
