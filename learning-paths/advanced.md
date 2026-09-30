# Advanced — your own provider, other channels

Goal: run on a provider other than Periskope, and wire the stubbed channels.

## Wiring a different provider

The skills call exactly two provider operations: list-messages-in-a-chat and send-message. To swap providers:

1. In `~/.claude/wa-registry.json`, set `provider.type` and add whatever config your provider needs (key env var, base url).
2. In `plugins/pull/skills/chat-pull/SKILL.md`, replace the Step 3 fetch with your provider's list call. Normalize each message to `{ id, timestamp, sender, body, media }` so the rest of the pipeline is unchanged.
3. In `plugins/push/skills/chat-push/SKILL.md`, replace the Step 5 send with your provider's send call.
4. If there is no MCP, add fetch and send helpers modeled on `plugins/pull/bin/wa-fetch.sh` and `plugins/push/bin/wa-send.sh` (keep the `--yes` gate).

Inference, dedup, slicing, the preview gate, the audit log, and transcription all stay the same. That separation is the reason this repo is worth open-sourcing: the logic is portable, the provider is a detail.

A self-hosted or Baileys-based provider fits here. So does any aggregator that exposes the two operations.

## The Discord channel

`ds` runs through a Discord MCP server you connect. Target is a channel within a server. Read with that server's read-messages tool (for example `discord_read_messages`), send with its send tool (for example `discord_send`). Add `ds` targets to the registry the same way as `wa`, with the channel id as `id`. Sender resolution is by Discord username.

## The email channel

`em` runs through an email MCP server or connector you connect. Resolve a person alias to an email address. Backend by the target's optional `backend` field, else whatever mail tool is connected: a Gmail connector, or a Microsoft 365 server for work domains. Reading is a thread search; sending is draft first, and needs a subject. Same registry shape, `channel: "em"`.

## State and audit

- Pull state per target: `~/.claude/wa-state/pull/<channel>__<target-id>.json` (`PULL_STATE_DIR`).
- Push audit log: `~/.claude/wa-state/push/log.jsonl` (`PUSH_STATE_DIR`), metadata plus a body hash, never bodies.

Both directories are gitignored. Keep them that way.

## What you learned

- The provider lives behind two operations; everything else is portable.
- New channels follow the `wa` adapter shape in both skills.
- State and audit are local and gitignored by design.
