# Advanced — your own provider, other channels

Goal: run on a provider other than Periskope, and wire the stubbed channels.

## Wiring a different provider

The skills call exactly two provider operations: list-messages-in-a-chat and send-message. To swap providers:

1. In `~/.claude/wa-registry.json`, set `provider.type` and add whatever config your provider needs (key env var, base url).
2. In `plugins/pull/skills/pull.md`, replace the Step 3 fetch with your provider's list call. Normalize each message to `{ id, timestamp, sender, body, media }` so the rest of the pipeline is unchanged.
3. In `plugins/push/skills/push.md`, replace the Step 5 send with your provider's send call.
4. If there is no MCP, add a fetch helper modeled on `plugins/pull/bin/wa-fetch.sh`.

Inference, dedup, slicing, the preview gate, the audit log, and transcription all stay the same. That separation is the reason this repo is worth open-sourcing: the logic is portable, the provider is a detail.

A self-hosted or Baileys-based provider fits here. So does any aggregator that exposes the two operations.

## Filling the Discord channel

`ds` is stubbed in both skills. Target is a channel within a server. Read with `mcp__discord__discord_read_messages`, send with `mcp__discord__discord_send`. Add `ds` targets to the registry the same way as `wa`. Sender resolution is by Discord username.

## Filling the email channel

`em` is stubbed. Resolve a person alias to an email address. Backend by recipient domain: Gmail via its MCP, Microsoft Graph for work domains. Reading is a thread search; sending needs a subject. Same registry shape, `channel: "em"`.

## State and audit

- Pull state per target: `~/.claude/skills/pull/state/<channel>__<target-id>.json`.
- Push audit log: `~/.claude/skills/push/state/log.jsonl`, metadata only, never bodies.

Both directories are gitignored. Keep them that way.

## What you learned

- The provider lives behind two operations; everything else is portable.
- New channels follow the `wa` adapter shape in both skills.
- State and audit are local and gitignored by design.
