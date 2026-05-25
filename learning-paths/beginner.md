# Beginner — your first read and reply

Goal: pull one chat and send one reply, end to end.

## Before you start

- Plugins installed (`./setup.sh`), Claude Code restarted.
- A Periskope account with your WhatsApp number connected, and an API key.
- `~/.claude/wa-registry.json` created from `registry.example.json`.

## 1. Add one target

In `~/.claude/wa-registry.json`, set `provider.org_phone` and `provider.default_sender_phone` to your own number, and add one entry under `targets` for a chat you message often:

```json
"teammate": { "channel": "wa", "id": "15551234567@c.us", "type": "dm" }
```

## 2. Pull it

```
/pull wa teammate
```

You see the recent messages, newest grouped as new. Pull again in a minute and only messages that arrived since show up. That dedup is the whole point — you check a chat without re-reading what you already saw.

## 3. Reply

```
/push reply "Got it, looking now."
```

`reply` targets the chat you just pulled. You get a preview and a confirm prompt. Approve it, and it sends from your number.

## What you learned

- Aliases map to chat ids in your local registry.
- `/pull` shows only what is new since last time.
- `/push` previews before sending, and `reply` chains off the last pull.

## Next

Add a group target (id ends in `@g.us`) and try `/grab teammate link` to copy the last URL someone sent. Then read the intermediate path.
