<img src=".claude-plugin/icon.png" width="96" alt="Kipchak" />

# Kipchak agent skill

An [Agent Skill](https://agentskills.io) that teaches coding assistants to build and maintain PHP APIs with
[Kipchak](https://kipchak.dev), the API development kit on Slim 4 and FrankenPHP worker mode.

With it, an assistant writes Kipchak code as the framework intends: routes, thin controllers, DTOs that carry the
OpenAPI contract, models, tests, drivers and middleware, and code that is safe in a long-lived worker. Without it,
assistants tend to write Kipchak code as they would write Laravel or plain Slim code.

The skill is in [`skills/kipchak`](skills/kipchak): `SKILL.md` and the references it loads when a task needs them.

## Install

### Claude Code

```text
/plugin marketplace add kipchak-dev/skills
/plugin install kipchak@kipchak
```

Or copy `skills/kipchak` into `.claude/skills/` in a project, or into `~/.claude/skills/` for every project.

### Codex, Cursor, GitHub Copilot and other assistants

Assistants that read Agent Skills look for them in a skills folder. Copy `skills/kipchak` into the project's
`.agents/skills/` folder, which Codex reads and Cursor and VS Code also recognise:

```bash
git clone --depth 1 https://github.com/kipchak-dev/skills.git /tmp/kipchak-skills
mkdir -p .agents/skills && cp -R /tmp/kipchak-skills/skills/kipchak .agents/skills/
```

Each assistant's documentation gives its own folders as well: for example `.cursor/skills/` for Cursor and
`.github/skills/` for GitHub Copilot.

### Assistants without skills

Point the assistant at [`skills/kipchak/SKILL.md`](skills/kipchak/SKILL.md), or at the documentation index for
language models, <https://kipchak.dev/llms.txt>. Projects created from the Kipchak starter also include an
`AGENTS.md` file.

## Contributing

This repository is a read-only mirror. Development takes place on [1x.ax](https://1x.ax/mamluk/kipchak), and pull
requests opened here are not merged. To report a problem or propose a change, [contact Mamluk](https://mamluk.net/contact/).

## Licence

MIT. See [LICENSE](LICENSE).
