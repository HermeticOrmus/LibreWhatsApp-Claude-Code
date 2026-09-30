#!/usr/bin/env bash
# wa-fetch.sh — fetch WhatsApp messages from a chat via the Periskope REST API.
# Reference adapter. Used by /pull when the MCP is unavailable.
#
# Usage:  wa-fetch.sh <chat-id> [limit] [x-phone]
#   chat-id  : e.g. 123456789@c.us (DM) or 123456789012345678@g.us (group)
#   limit    : default 30
#   x-phone  : sender number the API answers as. Defaults to $WA_SENDER_PHONE,
#              else provider.default_sender_phone in the registry.
#              The API only returns messages this number participated in
#              (see the x-phone gotcha in the pull skill).
#
# API key: read from the env var named by $WA_API_KEY_ENV, else by
# provider.api_key_env in the registry, else PERISKOPE_API_KEY.
# Registry: $WA_REGISTRY, else ~/.claude/wa-registry.json (read with jq if present).
# Prints raw JSON on stdout; also writes ${TMPDIR:-/tmp}/wa-<sanitized-chat-id>.json.

set -euo pipefail
IFS=$'\n\t'

CHAT_ID="${1:?chat-id required (e.g. 123456789@c.us)}"
LIMIT="${2:-30}"
REGISTRY="${WA_REGISTRY:-$HOME/.claude/wa-registry.json}"

reg() {  # reg <jq path>: print a registry value, or nothing
  [[ -f "$REGISTRY" ]] && command -v jq >/dev/null 2>&1 || return 0
  jq -r "$1 // empty" "$REGISTRY" 2>/dev/null || true
}

XPHONE="${3:-${WA_SENDER_PHONE:-$(reg .provider.default_sender_phone)}}"
[[ -n "$XPHONE" && "$XPHONE" != \<* ]] || {
  echo "no sender number: pass x-phone as arg 3, set WA_SENDER_PHONE, or set provider.default_sender_phone in $REGISTRY" >&2
  exit 1
}

KEY_ENV="${WA_API_KEY_ENV:-$(reg .provider.api_key_env)}"
KEY_ENV="${KEY_ENV:-PERISKOPE_API_KEY}"
TOKEN="${!KEY_ENV:-}"
[[ -n "$TOKEN" ]] || { echo "$KEY_ENV is not set in the environment" >&2; exit 1; }

SAFE_NAME=$(printf '%s' "$CHAT_ID" | tr '@.' '__')
OUT="${TMPDIR:-/tmp}/wa-${SAFE_NAME}.json"

curl -sS \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-phone: $XPHONE" \
  "https://api.periskope.app/v1/chats/${CHAT_ID}/messages?limit=${LIMIT}" \
  | tee "$OUT"
