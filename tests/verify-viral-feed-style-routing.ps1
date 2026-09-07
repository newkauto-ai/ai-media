[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True { param([bool]$Condition, [string]$Message) if (-not $Condition) { throw "ASSERTION FAILED: $Message" } }

$root = Split-Path -Parent $PSScriptRoot
$fixture = Get-Content -Raw -Encoding UTF8 (Join-Path $root 'tests\fixtures\viral-feed-style-routing-cases.json') | ConvertFrom-Json
$registry = Get-Content -Raw -Encoding UTF8 (Join-Path $root 'style-profiles\registry.json') | ConvertFrom-Json
$router = Get-Content -Raw -Encoding UTF8 (Join-Path $root 'audiovisual-director\router\style-ingestion.md')
$inputContract = Get-Content -Raw -Encoding UTF8 (Join-Path $root 'video-production\contracts\input-contract.md')
$compiler = Get-Content -Raw -Encoding UTF8 (Join-Path $root 'video-production\modules\clip-prompt-compiler.md')
$controller = Get-Content -Raw -Encoding UTF8 (Join-Path $root 'workflow-controller\SKILL.md')

Assert-True ($fixture.cases.Count -eq 3) 'Fixture must cover exactly the three supported Viral Feed names.'
foreach ($case in $fixture.cases) {
    $registryMatches = @($registry.profiles | Where-Object { $_.profile_id -eq $case.profile_id -and $_.status -eq 'ready' })
    Assert-True ($registryMatches.Count -eq 1) "$($case.visible_name): must bind exactly one ready registry profile."
    Assert-True ($router -match [regex]::Escape($case.visible_name) -and $router -match [regex]::Escape($case.profile_id)) "$($case.visible_name): exact mapping missing from router."
    $normalizedFile = ($registryMatches[0]).normalized_file
    $normalized = Get-Content -Raw -Encoding UTF8 (Join-Path $root ('style-profiles\normalized\' + $normalizedFile)) | ConvertFrom-Json
    $modules = $normalized.style_profile.audiovisual_modules | ConvertTo-Json -Depth 8
    foreach ($forbidden in $case.must_not_contain) { Assert-True ($modules -notmatch [regex]::Escape($forbidden)) "$($case.visible_name): cross-type rule '$forbidden' leaked into selected profile." }
    Assert-True ($case.adapter.model_id -eq 'runtime-model' -and $case.adapter.duration_seconds -eq 11 -and $case.adapter.aspect_ratio -eq '9:16') "$($case.visible_name): fixture Adapter values changed."
}
$exactNames = @('迷你厨房烹饪', '纸板制作任意物品', '美女跳舞卡点变装')
foreach ($name in $fixture.negative_cases) { Assert-True ($exactNames -notcontains $name) "${name}: near or unknown name must not have an exact mapping." }
Assert-True ($router -match 'exact' -and $router -match 'Do not auto-stack' -and $router -match 'Do not add a routing field') 'Router must enforce one exact selected_style_profiles binding without a second route.'
Assert-True ($inputContract -match 'must resolve to exactly one ready registry Profile' -and $inputContract -match 'Do not.*override Adapter') 'Input contract must protect unique binding and Adapter ownership.'
Assert-True ($compiler -match 'prompt_ready_for_external_use' -and $controller -match 'never requests.*provider call') 'PASS must remain local prompt readiness without a provider call.'
Write-Output 'PASS: three exact Viral Feed names uniquely bind ready Style Profiles, do not leak cross-type rules or Adapter parameters, and stop at prompt_ready_for_external_use without provider calls.'
