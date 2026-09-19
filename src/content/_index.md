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
  Set up Windows 11 with a local account, without a Microsoft account
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

## Usage

Press **Shift+F10** during Windows setup (OOBE) to open a command prompt, then run:

```powershell
iex(irm bypassnro.thectic.nl/bypass.ps1)
```

That is the whole thing. There are no options or parameters.

## File checksums

**SHA256:**
- `bypass.ps1`: `323da784576c2744cb2981ff4f8d52ba836be0a6edb8ffa1fe05279cce292da1`
- `unattend.xml`: `7c5d4eb9a9cfe03cb506c4189e3955ca5f36788131386f30f519d8e861c0ad1c`

The script prints the SHA256 of both files it downloads and then waits. Compare
the two values on screen with the two above before you answer `y`. If either one
differs, answer `n` — nothing has been changed at that point.

Checking a file you downloaded yourself: `Get-FileHash .\bypass.ps1 -Algorithm SHA256`

## If you are not in Windows setup

The script also checks which account you are signed in as. Windows setup runs
under a temporary account called `defaultuser0`, so that is who you are in the
Shift+F10 console. Anyone else means the computer is most likely already set up,
and running Sysprep there sends the whole machine back through setup.

In that case the script warns first and only goes on if you type `CONTINUE`.
Plain `y` is not enough, so a stray keypress cannot reset a working computer.

{{< callout type="info" >}}
**Status:** last tested on **19 September 2026** on Windows 11 build **26200.9457** (25H2) — still works. It looks like this still works on 26H2 as well.

**Why this method keeps working:** Microsoft removed `oobe\bypassnro` from Windows 11 in March 2025, and blocked the alternative `start ms-cxh:localonly` from October 2025. Sysprep and `unattend.xml` are different: they are part of Windows' own enterprise deployment tooling, so they cannot be removed without breaking corporate imaging.

See the [GitHub repository](https://github.com/Thectic-NL/BypassNRO) for open issues and updates.
{{< /callout >}}

## What it does

1. Downloads `unattend.xml` and writes it to `C:\Windows\Panther\unattend.xml`
2. Runs `Sysprep.exe /oobe /unattend:C:\Windows\Panther\unattend.xml /reboot`
3. The computer restarts into OOBE, which reads the answer file and creates the accounts below

Anything unsaved on the machine is lost at the restart.

## Accounts it creates

| Account | Group | Password | Notes |
|---------|-------|----------|-------|
| `Admin` | Administrators | none | Signed in automatically once, after that autologon is switched off |
| `User` | Users | none | Standard user |

Those are the literal account names. OOBE never asks for a Microsoft account, a
user name or a password, so **give both accounts a password right after the
first sign-in**.

## Timeline

| Date | Event |
|------|-------|
| March 2025 | Microsoft removed `oobe\bypassnro` from Windows 11 (24H2/25H2) |
| 6 October 2025 | `start ms-cxh:localonly` blocked from Insider builds 26220.6772 / 26120.6772 |
| 19 September 2026 | This Sysprep method still works on build 26200.9457 |

## Troubleshooting

If the computer does not restart, Sysprep logs the reason to
`C:\Windows\System32\Sysprep\Panther\setuperr.log`.

The script must run elevated. The console you get with Shift+F10 during OOBE
already is.

## Notes

Only the `oobeSystem` pass of the answer file applies. `Sysprep /oobe` without
`/generalize` does not re-run `specialize`, so anything placed there is ignored.
For debloating and tweaks use [WinDeploy](https://github.com/Thectic-NL/WinDeploy)
or [WinUtil](https://github.com/ChrisTitusTech/winutil).

## Credits

The `unattend.xml` here leans heavily on Christoph Schneegans' [unattend.xml generator](https://schneegans.de/windows/unattend-generator/), a thorough and well-documented tool for building Windows answer files. We cribbed from it and learned a lot in the process. To customise the answer file beyond what this project ships, start there.
