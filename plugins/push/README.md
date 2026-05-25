# push

Channel-aware message send for Claude Code. The write-side counterpart to `/pull`, with a preview-and-confirm gate.

## What it does

- Resolves an alias to a chat id from your registry (same registry as `/pull`).
- Composes a message from conversation context when you do not supply one.
- Shows a preview and waits for confirmation before sending.
- Fans out to multiple targets in one call.
- Logs send metadata for audit (never the message body).

## Usage

```
/push wa team "Heads-up: deploy is live"     preview, then confirm
/push wa teammate --send "Confirmed."         send immediately
/push wa team teammate "..."                  fan-out to two targets
/push reply "Got it."                          reply to the last /pull
/push --dry "draft text"                       preview only, never send
```

## Safety

Sending is hard to undo, so the defaults are conservative:

- First send to a target this session always previews, even with `--send`.
- Sending to an id not in your registry shows an unverified-target warning.
- The body is scanned for credentials and refused if any are found.
- No AI-attribution footers — the send identity is a real number.

## Setup

Shares `~/.claude/wa-registry.json` with `/pull`. Set `PERISKOPE_API_KEY` or wire the Periskope MCP for the reference WhatsApp adapter.
