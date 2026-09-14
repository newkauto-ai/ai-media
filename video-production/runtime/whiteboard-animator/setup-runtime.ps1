param(
    [string]$RuntimeRoot = "$env:LOCALAPPDATA\Codex\runtimes\ai-media-whiteboard-animator\0.1.0"
)

$ErrorActionPreference = 'Stop'
$runtimeScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
python -m venv $RuntimeRoot
$venvPython = Join-Path $RuntimeRoot 'Scripts\python.exe'
& $venvPython -m pip install --disable-pip-version-check -r (Join-Path $runtimeScriptRoot 'requirements.lock')
if ($LASTEXITCODE -ne 0) { throw "Dependency installation failed with exit code $LASTEXITCODE" }
& $venvPython -c "import cv2, numpy, scipy, skimage, PIL, onnxruntime; print('whiteboard-animator runtime ready')"
if ($LASTEXITCODE -ne 0) { throw "Runtime import check failed with exit code $LASTEXITCODE" }
