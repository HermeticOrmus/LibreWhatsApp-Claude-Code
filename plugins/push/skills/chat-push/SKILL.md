---
name: chat-push
description: "Drafts and sends a message to a WhatsApp chat (or a Discord channel or email) from the session, consent first: it composes from the conversation when no text is given, formats for the channel, shows a preview, and sends only after an explicit confirmation, with a credential scan, fan-out to several chats, and a metadata-only audit log. Use when the user wants to reply to, message, notify, or draft something for a chat or person."
user-invocable: false
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

Read `~/.claude/wa-registry.json`, or the file named in `WA_REGISTRY` (copy `registry.example.json` from the repo root). It holds provider config, target aliases, and optional per-target `style` strings. If missing, tell the user to create it and stop.

## Step 1: resolve channel and target(s)

1. First arg is the channel code.
2. Args before `--send`/`--dry`/the quoted body are target aliases. Multiple = fan-out.
3. Resolve aliases against the registry. `reply` reads `<pull-state-dir>/last.json` (`PULL_STATE_DIR`, default `~/.claude/wa-state/pull/`).
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

With `--send`: skip the preview, send, print a one-line `sent: <queue-id>` confirmation. The first send to a target in a session still previews (safety rule 1), and a message suggested in passing ("you should tell them...") is never a send directive: draft it, preview it, and wait.

## Step 5: send (channel-specific)

### Channel `wa` (WhatsApp)

Reference adapter, the Periskope MCP (the tool is `periskope_send_message`; Claude Code shows it as `mcp__<server>__periskope_send_message`, where `<server>` is the name you gave the MCP server):

```
periskope_send_message({
  phone: "<resolved-id>",
  message: "<formatted body>"
})
```

Identity: messages send from the provider account's number (`provider.org_phone` in the registry). Recipients see that number's saved name, not "Claude" or any AI. If the content should be attributed to a specific person, put an attribution line in the body.

CLI fallback (no MCP), only after the user confirmed the preview: write the exact formatted body to a temp file (`mktemp`), then run `${CLAUDE_PLUGIN_ROOT}/bin/wa-send.sh <chat-id> <file> --yes`. The script refuses to send without `--yes`, sends from `provider.org_phone`, reads the key from the env var named in `provider.api_key_env`, and prints the API response with the queue id. Delete the temp file afterwards.

Fan-out: loop the send once per target, collect each queue id, roll up into one confirmation.

### Channel `ds` (Discord)

Needs a Discord MCP server connected to Claude Code. Send with that server's send tool, for example `discord_send` (channel id, message), or its forum-reply tool for forum threads. Preserve mentions (`<@id>`). The same preview and confirmation apply. No Discord tool connected: say so and stop.

### Channel `em` (email)

Needs an email MCP server or connector. Draft first: create the message as a draft in the user's mailbox (a Gmail-style `create_draft`, or the equivalent draft tool of a Microsoft 365 server) and show the preview with `Subject:` and `Backend:` lines. Send it only on confirmation, and only if the connected server has a send tool; otherwise tell the user the draft is waiting in their mailbox. Subject required: draft one from context and include it in the preview if the user gave none. No mail tool connected: say so and stop.

## Step 6: post-send

1. Update `<push-state-dir>/last.json` with `{ channel, target_alias, target_id, queue_id, ts }`.
2. Append a metadata-only line to `<push-state-dir>/log.jsonl` (never the body): `{ "ts", "channel", "target_alias", "target_id", "queue_id", "chars", "body_sha256" }`. The hash (`sha256sum` or `shasum -a 256` of the formatted body) lets a later send detect a repeat without storing what was said.
3. Print the confirmation line.

`<push-state-dir>` defaults to `~/.claude/wa-state/push/` (override with `PUSH_STATE_DIR`). Create it on first use.

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
- `PUSH_STATE_DIR` (default `~/.claude/wa-state/push/`)
- `WA_REGISTRY` (default `~/.claude/wa-registry.json`)

## Anti-patterns

- Do not call the provider send tool directly when `/push` would do — go through the skill so the audit log captures it.
- Do not treat a conversational suggestion ("you should tell them...") as a send directive. Wait for explicit confirmation.
- Do not fan-out broadcast without flagging it in the preview.
- Do not re-send the same body to the same target without confirmation: before sending, compare the body's `body_sha256` with the last log entries for that target, and if it matches say when it was sent and ask again.
