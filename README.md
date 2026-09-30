<p align="center">
  <img src="https://ormus.solutions/mascot/pixellab_liquid_to_caduceus.gif" alt="LibreWhatsApp Claude Code" width="128" style="image-rendering: pixelated;" />
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

Each plugin ships a slash command and a skill (4 of each), so Claude can also use them when you ask in plain words ("what did the team say?", "draft a reply"). Three helper scripts cover the no-MCP path: `wa-fetch.sh` (read), `wa-send.sh` (send, only with `--yes` after you confirm), and `wa-transcribe.sh` (local Whisper). Nothing is sent without your explicit yes: a "send" reply to the preview, or `--send` typed on the command yourself (and even then the first send to a chat in a session previews).

## How it fits together

```
voice note ──► /transcribe (local Whisper) ──┐
                                              ▼
   a chat ──► /pull ──► only-what-is-new ──► you read it ──► /push reply ──► confirm ──► sent
                 │
                 └──► /grab ──► clipboard
```

## Quick start

### Install from Claude Code

```
/plugin marketplace add HermeticOrmus/LibreWhatsApp-Claude-Code
/plugin install pull@libre-whatsapp
/plugin install push@libre-whatsapp
```

`grab` and `transcribe` install the same way. From a terminal, the equivalent is:

```bash
claude plugin marketplace add HermeticOrmus/LibreWhatsApp-Claude-Code
claude plugin install pull@libre-whatsapp
```

Or clone the repo and let `setup.sh` register the marketplace and install all four (`./setup.sh --list`, `./setup.sh --only pull,push`, `./setup.sh --uninstall`). This pack has no hooks plugin: nothing reads or sends unless you invoke it.

### Install in Grok Build

Grok Build reads the same plugin folders. Add the marketplace, then install any of the four by name:

```bash
grok plugin marketplace add HermeticOrmus/LibreWhatsApp-Claude-Code
grok plugin install pull@LibreWhatsApp-Claude-Code --trust
grok plugin install push@LibreWhatsApp-Claude-Code --trust
```

Grok asks you to trust a plugin before it installs it; `--trust` is that answer. To install one plugin straight from its folder, without the marketplace:

```bash
grok plugin install HermeticOrmus/LibreWhatsApp-Claude-Code#plugins/pull --trust
```

From a clone, `./setup.sh --grok` installs all four into Grok Build, with the same `--only`, `--list`, and `--uninstall` options. The registry and state files are the same ones Claude Code uses. Two limits are known and tracked in [LEDGER.md](LEDGER.md): the commands read their skill and helper scripts through `${CLAUDE_PLUGIN_ROOT}`, which Grok Build documents for hooks only, so they have not been verified in a live Grok session yet; and LibreSessionFlow also ships a plugin named `grab`, which a bare `grok plugin uninstall grab` cannot tell apart from this one.

### From a clone

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

Target resolution lives in `~/.claude/wa-registry.json` on your machine (or the path in `WA_REGISTRY`), never in the repo. You copy [`registry.example.json`](registry.example.json) and fill in your own aliases, ids, and provider config. The published skills carry zero real numbers: leaking your contacts is structurally impossible, not just scrubbed. That file is the only place your data lives.

## The provider is yours

The skills call exactly two provider operations: list-messages-in-a-chat and send-message. Periskope is the reference adapter because it sits on the official WhatsApp Business API and exposes both over a clean REST surface and an MCP. It is a paid service. If you would rather run a self-hosted or free provider, you wire it at the same seam; see "Wiring a new provider" in [`plugins/pull/skills/chat-pull/SKILL.md`](plugins/pull/skills/chat-pull/SKILL.md). The inference, dedup, slicing, safety, and transcription logic do not change.

## The sender gotcha

The most common wiring mistake, called out here so you avoid it: a provider that aggregates one number's chats only returns messages that number participated in. Ask with the wrong number and you get an empty slice with no error. Set `provider.default_sender_phone` to a number that is actually in the chats you read. Details in [`plugins/pull/skills/chat-pull/SKILL.md`](plugins/pull/skills/chat-pull/SKILL.md).

## Compatibility

- Claude Code 2.1 or later (plugin marketplaces; tested on 2.1.285)
- Linux and macOS. Windows via WSL2 should work but is untested.
- Clipboard for `/grab`: `wl-copy`, `xclip`/`xsel`, `pbcopy`, or `clip.exe` (WSL).
- `curl` and `jq` for the no-MCP fallbacks.
- Local Whisper for `/transcribe`: whisper.cpp or openai-whisper.

## Sibling repos

Part of the Libre-*-Claude-Code family. The general-purpose `/grab` and `/share-prompt` live in [LibreSessionFlow](https://github.com/HermeticOrmus/LibreSessionFlow-Claude-Code); the `/grab` here is the WhatsApp-specific variant.

## Feedback

Starred this? Tell us what worked and what is missing: [open a feedback issue](https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code/issues/new?template=feedback.yml). Every piece of feedback gets an answer, and changes that come from it are credited in the release notes.

## Contribute

- Cracks we found and sealed: [LEDGER.md](LEDGER.md). The open rows are work anyone can pick up.
- Pick up the next piece of work from the [Menu](pantry/MENU.md): each item has a Done-when anyone can check, keeps sending draft first and consent first, and cites the research in [`pantry/`](pantry/).
- New here? Start with the [good first issues](https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code/contribute).
- Claude picked the wrong plugin? File a [routing miss](https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code/issues/new?template=routing-miss.yml). Want a new plugin? Open a [plugin proposal](https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code/issues/new?template=plugin-proposal.yml). Anything else goes in a [feedback issue](https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code/issues/new?template=feedback.yml).
- Show what you built in [Discussions](https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code/discussions). The full guide is in [CONTRIBUTING.md](CONTRIBUTING.md#ways-to-contribute).

## Contributing

PRs welcome, especially: provider adapters beyond Periskope, reports from running the Discord and email channels against real servers, and transcription back ends. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT © 2026 [Diego Bodart](https://github.com/HermeticOrmus) — see [LICENSE](LICENSE). Built under the [Gold Hat principle](GOLD_HAT.md).
