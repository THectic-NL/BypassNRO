---
title: ""
toc: false
---

<div class="hx-mt-6 hx-mb-6">
{{< hextra/hero-headline >}}
  BypassNRO
{{< /hextra/hero-headline >}}
</div>

<div class="hx-mb-12">
{{< hextra/hero-subtitle >}}
  Windows OOBE bypass using Sysprep and unattend.xml — a reliable method that still works
{{< /hextra/hero-subtitle >}}
</div>

<div class="hx-mb-6">
{{< hextra/hero-badge link="https://raw.githubusercontent.com/Thectic-NL/BypassNRO/main/bypass.ps1" >}}
  <span>Download script</span>
  {{< icon name="download" attributes="height=20" >}}
{{< /hextra/hero-badge >}}
</div>

<div class="hx-mt-6"></div>

## File Checksums

**SHA256:**
- `bypass.ps1`: `3315608fdc5393ead7c015cedfbd61fb5737abd403d405c5bd64c6624c303003`
- `unattend.xml`: `a7bdc3c7ee9046ddaf8caf9b198c915d7ad5b55814a5fccbcf07ca4480b8b877`

Verify with: `sha256sum bypass.ps1 unattend.xml`

{{< callout type="info" >}}
**Why this method still works:** Since March 2025, Microsoft has removed the `oobe\bypassnro` command from Windows 11 (24H2/25H2). The alternative `start ms-cxh:localonly` was blocked starting with Insider build 26220.6772 (October 6, 2025). Whether that block reached the retail 25H2 branch has not been re-tested, so check your own image before relying on it.

This Sysprep-based approach using unattend.xml continues to work because it's part of Windows' official enterprise deployment tools and cannot easily be blocked without breaking enterprise scenarios.

See the [GitHub repository](https://github.com/Thectic-NL/BypassNRO) for open issues and updates.
{{< /callout >}}

## Usage

Press **Shift+F10** during Windows OOBE (Out of Box Experience) and run:

### PowerShell
```powershell
iex(irm bypassnro.thectic.nl)
```

### With parameters
```powershell
& ([scriptblock]::Create((irm bypassnro.thectic.nl))) -Force      # skip confirmation
& ([scriptblock]::Create((irm bypassnro.thectic.nl))) -NoReboot   # shut down instead
```

## Without Sysprep (faster)

Save [`unattend.xml`](https://raw.githubusercontent.com/Thectic-NL/BypassNRO/main/unattend.xml) to the root of the Windows 11 USB as `autounattend.xml`. Setup reads it during installation, so OOBE never asks for an account and there is no second reboot.

## Accounts

The unattend.xml creates `Admin` (Administrators) and `User` (Users), both **without a password**, and signs `Admin` in automatically once. Set a password right after first logon.

## Timeline

| Date | Event |
|------|-------|
| March 2025 | Microsoft removed `oobe\bypassnro` from Windows 11 (24H2/25H2) |
| October 6, 2025 | Alternative `start ms-cxh:localonly` blocked from Insider builds 26220.6772 / 26120.6772 |
| September 1, 2026 | This Sysprep method continues to work |

## Notes

Only the `oobeSystem` pass applies. `Sysprep /oobe` without `/generalize` does not re-run `specialize`, so anything placed there is ignored. For debloating and tweaks use [WinDeploy](https://github.com/Stensel8/WinDeploy) or [WinUtil](https://github.com/ChrisTitusTech/winutil).

Troubleshooting: Sysprep logs to `C:\Windows\System32\Sysprep\Panther\setuperr.log`.
