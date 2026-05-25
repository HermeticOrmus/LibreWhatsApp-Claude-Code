---
name: push
description: Channel-aware message send. Posts a message to a named channel (wa/ds/em) and target (user/chat). Mirrors /pull — same channel codes, same registry aliases. Shows a preview and waits for confirmation by default; --send skips the gate. First wired channel is wa (WhatsApp via a pluggable provider).
---

# /push — channel-aware message send

The write-side counterpart to `/pull`. Same channel codes, same registry, different verb.

Sending is harder to undo than reading, so the default behaviour shows a preview and waits for confirmation.

## Argument shape

```
/push <channel> <target> [--send|--dry] [<message body>]
```

| Arg | Meaning |
|---|---|
| `channel` | `wa`, `ds`, `em`. Same registry as `/pull`. |
| `target` | Alias, literal id, or multiple targets for fan-out: `/push wa team teammate "..."`. |
| `--send` | Skip the preview gate and send immediately. |
| `--dry` | Preview only, never send. Useful for drafting. |
| `<message body>` | The message. If omitted, enter compose mode (Step 1). |

Shortcut: `reply` targets whatever `(channel, target)` was the most recent `/pull`. `/push reply "<body>"` inherits the channel too.

Bare `/push` with no body composes from the current conversation context.

## Step 0: load the registry

Read `~/.claude/wa-registry.json` (copy `registry.example.json` from this repo). It holds provider config, target aliases, and optional per-target `style` strings. If missing, tell the user to create it and stop.

## Step 1: resolve channel and target(s)

1. First arg is the channel code.
2. Args before `--send`/`--dry`/the quoted body are target aliases. Multiple = fan-out.
3. Resolve aliases against the registry. `reply` reads `<pull-state-dir>/last.json`.
4. If a target is not resolvable, ask one targeted question naming recent options.

## Step 2: compose (when body is absent)

Draft from: recent conversation context, the target's `style` string in the registry, and the global writing preference (lead with the point, no filler, no AI flourishes). Do not invent content the user has not implied.

## Step 3: format for the channel

WhatsApp: `*bold*`, `_italic_`, `~strike~`, `` `code` ``, ```` ```block``` ````. No `#` headers (render as bold). Split messages over `PUSH_LONG_MESSAGE_THRESHOLD` (default 3500) chars at paragraph boundaries with `(1/N)` markers; never split a code block.

Discord: full markdown, mentions via `<@id>`, 2000-char segments.

Email: subject required (prompt if absent); HTML with plain-text fallback.

## Step 4: preview (default) or send (--send)

Preview block, shown in the conversation before any send:

```
PUSH PREVIEW
Channel:  wa
To:       <Target Name>  (<id>)
Sending as: <org_phone from registry>
Length:   <N chars> · <M segments>
---
<message body, channel-formatted>
---
Confirm: reply "send"   Edit: reply with replacement   Cancel: reply "cancel"
```

Wait for confirmation. Do not call the send tool yet.

With `--send`: skip the preview, send, print a one-line `sent: <queue-id>` confirmation.

## Step 5: send (channel-specific)

### Channel `wa` (WhatsApp)

Reference adapter — Periskope MCP:

```
mcp__periskope-whatsapp__periskope_send_message({
  phone: "<resolved-id>",
  message: "<formatted body>"
})
```

Identity: messages send from the provider account's number (`provider.org_phone` in the registry). Recipients see that number's saved name, not "Claude" or any AI. If the content should be attributed to a specific person, put an attribution line in the body.

Fan-out: loop the send once per target, collect each queue id, roll up into one confirmation.

### Channel `ds` (Discord) — stub

`mcp__discord__discord_send` (per channel) or `discord_reply_to_forum`. Preserve mentions.

### Channel `em` (email) — stub

Gmail: `create_draft` then send. Microsoft Graph: `send-mail`. Backend by recipient domain. Subject required.

## Step 6: post-send

1. Update `<push-state-dir>/last.json` with `{ channel, target_alias, target_id, queue_id, ts }`.
2. Append a metadata-only line to `<push-state-dir>/log.jsonl` (never the body): `{ "ts", "channel", "target_alias", "target_id", "queue_id", "chars" }`.
3. Print the confirmation line.

`<push-state-dir>` defaults to `~/.claude/skills/push/state/`.

## Safety rules

1. No silent send to a target seen for the first time this session — always preview, even with `--send`, unless `--send-trust` is also passed.
2. No send to an id not in the registry without a preview carrying an "unverified target" warning.
3. Body content must come from the user's invocation, the current conversation, or a message being forwarded. Never pull external file/URL content into a send without explicit direction.
4. Scan the body for `(?i)(api[_-]?key|secret|password|token|bearer)\s*[:=]\s*\S+`. If matched, refuse and ask the user to confirm.
5. No AI-attribution footers ("Generated with...", robot emoji) in any push. The send identity is a real person's number.

## Configuration

- `PUSH_DEFAULT_CHANNEL` (default `wa`)
- `PUSH_PREVIEW_MODE` (default `true`; set `false` to make `--send` the default)
- `PUSH_LONG_MESSAGE_THRESHOLD` (default 3500)
- `PUSH_STATE_DIR` (default `~/.claude/skills/push/state/`)

## Anti-patterns

- Do not call the provider send tool directly when `/push` would do — go through the skill so the audit log captures it.
- Do not treat a conversational suggestion ("you should tell them...") as a send directive. Wait for explicit confirmation.
- Do not fan-out broadcast without flagging it in the preview.
- Do not re-send the same body to the same target without confirmation (the log dedupes).
