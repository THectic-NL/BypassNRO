# Contributing

Found a Windows build where this method behaves differently, or spotted a wrong
command or a broken link? Issues and pull requests are welcome.

---

## Commit messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/).

**Format:**
```
<type>: <short description>
```

**Types:**

| Type | When to use |
|------|-------------|
| `feat` | New page or new feature |
| `fix` | Bug fix — broken link, wrong command, layout issue |
| `content` | Update or improve existing page content |
| `docs` | Changes to README, CONTRIBUTING, or other meta files |
| `chore` | Maintenance — dependencies, config, CI/CD, Hugo theme |
| `refactor` | Restructure without changing content |
| `style` | Formatting, whitespace, typo fixes |
| `revert` | Reverting a previous commit |

**Examples:**
```
feat: add autounattend.xml install path
fix: correct Sysprep flag in bypass.ps1
content: update timeline with 25H2 retail status
chore: upgrade Hextra theme
```

**Rules:**
- Use lowercase for the type and description
- Keep the subject line under 72 characters
- No period at the end
- Use the imperative mood ("add", "fix", "update" — not "added", "fixed")

---

## Pull requests

- PR titles must follow the same commit convention above
- One logical change per PR
- Update both EN (`*.md`) and NL (`*.nl.md`) versions where applicable
- Test locally with `cd src && hugo server` before opening a PR

---

## Project layout

The Hugo site lives in `src/`:

- `src/content/` — page content (`_index.md` EN, `_index.nl.md` NL)
- `src/static/` — files served as-is: `bypass.ps1`, `unattend.xml`, `robots.txt`
- `src/layouts/` — template overrides on top of the Hextra theme
- `src/hugo.toml` — site configuration

The site is built and deployed to Bunny.net from `.github/workflows/deploy-bunny.yml`
on every push to `main` that touches `src/`.

---

## Language

This site is bilingual (EN + NL). When updating content, edit both
`src/content/<page>.md` and `src/content/<page>.nl.md`, and keep the structure
and headings in sync between the two files.
