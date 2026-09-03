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
  Windows OOBE bypass using Sysprep and unattend.xml; a reliable method that still works
{{< /hextra/hero-subtitle >}}
</div>

<div class="hx-mb-10" style="margin-top: 2.5rem !important;">
{{< hextra/hero-badge link="https://bypassnro.thectic.nl/bypass.ps1" >}}
  <span>Download script</span>
  {{< icon name="download" attributes="height=20" >}}
{{< /hextra/hero-badge >}}
{{< hextra/hero-badge link="https://bypassnro.thectic.nl/unattend.xml" >}}
  <span>Download answer file</span>
  {{< icon name="download" attributes="height=20" >}}
{{< /hextra/hero-badge >}}
</div>

<div class="hx-mt-6"></div>

## File Checksums

**SHA256:**
- `bypass.ps1`: `8b3228d0f48c42358829425c6ee9414bbe0ea75c3da14e8d5a84ceb805367059`
- `unattend.xml`: `f9420180589c986a8315445a2c3b999ef74d62100999d5a68b17e330e9a890c0`

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
iex(irm bypassnro.thectic.nl/bypass.ps1)
```

### With parameters
```powershell
& ([scriptblock]::Create((irm bypassnro.thectic.nl/bypass.ps1))) -Force      # skip confirmation
& ([scriptblock]::Create((irm bypassnro.thectic.nl/bypass.ps1))) -NoReboot   # shut down instead
```

## Accounts

The unattend.xml creates `Admin` (Administrators) and `User` (Users), both **without a password**, and signs `Admin` in automatically once. Set a password right after first logon.

## Timeline

| Date | Event |
|------|-------|
| March 2025 | Microsoft removed `oobe\bypassnro` from Windows 11 (24H2/25H2) |
| October 6, 2025 | Alternative `start ms-cxh:localonly` blocked from Insider builds 26220.6772 / 26120.6772 |
| September 1, 2026 | This Sysprep method continues to work |

## Notes

Only the `oobeSystem` pass applies. `Sysprep /oobe` without `/generalize` does not re-run `specialize`, so anything placed there is ignored. For debloating and tweaks use [WinDeploy](https://github.com/Thectic-NL/WinDeploy) or [WinUtil](https://github.com/ChrisTitusTech/winutil).

Troubleshooting: Sysprep logs to `C:\Windows\System32\Sysprep\Panther\setuperr.log`.

## Credits

The `unattend.xml` here leans heavily on Christoph Schneegans' [unattend.xml generator](https://schneegans.de/windows/unattend-generator/), a thorough and well-documented tool for building Windows answer files. We cribbed from it and learned a lot in the process. To customise the answer file beyond what this project ships, start there.
