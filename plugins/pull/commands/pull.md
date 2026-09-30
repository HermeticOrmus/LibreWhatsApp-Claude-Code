---
description: Read a chat into the session, showing only messages that are new since the last pull
argument-hint: "<wa|ds|em> [target] [count | last <window>] [verbose]"
---

# Pull messages from a channel

Fetch recent messages from a messaging channel (WhatsApp, Discord, email) and a target, showing only what is new since the last pull.

## Arguments

$ARGUMENTS

Argument shape: `<channel> [<target>] [<count>|last <window>] [verbose]`. Bare invocation repeats the last `(channel, target)` pair.

## Instructions

Read `${CLAUDE_PLUGIN_ROOT}/skills/chat-pull/SKILL.md` and follow it:

1. Load `~/.claude/wa-registry.json`. If absent, tell the user to copy `registry.example.json` to that path and fill it in, then stop.
2. Resolve the channel and target. Infer the target from the current conversation if it was not given.
3. Fetch via the configured provider. Mind the x-phone sender gotcha for WhatsApp.
4. If the result is large, save to disk and slice via a subagent.
5. Dedup against the per-target state file. Show only new messages, oldest-first.
6. Update state. Print the formatted output.

Quote message bodies verbatim. Never paraphrase.
