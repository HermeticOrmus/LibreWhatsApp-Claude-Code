#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_SRC="$SCRIPT_DIR/plugins"
PLUGINS_DST="${CLAUDE_PLUGINS_DIR:-$HOME/.claude/plugins}"
ONLY=""

while (( $# )); do
  case "$1" in
    --plugins-dir) PLUGINS_DST="$2"; shift 2;;
    --only)        ONLY="$2"; shift 2;;
    -h|--help) echo "Usage: $0 [--plugins-dir <path>] [--only p1,p2]"; exit 0;;
    *) exit 64;;
  esac
done

mkdir -p "$PLUGINS_DST"

if [[ -n "$ONLY" ]]; then
  IFS=',' read -r -a SELECTED <<< "$ONLY"
else
  SELECTED=()
  for d in "$PLUGINS_SRC"/*/; do SELECTED+=("$(basename "$d")"); done
fi

count=0
for name in "${SELECTED[@]}"; do
  src="$PLUGINS_SRC/$name"
  dst="$PLUGINS_DST/libre-whatsapp-$name"
  [[ ! -d "$src" ]] && { echo "  [skip] $name"; continue; }
  [[ -d "$dst" ]] && { echo "  [skip] libre-whatsapp-$name (installed)"; continue; }
  cp -r "$src" "$dst"
  chmod +x "$dst"/bin/*.sh 2>/dev/null || true
  echo "  [ok] libre-whatsapp-$name"
  count=$((count + 1))
done

echo "Installed $count plugins. Restart Claude Code."
echo ""
echo "Next:"
echo "  cp registry.example.json ~/.claude/wa-registry.json   # then fill it in"
echo "  export PERISKOPE_API_KEY=...                           # or wire the MCP"
echo "  /pull wa team                                          # read a chat"
