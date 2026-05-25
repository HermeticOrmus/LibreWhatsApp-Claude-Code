# Troubleshooting

## A pull comes back empty or stale, but the chat is active

Your sender number is wrong. Periskope returns only messages the requesting number participated in. Set `provider.default_sender_phone` in `~/.claude/wa-registry.json` to a number that is genuinely in that chat. There is no error for this case — the result is just empty.

## "registry not found"

Copy `registry.example.json` from the repo root to `~/.claude/wa-registry.json` and fill it in. The skills read aliases from there and ship with none.

## An alias does not resolve

Check it exists under `targets` in `~/.claude/wa-registry.json` and that the `id` has the right suffix: `@g.us` for groups, `@c.us` for DMs. You can always pass a literal id instead of an alias.

## Pull shows everything every time, never "new only"

State is not being written, or the state dir differs between runs. Check `PULL_STATE_DIR` is consistent and the path is writable. Default is `~/.claude/skills/pull/state/`.

## A pulled voice note has no text

You need a local Whisper binary for `/transcribe`. Install whisper.cpp (`whisper-cli`) or openai-whisper (`whisper`), or set `WHISPER_BIN` to the path. The skill does not fall back to a cloud service by design.

## "no Whisper binary found"

`/transcribe` looks for `whisper-cli`, `main`, or `whisper` on PATH. Install one, or set `WHISPER_BIN`. For whisper.cpp, also point `WHISPER_MODEL` at a ggml model file.

## /grab does not copy

No clipboard tool was found. Install `wl-copy` (Wayland), `xclip` or `xsel` (X11), or use `pbcopy` (macOS). Override the command with `GRAB_CLIPBOARD_CMD`.

## Provider key not picked up by the CLI fallback

`wa-fetch.sh` reads the env var named in `provider.api_key_env` (default `PERISKOPE_API_KEY`). Export it in the shell that runs Claude Code. The MCP path reads its key from the MCP config instead.
