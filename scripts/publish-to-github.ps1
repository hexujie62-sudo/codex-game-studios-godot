#requires -Version 7.0
[CmdletBinding()]
param(
    [string]$RepoName = 'codex-game-studios-godot',
    [string]$Owner = '',
    [ValidateSet('public', 'private')]
    [string]$Visibility = 'public',
    [string]$ReleaseTag = 'v0.1.0-alpha',
    [string]$ReleaseTitle = 'Codex Game Studios for Godot v0.1.0-alpha',
    [string]$Description = 'Unofficial Codex-first Godot game development workflow kit, adapted from Claude Code Game Studios.',
    [string]$Proxy = '',
    [switch]$NoProxyAutoDetect,
    [switch]$SkipRelease,
    [switch]$OpenInBrowser
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:GitProxyArgs = @()

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

function Get-GitHubCliPath {
    $command = Get-Command gh -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $candidates = @(
        'C:\Program Files\GitHub CLI\gh.exe',
        (Join-Path $env:LOCALAPPDATA 'GitHub CLI\gh.exe')
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return $candidate
        }
    }

    throw 'GitHub CLI is not installed. Install it with: winget install --id GitHub.cli -e --source winget'
}

function Test-LocalTcpPort {
    param(
        [Parameter(Mandatory = $true)][string]$HostName,
        [Parameter(Mandatory = $true)][int]$Port,
        [int]$TimeoutMilliseconds = 300
    )

    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $task = $client.ConnectAsync($HostName, $Port)
        return $task.Wait($TimeoutMilliseconds) -and $client.Connected
    }
    catch {
        return $false
    }
    finally {
        $client.Dispose()
    }
}

function Set-GitHubProxyEnvironment {
    param([string]$RequestedProxy)

    $proxyUrl = $RequestedProxy
    if (-not $proxyUrl -and -not $NoProxyAutoDetect) {
        if (Test-LocalTcpPort -HostName '127.0.0.1' -Port 7890) {
            $proxyUrl = 'http://127.0.0.1:7890'
        }
    }

    if ($proxyUrl) {
        $env:HTTP_PROXY = $proxyUrl
        $env:HTTPS_PROXY = $proxyUrl
        $env:ALL_PROXY = $proxyUrl
        $env:NO_PROXY = 'localhost,127.0.0.1,::1'
        $script:GitProxyArgs = @('-c', "http.proxy=$proxyUrl", '-c', "https.proxy=$proxyUrl")
        Write-Host "Using proxy: $proxyUrl"
    }
}

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [string]$WorkingDirectory = ''
    )

    if ($WorkingDirectory) {
        Push-Location -LiteralPath $WorkingDirectory
    }

    try {
        & $FilePath @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "Command failed: $FilePath $($Arguments -join ' ')"
        }
    }
    finally {
        if ($WorkingDirectory) {
            Pop-Location
        }
    }
}

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$WorkingDirectory
    )

    Invoke-Checked -FilePath 'git' -Arguments ($script:GitProxyArgs + $Arguments) -WorkingDirectory $WorkingDirectory
}

function Get-GitOutput {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$WorkingDirectory
    )

    Push-Location -LiteralPath $WorkingDirectory
    try {
        $gitArgs = $script:GitProxyArgs + $Arguments
        $output = & git @gitArgs
        if ($LASTEXITCODE -ne 0) {
            throw "Command failed: git $($Arguments -join ' ')"
        }
        return ($output -join "`n").Trim()
    }
    finally {
        Pop-Location
    }
}

function Test-GhCommand {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)

    & $Gh @Arguments *> $null
    return $LASTEXITCODE -eq 0
}

function Sync-StagingToReleaseRepo {
    param(
        [Parameter(Mandatory = $true)][string]$StagingRoot,
        [Parameter(Mandatory = $true)][string]$ReleaseRoot
    )

    $stagingFull = Get-FullPath $StagingRoot
    $releaseFull = Get-FullPath $ReleaseRoot

    if (-not (Test-Path -LiteralPath $stagingFull -PathType Container)) {
        throw "Missing staging directory: $stagingFull"
    }

    New-Item -ItemType Directory -Force -Path $releaseFull | Out-Null

    foreach ($item in Get-ChildItem -LiteralPath $releaseFull -Force) {
        if ($item.Name -eq '.git') {
            continue
        }

        $itemPath = Get-FullPath $item.FullName
        if (-not (Test-IsSameOrChildPath -Candidate $itemPath -Root $releaseFull)) {
            throw "Refusing to remove path outside release directory: $itemPath"
        }

        Remove-Item -LiteralPath $itemPath -Recurse -Force
    }

    foreach ($item in Get-ChildItem -LiteralPath $stagingFull -Force) {
        $destination = Join-Path $releaseFull $item.Name
        Copy-Item -LiteralPath $item.FullName -Destination $destination -Recurse -Force
    }
}

function Get-ReleaseNotes {
    return @'
First public alpha of Codex Game Studios for Godot.

This release includes:

- Codex-first CCGS workflow conversion
- Godot-focused technical defaults
- 49 agent definitions
- 76 Skills
- Lightweight Codex hooks and local Git hooks
- Multi-window lane workflow
- File-backed session state and handoff guidance
- Skill route index
- CCGS Skill Testing Framework
- Public release generator with whitelist copying and path sanitization

This is an unofficial MIT-licensed derivative of Claude Code Game Studios.
It is not affiliated with OpenAI, Anthropic, Claude, Codex, Godot, or the original CCGS author.
'@
}

