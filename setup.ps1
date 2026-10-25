#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Sets up a Windows development machine with Chocolatey.

.DESCRIPTION
    Installs Chocolatey (if missing), then installs packages grouped by category:
    Favorites, Languages, CLIs, Monitoring, VSCodeExtensions and NonEssentials.
    Failed packages are collected and listed at the end instead of stopping the run.
    A full transcript is written to the log file.

.PARAMETER Skip
    One or more categories to leave out.
    Valid values: Favorites, Languages, CLIs, Monitoring, VSCodeExtensions, NonEssentials

.PARAMETER Only
    Install only these categories (overrides -Skip).

.PARAMETER IncludeOffice
    Also install Microsoft 365 (64-bit, without Publisher, OneDrive, OneNote, Lync, Groove).

.PARAMETER SkipOracle
    Don't install Oracle SQL Developer (it needs an Oracle account to download).

.PARAMETER LogPath
    Where to write the transcript. Defaults to %TEMP%\windows-setup-<timestamp>.log

.EXAMPLE
    .\setup.ps1
    Installs everything except Microsoft Office.

.EXAMPLE
    .\setup.ps1 -Skip NonEssentials,Monitoring
    Lean work machine.

.EXAMPLE
    .\setup.ps1 -Only CLIs -SkipOracle
    Only the cloud and Kubernetes CLIs.

.NOTES
    Run from an elevated PowerShell:
        Set-ExecutionPolicy Bypass -Scope Process -Force
        .\setup.ps1
#>
[CmdletBinding()]
param(
    [ValidateSet('Favorites', 'Languages', 'CLIs', 'Monitoring', 'VSCodeExtensions', 'NonEssentials')]
    [string[]]$Skip = @(),

    [ValidateSet('Favorites', 'Languages', 'CLIs', 'Monitoring', 'VSCodeExtensions', 'NonEssentials')]
    [string[]]$Only = @(),

    [switch]$IncludeOffice,

    [switch]$SkipOracle,

    [string]$LogPath = (Join-Path $env:TEMP ("windows-setup-{0:yyyyMMdd-HHmmss}.log" -f (Get-Date)))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

#region ---- Package lists ------------------------------------------------------

$Packages = [ordered]@{
    Favorites        = @(
        'jdk8'
        'googlechrome'
        'microsoft-edge'
        'notepadplusplus'
        '7zip'
        'vscode'
        'filezilla'
        'winscp'
        'pgptool'
        'adobereader'
        'vlc'
        'git'
        'zoom'
        'mobaxterm'
        'tigervnc'
        'gnupg'
        'sysinternals'
        'curl'
        'virtualbox'
        'tortoisegit'
        'postman'
        'drawio'
        'citrix-workspace'      # replaces deprecated citrix-receiver
        'cpu-z'
        'intellijidea-community'
        'pycharm-community'
        'dbeaver'
        'github-desktop'
        'openssl'
        'pgadmin4'
    )

    Languages        = @(
        'golang'
        'python3'
        'nodejs'
        'chef-workstation'
        'terraform'
        'ruby'
        'typescript'
        'graalvm-java8'
        'xampp-80'
        'docker-desktop'
        'mongodb'
        'mongodb-compass'
        'k3d'
        'wingide101'
        'vscode-intellicode'
        'traefik'
        'tomcat'
    )

    CLIs             = @(
        'azure-cli'
        'awscli'
        'az.powershell'
        'argocd-cli'
        'gh'
        'kubernetes-cli'
        'serverless'
    )

    Monitoring       = @(
        'prometheus-windows-exporter.install'
        'wireshark'
        'sandboxie-plus'
        'speedtest'
        'teamviewer'
        'adexplorer'
        'sysmon'
        'autoruns'
        'procmon'
        'hashmyfiles'
        'malwarebytes'
        'ccleaner'
        'rdmfree'
    )

    VSCodeExtensions = @(
        'vscode-spring-boot'
        'vscode-mongodb'
    )

    NonEssentials    = @(
        'itunes'
        'dropbox'
        'slack'
        'rocketchat'
        'signal'
        'brave'
        'evernote'
        'chromium'
        'electron'
        'etcher'
        'tableau-public'
        'darktable'
        'whatsapp'
        'ubiquiti-unifi-controller'
        'libreoffice-fresh'
    )
}

# Python packages installed with pip after python3 (numpy is not a Chocolatey package)
$PipPackages = @('numpy')

#endregion

#region ---- Helpers ------------------------------------------------------------

# choco exit codes that mean success (1641/3010 = success, reboot required)
$SuccessCodes = @(0, 1641, 3010)
$RebootCodes  = @(1641, 3010)

$script:Failed         = [System.Collections.Generic.List[string]]::new()
$script:Installed      = [System.Collections.Generic.List[string]]::new()
$script:RebootRequired = $false

function Write-Section {
    param([string]$Title)
    Write-Host ''
    Write-Host ('=' * 70) -ForegroundColor DarkCyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host ('=' * 70) -ForegroundColor DarkCyan
}

function Update-PathFromRegistry {
    # Pick up PATH changes made by installers without restarting the shell
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user    = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machine;$user"
}

function Install-Chocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host 'Chocolatey is already installed.' -ForegroundColor Green
        return
    }

    Write-Host 'Installing Chocolatey...' -ForegroundColor Yellow
    [System.Net.ServicePointManager]::SecurityProtocol =
        [System.Net.ServicePointManager]::SecurityProtocol -bor 3072   # TLS 1.2
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(
        'https://community.chocolatey.org/install.ps1'))

    Update-PathFromRegistry
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        throw 'Chocolatey install finished but choco is not on PATH. Reopen PowerShell and run the script again.'
    }
}

