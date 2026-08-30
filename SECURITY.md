## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Report privately via [GitHub Security Advisories](https://github.com/Stensel8/bypassnro/security/advisories/new).

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

You will receive a response within 7 days. If the report is accepted, a fix will be released as soon as possible and you will be credited in the release notes.

### Out of scope

By design, `unattend.xml` creates accounts without a password and auto-logs in once, and the one-liner downloads and runs a remote script. These are documented in the README, not vulnerabilities.
