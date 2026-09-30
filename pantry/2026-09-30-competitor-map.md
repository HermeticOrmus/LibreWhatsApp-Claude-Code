# Competitor map: LibreWhatsApp-Claude-Code

## How this fills

1. Name the product and its surfaces (plugins, agents, skills, commands, install paths).
2. WebSearch / WebFetch public competitor docs, READMEs and homepages: other Claude Code plugin packs and marketplaces in this domain, Cursor rules and plugins, Codex or Gemini CLI extensions, and standalone tools people use for the same job.
3. One row per competitor; blank unknowns; cite a URL per row.
4. Fill the capabilities matrix (Y / N / P / ?) with the capabilities that matter in this domain, and a source per claimed cell.
5. Save as `YYYY-MM-DD-competitor-map.md` (keep this template).

## Product

- Name: LibreWhatsApp-Claude-Code, v1.0.0 (read from `main` at `4e9dcc1` on 2026-09-30)
- Flagship: `pull` (`/pull` reads a chat and shows only what is new since the last pull) with its consent-first partner `push` (`/push` drafts, previews, and sends only after an explicit yes)
- Our surfaces: 4 plugins in the marketplace `libre-whatsapp` (`grab`, `pull`, `push`, `transcribe`), each with one slash command and one skill (`chat-grab`, `chat-pull`, `chat-push`, `voice-transcribe`, all `user-invocable: false`); three helper scripts (`pull/bin/wa-fetch.sh`, `push/bin/wa-send.sh`, `transcribe/bin/wa-transcribe.sh`); a user-local registry (`~/.claude/wa-registry.json`, copied from `registry.example.json`). The provider is swappable at two operations (list-messages, send-message); Periskope is the reference adapter. Discord (`ds`) and email (`em`) channels run through an MCP server the user connects. Install: `/plugin marketplace add HermeticOrmus/LibreWhatsApp-Claude-Code`, then `/plugin install <name>@libre-whatsapp`.

Star counts are from the GitHub API (`gh api repos/<owner>/<repo>`) on 2026-09-30.

## Map

| Competitor | What it is | Overlap with us | Watch / differentiator | Source URL |
|------------|------------|-----------------|------------------------|------------|
| lharries/whatsapp-mcp (6,332 stars, MIT, last push 2025-07-13) | WhatsApp MCP server: a Go bridge on the WhatsApp Web multi-device API (whatsmeow) plus a Python MCP server | `pull`, `push` | Personal account, no paid provider; local SQLite store with search; sends text, files and voice messages; README warns of "the lethal trifecta" (prompt injection leading to data exfiltration) | https://github.com/lharries/whatsapp-mcp |
| verygoodplugins/whatsapp-mcp (203 stars) | Maintained continuation of lharries/whatsapp-mcp | `pull`, `push`, `transcribe` | Adds `transcribe_audio` with whisper.cpp by default (or an OpenAI-compatible endpoint you set), webhooks, call history; CI badge | https://github.com/verygoodplugins/whatsapp-mcp |
| FelixIsaac/whatsapp-mcp-extended (33 stars) | Extended WhatsApp MCP server with gated toolsets | `pull`, `push` | 26 tools split into toolsets (`core`, `send`, `media`, ...), so an agent can run without `send`; an allowlist for who it may send to | https://github.com/FelixIsaac/whatsapp-mcp-extended |
| openclaw/wacli (2,767 stars, MIT) | WhatsApp CLI: pairs as a linked device, mirrors messages into local SQLite, search, send | `pull`, `push`, `grab` | `--read-only` (or `WACLI_READONLY=1`) for integrations that must not change anything; offline search of the local index; states it uses the WhatsApp Web protocol and is not affiliated with WhatsApp or Meta | https://github.com/openclaw/wacli |
| vicentereig/whatsapp-cli (200 stars) | Go CLI with JSON output, written for humans and LLMs ("Give your codex/claude access to WhatsApp") | `pull`, `push` | Local SQLite; a documented Claude Code and Codex integration section | https://github.com/vicentereig/whatsapp-cli |
| OpenClaw (openclaw/openclaw, 390,933 stars) | Self-hosted AI assistant that meets you in WhatsApp, Telegram, Slack, Discord, Signal, iMessage and more | `pull`, `push` across channels | README: "Treat inbound messages as untrusted input"; unknown DM senders must be approved by pairing | https://github.com/openclaw/openclaw |
| Anthropic channel plugins in `claude-plugins-official` (Discord, Telegram, iMessage; the marketplace repo has 37,242 stars) | Official Claude Code plugins that bridge a Discord bot, a Telegram bot, or macOS Messages into a session | `pull` and `push` for the `ds` channel; no WhatsApp plugin in that list | Install with `/plugin install <name>@claude-plugins-official`; pairing and allowlists decide who may message the session (`ACCESS.md` per plugin) | https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins |

## Capabilities matrix

Mark Y / N / P (partial) / ? and cite. Rows are the capabilities that matter for this domain.

