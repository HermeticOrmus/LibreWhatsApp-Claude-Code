# Contributing

PRs welcome, especially for provider adapters, the stubbed channels, and transcription back ends.

## Welcome

- Provider adapters beyond Periskope (self-hosted, Baileys-based, other aggregators).
- Filling in the Discord (`ds`) and email (`em`) channel stubs in `/pull` and `/push`.
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

Each plugin: `plugins/<name>/README.md` + `commands/<name>.md` + `skills/<name>.md`, plus an optional `bin/` for helpers. See `plugins/pull/` for the reference.
