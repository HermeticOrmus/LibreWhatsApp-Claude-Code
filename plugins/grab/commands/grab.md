# Grab chat content to the clipboard

Extract the latest shell command, URL, or code block from a WhatsApp chat and copy it to the system clipboard.

## Arguments

$ARGUMENTS

Argument shape: `[<target>] [cmd|link|code]`. Bare invocation uses the last `/pull` target and grabs the latest command.

## Instructions

Follow the `/grab` skill (`skills/grab.md`):

1. Resolve the target from the registry, or the last `/pull` target.
2. Fetch the last ~20 messages for that target.
3. Extract by kind, scanning newest-first.
4. Copy to the clipboard with the platform tool (`wl-copy`/`xclip`/`pbcopy`).
5. Confirm in one line with a short preview. Do not echo content that looks like a credential.