$SourceRoot = Get-FullPath (Join-Path $PSScriptRoot '..')
$BuildScript = Join-Path $SourceRoot 'scripts\build-public-release.ps1'
$StagingRoot = Get-FullPath (Join-Path $SourceRoot '..\codex-game-studios-godot-public-staging')
$ReleaseRoot = Get-FullPath (Join-Path $SourceRoot '..\codex-game-studios-godot-public')
$Gh = Get-GitHubCliPath
Set-GitHubProxyEnvironment -RequestedProxy $Proxy

Write-Host "Using GitHub CLI: $Gh"
& $Gh auth status --hostname github.com
if ($LASTEXITCODE -ne 0) {
    throw 'GitHub CLI is not authenticated. Run scripts/setup-github-auth.ps1 once, then retry.'
}

Push-Location -LiteralPath $SourceRoot
try {
    & $BuildScript -OutputPath $StagingRoot -Clean
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed: $BuildScript -OutputPath $StagingRoot -Clean"
    }
}
finally {
    Pop-Location
}

if (-not (Test-Path -LiteralPath (Join-Path $ReleaseRoot '.git') -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $ReleaseRoot | Out-Null
    Invoke-Git -Arguments @('init', '-b', 'main') -WorkingDirectory $ReleaseRoot
}

Sync-StagingToReleaseRepo -StagingRoot $StagingRoot -ReleaseRoot $ReleaseRoot

Invoke-Git -Arguments @('add', '.') -WorkingDirectory $ReleaseRoot
$status = Get-GitOutput -Arguments @('status', '--porcelain') -WorkingDirectory $ReleaseRoot
if ($status) {
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
    Invoke-Git -Arguments @('commit', '-m', "chore: publish Codex Game Studios for Godot ($timestamp)") -WorkingDirectory $ReleaseRoot
}
else {
    Write-Host 'No local release-package changes to commit.'
}

if (-not $Owner) {
    $Owner = (& $Gh api user --jq '.login').Trim()
}

$FullRepo = "$Owner/$RepoName"
$RemoteUrl = "https://github.com/$FullRepo.git"
Write-Host "Target GitHub repository: $FullRepo"

$repoExists = Test-GhCommand -Arguments @('repo', 'view', $FullRepo)
if (-not $repoExists) {
    $visibilityFlag = if ($Visibility -eq 'public') { '--public' } else { '--private' }
    Invoke-Checked -FilePath $Gh -Arguments @('repo', 'create', $FullRepo, $visibilityFlag, '--description', $Description, '--source', $ReleaseRoot, '--remote', 'origin') -WorkingDirectory $ReleaseRoot
}
else {
    Push-Location -LiteralPath $ReleaseRoot
    try {
        $remoteNames = Get-GitOutput -Arguments @('remote') -WorkingDirectory $ReleaseRoot
        $remoteNameList = if ($remoteNames) { $remoteNames -split "`n" } else { @() }
        if ($remoteNameList -contains 'origin') {
            Invoke-Git -Arguments @('remote', 'set-url', 'origin', $RemoteUrl) -WorkingDirectory $ReleaseRoot
        }
        else {
            Invoke-Git -Arguments @('remote', 'add', 'origin', $RemoteUrl) -WorkingDirectory $ReleaseRoot
        }
    }
    finally {
        Pop-Location
    }
}

Invoke-Checked -FilePath $Gh -Arguments @('auth', 'setup-git', '--hostname', 'github.com') -WorkingDirectory $ReleaseRoot

$topicArgs = @(
    'repo', 'edit', $FullRepo,
    '--description', $Description,
    '--add-topic', 'codex',
    '--add-topic', 'godot',
    '--add-topic', 'gamedev',
    '--add-topic', 'ai-assisted-development',
    '--add-topic', 'skills',
    '--add-topic', 'agents',
    '--add-topic', 'workflow',
    '--add-topic', 'gdscript',
    '--add-topic', 'indie-game-development',
    '--add-topic', 'automation'
)
Invoke-Checked -FilePath $Gh -Arguments $topicArgs -WorkingDirectory $ReleaseRoot

Invoke-Git -Arguments @('push', '-u', 'origin', 'main') -WorkingDirectory $ReleaseRoot

$releaseExists = Test-GhCommand -Arguments @('release', 'view', $ReleaseTag, '-R', $FullRepo)
if (-not $releaseExists -and -not $SkipRelease) {
    Invoke-Git -Arguments @('tag', '-f', '-a', $ReleaseTag, '-m', $ReleaseTitle) -WorkingDirectory $ReleaseRoot
    Invoke-Git -Arguments @('push', 'origin', $ReleaseTag, '--force') -WorkingDirectory $ReleaseRoot

    $notesFile = New-TemporaryFile
    try {
        Set-Content -LiteralPath $notesFile.FullName -Value (Get-ReleaseNotes) -Encoding UTF8
        Invoke-Checked -FilePath $Gh -Arguments @('release', 'create', $ReleaseTag, '-R', $FullRepo, '--title', $ReleaseTitle, '--notes-file', $notesFile.FullName, '--prerelease', '--verify-tag') -WorkingDirectory $ReleaseRoot
    }
    finally {
        Remove-Item -LiteralPath $notesFile.FullName -Force -ErrorAction SilentlyContinue
    }
}
elseif ($releaseExists) {
    Write-Host "Release already exists: $ReleaseTag"
}

if ($OpenInBrowser) {
    Invoke-Checked -FilePath $Gh -Arguments @('repo', 'view', $FullRepo, '--web') -WorkingDirectory $ReleaseRoot
}

Write-Host ''
Write-Host "Published: https://github.com/$FullRepo"
Write-Host "Local release repo: $ReleaseRoot"
