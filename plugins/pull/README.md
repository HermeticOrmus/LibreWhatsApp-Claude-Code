# pull

Channel-aware message pull for Claude Code. Fetch recent messages from WhatsApp (or Discord/email), see only what is new since last time, with verbatim quoting.

## What it does

- Resolves a human alias (`team`, `teammate`, `me`) to a chat id from your local registry.
- Infers the target from the current conversation when you do not name one.
- Fetches the last N messages or a time window.
- Tracks last-seen state per chat, so repeat pulls show only new messages.
- Slices large histories through a subagent to keep your context small.

## Usage

```
/pull wa team            read a group, only what is new
/pull wa teammate 50     last 50 from a DM
/pull wa team last 4h    a time window
/pull                    repeat the last pull
/pull wa team verbose    include previously-seen messages
```

## Setup

1. Copy `registry.example.json` (repo root) to `~/.claude/wa-registry.json` and fill in your provider config and target aliases.
2. For the reference WhatsApp adapter, set `PERISKOPE_API_KEY` in your environment, or wire the Periskope MCP.
3. Voice notes: pair with the `transcribe` plugin to turn audio into text.

## The x-phone gotcha

Periskope returns only messages the requesting number participated in. Set `provider.default_sender_phone` to a number that is actually in the chats you read, or you get an empty result with no error. This is the single most common wiring mistake.

## Provider independence

The fetch is the only provider-specific step. The alias resolution, inference, dedup, and slicing are provider-agnostic. To use a different provider, see "Wiring a new provider" in `skills/pull.md`.
