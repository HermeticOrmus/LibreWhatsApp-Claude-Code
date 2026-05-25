#!/usr/bin/env bash
# wa-fetch.sh — fetch WhatsApp messages from a chat via the Periskope REST API.
# Reference adapter. Used by /pull when the MCP is unavailable.
#
# Usage:  wa-fetch.sh <chat-id> [limit] [x-phone]
#   chat-id  : e.g. 123456789@c.us (DM) or 123456789012345678@g.us (group)
#   limit    : default 30
#   x-phone  : sender number the API answers as. Defaults to $WA_SENDER_PHONE.
#              The API only returns messages this number participated in
#              (see the x-phone gotcha in skills/pull.md).
#
# Requires PERISKOPE_API_KEY in the environment (or override WA_API_KEY_ENV).
# Prints raw JSON on stdout; also writes /tmp/wa-<sanitized-chat-id>.json.

set -euo pipefail

CHAT_ID="${1:?chat-id required (e.g. 123456789@c.us)}"
LIMIT="${2:-30}"
XPHONE="${3:-${WA_SENDER_PHONE:?set WA_SENDER_PHONE or pass x-phone as arg 3}}"

KEY_ENV="${WA_API_KEY_ENV:-PERISKOPE_API_KEY}"
TOKEN="${!KEY_ENV:?$KEY_ENV is not set in the environment}"

SAFE_NAME=$(echo "$CHAT_ID" | tr '@.' '__')
OUT="/tmp/wa-${SAFE_NAME}.json"

curl -sS \
  -H "Authorization: Bearer $TOKEN" \
  -H "x-phone: $XPHONE" \
  "https://api.periskope.app/v1/chats/${CHAT_ID}/messages?limit=${LIMIT}" \
  | tee "$OUT"
