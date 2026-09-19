# Bypass NRO

Set up Windows 11 with a **local account**, without a Microsoft account.

Press **Shift+F10** during Windows setup (OOBE) to open a command prompt, then run:

```powershell
iex(irm bypassnro.thectic.nl/bypass.ps1)
```

That is the whole thing. There are no options or parameters.

## Status

- **Last tested:** 19 September 2026
- **Windows build:** 26200.9457 (Windows 11 25H2)
- **Result:** works

It looks like this still works on 26H2 as well.

The reason it keeps working: Sysprep and `unattend.xml` are part of Windows' own
enterprise deployment tooling, so Microsoft cannot remove them without breaking
corporate imaging. The older tricks had no such protection:

| Date | Event |
|------|-------|
| March 2025 | `oobe\bypassnro` removed from Windows 11 (24H2/25H2) |
| 6 October 2025 | `start ms-cxh:localonly` blocked from Insider builds 26220.6772 / 26120.6772 |
| 19 September 2026 | This Sysprep method still works on 26200.9457 |

## Check before you run it

The script prints the SHA256 of both files it downloads and waits for you to
confirm. Compare those two values with the checksums published on
<https://bypassnro.thectic.nl/> before answering `y`. If either one differs,
answer `n` — nothing has been changed at that point.

## What it does

1. Downloads [`unattend.xml`](https://bypassnro.thectic.nl/unattend.xml) and writes it to `C:\Windows\Panther\unattend.xml`
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

## Troubleshooting

If the computer does not restart, Sysprep logs the reason to
`C:\Windows\System32\Sysprep\Panther\setuperr.log`.

The script must run elevated. The console you get with Shift+F10 during OOBE
already is.

## Notes

Only the `oobeSystem` pass of the answer file applies: `Sysprep /oobe` without
`/generalize` does not re-run `specialize`, so anything placed there is ignored.
For debloating and tweaks use [WinDeploy](https://github.com/Thectic-NL/WinDeploy)
or [WinUtil](https://github.com/ChrisTitusTech/winutil).

The `unattend.xml` leans heavily on Christoph Schneegans'
[unattend.xml generator](https://schneegans.de/windows/unattend-generator/). To
customise the answer file beyond what this project ships, start there.
