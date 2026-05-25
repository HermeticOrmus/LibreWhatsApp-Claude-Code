---
name: transcribe
description: Turn a WhatsApp voice note into text using a local Whisper install, so /pull and /push can read, summarize, or route voice messages. Audio never leaves your machine. Use when a pulled message is a voice note, or when the user asks to transcribe an audio message.
---

# /transcribe — voice note to text, locally

WhatsApp voice notes arrive as audio with no text body. Cloud message providers do not transcribe them. This skill downloads the audio and runs it through a local Whisper binary, so the rest of the workflow can treat a voice note like any other message. The audio and the transcript stay on your machine.

## Argument shape

```
/transcribe <audio-url-or-path> [lang] [model]
```

| Arg | Meaning |
|---|---|
| `audio-url-or-path` | The media url from a pulled message, or a local file path. |
| `lang` | Optional language hint (e.g. `en`, `es`). Omit to let Whisper detect. |
| `model` | Optional Whisper model name. Defaults to `WHISPER_MODEL` or `base`. |

In practice this is usually invoked by `/pull`: when a pulled WhatsApp message is a voice note, hand its media url here.

## Step 1: get the audio local

If given a URL, download it to a temp file (`/tmp/wa-voice-<hash>.<ext>`). If given a path, use it directly.

## Step 2: transcribe with local Whisper

Run the local transcriber via `plugins/transcribe/bin/wa-transcribe.sh <file> [lang] [model]`. The helper shells to a `whisper` binary on `PATH` (override with `WHISPER_BIN`). It prints the transcript to stdout.

Supported back ends, in preference order, auto-detected by the helper:

- `whisper.cpp` (`whisper-cli` / `main`) — fast, CPU-friendly, no Python.
- OpenAI `whisper` Python CLI.
- `faster-whisper` if exposed as a CLI.

If no Whisper binary is found, say so and point the user at the setup notes in the plugin README. Do not fall back to a cloud transcription service — local-only is the point.

## Step 3: return the transcript

Print the transcript text. When invoked from `/pull`, fold it back into the message stream in place of the empty voice-note body, tagged so it is clear it was transcribed:

```
**`HH:MM:SSZ` <Sender>** — [voice, transcribed] <transcript text>
```

## Configuration

- `WHISPER_BIN` — path to the Whisper binary (else auto-detected on PATH).
- `WHISPER_MODEL` — default model (else `base`).
- `WHISPER_LANG` — default language hint (else auto-detect).

## Why local

Voice notes are often the most personal messages in a chat. Sending them to a third-party transcription API leaks that content. Running Whisper locally keeps the audio and the transcript on hardware you control. This is the same principle the rest of this repo runs on: the logic is yours, and so is the data.
