---
name: chat-pull
description: "Reads recent messages from a WhatsApp chat (or a Discord channel or email thread) into the session, resolving human aliases from your local registry, inferring the chat from the conversation when none is named, and showing only what is new since the last pull, quoted verbatim. Use when the user wants to read, check, or catch up on a chat, see what someone said, or pull a thread before replying."
user-invocable: false
---

# /pull — channel-aware message pull

The entry point for "show me what has been said in `<channel>` by/about `<target>`". The skill carries the inference, dedup, and slicing logic; channel adapters carry the API specifics. None of the logic is provider-specific.

## Argument shape

```
/pull <channel> [<target>] [<count>|last <window>] [verbose]
```

| Arg | Meaning |
|---|---|
| `channel` | Two-letter code: `wa` (WhatsApp), `ds` (Discord), `em` (email). |
| `target` | Alias from your registry, a literal id, or omitted (then inferred). |
| `count` / `last <window>` | How much to pull. Default 30 messages. Window form: `last 4h`, `last 24h`. |
| `verbose` | Show previously-seen messages too. Default shows only what is new. |

Bare `/pull` repeats the most-recent `(channel, target)` pair from state.

## Step 0: load the registry

Read `~/.claude/wa-registry.json`, or the file named in `WA_REGISTRY` if that is set (copy `registry.example.json` from the repo root to create it). It holds your provider config, target aliases, inference hints, and sender-to-name map. If it is missing, tell the user to create it and stop. The skill never ships with real ids; resolution is entirely registry-driven.

## Step 1: resolve channel and target

1. First arg is the channel code. If unrecognized, ask `wa / ds / em?`.
2. Second arg is the target. Resolve it against `targets` in the registry. A literal id matching `^[0-9]+@(c|g)\.us$` passes through unchanged.
3. If the target is absent, run inference (Step 2).
4. State file path: `<state-dir>/<channel>__<target-id>.json`. If channel and target are both absent, read `<state-dir>/last.json` to recover the prior pair.

`<state-dir>` defaults to `~/.claude/wa-state/pull/` and can be overridden with `PULL_STATE_DIR`. Create it on first use.

## Step 2: target inference (when target is absent)

Look at the last ~50 turns of the current conversation. Score each registry target using the `inference.signals` keyword hints, plus channel-specific signals (below). Pick the highest score; if two are within a few points, ask one targeted question naming the top options. Fall back to `inference.default_target`.

Save the resolved `(channel, target)` pair to `<state-dir>/last.json` so a bare future `/pull` knows the default.

## Step 3: fetch (channel-specific)

### Channel `wa` (WhatsApp)

Resolve the target id from the registry. Then call the provider.

Reference adapter, the Periskope MCP (the tool is `periskope_list_messages_in_a_chat`; Claude Code shows it as `mcp__<server>__periskope_list_messages_in_a_chat`, where `<server>` is the name you gave the MCP server):

```
periskope_list_messages_in_a_chat({
  chat_id: <resolved-id>,
  offset: 0,
  limit: <count, default 30>,
  start_time: <if "last <window>" form>
})
```

The x-phone gotcha (provider-specific, costs you silently if wrong): Periskope returns only messages that the requesting account number participated in. If you ask with a number that is not actually in the chat, you get an empty or stale slice with no error. Set `provider.default_sender_phone` in the registry to a number that is genuinely in the chats you read. When the MCP is used, it takes the sender from its own session — verify that session is the right number when first wiring on a new machine.

CLI fallback (no MCP): `${CLAUDE_PLUGIN_ROOT}/bin/wa-fetch.sh <chat-id> [limit] [x-phone]`. It reads the API key from the env var named in `provider.api_key_env` and the sender from `provider.default_sender_phone` (both from the registry; `WA_API_KEY_ENV` and `WA_SENDER_PHONE` override them), writes raw JSON to stdout, and saves a copy to `${TMPDIR:-/tmp}/wa-<chat-id-slug>.json` for slicing.

Sender-to-name resolution for output: map each `sender_phone` through `sender_resolution` in the registry. Without an entry, print the raw id.

