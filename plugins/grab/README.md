# grab

Pull the latest useful content out of a WhatsApp chat to your clipboard. Companion to `/pull`.

## Contents

- **Command**: `/grab`
- **Skill**: `chat-grab`

Clipboard tools: `wl-copy`, `xclip` or `xsel`, `pbcopy`, or `clip.exe` on WSL. To copy the latest command or reply from your own Claude Code session instead of a chat, use the `grab` plugin in the LibreSessionFlow pack.

## What it does

`/pull` reads a chat into your view. `/grab` puts the next thing you would copy by hand — a shell command someone sent, a URL, a code block — straight onto the system clipboard.

## Usage

```
/grab                 latest command from the last /pull target
/grab teammate        latest command from a specific chat
/grab team link       latest URL from a group
/grab teammate code   latest fenced code block
```

## Setup

Shares `~/.claude/wa-registry.json` with `/pull`. Needs a clipboard tool: `wl-copy` (Wayland), `xclip`/`xsel` (X11), or `pbcopy` (macOS). Override with `GRAB_CLIPBOARD_CMD`.
