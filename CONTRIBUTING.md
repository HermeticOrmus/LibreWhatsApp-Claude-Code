# Contributing

PRs welcome, especially for provider adapters, the stubbed channels, and transcription back ends.

## Welcome

- Provider adapters beyond Periskope (self-hosted, Baileys-based, other aggregators).
- Hardening the Discord (`ds`) and email (`em`) channels in `/pull` and `/push` against real servers.
- Transcription back ends for `/transcribe` (faster-whisper, remote-but-self-hosted).
- Bug fixes and clearer docs.

## Not accepted

- Any committed file containing a real phone number, group id, or API key. Target resolution belongs in the user's local `~/.claude/wa-registry.json`, never in the repo.
- A `/push` change that weakens the preview-and-confirm gate or the credential scan.
- Cloud transcription fallbacks in `/transcribe`. Local-only is the design.
- AI-generated content that has not been run against a real chat.

## Design rules

- The skills carry provider-agnostic logic. Provider specifics live behind the two operations: list-messages and send-message.
- Keep message bodies out of audit logs. Log metadata only.
- Quote verbatim in `/pull` output. Never paraphrase someone's message.

## Branch and PR

Branches: `feat/`, `fix/`, `adapter/<provider>`, `channel/<code>`. Commit format: `type(scope): description`. MIT, no CLA.

## Plugin layout

Each plugin:

```
plugins/<name>/
  .claude-plugin/plugin.json      name, version, description, author, homepage, repository, license, keywords
  commands/<name>.md              the slash command; frontmatter: description (+ argument-hint)
  skills/<skill-name>/SKILL.md    the method; frontmatter: name, description, user-invocable: false
  bin/                            optional helpers, called through ${CLAUDE_PLUGIN_ROOT}/bin/
  README.md
```

The command is the user entry point and reads its skill by path. The skill has a different name from the command (two components with the same name collide) and is hidden from the slash menu, so each plugin shows one entry. Add the plugin to `.claude-plugin/marketplace.json` with the same description as its `plugin.json`, then run `claude plugin validate .` and `claude plugin validate plugins/<name>`. See `plugins/pull/` for the reference.
