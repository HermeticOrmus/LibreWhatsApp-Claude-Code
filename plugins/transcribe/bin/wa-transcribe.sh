#!/usr/bin/env bash
# wa-transcribe.sh — transcribe an audio file with a local Whisper install.
# Audio stays on this machine. No cloud calls.
#
# Usage:  wa-transcribe.sh <audio-file> [lang] [model]
#   audio-file : local path to the audio (download remote urls first)
#   lang       : optional language hint (en, es, ...). Default: $WHISPER_LANG or auto.
#   model      : optional model name. Default: $WHISPER_MODEL or "base".
#
# Override the binary with WHISPER_BIN. Otherwise the first of these on PATH wins:
#   whisper-cli, main (whisper.cpp), whisper (OpenAI Python CLI).
#
# Prints the transcript text to stdout.

set -euo pipefail

FILE="${1:?audio file path required}"
LANG_HINT="${2:-${WHISPER_LANG:-}}"
MODEL="${3:-${WHISPER_MODEL:-base}}"

[[ -f "$FILE" ]] || { echo "no such file: $FILE" >&2; exit 1; }

find_bin() {
  if [[ -n "${WHISPER_BIN:-}" ]]; then echo "$WHISPER_BIN"; return; fi
  for b in whisper-cli main whisper; do
    command -v "$b" >/dev/null 2>&1 && { echo "$b"; return; }
  done
  return 1
}

BIN="$(find_bin)" || {
  echo "no Whisper binary found. Install whisper.cpp or openai-whisper, or set WHISPER_BIN." >&2
  exit 1
}

case "$(basename "$BIN")" in
  whisper-cli|main)
    # whisper.cpp: needs a ggml model file. Honor WHISPER_MODEL as a path if it is one.
    MODEL_ARG=()
    [[ -f "$MODEL" ]] && MODEL_ARG=(-m "$MODEL")
    LANG_ARG=(); [[ -n "$LANG_HINT" ]] && LANG_ARG=(-l "$LANG_HINT")
    "$BIN" "${MODEL_ARG[@]}" "${LANG_ARG[@]}" -nt -f "$FILE"
    ;;
  whisper)
    # OpenAI Python CLI. Writes alongside; we capture stdout instead.
    LANG_ARG=(); [[ -n "$LANG_HINT" ]] && LANG_ARG=(--language "$LANG_HINT")
    "$BIN" "$FILE" --model "$MODEL" "${LANG_ARG[@]}" --output_format txt --output_dir /tmp \
      >/dev/null 2>&1
    cat "/tmp/$(basename "${FILE%.*}").txt"
    ;;
esac