function Install-ChocoPackage {
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$PackageParameters
    )

    Write-Host "-> $Name" -ForegroundColor White -NoNewline

    # Native stderr must not become a terminating error under Windows PowerShell 5.1
    $ErrorActionPreference = 'Continue'

    $chocoArgs = @('install', $Name, '-y', '--no-progress', '--limit-output')
    if ($PackageParameters) { $chocoArgs += @('--params', $PackageParameters) }

    $output = & choco @chocoArgs 2>&1
    $code   = $LASTEXITCODE

    if ($code -in $SuccessCodes) {
        $script:Installed.Add($Name)
        if ($code -in $RebootCodes) {
            $script:RebootRequired = $true
            Write-Host '  OK (reboot required)' -ForegroundColor Yellow
        }
        else {
            Write-Host '  OK' -ForegroundColor Green
        }
    }
    else {
        $script:Failed.Add($Name)
        Write-Host "  FAILED (exit $code)" -ForegroundColor Red
        $output | Select-Object -Last 5 | ForEach-Object { Write-Host "     $_" -ForegroundColor DarkGray }
    }
}

function Install-OracleSqlDeveloper {
    Write-Host ''
    Write-Host 'Oracle SQL Developer needs an Oracle account to download.' -ForegroundColor Yellow
    $cred = Get-Credential -Message 'Oracle account (Cancel to skip SQL Developer)'

    if (-not $cred) {
        Write-Host '-> oracle-sql-developer  SKIPPED' -ForegroundColor DarkYellow
        return
    }

    $user = $cred.UserName
    $pass = $cred.GetNetworkCredential().Password
    Install-ChocoPackage -Name 'oracle-sql-developer' -PackageParameters "'/Username:$user /Password:$pass'"
    Remove-Variable pass, cred -ErrorAction SilentlyContinue
}

function Install-PipPackages {
    param([string[]]$Names)

    $ErrorActionPreference = 'Continue'
    Update-PathFromRegistry
    $python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $python) {
        Write-Host 'Python not found on PATH; skipping pip packages.' -ForegroundColor DarkYellow
        $Names | ForEach-Object { $script:Failed.Add("pip:$_") }
        return
    }

    foreach ($name in $Names) {
        Write-Host "-> pip $name" -ForegroundColor White -NoNewline
        & $python.Source -m pip install --upgrade $name --quiet 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $script:Installed.Add("pip:$name")
            Write-Host '  OK' -ForegroundColor Green
        }
        else {
            $script:Failed.Add("pip:$name")
            Write-Host "  FAILED (exit $LASTEXITCODE)" -ForegroundColor Red
        }
    }
}

#endregion

#region ---- Main ---------------------------------------------------------------

Start-Transcript -Path $LogPath | Out-Null
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

try {
    Write-Section 'Chocolatey'
    Install-Chocolatey

    # Stop asking for confirmation on every package
    choco feature enable -n allowGlobalConfirmation | Out-Null

    # Work out which categories to install
    $categories = if ($Only.Count) { $Only } else { $Packages.Keys | Where-Object { $_ -notin $Skip } }

    foreach ($category in $Packages.Keys) {
        if ($category -notin $categories) { continue }

        Write-Section $category
        foreach ($pkg in $Packages[$category]) {
            Install-ChocoPackage -Name $pkg
        }

        if ($category -eq 'Favorites' -and -not $SkipOracle) {
            Install-OracleSqlDeveloper
        }

        if ($category -eq 'Languages' -and $PipPackages.Count) {
            Install-PipPackages -Names $PipPackages
        }
    }

    if ($IncludeOffice) {
        Write-Section 'Microsoft Office'
        Install-ChocoPackage -Name 'microsoft-office-deployment' `
            -PackageParameters "'/64bit /Shared /Product:O365ProPlusRetail /Exclude=Publisher,OneDrive,OneNote,Lync,Groove'"
    }
}
finally {
    $stopwatch.Stop()

    Write-Section 'Summary'
    Write-Host ("Installed : {0}" -f $script:Installed.Count) -ForegroundColor Green
    Write-Host ("Failed    : {0}" -f $script:Failed.Count) -ForegroundColor ($(if ($script:Failed.Count) { 'Red' } else { 'Green' }))
    Write-Host ("Duration  : {0:hh\:mm\:ss}" -f $stopwatch.Elapsed)
    Write-Host ("Log       : {0}" -f $LogPath)

    if ($script:Failed.Count) {
        Write-Host ''
        Write-Host 'Failed packages (retry with: choco install <name> --force):' -ForegroundColor Red
        $script:Failed | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    }

    if ($script:RebootRequired) {
        Write-Host ''
        Write-Host 'One or more packages need a reboot to finish installing.' -ForegroundColor Yellow
    }

    Stop-Transcript | Out-Null
}

if ($script:Failed.Count) { exit 1 } else { exit 0 }

#endregion
