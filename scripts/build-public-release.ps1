#requires -Version 7.0
[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path (Join-Path $PSScriptRoot '..') '..\codex-game-studios-godot-public'),
    [switch]$Clean
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

function Copy-ReleaseFile {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $source = Join-Path $SourceRoot $RelativePath
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        Write-Warning "Missing file, skipped: $RelativePath"
        return
    }

    $destination = Join-Path $OutputRoot $RelativePath
    $destinationParent = Split-Path -Parent $destination
    New-Item -ItemType Directory -Force -Path $destinationParent | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination -Force
    $script:CopiedEntries.Add($RelativePath) | Out-Null
}

function Copy-ReleaseDirectory {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $source = Join-Path $SourceRoot $RelativePath
    if (-not (Test-Path -LiteralPath $source -PathType Container)) {
        Write-Warning "Missing directory, skipped: $RelativePath"
        return
    }

    $destination = Join-Path $OutputRoot $RelativePath
    $destinationParent = Split-Path -Parent $destination
    New-Item -ItemType Directory -Force -Path $destinationParent | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force
    $script:CopiedEntries.Add($RelativePath) | Out-Null
}

function Set-TextFileContent {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )

    Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
}

function Sanitize-PublicRelease {
    $agentsPath = Join-Path $OutputRoot 'AGENTS.md'
    if (Test-Path -LiteralPath $agentsPath -PathType Leaf) {
        $agents = Get-Content -LiteralPath $agentsPath -Raw
        $agents = [regex]::Replace(
            $agents,
            '(?ms)## Local Tool Paths\r?\n\r?\n- \*\*Godot[^\r\n]*\r?\n- Use [^\r\n]*\r?\n',
            "## Local Tool Paths`r`n`r`n- Set your local Godot executable path in `AGENTS.local.md` or update this section after cloning.`r`n- For command-line export and headless tasks, use your local Godot console executable.`r`n"
        )
        $agents = [regex]::Replace(
            $agents,
            '- Use PowerShell 7 at `[^`]+`; avoid WindowsApps/MSIX launch targets\.',
            '- Use PowerShell 7+ (`pwsh`); avoid WindowsApps/MSIX launch targets when they cause shell issues.'
        )
        Set-TextFileContent -Path $agentsPath -Content $agents
    }

    $textExtensions = @('.md', '.yaml', '.yml', '.json', '.toml', '.sh', '.ps1', '.txt')
    $textFiles = Get-ChildItem -LiteralPath $OutputRoot -Recurse -File -Force |
        Where-Object {
            $textExtensions -contains $_.Extension.ToLowerInvariant() -or
            $_.Name -in @('LICENSE', 'NOTICE', 'README')
        }

    $sourceEscaped = [regex]::Escape($SourceRoot)
    $outputEscaped = [regex]::Escape($OutputRoot)
    foreach ($file in $textFiles) {
        $content = Get-Content -LiteralPath $file.FullName -Raw
        $updated = $content
        $updated = [regex]::Replace($updated, $sourceEscaped, '<local-source-repository-path>')
        $updated = [regex]::Replace($updated, $outputEscaped, '<public-release-output-path>')
        $updated = $updated -replace 'C:\\tmp\\pwsh-7\.6\.2-msix-extracted\\x64\\pwsh\.exe', 'pwsh'
        $updated = $updated -replace 'pwsh-7\.6\.2-msix-extracted', 'pwsh'
        if ($updated -ne $content) {
            Set-TextFileContent -Path $file.FullName -Content $updated
        }
    }
}

function Assert-PublicReleaseIsSanitized {
    $textExtensions = @('.md', '.yaml', '.yml', '.json', '.toml', '.sh', '.ps1', '.txt')
    $textFiles = Get-ChildItem -LiteralPath $OutputRoot -Recurse -File -Force |
        Where-Object {
            $textExtensions -contains $_.Extension.ToLowerInvariant() -or
            $_.Name -in @('LICENSE', 'NOTICE', 'README')
        }

    $forbiddenPatterns = @(
        'C:\\Users\\',
        [regex]::Escape($SourceRoot),
        [regex]::Escape($OutputRoot),
        'Godot_v4\.',
        'pwsh-7\.6\.2-msix-extracted'
    )

    $violations = @()
    foreach ($file in $textFiles) {
        foreach ($pattern in $forbiddenPatterns) {
            $match = Select-String -LiteralPath $file.FullName -Pattern $pattern -CaseSensitive:$false -ErrorAction SilentlyContinue
            if ($match) {
                $relative = [System.IO.Path]::GetRelativePath($OutputRoot, $file.FullName)
                $violations += "$relative => $pattern"
            }
        }
    }

    if ($violations.Count -gt 0) {
        throw "Public release still contains local/private markers: $($violations -join '; ')"
    }
}

