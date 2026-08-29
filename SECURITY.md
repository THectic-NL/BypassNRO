# Security Policy

## Supported versions

Only the `main` branch is supported. Use the current version of `bypass.ps1`
and `unattend.xml`.

## Reporting a vulnerability

Report vulnerabilities privately through
[GitHub Security Advisories](https://github.com/Stensel8/bypassnro/security/advisories/new).

Please do not open a public issue for a security problem.

## Scope

This project writes a Windows answer file and runs Sysprep. Things worth
reporting:

- A way to make `bypass.ps1` fetch or execute content from somewhere other
  than the configured `UnattendUrl`.
- A flaw that leaves the answer file (which contains plaintext passwords) on
  disk after first logon.
- Anything that grants more privilege than the documented behaviour.

## Known and intended behaviour

These are documented trade-offs, not vulnerabilities:

- `unattend.xml` creates the `Admin` and `User` accounts **without a
  password**, and signs `Admin` in automatically once. This is what makes the
  bypass work. Set a password immediately after first logon.
- The one-liner (`iex (irm bypassnro.stensel.nl)`) downloads and executes a
  remote script. Read `bypass.ps1` before running it if that matters to you.
- Sysprep reboots the machine and sends it back through OOBE.
