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
  Windows 11 instellen met een lokaal account, zonder Microsoft-account
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

## Gebruik

Druk tijdens Windows Setup (OOBE) op **Shift+F10** voor een opdrachtprompt en voer uit:

```powershell
iex(irm bypassnro.thectic.nl/bypass.ps1)
```

Dat is alles. Er zijn geen opties of parameters.

## Checksums

**SHA256:**
- `bypass.ps1`: `323da784576c2744cb2981ff4f8d52ba836be0a6edb8ffa1fe05279cce292da1`
- `unattend.xml`: `7c5d4eb9a9cfe03cb506c4189e3955ca5f36788131386f30f519d8e861c0ad1c`

Het script toont de SHA256 van beide bestanden die het downloadt en wacht dan.
Vergelijk de twee waarden op het scherm met de twee hierboven voordat je `y`
antwoordt. Wijkt er één af, antwoord dan `n` — op dat moment is er nog niets
gewijzigd.

Een zelf gedownload bestand controleer je zo: `Get-FileHash .\bypass.ps1 -Algorithm SHA256`

## Als je niet in Windows Setup zit

Het script kijkt ook onder welk account je bent aangemeld. Windows Setup draait
onder een tijdelijk account met de naam `defaultuser0`, dus dat ben jij in de
console van Shift+F10. Iedere andere naam betekent dat de computer waarschijnlijk
al is ingericht, en Sysprep stuurt die machine dan volledig terug door Setup.

In dat geval waarschuwt het script eerst en gaat het alleen verder als je
`CONTINUE` typt. Een simpele `y` is niet genoeg, zodat één losse toetsaanslag
geen werkende computer terugzet.

{{< callout type="info" >}}
**Status:** voor het laatst getest op **19 september 2026** op Windows 11 build **26200.9457** (25H2) — werkt nog steeds. Het lijkt erop dat dit ook in 26H2 nog werkt.

**Waarom deze methode blijft werken:** Microsoft verwijderde `oobe\bypassnro` in maart 2025 uit Windows 11 en blokkeerde het alternatief `start ms-cxh:localonly` vanaf oktober 2025. Sysprep en `unattend.xml` zijn van een andere orde: ze horen bij Windows' eigen enterprise-deploymenttools en zijn niet te verwijderen zonder zakelijke imaging te breken.

Zie de [GitHub-repository](https://github.com/Thectic-NL/BypassNRO) voor openstaande issues en updates.
{{< /callout >}}

## Wat het doet

1. Downloadt `unattend.xml` en schrijft die naar `C:\Windows\Panther\unattend.xml`
2. Voert `Sysprep.exe /oobe /unattend:C:\Windows\Panther\unattend.xml /reboot` uit
3. De computer herstart naar OOBE, dat de answer file leest en de accounts hieronder aanmaakt

Alles wat niet is opgeslagen gaat bij de herstart verloren.

## Accounts die worden aangemaakt

| Account | Groep | Wachtwoord | Opmerkingen |
|---------|-------|------------|-------------|
| `Admin` | Administrators | geen | Wordt één keer automatisch aangemeld, daarna gaat autologon uit |
| `User` | Users | geen | Standaardgebruiker |

Dat zijn de letterlijke accountnamen. OOBE vraagt niet meer om een
Microsoft-account, een gebruikersnaam of een wachtwoord, dus **geef beide
accounts direct na de eerste aanmelding een wachtwoord**.

## Tijdlijn

| Datum | Gebeurtenis |
|------|-------|
| Maart 2025 | Microsoft verwijdert `oobe\bypassnro` uit Windows 11 (24H2/25H2) |
| 6 oktober 2025 | `start ms-cxh:localonly` geblokkeerd vanaf Insider-builds 26220.6772 / 26120.6772 |
| 19 september 2026 | Deze Sysprep-methode werkt nog steeds op build 26200.9457 |

## Problemen oplossen

Als de computer niet herstart, logt Sysprep de reden in
`C:\Windows\System32\Sysprep\Panther\setuperr.log`.

Het script moet verhoogd (als Administrator) draaien. De console die je met
Shift+F10 tijdens OOBE krijgt, is dat al.

## Opmerkingen

Alleen de `oobeSystem`-pass van de answer file wordt toegepast. `Sysprep /oobe`
zonder `/generalize` draait `specialize` niet opnieuw, dus alles wat daar staat
wordt genegeerd. Gebruik voor debloaten en tweaks
[WinDeploy](https://github.com/Thectic-NL/WinDeploy) of
[WinUtil](https://github.com/ChrisTitusTech/winutil).

## Met dank aan

De `unattend.xml` hier leunt sterk op de [unattend.xml-generator](https://schneegans.de/windows/unattend-generator/) van Christoph Schneegans, een grondige en goed gedocumenteerde tool om Windows-answerfiles te bouwen. We hebben er bij hem afgekeken en er veel van geleerd. Wil je de answer file verder aanpassen dan wat dit project meelevert, begin daar.
