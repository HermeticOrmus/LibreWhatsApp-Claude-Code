# Quick start

From clone to reading a chat in about five minutes.

## 1. Install the plugins

```bash
git clone https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code.git ~/projects/LibreWhatsApp-Claude-Code
cd ~/projects/LibreWhatsApp-Claude-Code
./setup.sh
```

`setup.sh` copies the four plugins into `~/.claude/plugins/` as `libre-whatsapp-pull`, `-push`, `-grab`, `-transcribe`. Restart Claude Code afterward. Install a subset with `./setup.sh --only pull,push`.

## 2. Pick a provider

The reference adapter is Periskope, which sits on the official WhatsApp Business API.

- Sign up for Periskope and connect your WhatsApp number.
- Get an API key.
- Either wire the Periskope MCP into Claude Code, or set `PERISKOPE_API_KEY` in your shell so the CLI fallback works.

Prefer a different provider? Any service that can list a chat's messages and send a message fits. See "Wiring a new provider" in `plugins/pull/skills/pull.md`.

## 3. Build your registry

```bash
cp registry.example.json ~/.claude/wa-registry.json
```

Edit `~/.claude/wa-registry.json`:

- `provider.org_phone` — the number your provider account sends from, digits only.
- `provider.default_sender_phone` — usually the same number. Read the note on it; this is the field people get wrong.
- `targets` — your aliases. Group ids end in `@g.us`, DMs in `@c.us`. Find them by listing chats in your provider dashboard, or pull a known chat once with a literal id and copy it from the output.

This file stays on your machine. Nothing in the repo contains a real number.

## 4. Read a chat

```
/pull wa team
```

First pull shows everything in the window. Pull again later and you see only what arrived since. Try `/pull wa teammate 50` for a longer window, or `/pull wa team last 4h` for a time slice.

## 5. The one mistake everyone makes

If a pull comes back empty or stale even though the chat is active, your sender number is wrong. Periskope returns only messages the requesting number participated in. Set `provider.default_sender_phone` to a number that is genuinely in that chat. There is no error for this — just an empty result.

## 6. Send a reply

```
/push reply "On it."
```

`reply` targets whatever you last pulled. You get a preview and a confirm prompt before anything sends. Use `/push wa team "..."` to target a specific chat, or `--send` to skip the gate once you trust it.

## 7. Voice notes

If a pulled message is a voice note, hand its audio url to `/transcribe` (or let `/pull` do it automatically once a local Whisper binary is installed). The audio is processed locally and never sent to a cloud service.

## Next

- `plugins/pull/README.md` — full pull options and the sender gotcha.
- `plugins/push/README.md` — send safety rules and fan-out.
- `TROUBLESHOOTING.md` — empty pulls, clipboard, Whisper not found.
