# Bypass NRO

Set up Windows 11 with a local account, using Windows' own answer-file mechanism instead of a console trick that Microsoft can remove.

```powershell
iex (irm bypassnro.stensel.nl)
```

Run from an elevated prompt. During OOBE, **Shift+F10** gives you one.

---

## Status of bypass methods

**Last verified: August 2026.** Microsoft has removed the console-based bypasses one by one; the answer-file route is the one that has held.

| Method | Status | Notes |
|---|---|---|
| **`unattend.xml` / `autounattend.xml`** (this project) | **Works** | Part of Windows' supported deployment tooling. Microsoft cannot remove it without breaking enterprise imaging, Autopilot and MDT/SCCM. |
| **Rufus** ("Remove requirement for an online Microsoft account") | **Works** | Rufus patches the install media rather than using an OOBE trick, so it is unaffected by the OOBE changes. |
| **Domain join** — "Set up for work or school" → "Sign-in options" → "Domain join instead" | **Works on Pro/Enterprise** | Not available on Home. Microsoft has been narrowing this path, so treat it as a fallback. |
| **`start ms-cxh:localonly`** | **Blocked on Insider; retail unconfirmed** | Blocked in Insider Dev 26220.6772 / Beta 26120.6772 (6 October 2025). Whether that block has reached the retail 25H2 branch (26200.x) has **not** been re-tested for this repo — check your own image before relying on it either way. |
| **`oobe\bypassnro`** | **Removed** | The script was deleted from the image in March 2025. |
| **`BypassNRO` registry value** | **Build-dependent** | `reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE /v BypassNRO /t REG_DWORD /d 1 /f` re-enables the flow, but only on builds where the underlying code is still present. Unreliable on current builds. |

**Timeline**

- **March 2025** — `oobe\bypassnro` removed from Windows 11 24H2/25H2.
- **6 October 2025** — `ms-cxh:localonly` blocked in Insider builds Dev 26220.6772 and Beta 26120.6772.
- **August 2026** — answer files, Rufus and (on Pro) domain join still reach a local account. No single console command works on every image any more.

### How current is this table?

The answer-file route is the only row verified against this repo's own code. The
rest is compiled from public reporting, not from a test run on each build, and
Microsoft changes this often enough that a row can go stale between releases.
Treat the console-command rows as "last known state", not as a guarantee, and
open an issue if your image behaves differently.

---

## Two ways to use it

### Option 1 — On the installation media (recommended)

Put the answer file on the USB **before** installing. Setup reads it automatically and never shows the account screen, so there is nothing to bypass and no second trip through OOBE.

1. Create a Windows 11 USB (Media Creation Tool, Rufus, or by extracting the ISO).
2. Download [`unattend.xml`](unattend.xml) and save it to the **root of the USB** as `autounattend.xml`.
3. Boot from the USB and install as normal.

This is faster and more reliable than Option 2, because Sysprep never has to run.

### Option 2 — During OOBE, on a machine that is already installed

Use this when you are already staring at the "Sign in with Microsoft" screen.

1. Press **Shift+F10** to open a command prompt.
2. Run:

   ```powershell
   powershell -c "iex (irm bypassnro.stensel.nl)"
   ```

3. Confirm the prompt. The machine reboots and comes back through OOBE with the local accounts already created.

Under the hood this downloads [`unattend.xml`](unattend.xml) to `C:\Windows\Panther\unattend.xml` and runs:

```
Sysprep.exe /oobe /unattend:C:\Windows\Panther\unattend.xml /reboot
```

**Parameters.** `iex` cannot pass arguments. Use a script block if you need them:

```powershell
# Skip the confirmation prompt
& ([scriptblock]::Create((irm bypassnro.stensel.nl))) -Force

# Shut down instead of rebooting
& ([scriptblock]::Create((irm bypassnro.stensel.nl))) -NoReboot

# See what it would do without doing it
& ([scriptblock]::Create((irm bypassnro.stensel.nl))) -WhatIf
```

---

## What the answer file does

Only the **oobeSystem** pass is used. Defining local accounts there is what performs the bypass: OOBE skips the account screens because the accounts already exist, so it never asks for a Microsoft account.

| Account | Group | Password |
|---|---|---|
| `Admin` | Administrators | *(none)* |
| `User` | Users | *(none)* |

`Admin` is signed in automatically once, then autologon is switched off and the answer file is deleted from `C:\Windows\Panther`.

> [!WARNING]
> **Both accounts are created without a password, and `Admin` logs in automatically.** That is what makes the bypass work, but it means the machine is wide open until you fix it. **Set a password immediately after the first sign-in** (`Settings > Accounts > Sign-in options`, or `net user Admin *`).

### Why the answer file has an empty `specialize` pass

`Sysprep /oobe` without `/generalize` does **not** re-run the specialize pass — only `oobeSystem` is processed. Anything placed in `specialize` (app removal, registry tweaks, script extraction) silently never runs in this flow. Earlier versions of this file carried a large debloat payload there that never executed. It has been removed rather than left in place looking functional.

If you want debloating and tweaks, do it after setup with something built for it, such as [WinDeploy](https://github.com/Stensel8/WinDeploy) or [WinUtil](https://github.com/ChrisTitusTech/winutil).

---

## Troubleshooting

**"This script must be run elevated"**
Shift+F10 during OOBE already gives you an elevated prompt. Outside OOBE, start PowerShell as Administrator.

**Script blocked by execution policy**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

**Sysprep exits non-zero**
Sysprep refused to run. Check `C:\Windows\System32\Sysprep\Panther\setuperr.log`. The usual causes are a pending reboot, an in-progress Windows Update, or Sysprep having already run the maximum number of times on this image.

**Download fails**
The OOBE environment may have no network yet. Connect Ethernet (or use `Shift+F10` → `netsh wlan` to join Wi-Fi), or use Option 1 instead, which needs no network at all.

---

## Requirements

- Windows 11 (24H2 / 25H2 and later)
- Windows PowerShell 5.1 — what Shift+F10 provides
- Administrator rights

## Disclaimer

Provided as is, without warranty. Sysprep reboots the machine and sends it back through OOBE; anything unsaved is lost. Test before using on a machine you care about.

## Licence

[MIT](LICENSE)
