[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RequirementsPath,

    [string]$DatabasePath,

    [ValidateRange(1, 5)]
    [int]$TopK = 3,

    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-PropertyValue {
    param([object]$Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) { return $null }
    return $property.Value
}

function Get-List {
    param([object]$Object, [string]$Name)
    $value = Get-PropertyValue -Object $Object -Name $Name
    if ($null -eq $value) { return @() }
    return @($value)
}

function Normalize-Value {
    param([object]$Value, [string]$Kind)
    if ($null -eq $Value) { return $null }
    $text = ([string]$Value).Trim()
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    $key = $text.ToLowerInvariant()

    $aliases = switch ($Kind) {
        'gender' { @{
            '男' = 'male'; '男性' = 'male'; 'male' = 'male'
            '女' = 'female'; '女性' = 'female'; 'female' = 'female'
        } }
        'dialect' { @{
            '四川' = 'sichuan'; '四川话' = 'sichuan'; '四川方言' = 'sichuan'; '川渝' = 'sichuan'; 'sichuan' = 'sichuan'
            '台湾' = 'taiwan'; '台湾口音' = 'taiwan'; '台普' = 'taiwan'; 'taiwan' = 'taiwan'
            '北京' = 'beijing'; '北京口音' = 'beijing'; 'beijing' = 'beijing'
            '粤语' = 'cantonese'; '广东' = 'cantonese'; 'cantonese' = 'cantonese'
            '河南' = 'henan'; '河南口音' = 'henan'; 'henan' = 'henan'
            '东北' = 'northeast'; '东北口音' = 'northeast'; 'northeast' = 'northeast'
            '上海' = 'shanghai'; '上海口音' = 'shanghai'; 'shanghai' = 'shanghai'
            '陕西' = 'shaanxi'; '陕西口音' = 'shaanxi'; 'shaanxi' = 'shaanxi'
            '天津' = 'tianjin'; '天津口音' = 'tianjin'; 'tianjin' = 'tianjin'
        } }
        'age_band' { @{
            '儿童' = 'child'; '孩童' = 'child'; 'child' = 'child'
            '少年' = 'teen'; 'teen' = 'teen'
            '青年' = 'young_adult'; '年轻' = 'young_adult'; 'young_adult' = 'young_adult'
            '成年' = 'adult'; 'adult' = 'adult'
            '成熟' = 'middle_aged'; '中年' = 'middle_aged'; 'middle-aged' = 'middle_aged'; 'middle_aged' = 'middle_aged'
            '老年' = 'older_adult'; '老人' = 'older_adult'; 'older_adult' = 'older_adult'
        } }
        'use_case' { @{
            '旁白' = 'narration'; '解说' = 'narration'; 'narration' = 'narration'
            '角色对白' = 'character_dialogue'; '对白' = 'character_dialogue'; 'character_dialogue' = 'character_dialogue'
            '有声阅读' = 'audiobook'; '有声书' = 'audiobook'; 'audiobook' = 'audiobook'
            '儿童故事' = 'children_story'; '绘本' = 'children_story'; 'children_story' = 'children_story'
            '广告' = 'advertising'; '广告解说' = 'advertising'; 'advertising' = 'advertising'
            '通用' = 'general'; 'general' = 'general'
        } }
        'style' { @{
            '沉稳' = 'steady'; '稳重' = 'steady'; 'steady' = 'steady'
            '亲切' = 'warm'; '温暖' = 'warm'; 'warm' = 'warm'
            '清晰' = 'clear'; '清亮' = 'clear'; 'clear' = 'clear'
            '磁性' = 'magnetic'; 'magnetic' = 'magnetic'
            '温柔' = 'gentle'; 'gentle' = 'gentle'
            '悬疑' = 'suspense'; '神秘' = 'suspense'; 'suspense' = 'suspense'
            '活力' = 'energetic'; '活泼' = 'energetic'; 'energetic' = 'energetic'
            '威严' = 'authoritative'; '霸气' = 'authoritative'; 'authoritative' = 'authoritative'
            '儒雅' = 'refined'; 'refined' = 'refined'
            '童声' = 'childlike'; '奶气' = 'childlike'; 'childlike' = 'childlike'
        } }
        'language' { @{
            '中文' = 'zh-CN'; '普通话' = 'zh-CN'; 'zh-cn' = 'zh-CN'; 'zh' = 'zh-CN'
            '英文' = 'en'; '英语' = 'en'; 'en' = 'en'
        } }
        default { @{} }
    }

    if ($aliases.ContainsKey($key)) { return $aliases[$key] }
    return $key
}

function Normalize-List {
    param([object[]]$Values, [string]$Kind)
    return @($Values | ForEach-Object { Normalize-Value -Value $_ -Kind $Kind } | Where-Object { $null -ne $_ } | Select-Object -Unique)
}

if (-not (Test-Path -LiteralPath $RequirementsPath -PathType Leaf)) { throw "Requirements file not found: $RequirementsPath" }
$DatabasePath = if ([string]::IsNullOrWhiteSpace($DatabasePath)) {
    Join-Path (Split-Path -Parent $PSScriptRoot) 'data\voice-types.json'
} else { $DatabasePath }
if (-not (Test-Path -LiteralPath $DatabasePath -PathType Leaf)) { throw "Voice catalog not found: $DatabasePath" }

$requirements = Get-Content -LiteralPath $RequirementsPath -Raw -Encoding UTF8 | ConvertFrom-Json
$database = Get-Content -LiteralPath $DatabasePath -Raw -Encoding UTF8 | ConvertFrom-Json
$roles = @($requirements.roles)
if ($roles.Count -eq 0) { throw 'At least one role requirement is required.' }
$voices = @($database.voices | Where-Object { $_.provider -eq 'doubao_tts' -and $_.status -eq 'active' })
if ($voices.Count -eq 0) { throw 'Voice catalog has no active Doubao candidates.' }

$roleResults = @(
    foreach ($role in $roles) {
        if ([string]::IsNullOrWhiteSpace([string]$role.voice_profile_id)) { throw 'Every role requires voice_profile_id.' }
        $hard = Get-PropertyValue -Object $role -Name 'hard_constraints'
        $preferences = Get-PropertyValue -Object $role -Name 'preferences'

        $requiredLanguage = Normalize-Value -Value (Get-PropertyValue -Object $hard -Name 'language') -Kind 'language'
        $requiredGender = Normalize-Value -Value (Get-PropertyValue -Object $hard -Name 'gender') -Kind 'gender'
        $requiredDialect = Normalize-Value -Value (Get-PropertyValue -Object $hard -Name 'dialect') -Kind 'dialect'
        $requiredRoute = Normalize-Value -Value (Get-PropertyValue -Object $hard -Name 'provider_route') -Kind 'default'
        $requiredAge = Normalize-Value -Value (Get-PropertyValue -Object $preferences -Name 'age_band') -Kind 'age_band'
        $requiredUseCases = @(Normalize-List -Values (Get-List -Object $preferences -Name 'use_cases') -Kind 'use_case')
        $requiredStyles = @(Normalize-List -Values (Get-List -Object $preferences -Name 'style_tags') -Kind 'style')
        $prohibitedTraits = @(Normalize-List -Values (Get-List -Object $role -Name 'prohibited_traits') -Kind 'style')

        $ranked = @(
            foreach ($voice in $voices) {
                $voiceLanguages = @(Normalize-List -Values (Get-List -Object $voice -Name 'languages') -Kind 'language')
                if ($voiceLanguages.Count -eq 0) {
                    $voiceLanguages = @(Normalize-List -Values (Get-List -Object $voice -Name 'language') -Kind 'language')
                }
                $voiceGender = Normalize-Value -Value (Get-PropertyValue -Object $voice -Name 'gender') -Kind 'gender'
                $voiceDialects = @(Normalize-List -Values (Get-List -Object $voice -Name 'dialects') -Kind 'dialect')
                $voiceRoute = Normalize-Value -Value (Get-PropertyValue -Object $voice -Name 'provider_route') -Kind 'default'
                $voiceAgeBands = @(Normalize-List -Values (Get-List -Object $voice -Name 'age_bands') -Kind 'age_band')
                $voiceUseCases = @(Normalize-List -Values (Get-List -Object $voice.recommendation -Name 'use_cases') -Kind 'use_case')
                $voiceStyles = @(Normalize-List -Values (Get-List -Object $voice.recommendation -Name 'style_tags') -Kind 'style')
                $voiceTraits = @(Normalize-List -Values (Get-List -Object $voice -Name 'traits') -Kind 'style')

                if ($requiredLanguage -and $requiredLanguage -notin $voiceLanguages) { continue }
                if ($requiredGender -and $requiredGender -ne $voiceGender) { continue }
                if ($requiredDialect -and $requiredDialect -notin $voiceDialects) { continue }
                if ($requiredRoute -and $requiredRoute -ne $voiceRoute) { continue }
                if (@($prohibitedTraits | Where-Object { $_ -in $voiceTraits }).Count -gt 0) { continue }

                $priorityValue = Get-PropertyValue -Object $voice.recommendation -Name 'priority'
                $score = if ($null -eq $priorityValue) { 0 } else { [math]::Min([int]$priorityValue, 20) }
                $hardMatches = New-Object System.Collections.Generic.List[string]
                $softMatches = New-Object System.Collections.Generic.List[string]
                if ($requiredLanguage) { $score += 10; [void]$hardMatches.Add("language=$requiredLanguage") }
                if ($requiredGender) { $score += 10; [void]$hardMatches.Add("gender=$requiredGender") }
                if ($requiredDialect) { $score += 30; [void]$hardMatches.Add("dialect=$requiredDialect") }
                if ($requiredRoute) { [void]$hardMatches.Add("provider_route=$requiredRoute") }
                foreach ($useCase in $requiredUseCases) {
                    if ($useCase -in $voiceUseCases) { $score += 12; [void]$softMatches.Add("use_case=$useCase") }
                }
                if ($requiredAge -and $requiredAge -in $voiceAgeBands) { $score += 10; [void]$softMatches.Add("age_band=$requiredAge") }
                foreach ($style in $requiredStyles) {
                    if ($style -in $voiceStyles) { $score += 5; [void]$softMatches.Add("style=$style") }
                }

                $availability = [string](Get-PropertyValue -Object $voice -Name 'account_availability')
                $unresolved = @()
                if ([string]::IsNullOrWhiteSpace($availability) -or $availability -eq 'unknown') { $unresolved += 'account_availability' }
                [pscustomobject]@{
                    voice_id = $voice.voice_id
                    voice_type = $voice.voice_type
                    display_name = $voice.display_name
                    provider_route = $voice.provider_route
                    model_id = $voice.model_id
                    gender = $voiceGender
                    languages = $voiceLanguages
                    dialects = $voiceDialects
                    score = $score
                    hard_matches = @($hardMatches)
                    soft_matches = @($softMatches)
                    account_availability = if ([string]::IsNullOrWhiteSpace($availability)) { 'unknown' } else { $availability }
                    unresolved = $unresolved
                    source = $voice.source
                    evidence_url = $voice.evidence.url
                }
            }
        ) | Sort-Object @{ Expression = 'score'; Descending = $true }, @{ Expression = 'voice_id'; Descending = $false }

        $shortlist = @($ranked | Select-Object -First $TopK)
        $status = if ($shortlist.Count -eq 0) {
            'blocked_no_candidate'
        } elseif ($shortlist.Count -lt $TopK) {
            'shortlist_partial_requires_human_review'
        } elseif (@($shortlist | Where-Object { $_.account_availability -eq 'unknown' }).Count -gt 0) {
            'shortlist_requires_account_verification'
        } else {
            'shortlist_ready_for_human_approval'
        }

        [pscustomobject]@{
            voice_profile_id = $role.voice_profile_id
            speaker_id = $role.speaker_id
            speaker_name = $role.speaker_name
            scope = $role.scope
            requirement_provenance = if ([string]::IsNullOrWhiteSpace([string](Get-PropertyValue -Object $role -Name 'provenance'))) { 'runtime_inferred' } else { [string]$role.provenance }
            status = $status
            hard_constraints = [pscustomobject]@{
                language = $requiredLanguage
                gender = $requiredGender
                dialect = $requiredDialect
                provider_route = $requiredRoute
            }
            preferences = [pscustomobject]@{
                age_band = $requiredAge
                use_cases = $requiredUseCases
                style_tags = $requiredStyles
            }
            candidates = $shortlist
            recommended_voice = if ($shortlist.Count -gt 0) { $shortlist[0] } else { $null }
            selected_voice = $null
            provider_call_authorized = $false
        }
    }
)

$result = [pscustomobject]@{
    schema_version = '1.0'
    catalog_path = (Resolve-Path -LiteralPath $DatabasePath).Path
    catalog_scope = $database.catalog.scope
    catalog_checked_at = $database.catalog.checked_at
    selection_policy = 'hard_filter_then_score_top_k; human approval required; public catalog does not prove account availability'
    status = if (@($roleResults | Where-Object { $_.status -eq 'blocked_no_candidate' }).Count -gt 0) { 'blocked' } else { 'human_review' }
    roles = $roleResults
}

if ($Json) {
    $result | ConvertTo-Json -Depth 20
} else {
    foreach ($role in $roleResults) {
        Write-Output "$($role.voice_profile_id): $($role.status)"
        foreach ($candidate in $role.candidates) {
            Write-Output "  $($candidate.display_name) [$($candidate.voice_type)] score=$($candidate.score); availability=$($candidate.account_availability)"
        }
    }
}
