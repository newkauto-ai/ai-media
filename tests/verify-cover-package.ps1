[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'helpers\publishing-packaging-test-helpers.ps1')
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ('skill5-cover-' + [guid]::NewGuid().ToString('N'))

try {
    New-Item -ItemType Directory -Force -Path $temp | Out-Null
    $video = Join-Path $temp 'source.mp4'
    New-Skill5TestVideo -Path $video -Color '0x365A7A'
    $input = New-Skill5BaseInput -VideoPath $video -Platforms @('youtube_shorts', 'youtube_long') -FixtureOnly $true
    $first = Invoke-Skill5Compile -InputObject $input -TempRoot $temp -ProjectRoot $root -Name 'cover-first'
    Assert-True ($first.ExitCode -eq 0) 'Initial cover compilation must succeed.'
    $shortFirst = Get-Content -LiteralPath (Join-Path $first.OutputPath 'youtube_shorts\publish-package.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $longFirst = Get-Content -LiteralPath (Join-Path $first.OutputPath 'youtube_long\publish-package.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-True ($shortFirst.cover.source_type -eq 'extracted_frame_optional' -and $longFirst.cover.source_type -eq 'extracted_frame_optional') 'Final-media extraction must remain an optional fallback when no approved cover reference exists.'
    Assert-True ($shortFirst.cover.qa.ocr.status -eq 'unknown' -and $shortFirst.cover.qa.overall -eq 'blocked') 'Missing OCR runtime must be explicit and block cover QA.'

    $input.qa_evidence = @{ ocr_by_platform = @{
        youtube_shorts = @{ asset_checksum_sha256 = $shortFirst.cover.composed_asset_checksum_sha256; observed_text = $shortFirst.cover.cover_text; engine = 'declared-test-ocr'; evidence_ref = 'fixture:ocr-short' }
        youtube_long = @{ asset_checksum_sha256 = $longFirst.cover.composed_asset_checksum_sha256; observed_text = $longFirst.cover.cover_text; engine = 'declared-test-ocr'; evidence_ref = 'fixture:ocr-long' }
    } }
    $second = Invoke-Skill5Compile -InputObject $input -TempRoot $temp -ProjectRoot $root -Name 'cover-second'
    Assert-True ($second.ExitCode -eq 0) 'Cover compilation with checksum-bound OCR evidence must succeed.'
    $shortPackage = Get-Content -LiteralPath (Join-Path $second.OutputPath 'youtube_shorts\publish-package.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $longPackage = Get-Content -LiteralPath (Join-Path $second.OutputPath 'youtube_long\publish-package.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($package in @($shortPackage, $longPackage)) {
        Assert-True (Test-Path -LiteralPath $package.cover.composed_asset_path) 'Programmatic compositor must emit an actual cover file.'
        Assert-True ((Get-FileHash -LiteralPath $package.cover.composed_asset_path -Algorithm SHA256).Hash -eq $package.cover.composed_asset_checksum_sha256) 'Cover checksum must read back.'
        Assert-True ($package.cover.qa.overall -eq 'pass') 'Checksum-bound OCR, dimensions, safe zone, contrast, watermark and Series QA must pass.'
        Assert-True ($package.review.cover_semantic_review.verdict -eq 'unknown') 'Technical QA PASS must remain separate from missing semantic visual review.'
        Assert-True ($package.cover.typography_spec.font_rights_status -in @('system', 'approved')) 'Font rights status must be explicit.'
        Assert-True ($package.cover.typography_spec.line_boxes.Count -gt 0) 'Chinese title must be programmatically laid out.'
        Assert-True ($package.readiness.status -eq 'PACKAGE_DRAFT') 'Fixture real files must still never become Ready.'
    }
    Assert-True ($shortPackage.cover.width -eq 2160 -and $shortPackage.cover.height -eq 3840) 'YouTube Shorts cover must use current 9:16 profile dimensions.'
    Assert-True ($longPackage.cover.width -eq 3840 -and $longPackage.cover.height -eq 2160) 'YouTube Long cover must use current 16:9 profile dimensions.'
    Assert-True ($shortPackage.cover.composed_asset_checksum_sha256 -ne $longPackage.cover.composed_asset_checksum_sha256) 'Platform exports must not cross-contaminate.'
    Assert-True (@($shortPackage.platform_overlay.PSObject.Properties.Name) -contains 'youtube_shorts_overlay') 'Shorts overlay must be present.'
    Assert-True (-not (@($shortPackage.platform_overlay.PSObject.Properties.Name) -contains 'youtube_long_overlay')) 'Long overlay must not leak into Shorts.'
    $keyframe = Join-Path $temp 'approved-keyframe.png'
    Copy-Item -LiteralPath $shortPackage.cover.source_ref -Destination $keyframe
    $python = Get-Skill5Python
    & $python (Join-Path $root 'tests\helpers\verify_cover_source_fallback.py') (Join-Path $root 'publishing-packaging\scripts\publishing_packaging_runtime.py') $video $keyframe | Out-Null
    Assert-True ($LASTEXITCODE -eq 0) 'An approved Key Frame must be selected before an available final-video frame; missing routes must not call a model.'
    Write-Output 'PASS: Cover resolver prioritizes approved references, compositor emits platform variants, and technical QA remains separate from semantic visual review without Fixture Ready.'
}
finally {
    if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
}
