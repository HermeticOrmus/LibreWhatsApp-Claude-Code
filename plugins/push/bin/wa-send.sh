#!/usr/bin/env bash
# wa-send.sh: send one WhatsApp message via the Periskope REST API.
# Reference adapter. Used by /push when the MCP is unavailable, and only after
# the user has confirmed the preview.
#
# Usage:  wa-send.sh <chat-id> <message-file> --yes [x-phone]
#   chat-id      : <phone>@c.us for a DM, <group-id>@g.us for a group
#   message-file : file holding the exact, already formatted message body
#   --yes        : required. The script refuses to send without it, so nothing
#                  goes out unless the caller has a confirmation in hand.
#   x-phone      : number the message is sent from. Defaults to $WA_SENDER_PHONE,
#                  else provider.org_phone in the registry.
#
# API key: the env var named by $WA_API_KEY_ENV, else provider.api_key_env in the
# registry, else PERISKOPE_API_KEY. Registry: $WA_REGISTRY, else ~/.claude/wa-registry.json.
# Needs curl and jq. Prints the API response (JSON with a queue id) on stdout.

set -euo pipefail
IFS=$'\n\t'

CHAT_ID="${1:?chat-id required (<phone>@c.us or <group-id>@g.us)}"
MSG_FILE="${2:?message file required}"
CONFIRM="${3:-}"
REGISTRY="${WA_REGISTRY:-$HOME/.claude/wa-registry.json}"

[[ "$CONFIRM" == "--yes" ]] || {
  echo "refusing to send without --yes: show the preview and get the user's confirmation first" >&2
  exit 2
}
[[ -s "$MSG_FILE" ]] || { echo "message file is missing or empty: $MSG_FILE" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }
[[ "$CHAT_ID" =~ ^[0-9]+@(c|g)\.us$ ]] || { echo "not a WhatsApp chat id: $CHAT_ID" >&2; exit 1; }

reg() {  # reg <jq path>: print a registry value, or nothing
  [[ -f "$REGISTRY" ]] || return 0
  jq -r "$1 // empty" "$REGISTRY" 2>/dev/null || true
}

XPHONE="${4:-${WA_SENDER_PHONE:-$(reg .provider.org_phone)}}"
[[ -n "$XPHONE" && "$XPHONE" != \<* ]] || {
  echo "no sending number: pass x-phone as arg 4, set WA_SENDER_PHONE, or set provider.org_phone in $REGISTRY" >&2
  exit 1
}

KEY_ENV="${WA_API_KEY_ENV:-$(reg .provider.api_key_env)}"
KEY_ENV="${KEY_ENV:-PERISKOPE_API_KEY}"
TOKEN="${!KEY_ENV:-}"
[[ -n "$TOKEN" ]] || { echo "$KEY_ENV is not set in the environment" >&2; exit 1; }

jq -n --arg chat_id "$CHAT_ID" --rawfile message "$MSG_FILE" '{chat_id: $chat_id, message: $message}' \
  | curl -sS \
      -X POST \
      -H "Authorization: Bearer $TOKEN" \
      -H "x-phone: $XPHONE" \
      -H "Content-Type: application/json" \
      --data-binary @- \
      "https://api.periskope.app/v1/message/send"
echo
