---
description: Transcribe a voice note or audio file locally with Whisper
argument-hint: "<audio-url-or-path> [lang] [model]"
---

# Transcribe a voice note locally

Turn a WhatsApp voice note into text using a local Whisper install. Audio never leaves the machine.

## Arguments

$ARGUMENTS

Argument shape: `<audio-url-or-path> [lang] [model]`. Usually called by `/pull` when a pulled message is a voice note.

## Instructions

Read `${CLAUDE_PLUGIN_ROOT}/skills/voice-transcribe/SKILL.md` and follow it:

1. If given a URL, download the audio to a temp file. If given a path, use it.
2. Run `${CLAUDE_PLUGIN_ROOT}/bin/wa-transcribe.sh <file> [lang] [model]`, which shells to a local Whisper binary.
3. Print the transcript. If invoked from `/pull`, fold it back into the message stream tagged `[voice, transcribed]`.

If no Whisper binary is found, say so and point at the plugin README. Do not use a cloud transcription service — local-only is the point.
