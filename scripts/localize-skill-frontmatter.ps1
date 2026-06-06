#requires -Version 7.0
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$Language = 'en',
    [string]$SkillsRoot = (Join-Path (Join-Path $PSScriptRoot '..') '.agents\skills'),
    [string]$CatalogPath = (Join-Path (Join-Path $PSScriptRoot '..') '.codex\docs\skill-frontmatter-locales.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-FullPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return [System.IO.Path]::GetFullPath($Path)
}

function Test-IsSameOrChildPath {
    param(
        [Parameter(Mandatory = $true)][string]$Candidate,
        [Parameter(Mandatory = $true)][string]$Root
    )

    $candidateFull = (Get-FullPath $Candidate).TrimEnd('\', '/')
    $rootFull = (Get-FullPath $Root).TrimEnd('\', '/')

    if ([string]::Equals($candidateFull, $rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    $rootWithSeparator = $rootFull + [System.IO.Path]::DirectorySeparatorChar
    return $candidateFull.StartsWith($rootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)
}

function Resolve-Language {
    param([Parameter(Mandatory = $true)][string]$Value)

    switch ($Value.ToLowerInvariant()) {
        'en' { return 'en' }
        'en-us' { return 'en' }
        'en-gb' { return 'en' }
        'zh' { return 'zh-CN' }
        'zh-cn' { return 'zh-CN' }
        'zh-hans' { return 'zh-CN' }
        'cn' { return 'zh-CN' }
        default { throw "Unsupported Skill frontmatter language: $Value" }
    }
}

function ConvertTo-YamlDoubleQuoted {
    param([Parameter(Mandatory = $true)][string]$Value)

    $escaped = $Value.Replace('\', '\\').Replace('"', '\"')
    return '"' + $escaped + '"'
}

function Set-FrontmatterLine {
    param(
        [Parameter(Mandatory = $true)][string[]]$Lines,
        [Parameter(Mandatory = $true)][string]$Field,
        [Parameter(Mandatory = $true)][string]$Value
    )

    $replacement = "${Field}: $(ConvertTo-YamlDoubleQuoted -Value $Value)"
    for ($index = 0; $index -lt $Lines.Count; $index++) {
        if ($Lines[$index] -match "^$([regex]::Escape($Field))\s*:") {
            $Lines[$index] = $replacement
            return $Lines
        }
    }

    return @($Lines + $replacement)
}

$resolvedLanguage = Resolve-Language -Value $Language
$RepoRoot = Get-FullPath (Join-Path $PSScriptRoot '..')
$SkillsRoot = Get-FullPath $SkillsRoot
$CatalogPath = Get-FullPath $CatalogPath

if (-not (Test-IsSameOrChildPath -Candidate $SkillsRoot -Root $RepoRoot)) {
    throw "Refusing to update Skills outside the current repository: $SkillsRoot"
}

if (-not (Test-IsSameOrChildPath -Candidate $CatalogPath -Root $RepoRoot)) {
    throw "Refusing to read a locale catalog outside the current repository: $CatalogPath"
}

if (-not (Test-Path -LiteralPath $CatalogPath -PathType Leaf)) {
    throw "Missing localization catalog: $CatalogPath"
}

if (-not (Test-Path -LiteralPath $SkillsRoot -PathType Container)) {
    throw "Missing Skills root: $SkillsRoot"
}

$catalog = Get-Content -LiteralPath $CatalogPath -Raw | ConvertFrom-Json
$locale = $catalog.locales.$resolvedLanguage
if (-not $locale) {
    throw "Localization catalog does not contain locale: $resolvedLanguage"
}

$updatedCount = 0
$skillNames = $locale.PSObject.Properties.Name | Sort-Object

foreach ($skillName in $skillNames) {
    $entry = $locale.$skillName
    $skillPath = Join-Path (Join-Path $SkillsRoot $skillName) 'SKILL.md'

    if (-not (Test-Path -LiteralPath $skillPath -PathType Leaf)) {
        Write-Warning "Skipping missing Skill file: $skillPath"
        continue
    }

    $content = Get-Content -LiteralPath $skillPath -Raw
    if (-not ($content -match '(?s)\A---\r?\n(?<frontmatter>.*?)\r?\n---\r?\n(?<body>.*)\z')) {
        throw "Skill file does not start with YAML frontmatter: $skillPath"
    }

    $newline = if ($content.Contains("`r`n")) { "`r`n" } else { "`n" }
    $frontmatterLines = [string[]]($Matches.frontmatter -split '\r?\n')
    $body = $Matches.body

    if ($entry.PSObject.Properties.Name -contains 'description') {
        $frontmatterLines = Set-FrontmatterLine -Lines $frontmatterLines -Field 'description' -Value $entry.description
    }

    if ($entry.PSObject.Properties.Name -contains 'argument-hint') {
        $frontmatterLines = Set-FrontmatterLine -Lines $frontmatterLines -Field 'argument-hint' -Value $entry.'argument-hint'
    }

    $updated = "---$newline$($frontmatterLines -join $newline)$newline---$newline$body"
    if ($updated -eq $content) {
        continue
    }

    if ($PSCmdlet.ShouldProcess($skillPath, "localize frontmatter to $resolvedLanguage")) {
        [System.IO.File]::WriteAllText(
            (Resolve-Path -LiteralPath $skillPath).Path,
            $updated,
            [System.Text.UTF8Encoding]::new($false)
        )
        $updatedCount++
        Write-Host "Updated $skillName"
    }
}

Write-Host "Skill frontmatter locale: $resolvedLanguage"
Write-Host "Updated files: $updatedCount"
