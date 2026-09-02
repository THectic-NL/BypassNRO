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
  Windows OOBE omzeilen met Sysprep en unattend.xml; een betrouwbare methode die nog steeds werkt
{{< /hextra/hero-subtitle >}}
</div>

<div class="hx-mb-10" style="margin-top: 2.5rem !important;">
{{< hextra/hero-badge link="https://bypassnro.thectic.nl/bypass.ps1" >}}
  <span>Script downloaden</span>
  {{< icon name="download" attributes="height=20" >}}
{{< /hextra/hero-badge >}}
{{< hextra/hero-badge link="https://bypassnro.thectic.nl/unattend.xml" >}}
  <span>Answer file downloaden</span>
  {{< icon name="download" attributes="height=20" >}}
{{< /hextra/hero-badge >}}
</div>

<div class="hx-mt-6"></div>

## Checksums

**SHA256:**
- `bypass.ps1`: `8b3228d0f48c42358829425c6ee9414bbe0ea75c3da14e8d5a84ceb805367059`
- `unattend.xml`: `f9420180589c986a8315445a2c3b999ef74d62100999d5a68b17e330e9a890c0`

Controleer met: `sha256sum bypass.ps1 unattend.xml`

{{< callout type="info" >}}
**Waarom deze methode nog werkt:** Sinds maart 2025 heeft Microsoft het commando `oobe\bypassnro` uit Windows 11 (24H2/25H2) verwijderd. Het alternatief `start ms-cxh:localonly` werd geblokkeerd vanaf Insider-build 26220.6772 (6 oktober 2025). Of die blokkade ook de retail-tak 25H2 heeft bereikt, is niet opnieuw getest, dus controleer je eigen image voordat je erop vertrouwt.

Deze aanpak met Sysprep en unattend.xml blijft werken omdat het onderdeel is van Windows' officiële enterprise-deploymenttools en niet eenvoudig te blokkeren is zonder enterprise-scenario's te breken.

Zie de [GitHub-repository](https://github.com/Thectic-NL/BypassNRO) voor openstaande issues en updates.
{{< /callout >}}

## Gebruik

Druk tijdens Windows OOBE (Out of Box Experience) op **Shift+F10** en voer uit:

### PowerShell
```powershell
iex(irm bypassnro.thectic.nl/bypass.ps1)
```

### Met parameters
```powershell
& ([scriptblock]::Create((irm bypassnro.thectic.nl/bypass.ps1))) -Force      # bevestiging overslaan
& ([scriptblock]::Create((irm bypassnro.thectic.nl/bypass.ps1))) -NoReboot   # afsluiten in plaats van herstarten
```

## Accounts

De unattend.xml maakt `Admin` (Administrators) en `User` (Users) aan, beide **zonder wachtwoord**, en meldt `Admin` één keer automatisch aan. Stel direct na de eerste aanmelding een wachtwoord in.

## Tijdlijn

| Datum | Gebeurtenis |
|------|-------|
| Maart 2025 | Microsoft verwijdert `oobe\bypassnro` uit Windows 11 (24H2/25H2) |
| 6 oktober 2025 | Alternatief `start ms-cxh:localonly` geblokkeerd vanaf Insider-builds 26220.6772 / 26120.6772 |
| 1 september 2026 | Deze Sysprep-methode werkt nog steeds |

## Opmerkingen

Alleen de `oobeSystem`-pass wordt toegepast. `Sysprep /oobe` zonder `/generalize` draait `specialize` niet opnieuw, dus alles wat daar staat wordt genegeerd. Gebruik voor debloaten en tweaks [WinDeploy](https://github.com/Stensel8/WinDeploy) of [WinUtil](https://github.com/ChrisTitusTech/winutil).

Problemen oplossen: Sysprep logt naar `C:\Windows\System32\Sysprep\Panther\setuperr.log`.
