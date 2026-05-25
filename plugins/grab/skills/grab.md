---
name: grab
description: Pull the latest useful content out of a WhatsApp chat straight to the system clipboard — the most recent shell command, URL, or code block someone sent. Companion to /pull. Bare /grab uses the last /pull target; /grab <alias> overrides.
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

Read `~/.claude/wa-registry.json` for aliases. If no target arg, read the last `/pull` target from `~/.claude/skills/pull/state/last.json`.

## Step 1: fetch recent messages

Pull the last ~20 messages for the target (reuse the `/pull` fetch path — MCP `periskope_list_messages_in_a_chat`, or `wa-fetch.sh`). Mind the x-phone sender setting from the registry.

## Step 2: extract by kind

Scan newest-first and pick the first match:

- `cmd` — a line that looks like a shell command: starts with a known binary, or is fenced as ```` ```bash ````/```` ```sh ````, or is prefixed with `$`. Strip a leading `$ ` and any fencing.
- `link` — the last `https?://...` URL.
- `code` — the contents of the last fenced code block (any language).

If nothing matches, say so and show the latest message so the user can pick manually.

## Step 3: copy to clipboard

Detect the clipboard tool and pipe the extracted text to it:

- Wayland: `wl-copy`
- X11: `xclip -selection clipboard` or `xsel --clipboard --input`
- macOS: `pbcopy`

Override with `GRAB_CLIPBOARD_CMD` if set. Print a one-line confirmation with a short preview of what was copied (truncate to ~80 chars). Never print full secrets if the content looks like a credential — note that it was copied without echoing it.

## Anti-patterns

- Do not copy and also paste/execute. Grab only puts it on the clipboard; the user decides what to do next.
- Do not echo full content that matches a credential pattern.
