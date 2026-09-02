# Bypass NRO

## Status of Bypass Methods (August 2026)

Since March 2025, Microsoft's `oobe\bypassnro` command has been removed from Windows 11 (24H2/25H2). The alternative `start ms-cxh:localonly` (and `start ms-cxh://setaddlocalonly`) was blocked starting with Insider build 26220.6772 (October 6, 2025). Whether that block reached the retail 25H2 branch (26200.x) has not been re-tested here, so check your own image before relying on it.

The **BypassNRO method in this project still works** because it uses Sysprep with a custom unattend.xml. This approach remains functional for now, because unattend.xml is part of Windows' official enterprise deployment tools and cannot easily be blocked by Microsoft without breaking enterprise scenarios.

Rufus, and on Pro/Enterprise "Set up for work or school" > "Sign-in options" > "Domain join instead", can still be used to create a local account.

**Timeline:**
- Removal of `oobe\bypassnro`: March 2025
- Blocking of `ms-cxh:localonly`: October 6, 2025 (Insider builds 26220.6772 / 26120.6772)

## Download and Run (Shift+F10 during OOBE)

### PowerShell
```powershell
iex(irm bypassnro.thectic.nl/bypass.ps1)
```

### CMD Wrapper
```powershell
powershell -c "iex(irm bypassnro.thectic.nl/bypass.ps1)"
```

`iex` cannot pass parameters. Use a script block for those:
```powershell
& ([scriptblock]::Create((irm bypassnro.thectic.nl/bypass.ps1))) -Force      # skip confirmation
& ([scriptblock]::Create((irm bypassnro.thectic.nl/bypass.ps1))) -NoReboot   # shut down instead
```

## Without Sysprep (faster)

Save [`unattend.xml`](https://bypassnro.thectic.nl/unattend.xml) to the root of the Windows 11 USB as `autounattend.xml`. Setup reads it during installation, so OOBE never asks for an account and there is no second reboot.

## Accounts

`unattend.xml` creates `Admin` (Administrators) and `User` (Users), both **without a password**, and signs `Admin` in automatically once. Set a password right after first logon.

## Notes

Only the `oobeSystem` pass applies. `Sysprep /oobe` without `/generalize` does not re-run `specialize`, so anything placed there is ignored. For debloating and tweaks use [WinDeploy](https://github.com/Stensel8/WinDeploy) or [WinUtil](https://github.com/ChrisTitusTech/winutil).

Troubleshooting: Sysprep logs to `C:\Windows\System32\Sysprep\Panther\setuperr.log`.
