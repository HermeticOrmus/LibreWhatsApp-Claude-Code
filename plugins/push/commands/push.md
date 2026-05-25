# Send a message to a channel

Send a message to a messaging channel (WhatsApp, Discord, email) and target, with a preview-and-confirm gate by default.

## Arguments

$ARGUMENTS

Argument shape: `<channel> <target> [--send|--dry] [<message body>]`. `reply` targets the last `/pull`. Bare invocation composes from the current conversation.

## Instructions

Follow the `/push` skill (`skills/push.md`):

1. Load `~/.claude/wa-registry.json`. If absent, tell the user to set it up and stop.
2. Resolve the channel and target(s). Multiple targets means fan-out.
3. If no body was given, compose one from conversation context and the target's style.
4. Format for the channel. Show the preview block and wait for confirmation, unless `--send` was passed.
5. Send via the configured provider. The send identity is a real number, never an AI.
6. Update state and the audit log. Print the confirmation.

Apply the safety rules in the skill: preview first-time targets, warn on unregistered ids, refuse secrets in the body, no AI-attribution footers.