$SourceRoot = Get-FullPath (Join-Path $PSScriptRoot '..')
$OutputRoot = Get-FullPath $OutputPath

$driveRoot = [System.IO.Path]::GetPathRoot($OutputRoot).TrimEnd('\', '/')
$outputComparable = $OutputRoot.TrimEnd('\', '/')
if ([string]::Equals($outputComparable, $driveRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to use a drive root as output path: $OutputRoot"
}

if (Test-IsSameOrChildPath -Candidate $OutputRoot -Root $SourceRoot) {
    throw "Refusing to write public release inside the source repository: $OutputRoot"
}

$outputParent = Split-Path -Parent $OutputRoot
New-Item -ItemType Directory -Force -Path $outputParent | Out-Null

if (Test-Path -LiteralPath $OutputRoot) {
    $existingItems = @(Get-ChildItem -LiteralPath $OutputRoot -Force)
    if ($existingItems.Count -gt 0) {
        if (-not $Clean) {
            throw "Output directory is not empty. Re-run with -Clean to replace it: $OutputRoot"
        }

        foreach ($item in $existingItems) {
            Remove-Item -LiteralPath $item.FullName -Recurse -Force
        }
    }
}
else {
    New-Item -ItemType Directory -Force -Path $OutputRoot | Out-Null
}

$CopiedEntries = [System.Collections.Generic.List[string]]::new()

$RootFiles = @(
    'AGENTS.md',
    'CONTRIBUTING.md',
    'LICENSE',
    'NOTICE.md',
    'README.md',
    'SECURITY.md',
    'UPGRADING.md',
    '.gitignore'
)

$Directories = @(
    '.agents\skills',
    '.codex\agents',
    '.codex\docs',
    '.codex\hooks\lib',
    '.codex\rules',
    '.githooks',
    'CCGS Skill Testing Framework',
    'docs\engine-reference\godot'
)

$Files = @(
    '.codex\hooks.json',
    '.codex\hooks\dangerous-command-policy.sh',
    '.codex\hooks\detect-gaps-lite.sh',
    '.codex\hooks\post-compact-restore.sh',
    '.codex\hooks\session-start.sh',
    '.codex\hooks\skill-change-reminder.sh',
    'docs\AGENTS.md',
    'docs\ccgs-codex-architecture.md',
    'docs\ccgs-codex-hook-adaptation-plan.md',
    'docs\COLLABORATIVE-DESIGN-PRINCIPLE.md',
    'docs\GITHUB-LISTING-COPY.md',
    'docs\GITHUB-PUBLISHING.md',
    'docs\WORKFLOW-GUIDE.md',
    'docs\engine-reference\README.md',
    'scripts\build-public-release.ps1',
    'scripts\publish-to-github.ps1',
    'scripts\setup-github-auth.ps1'
)

foreach ($file in $RootFiles) {
    Copy-ReleaseFile $file
}

foreach ($directory in $Directories) {
    Copy-ReleaseDirectory $directory
}

foreach ($file in $Files) {
    Copy-ReleaseFile $file
}

Sanitize-PublicRelease

$blockedRoots = @(
    '.git',
    '.claude',
    'design',
    'production',
    'prototypes',
    'src'
)

$blockedFound = @()
foreach ($blockedRoot in $blockedRoots) {
    $blockedPath = Join-Path $OutputRoot $blockedRoot
    if (Test-Path -LiteralPath $blockedPath) {
        $blockedFound += $blockedRoot
    }
}

if ($blockedFound.Count -gt 0) {
    throw "Public release contains blocked root entries: $($blockedFound -join ', ')"
}

$manifest = @(
    '# Public Release Manifest',
    '',
    "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')",
    'Source: local working tree (path omitted)',
    'Output: generated public release directory (path omitted)',
    '',
    'Included entries:',
    ($CopiedEntries | Sort-Object | ForEach-Object { "- $_" }),
    '',
    'Blocked source roots not copied:',
    ($blockedRoots | Sort-Object | ForEach-Object { "- $_" })
)

Set-Content -LiteralPath (Join-Path $OutputRoot 'PUBLIC-RELEASE-MANIFEST.md') -Value $manifest -Encoding UTF8

Assert-PublicReleaseIsSanitized

Write-Host "Public release generated:"
Write-Host "  $OutputRoot"
Write-Host ''
Write-Host 'Next: inspect the output directory before creating a GitHub repository.'
