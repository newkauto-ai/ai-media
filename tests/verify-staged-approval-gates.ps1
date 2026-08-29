[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "ASSERTION FAILED: $Message" }
}

$root = Split-Path -Parent $PSScriptRoot
$gate = Get-Content -Raw -LiteralPath (Join-Path $root 'workflow-controller\contracts\staged-approval-gates.md') -Encoding UTF8
$scriptSkill = Get-Content -Raw -LiteralPath (Join-Path $root 'script-engine\SKILL.md') -Encoding UTF8
$scriptTemplate = Get-Content -Raw -LiteralPath (Join-Path $root 'script-engine\templates\script-package.md') -Encoding UTF8
$directorSkill = Get-Content -Raw -LiteralPath (Join-Path $root 'audiovisual-director\SKILL.md') -Encoding UTF8
$directorTemplate = Get-Content -Raw -LiteralPath (Join-Path $root 'audiovisual-director\templates\output-package-template.md') -Encoding UTF8
$productionSkill = Get-Content -Raw -LiteralPath (Join-Path $root 'video-production\SKILL.md') -Encoding UTF8
$productionRouter = Get-Content -Raw -LiteralPath (Join-Path $root 'video-production\modules\production-router.md') -Encoding UTF8
$productionTemplate = Get-Content -Raw -LiteralPath (Join-Path $root 'video-production\templates\production-package.md') -Encoding UTF8
$clipCompiler = Get-Content -Raw -LiteralPath (Join-Path $root 'video-production\modules\clip-prompt-compiler.md') -Encoding UTF8

$stage0 = $gate.IndexOf('## Stage 0')
$stage1 = $gate.IndexOf('## Stage 1')
$stage2 = $gate.IndexOf('## Stage 2')
Assert-True ($stage0 -ge 0 -and $stage0 -lt $stage1 -and $stage1 -lt $stage2) 'Approval stages must remain ordered.'

foreach ($label in @('Topic Theses','Hook Selection','H-C-E-R-M outline')) {
    $needle = '`' + $label + '`'
    Assert-True ($gate.Contains($needle)) "Stage 0 is missing $label."
}
foreach ($label in @('Global visual DNA','主角','场景','Key Frame')) {
    $needle = '`' + $label + '`'
    Assert-True ($gate.Contains($needle)) "Stage 1 is missing $label."
}
Assert-True ($gate.Contains('确认第1点') -and $gate.Contains('确认第2点')) 'Explicit confirmation phrases are required.'
Assert-True ($gate.Contains('does not authorize paid image, video, voice, SFX, or BGM generation')) 'Stage 2 must not grant paid-generation approval.'
Assert-True ($gate.Contains('read back the page body, relations, and formatting')) 'Notion read-back requirement is missing.'

Assert-True ($scriptSkill.Contains('Stop and output the Stage 0 review package')) 'Script Engine must stop at the Stage 0 package.'
Assert-True ($scriptSkill.Contains('Do not bypass Stage 0')) 'Script Engine must enforce the Stage 0 boundary.'
Assert-True ($scriptTemplate.Contains('Do not include the full master script')) 'Script template must suppress downstream output before Stage 0 approval.'
Assert-True ($directorSkill.Contains('exactly three image-test targets')) 'Audiovisual Director must enforce three visual test targets.'
Assert-True ($directorTemplate.Contains('主角') -and $directorTemplate.Contains('场景') -and $directorTemplate.Contains('Key Frame')) 'Director template must expose the three visual test prompts.'
Assert-True ($productionSkill -match 'Only then may this Skill render the complete production materials and project them\s+to Notion') 'Video Production must defer full package and Notion projection.'
Assert-True ($productionRouter.Contains('block before the full package and any Notion write')) 'Production router must block premature Notion writes.'
Assert-True ($productionTemplate.Contains('Do not write Notion from that preview')) 'Production package must not project the Stage 1 preview to Notion.'
Assert-True ($clipCompiler.Contains('must not be written to Notion')) 'Clip compiler must enforce the staged Notion boundary.'

Write-Output 'PASS: staged approvals enforce script architecture review, three-item visual test review, deferred full production, and post-confirmation Notion projection.'
