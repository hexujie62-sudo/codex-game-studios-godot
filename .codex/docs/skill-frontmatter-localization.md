# Skill Frontmatter Localization

CodexForGodot keeps active Skill sources in English for public distribution.
The user-visible Skill list can still be localized by rewriting only the
frontmatter fields that the app displays.

Run the localizer after `/start` confirms or infers the user's response
language:

```powershell
pwsh -File scripts/localize-skill-frontmatter.ps1 -Language en
pwsh -File scripts/localize-skill-frontmatter.ps1 -Language zh-CN
```

The script updates only:

- `description`
- `argument-hint`

It does not rewrite Skill bodies, route indexes, README files, project design
docs, or runtime state.

Safety rules:

- Run it from the repository that owns the Skills being localized.
- Do not point `-SkillsRoot` or `-CatalogPath` at another repository.
- If the script or catalog is missing in a project, skip Skill-list
  localization instead of searching sibling framework copies.

To add another language, extend
`.codex/docs/skill-frontmatter-locales.json` with a new locale key and the same
Skill entries.