Voice notes arrive as audio with no text body. To turn them into readable text, hand the media url to `/transcribe` (the transcribe plugin's `voice-transcribe` skill, local Whisper). Without the transcribe plugin installed, show `[voice note, not transcribed]` with the media url instead.

### Channel `ds` (Discord)

Needs a Discord MCP server connected to Claude Code. Registry targets for Discord use `"channel": "ds"` and the channel id as `id` (plus an optional `server` note). Read with that server's read-messages tool, for example `discord_read_messages` (channel id, limit). If no Discord tool is in the tool list, say that the `ds` channel needs a Discord MCP server and stop. Sender resolution is by Discord username; map ids to names in `sender_resolution` if you want. The dedup, slicing, and output steps below apply unchanged.

### Channel `em` (email)

Needs an email MCP server or connector (a Gmail connector, a Microsoft 365 or Graph server, or any mail server with a search tool). Registry targets for email use `"channel": "em"` and the address as `id`. Read with that server's search tool: a Gmail-style `search_threads` with `from:<address>` (then `get_thread` for bodies), or a Graph-style mail list filtered on the sender address. Pick the backend by the registry entry's optional `backend` field, else by what is connected. Treat each email as a message (`timestamp`, `sender`, `subject` plus `body`); dedup and output work the same way. No mail tool connected: say so and stop.

## Step 4: slicing for large results

If the fetch result exceeds the threshold (`PULL_TOKEN_THRESHOLD`, default 50000 bytes), save it to disk and delegate parsing to a subagent rather than read the raw payload into context.

Subagent prompt:

```
Slice the file <saved-path> in ~80,000-char spans via python until you have read all of it.
Context: <one line — channel + target>.
Return verbatim, under 800 words:
1. Every message after <last-seen-timestamp or NEW cutoff> — timestamp, named sender, body. Most recent first.
2. Any markers your context defines as significant (locked plans, completions, decisions).
3. Specific commits/branches/tasks/files mentioned.
Quote verbatim, never paraphrase. Empty section = "(none)".
```

## Step 5: dedup against prior pulls

Read `<state-dir>/<channel>__<target-id>.json`:

```json
{ "last_seen_message_id": "...", "last_seen_timestamp": "ISO", "last_pulled_at": "ISO" }
```

Show only messages with `timestamp > last_seen_timestamp`, tagged as new. With `verbose`, show everything but separate new from previously-seen. No state file means a first pull — treat all as new.

Update the state file at the end with the newest message id, timestamp, and current time. Also update `<state-dir>/last.json` with `{ channel, target_alias, target_id, ts }`.

## Step 6: output format

```markdown
## Pulled `<channel>` from <Target Name>  (<id>)

Window: <30 messages | last 4h>
New since last pull: <N> | Total in window: <M>

### New messages (<N>)

**`HH:MM:SSZ` <Sender>** — verbatim body

### Previously seen (<M-N>)
(collapsed unless verbose)
```

Within "new", sort oldest-first so reading top-down is chronological.

## Configuration

Read from env at invoke time:

- `PULL_DEFAULT_LIMIT` (default 30)
- `PULL_TOKEN_THRESHOLD` (default 50000)
- `PULL_DEFAULT_CHANNEL` (default `wa`)
- `PULL_STATE_DIR` (default `~/.claude/wa-state/pull/`)
- `WA_REGISTRY` (default `~/.claude/wa-registry.json`)

## Wiring a new provider

The skill calls two provider operations: list-messages-in-chat and (for `/push`) send-message. To use a provider other than Periskope:

1. Set `provider.type` in the registry and add whatever config keys your provider needs (key env var, base url).
2. Replace the Step 3 fetch call with your provider's list call. Keep the return normalized to `{ id, timestamp, sender, body, media }` per message.
3. If there is no MCP, add a fetch helper modeled on `bin/wa-fetch.sh`.

Everything else — inference, dedup, slicing, output — is provider-independent and unchanged.

## Anti-patterns

- Do not read fetch results over the threshold directly. Save then subagent.
- Do not paraphrase message bodies. Quote verbatim.
- Do not update the state file before the result is successfully presented.
- Do not default to `verbose`. The point is "what is new since I last looked".
