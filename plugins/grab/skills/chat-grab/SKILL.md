---
name: chat-grab
description: "Copies the latest useful thing someone sent in a WhatsApp chat (a shell command, a URL, or a code block) straight to the system clipboard, using the same local registry as /pull. Use when the user wants to copy, grab, or paste a command, link, or snippet from a chat without opening their phone."
user-invocable: false
---

# /grab — chat content to clipboard

`/pull` reads a conversation into your view. `/grab` puts the next thing you would hand-copy from it onto the clipboard, so you can paste it straight into a terminal or editor.

## Argument shape

```
/grab [<target>] [cmd|link|code]
```

| Arg | Meaning |
|---|---|
| `target` | Registry alias or literal id. Omitted = the last `/pull` target. |
| kind | `cmd` (default — latest shell command), `link` (latest URL), `code` (latest fenced code block). |

## Step 0: resolve target

Read `~/.claude/wa-registry.json` (or `WA_REGISTRY`) for aliases. If no target arg, read the last `/pull` target from `<pull-state-dir>/last.json` (`PULL_STATE_DIR`, default `~/.claude/wa-state/pull/`).

## Step 1: fetch recent messages

Fetch the last 20 messages for the target without touching `/pull`'s last-seen state (grab means "latest", not "newest unseen"):

- With the Periskope MCP: `periskope_list_messages_in_a_chat({ chat_id: <id>, offset: 0, limit: 20 })`.
- Without it, the REST call the pull plugin's `wa-fetch.sh` makes, with the key from the env var named in `provider.api_key_env` (shown here as `PERISKOPE_API_KEY`, the default) and the sender from `provider.default_sender_phone`:

  ```bash
  curl -sS -H "Authorization: Bearer $PERISKOPE_API_KEY" -H "x-phone: <default_sender_phone>" \
    "https://api.periskope.app/v1/chats/<chat-id>/messages?limit=20"
  ```

Mind the x-phone sender setting: the wrong number returns an empty result with no error. Consider only messages from other people (skip ones marked `from_me`); you rarely need to grab your own.

## Step 2: extract by kind

Scan newest-first and pick the first match:

- `cmd`: in this order: lines prefixed with `!` (a convention for "run this"; strip the `!`), then a fenced ```` ```bash ````/```` ```sh ```` block, then a one-line message that starts with a known binary (`git`, `npm`, `curl`, `docker`, `ssh`, ...) or with `$`. Strip a leading `$ ` and any fencing.
- `link` — the last `https?://...` URL.
- `code` — the contents of the last fenced code block (any language).

If nothing matches, say so and show the latest message so the user can pick manually.

## Step 3: copy to clipboard

Detect the clipboard tool and pipe the extracted text to it:

- Wayland: `wl-copy`
- X11: `xclip -selection clipboard` or `xsel --clipboard --input`
- macOS: `pbcopy`
- WSL: `clip.exe`

Override with `GRAB_CLIPBOARD_CMD` if set. Print a one-line confirmation with a short preview of what was copied (truncate to ~80 chars). Never print full secrets if the content looks like a credential — note that it was copied without echoing it.

## Anti-patterns

- Do not copy and also paste/execute. Grab only puts it on the clipboard; the user decides what to do next.
- Do not echo full content that matches a credential pattern.

## Related

The LibreSessionFlow pack has a `grab` plugin for the other direction: copying the latest command, URL, or reply from the current Claude Code session.
