# Changelog

## [1.0.0] - 2026-09-30

The pack becomes installable, and the parts that only worked through the MCP, or were stubs, now work end to end. Before this release the old `setup.sh` copied folders that Claude Code never loaded, and half of the eight command and skill files had no frontmatter.

### Added

- Plugin marketplace `libre-whatsapp` (`.claude-plugin/marketplace.json`) and a `plugin.json` for each of the four plugins. Install with `/plugin marketplace add HermeticOrmus/LibreWhatsApp-Claude-Code`, then `/plugin install <name>@libre-whatsapp`.
- `push/bin/wa-send.sh`: a no-MCP send path through the Periskope REST API. It refuses to send without `--yes`, which the push skill passes only after you confirm the preview.
- Discord (`ds`) and email (`em`) channels in `/pull` and `/push`, running through an MCP server you connect instead of stubs. Email sends are draft first.
- Push audit log entries carry a `body_sha256`, so a repeated send to the same chat is caught without storing the message.
- `/grab` recognizes `!`-prefixed lines as commands, skips your own messages, and supports `clip.exe` on WSL; it fetches without moving `/pull`'s last-seen position.
- `WA_REGISTRY` overrides the registry path for every skill and script.
- CI workflow that validates the marketplace and every plugin and installs them into a clean config.
- Feedback issue template.

### Changed

- `setup.sh` registers the marketplace and installs through the Claude Code CLI (`--list`, `--only`, `--scope`, `--uninstall`); it still prints the registry next steps on a first install. `--plugins-dir` is accepted and ignored with a note.
- Skills live at `skills/<name>/SKILL.md` and are named `chat-pull`, `chat-push`, `chat-grab`, and `voice-transcribe`, so they no longer share a name with their commands. Commands gained frontmatter and remain the slash-menu entry; skills are what Claude loads when you ask in plain words.
- State moved from `~/.claude/skills/pull/state/` and `~/.claude/skills/push/state/` to `~/.claude/wa-state/pull/` and `~/.claude/wa-state/push/`, so it no longer lands inside the folder Claude Code scans for personal skills. `PULL_STATE_DIR` and `PUSH_STATE_DIR` still override it. To keep your last-seen positions, move the old files over.
- `wa-fetch.sh` takes its API key variable and sender number from the registry when the environment does not set them, and writes its copy under `$TMPDIR`.
- Provider tool names are documented without a server prefix (`periskope_list_messages_in_a_chat`, `periskope_send_message`), since the prefix depends on what you name the MCP server.

### Fixed

- Plugins installed with the old `setup.sh` were never loaded by Claude Code. Remove any `~/.claude/plugins/libre-whatsapp-*` copies and install through the marketplace.
- Commands and skills now reference their helpers through `${CLAUDE_PLUGIN_ROOT}`, so they work from the installed plugin location, not only from a clone.
- `wa-transcribe.sh` writes OpenAI Whisper output into a private temp folder instead of a fixed `/tmp` path, and exits with an error for an unrecognized `WHISPER_BIN` instead of printing nothing.
- The transcribe docs no longer claim faster-whisper is auto-detected; it is still planned.

## [0.1.0] — 2026-05-25

Initial release. WhatsApp inside Claude Code: read a chat, send with a confirm gate, grab content to the clipboard, transcribe voice notes locally. Provider-agnostic logic with Periskope as the reference adapter.

### Plugins (4 total)

| Plugin | Status |
|---|---|
| pull | depth-complete |
| push | depth-complete |
| grab | depth-complete |
| transcribe | depth-complete |

### Design

- Target resolution moved entirely into a user-local `~/.claude/wa-registry.json`. The repo ships zero real ids.
- Provider abstracted to two operations (list-messages, send-message) so non-Periskope providers wire at one seam.
- `/push` ships preview-and-confirm on by default, with a credential scan and a metadata-only audit log.
- `/transcribe` is local-only by design; no cloud transcription fallback.

### v0.2 priorities

- Fill the Discord (`ds`) channel adapter for `/pull` and `/push`.
- A second, self-hosted provider adapter as a worked example of the seam.

### v0.3 priorities

- Email (`em`) channel adapter.
- faster-whisper back end for `/transcribe`.
