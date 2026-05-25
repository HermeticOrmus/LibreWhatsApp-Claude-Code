# Transcribe a voice note locally

Turn a WhatsApp voice note into text using a local Whisper install. Audio never leaves the machine.

## Arguments

$ARGUMENTS

Argument shape: `<audio-url-or-path> [lang] [model]`. Usually called by `/pull` when a pulled message is a voice note.

## Instructions

Follow the `/transcribe` skill (`skills/transcribe.md`):

1. If given a URL, download the audio to a temp file. If given a path, use it.
2. Run `plugins/transcribe/bin/wa-transcribe.sh <file> [lang] [model]`, which shells to a local Whisper binary.
3. Print the transcript. If invoked from `/pull`, fold it back into the message stream tagged `[voice, transcribed]`.

If no Whisper binary is found, say so and point at the plugin README. Do not use a cloud transcription service — local-only is the point.