Columns: Us = LibreWhatsApp v1.0.0 on `main`; LH = lharries/whatsapp-mcp; VGP = verygoodplugins/whatsapp-mcp; FX = whatsapp-mcp-extended; wacli; VR = vicentereig/whatsapp-cli; OC = OpenClaw; ACP = Anthropic channel plugins.

| Capability | Us | LH | VGP | FX | wacli | VR | OC | ACP | Source notes |
|------------|----|----|-----|----|-------|----|----|-----|--------------|
| Installs as a Claude Code plugin from a marketplace | Y | N | N | N | N | N | N | Y | Us: README Quick start. LH: Claude Desktop or Cursor MCP config. VGP, FX: MCP servers. wacli: Homebrew or release archives. VR: Go CLI. OC: its own assistant. ACP: `/plugin install ...@claude-plugins-official`. |
| Reads WhatsApp chats inside the agent session | Y | Y | Y | Y | Y | Y | Y | N | Us: `/pull`. LH: "search and read your personal Whatsapp messages". wacli: `messages search`. OC: WhatsApp channel. ACP: Discord, Telegram and iMessage only. |
| Sends through the official WhatsApp Business API | Y | N | N | N | N | ? | ? | N | Us: README says the reference adapter Periskope "sits on the official WhatsApp Business API". LH: "Whatsapp web multidevice API (using the whatsmeow library)". VGP: whatsmeow bridge. FX: extends the same bridge. wacli: "uses the WhatsApp Web protocol through whatsmeow". |
| Provider is swappable at a documented seam | Y | N | N | N | N | N | ? | N | Us: README "The provider is yours" and "Wiring a new provider" in `plugins/pull/skills/chat-pull/SKILL.md`. |
| Works with no paid service | P | Y | Y | Y | Y | Y | Y | Y | Us: the reference adapter Periskope "is a paid service"; any provider can be wired at the seam, but no free adapter ships. The others connect an account or bot directly. |
| Shows only what is new since the last read | Y | ? | ? | ? | P | ? | ? | P | Us: `chat-pull` keeps `last_seen_timestamp` per target. wacli: `sync --follow` keeps a local store current. ACP: new messages are forwarded into the session as they arrive. |
| Preview and explicit yes before every send | Y | N | N | P | P | ? | ? | ? | Us: `/push` preview-and-confirm gate; `wa-send.sh` refuses without `--yes`. LH: `send_message` sends when called. FX: a send allowlist and a toolset without `send`. wacli: `--read-only` blocks sends entirely. |
| Read-only mode | Y | N | ? | Y | Y | ? | ? | ? | Us: install `pull` without `push`; `wa-send.sh` refuses without `--yes`. FX: run without the `send` toolset. wacli: `--read-only`. |
| Credential scan before sending | Y | ? | ? | ? | ? | ? | ? | ? | Us: `chat-push` credential scan (README, CHANGELOG 0.1.0 Design). |
| Send audit log without message bodies | Y | ? | ? | ? | ? | ? | ? | ? | Us: `~/.claude/wa-state/push/log.jsonl` with metadata and `body_sha256` (CHANGELOG 1.0.0). |
| Local voice-note transcription | Y | N | Y | ? | ? | ? | ? | ? | Us: `/transcribe` with whisper.cpp or openai-whisper, no cloud fallback. LH: `download_media` only. VGP: `transcribe_audio`, whisper.cpp by default. |
| Local message store with search | N | Y | Y | Y | Y | Y | ? | P | Us: reads live from the provider each pull; no local index. LH: "stored locally in a SQLite database". wacli: FTS5 index. VR: "SQLite database, no cloud dependencies". ACP: iMessage reads `chat.db` directly. |
| Sends media (files, images, voice) | N | Y | Y | Y | Y | ? | ? | ? | Us: `chat-push` "Never pull external file/URL content into a send". LH: `send_file`, `send_audio_message`. FX: `media` toolset. |
| Discord and email in the same commands | P | N | N | N | N | N | Y | P | Us: `ds` and `em` run through an MCP server you connect; README asks for "reports from running the Discord and email channels against real servers", and no such report is in the repo. OC: 20+ channels. ACP: Discord as a separate plugin, no email. |
| Tells the agent that inbound messages are untrusted input | N | Y | ? | ? | ? | ? | Y | ? | Us: no mention of prompt injection or untrusted input in `plugins/` or the README. LH: README caution on "the lethal trifecta". OC: "Treat inbound messages as untrusted input". |
| Tests for the helper scripts, run in CI | N | ? | Y | ? | Y | ? | ? | ? | Us: no tests for `wa-fetch.sh`, `wa-send.sh` or `wa-transcribe.sh`; CI validates manifests and installs only. VGP, wacli: CI badges in README. |
| No command-name clash with sibling packs | N | ? | ? | ? | ? | ? | ? | ? | Us: LibreSessionFlow also ships a plugin named `grab` with a command named `grab`. Installed together in one clean config on 2026-09-30, both were enabled, and `claude plugin details grab` resolved to the LibreSessionFlow one. |
