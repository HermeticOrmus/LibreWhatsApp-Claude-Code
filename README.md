<p align="center">
  <img src="https://ormus.solutions/mascot/chain_braces_to_swan.gif" alt="LibreWhatsApp Claude Code" width="128" style="image-rendering: pixelated;" />
</p>

<h1 align="center">LibreWhatsApp Claude Code</h1>

<p align="center">
  <em>Read and send WhatsApp from inside Claude Code — pull a chat, see only what is new, send with a confirm gate, transcribe voice notes locally. The logic is the library; the provider is yours.</em>
</p>

<p align="center">
  <a href="https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code/stargazers"><img src="https://img.shields.io/github/stars/HermeticOrmus/LibreWhatsApp-Claude-Code?style=flat-square&color=aa8142" alt="Stars" /></a>
  <a href="https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code/blob/main/LICENSE"><img src="https://img.shields.io/github/license/HermeticOrmus/LibreWhatsApp-Claude-Code?style=flat-square&color=aa8142" alt="License" /></a>
  <img src="https://img.shields.io/badge/Messaging-aa8142?style=flat-square&logo=whatsapp&logoColor=white" alt="Messaging" />
  <img src="https://img.shields.io/badge/Claude_Code-aa8142?style=flat-square&logo=anthropic&logoColor=white" alt="Claude Code" />
</p>

---

> Skills, commands, and helpers that put WhatsApp inside your Claude Code session.

You are working in Claude Code and the thing you need is in a WhatsApp chat — a command a teammate sent, a decision in a group, a voice note you have not listened to. Switching to your phone breaks the flow and loses the context. These four plugins let the model read and write that conversation for you, without leaving the session.

The value here is the workflow logic, not a vendor. The alias registry, the dedup-since-last-pull, the sender gotcha that silently returns empty results, the send-safety gate, the local-only voice transcription — that is the part worth open-sourcing. The message provider is a swappable detail. The reference adapter is Periskope; the seam is documented so you can wire any provider, including a self-hosted one.

## The four plugins

| Plugin | Command | What it does |
|---|---|---|
| pull | `/pull` | Fetch a chat, resolve aliases, show only what is new since last time, slice long histories through a subagent. |
| push | `/push` | Send a message with a preview-and-confirm gate, fan-out to multiple chats, audit-log every send. |
| grab | `/grab` | Copy the latest command, URL, or code block from a chat straight to the clipboard. |
| transcribe | `/transcribe` | Turn a voice note into text with a local Whisper install. Audio never leaves your machine. |

## How it fits together

```
voice note ──► /transcribe (local Whisper) ──┐
                                              ▼
   a chat ──► /pull ──► only-what-is-new ──► you read it ──► /push reply ──► confirm ──► sent
                 │
                 └──► /grab ──► clipboard
```

## Quick start

```bash
git clone https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code.git ~/projects/LibreWhatsApp-Claude-Code
cd ~/projects/LibreWhatsApp-Claude-Code
./setup.sh
cp registry.example.json ~/.claude/wa-registry.json   # then fill it in
```

Restart Claude Code. Set your provider key, then:

```
/pull wa team
```

See [QUICK_START.md](QUICK_START.md) for the full first-run walkthrough, including the one wiring mistake everyone makes.

## The registry

Target resolution lives in `~/.claude/wa-registry.json` on your machine, never in the repo. You copy [`registry.example.json`](registry.example.json) and fill in your own aliases, ids, and provider config. The published skills carry zero real numbers — leaking your contacts is structurally impossible, not just scrubbed. That file is the only place your data lives.

## The provider is yours

The skills call exactly two provider operations: list-messages-in-a-chat and send-message. Periskope is the reference adapter because it sits on the official WhatsApp Business API and exposes both over a clean REST surface and an MCP. It is a paid service. If you would rather run a self-hosted or free provider, you wire it at the same seam — see "Wiring a new provider" in [`plugins/pull/skills/pull.md`](plugins/pull/skills/pull.md). The inference, dedup, slicing, safety, and transcription logic do not change.

## The sender gotcha

The most common wiring mistake, called out here so you avoid it: a provider that aggregates one number's chats only returns messages that number participated in. Ask with the wrong number and you get an empty slice with no error. Set `provider.default_sender_phone` to a number that is actually in the chats you read. Details in [`plugins/pull/skills/pull.md`](plugins/pull/skills/pull.md).

## Compatibility

- Claude Code 1.x+
- Linux and macOS. Windows via WSL2 should work but is untested.
- Clipboard for `/grab`: `wl-copy`, `xclip`/`xsel`, or `pbcopy`.
- Local Whisper for `/transcribe`: whisper.cpp or openai-whisper.

## Sibling repos

Part of the Libre-*-Claude-Code family. The general-purpose `/grab` and `/share-prompt` live in [LibreSessionFlow](https://github.com/HermeticOrmus/LibreSessionFlow-Claude-Code); the `/grab` here is the WhatsApp-specific variant.

## Contributing

PRs welcome, especially: provider adapters beyond Periskope, the Discord and email channel stubs filled in, and transcription back ends. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT © 2026 [Diego Bodart](https://github.com/HermeticOrmus) — see [LICENSE](LICENSE). Built under the [Gold Hat principle](GOLD_HAT.md).
