[CmdletBinding()]
param(
    [string]$RuntimeRoot = "$env:LOCALAPPDATA\Codex\runtimes\ai-media-region-stream-ink\0.1.0",
    [string]$BootstrapPython = "python"
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$venvPython = Join-Path $RuntimeRoot 'Scripts\python.exe'
if (-not (Test-Path -LiteralPath $venvPython)) {
    & $BootstrapPython -m venv $RuntimeRoot
}
& $venvPython -m pip install --disable-pip-version-check --requirement (Join-Path $PSScriptRoot 'requirements.lock')
& $venvPython -c "import av, cv2, numpy, PIL; print('region-stream-ink runtime ready')"
Write-Output $venvPython
