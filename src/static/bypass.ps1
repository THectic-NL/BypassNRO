# BypassNRO - https://bypassnro.thectic.nl/
#
# Sets up Windows 11 with a local account instead of a Microsoft account.
# Downloads unattend.xml, writes it to C:\Windows\Panther\unattend.xml and runs
# Sysprep.exe /oobe /unattend:<file> /reboot. On the next boot OOBE reads the
# answer file, creates the accounts Admin and User, and skips the account
# screens.
#
# Run elevated during OOBE (Shift+F10). THIS RESTARTS THE COMPUTER.

#Requires -Version 5.1

$ErrorActionPreference = 'Stop'

# Invoke-WebRequest's progress bar makes downloads dramatically slower in
# Windows PowerShell, and it renders badly in the OOBE console.
$ProgressPreference = 'SilentlyContinue'

# No TLS version is pinned on purpose: Windows 11 already negotiates TLS 1.2/1.3
# through SystemDefault, and hardcoding one stops the OS from picking something
# better later.

$site        = 'https://bypassnro.thectic.nl/'
$scriptUrl   = 'https://bypassnro.thectic.nl/bypass.ps1'
$unattendUrl = 'https://bypassnro.thectic.nl/unattend.xml'
$destination = 'C:\Windows\Panther\unattend.xml'

Write-Host ''
Write-Host '  BypassNRO - local account setup for Windows 11' -ForegroundColor Cyan
Write-Host '  ---------------------------------------------' -ForegroundColor Cyan
Write-Host ''

# --- Elevation --------------------------------------------------------------

$identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]$identity
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host '  This script must run as Administrator.' -ForegroundColor Red
    Write-Host '  The console you get with Shift+F10 during OOBE is already elevated.' -ForegroundColor Red
    Write-Host ''
    return
}

# --- Are you actually in OOBE? ----------------------------------------------

# Windows runs OOBE under a temporary account called defaultuser0, so that is
# who you are in the console Shift+F10 opens. Any other account means this
# computer is most likely already set up, and Sysprep would reset it.
$currentUser = ($identity.Name -split '\\')[-1]
if ($currentUser -ne 'defaultuser0') {
    Write-Host '  WARNING - this does not look like Windows setup (OOBE).' -ForegroundColor Red
    Write-Host ''
    Write-Host "  You are signed in as '$currentUser'. During OOBE Windows signs you in" -ForegroundColor Red
    Write-Host "  as 'defaultuser0', so this computer looks like it is already set up." -ForegroundColor Red
    Write-Host ''
    Write-Host '  Continuing means Sysprep sends this computer back through Windows' -ForegroundColor Red
    Write-Host '  setup and restarts it. That cannot be undone from inside Windows.' -ForegroundColor Red
    Write-Host ''
    Write-Host '  Are you sure you want to continue?' -ForegroundColor Red
    Write-Host ''

    $sure = Read-Host '  Type CONTINUE to go on, anything else to stop'
    if ($sure.Trim() -ne 'CONTINUE') {
        Write-Host ''
        Write-Host '  Cancelled. Nothing was changed.' -ForegroundColor Cyan
        Write-Host ''
        return
    }
    Write-Host ''
}

# --- Download ---------------------------------------------------------------

# Download to a temporary folder first, so a failed or truncated transfer cannot
# leave a broken answer file behind in C:\Windows\Panther.
$temp = Join-Path ([IO.Path]::GetTempPath()) ('bypassnro-{0}' -f [guid]::NewGuid())
New-Item -Path $temp -ItemType Directory -Force | Out-Null

$answerFile = Join-Path $temp 'unattend.xml'
$scriptCopy = Join-Path $temp 'bypass.ps1'

Write-Host "  Downloading unattend.xml and bypass.ps1 from $site" -ForegroundColor Cyan
try {
    # bypass.ps1 is downloaded a second time purely so its checksum can be shown
    # below; only unattend.xml is used for anything.
    Invoke-WebRequest -Uri $unattendUrl -OutFile $answerFile -UseBasicParsing
    Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptCopy -UseBasicParsing
} catch {
    Write-Host ''
    Write-Host "  Download failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host '  Check the network connection and try again. Nothing was changed.' -ForegroundColor Red
    Write-Host ''
    Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
    return
}

