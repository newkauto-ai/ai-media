param(
    [string]$PythonPath = "$env:LOCALAPPDATA\Codex\runtimes\ai-media-whiteboard-animator\0.1.0\Scripts\python.exe",
    [string]$TempRoot
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $PythonPath)) { throw "Whiteboard Animator runtime is missing: $PythonPath" }
$env:PYTHONUTF8 = '1'
if ($TempRoot) {
    New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null
    $env:WHITEBOARD_TEST_TEMP_ROOT = (Resolve-Path -LiteralPath $TempRoot).Path
}
& $PythonPath -m unittest discover -s $PSScriptRoot -p 'test_whiteboard_animator.py' -v
if ($LASTEXITCODE -ne 0) { throw "Whiteboard Animator tests failed with exit code $LASTEXITCODE" }
Write-Output 'PASS: manifest-declared Skill entry covered legacy paths, contract 1.2, and contract 1.3 deterministic style slices, bounded local source compilation, Pilot fingerprint propagation, benchmark-backed semantic segmentation, serial stop/retention, continuous-canvas and board-cut merge, exact frames, active-frontier tip snapping, and real encoding. Technical PASS is not human viewing approval.'
