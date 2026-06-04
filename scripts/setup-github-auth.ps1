#requires -Version 7.0
[CmdletBinding()]
param(
    [switch]$UseToken,
    [string]$TokenEnvVar = 'GITHUB_TOKEN',
    [string]$Proxy = '',
    [switch]$NoProxyAutoDetect
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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
        Write-Host "Using proxy: $proxyUrl"
    }
}

function Invoke-GhAuthLoginWithToken {
    param(
        [Parameter(Mandatory = $true)][string]$GhPath,
        [Parameter(Mandatory = $true)][string]$Token
    )

    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $GhPath
    foreach ($argument in @('auth', 'login', '--hostname', 'github.com', '--git-protocol', 'https', '--with-token')) {
        $startInfo.ArgumentList.Add($argument)
    }
    $startInfo.RedirectStandardInput = $true
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.UseShellExecute = $false

    foreach ($name in @('HTTP_PROXY', 'HTTPS_PROXY', 'ALL_PROXY', 'NO_PROXY')) {
        if ([Environment]::GetEnvironmentVariable($name, 'Process')) {
            $startInfo.Environment[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
        }
    }

    $process = [System.Diagnostics.Process]::Start($startInfo)
    try {
        $process.StandardInput.WriteLine($Token)
        $process.StandardInput.Close()

        if (-not $process.WaitForExit(60000)) {
            try {
                $process.Kill($true)
            }
            catch {
                $process.Kill()
            }
            throw 'GitHub token authentication timed out after stdin was closed.'
        }

        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        if ($stdout) {
            Write-Host $stdout.TrimEnd()
        }
        if ($stderr) {
            Write-Host $stderr.TrimEnd()
        }

        if ($process.ExitCode -ne 0) {
            throw "GitHub token authentication failed with exit code $($process.ExitCode)."
        }
    }
    finally {
        $process.Dispose()
    }
}

$Gh = Get-GitHubCliPath
Set-GitHubProxyEnvironment -RequestedProxy $Proxy
Write-Host "Using GitHub CLI: $Gh"

if ($UseToken) {
    $tokenPlain = [Environment]::GetEnvironmentVariable($TokenEnvVar, 'Process')
    if (-not $tokenPlain) {
        $secureToken = Read-Host 'Paste GitHub PAT for persistent local gh login' -AsSecureString
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
        try {
            $tokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        }
        finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }

    if (-not $tokenPlain) {
        throw 'No GitHub token was provided.'
    }

    Remove-Item Env:\GITHUB_TOKEN -ErrorAction SilentlyContinue
    Remove-Item Env:\GH_TOKEN -ErrorAction SilentlyContinue
    Invoke-GhAuthLoginWithToken -GhPath $Gh -Token $tokenPlain
    $tokenPlain = $null
}
else {
    & $Gh auth status --hostname github.com
    if ($LASTEXITCODE -ne 0) {
        Write-Host 'Starting GitHub web login. Follow the browser/device-code prompt shown by GitHub CLI.'
        & $Gh auth login --hostname github.com --git-protocol https --web
        if ($LASTEXITCODE -ne 0) {
            throw 'GitHub authentication failed.'
        }
    }
}

& $Gh auth setup-git --hostname github.com
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to configure git authentication through GitHub CLI.'
}

& $Gh auth status --hostname github.com
if ($LASTEXITCODE -ne 0) {
    throw 'GitHub authentication is still unavailable after setup.'
}

$login = (& $Gh api user --jq '.login').Trim()
Write-Host ''
Write-Host "GitHub auth ready for: $login"
Write-Host 'Any Agent can now run scripts/publish-to-github.ps1 from this project.'
