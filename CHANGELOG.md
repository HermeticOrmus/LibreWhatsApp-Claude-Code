# Changelog

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