# Make sure this really is the answer file and not a captive-portal login page
# or a server error page.
try {
    $xml = New-Object System.Xml.XmlDocument
    $xml.Load($answerFile)
    if ($xml.DocumentElement.LocalName -ne 'unattend') {
        throw "its root element is <$($xml.DocumentElement.LocalName)>, expected <unattend>"
    }
} catch {
    Write-Host ''
    Write-Host "  The downloaded unattend.xml is not a Windows answer file: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host '  Nothing was changed. Try again, or download the file manually from' -ForegroundColor Red
    Write-Host "  $site" -ForegroundColor Red
    Write-Host ''
    Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
    return
}

# --- Checksums --------------------------------------------------------------

$scriptHash   = (Get-FileHash -LiteralPath $scriptCopy -Algorithm SHA256).Hash.ToLower()
$unattendHash = (Get-FileHash -LiteralPath $answerFile -Algorithm SHA256).Hash.ToLower()

Write-Host ''
Write-Host '  CHECK THIS FIRST - SHA256 of the downloaded files:' -ForegroundColor Yellow
Write-Host ''
Write-Host '    bypass.ps1    ' -NoNewline
Write-Host $scriptHash -ForegroundColor White
Write-Host '    unattend.xml  ' -NoNewline
Write-Host $unattendHash -ForegroundColor White
Write-Host ''
Write-Host "  Compare both values with the checksums published on $site" -ForegroundColor Yellow
Write-Host '  If either one differs, answer n below and do not continue.' -ForegroundColor Yellow

# --- Confirmation -----------------------------------------------------------

Write-Host ''
Write-Host '  What happens when you continue:' -ForegroundColor Yellow
Write-Host ''
Write-Host "    1. unattend.xml is copied to $destination"
Write-Host '    2. Sysprep runs and RESTARTS this computer into OOBE'
Write-Host '    3. OOBE reads the answer file and creates two local accounts:'
Write-Host ''
Write-Host '         Admin   administrator, NO password, signed in automatically once'
Write-Host '         User    standard user, NO password'
Write-Host ''
Write-Host '       Those are the exact account names. OOBE no longer asks for a'
Write-Host '       Microsoft account, a name, or a password.'
Write-Host '    4. Give both accounts a password right after the first sign-in.'
Write-Host ''
Write-Host '  Anything unsaved on this computer is lost when it restarts.' -ForegroundColor Yellow
Write-Host ''

$answer = Read-Host '  Continue? [y/N]'
if ($answer -notmatch '^\s*(y|yes)\s*$') {
    Write-Host ''
    Write-Host '  Cancelled. Nothing was changed.' -ForegroundColor Cyan
    Write-Host ''
    Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
    return
}

# --- Apply ------------------------------------------------------------------

$panther = Split-Path -Path $destination -Parent
if (-not (Test-Path -LiteralPath $panther)) {
    New-Item -Path $panther -ItemType Directory -Force | Out-Null
}
Copy-Item -LiteralPath $answerFile -Destination $destination -Force
Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ''
Write-Host "  Answer file written to $destination" -ForegroundColor Green
Write-Host '  Running Sysprep. The computer restarts on its own - this can take a minute.' -ForegroundColor Green
Write-Host ''

$sysprep = Join-Path $env:SystemRoot 'System32\Sysprep\Sysprep.exe'
try {
    $proc = Start-Process -FilePath $sysprep -ArgumentList '/oobe', "/unattend:`"$destination`"", '/reboot' -Wait -PassThru
} catch {
    Write-Host "  Could not start Sysprep ($sysprep): $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ''
    return
}

# Sysprep restarts the machine itself, so reaching this point with a non-zero
# exit code means it refused to run.
if ($proc.ExitCode -ne 0) {
    Write-Host "  Sysprep stopped with exit code $($proc.ExitCode) and the computer will not restart." -ForegroundColor Red
    Write-Host '  The reason is logged in C:\Windows\System32\Sysprep\Panther\setuperr.log' -ForegroundColor Red
    Write-Host ''
}
