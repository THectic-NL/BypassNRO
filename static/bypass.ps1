<#
.SYNOPSIS
    Sets up Windows 11 with a local account by applying an unattend.xml through Sysprep.

.DESCRIPTION
    Downloads an answer file from this repository, writes it to
    C:\Windows\Panther\unattend.xml and runs:

        Sysprep.exe /oobe /unattend:<path> /reboot

    On the next boot, OOBE processes the answer file's oobeSystem pass, which
    creates local accounts and skips the Microsoft-account sign-in screens.

    Unlike `oobe\bypassnro` (removed in March 2025) and `ms-cxh:localonly`
    (blocked from October 2025), unattend.xml is part of Windows' supported
    deployment tooling, so it is not something Microsoft can remove without
    breaking enterprise imaging.

.PARAMETER UnattendUrl
    Answer file to download. Defaults to the copy in this repository.

.PARAMETER Destination
    Where to write the answer file. Defaults to C:\Windows\Panther\unattend.xml.

.PARAMETER Force
    Skip the confirmation prompt.

.PARAMETER NoReboot
    Run Sysprep with /shutdown instead of /reboot.

.EXAMPLE
    & ([scriptblock]::Create((irm bypassnro.stensel.nl)))

    Run from an elevated prompt (Shift+F10 during OOBE gives you one).
    See the README for the shorter pipe-to-execute one-liner.

.EXAMPLE
    & ([scriptblock]::Create((irm bypassnro.stensel.nl))) -Force

    Same, without the confirmation prompt. The short one-liner form cannot pass
    parameters, so use a script block when you need them.

.NOTES
    Requires elevation. Designed for Windows PowerShell 5.1, which is what
    Shift+F10 gives you during OOBE.

    THIS REBOOTS THE MACHINE and sends it back through OOBE. Any work in
    progress is lost.
#>

#Requires -Version 5.1

[CmdletBinding()]
param(
    [string]$UnattendUrl = 'https://raw.githubusercontent.com/Thectic-NL/BypassNRO/main/unattend.xml',
    [string]$Destination = 'C:\Windows\Panther\unattend.xml',
    [switch]$Force,
    [switch]$NoReboot
)

$ErrorActionPreference = 'Stop'

# Invoke-WebRequest's progress bar makes downloads dramatically slower in
# Windows PowerShell, and it renders badly in the OOBE console.
$ProgressPreference = 'SilentlyContinue'

function Assert-Elevation {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error 'This script must be run elevated (as Administrator). Exiting.'
        exit 1
    }
}

function Save-Unattend {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$OutPath
    )

    $dir = Split-Path -Path $OutPath -Parent
    if (-not (Test-Path -Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }

    # Download to a temporary file first, so a failed or truncated transfer
    # cannot leave a broken answer file in C:\Windows\Panther.
    $temp = Join-Path ([System.IO.Path]::GetTempPath()) ("unattend-{0}.xml" -f [guid]::NewGuid())

    Write-Host "Downloading answer file from: $Url" -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $Url -UseBasicParsing -OutFile $temp -ErrorAction Stop
    } catch {
        Write-Warning "Invoke-WebRequest failed: $($_.Exception.Message). Trying Start-BitsTransfer..."
        try {
            Start-BitsTransfer -Source $Url -Destination $temp -ErrorAction Stop
        } catch {
            Write-Error "Failed to download $Url - $($_.Exception.Message)"
            exit 2
        }
    }

    if (-not (Test-Path -Path $temp)) {
        Write-Error "Download reported success but no file was written to $temp"
        exit 3
    }

    # Make sure we got XML and not a captive-portal page or a GitHub error.
    try {
        $xml = New-Object System.Xml.XmlDocument
        $xml.Load($temp)
        if ($xml.DocumentElement.LocalName -ne 'unattend') {
            throw "root element is <$($xml.DocumentElement.LocalName)>, expected <unattend>"
        }
    } catch {
        Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
        Write-Error "Downloaded file is not a valid unattend answer file: $($_.Exception.Message)"
        exit 3
    }

    # Keep whatever was there before; Windows may already have an answer file.
    if (Test-Path -LiteralPath $OutPath) {
        $backup = "$OutPath.bak-{0}" -f (Get-Date -Format 'yyyyMMdd-HHmmss')
        Copy-Item -LiteralPath $OutPath -Destination $backup -Force -ErrorAction SilentlyContinue
        Write-Host "Existing answer file backed up to $backup" -ForegroundColor DarkGray
    }

    Move-Item -LiteralPath $temp -Destination $OutPath -Force
}

function Start-Sysprep {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)][string]$UnattendPath,
        [switch]$Shutdown
    )

    $sysprep = Join-Path -Path $env:SystemRoot -ChildPath 'System32\Sysprep\Sysprep.exe'
    if (-not (Test-Path -Path $sysprep)) {
        Write-Error "Sysprep not found at $sysprep"
        exit 4
    }

    $finish = if ($Shutdown) { '/shutdown' } else { '/reboot' }
    $argumentList = @('/oobe', "/unattend:`"$UnattendPath`"", $finish)

    Write-Host "Running: $sysprep $($argumentList -join ' ')" -ForegroundColor Yellow
    if (-not $PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Run Sysprep /oobe $finish")) {
        return
    }

    $proc = Start-Process -FilePath $sysprep -ArgumentList $argumentList -Wait -PassThru

    # Sysprep restarts the machine itself, so a non-zero code here means it
    # refused to run - check C:\Windows\System32\Sysprep\Panther\setuperr.log.
    if ($proc.ExitCode -ne 0) {
        Write-Error "Sysprep exited with code $($proc.ExitCode). See C:\Windows\System32\Sysprep\Panther\setuperr.log"
        exit $proc.ExitCode
    }
}

Assert-Elevation

# No TLS version is pinned here on purpose. Windows 11 (the only supported
# target) already negotiates TLS 1.2/1.3 through SystemDefault, and hardcoding
# a version stops the OS handing us a better protocol later. Pinning is only
# needed on Windows 7/8.1-era images, which this script does not support.

if (-not $Force) {
    Write-Host ""
    Write-Host "This will run Sysprep and $(if ($NoReboot) { 'shut down' } else { 'restart' }) the computer." -ForegroundColor Yellow
    Write-Host "Windows will go back through OOBE and create the local accounts" -ForegroundColor Yellow
    Write-Host "defined in the answer file. Anything unsaved will be lost." -ForegroundColor Yellow
    Write-Host ""
    $answer = Read-Host "Continue? [y/N]"
    if ($answer -notmatch '^(y|yes)$') {
        Write-Host "Cancelled. Nothing was changed." -ForegroundColor Cyan
        exit 0
    }
}

Write-Host "Using destination: $Destination" -ForegroundColor Green
Save-Unattend -Url $UnattendUrl -OutPath $Destination
Write-Host "Answer file saved to $Destination" -ForegroundColor Green

Start-Sysprep -UnattendPath $Destination -Shutdown:$NoReboot
