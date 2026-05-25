# transcribe

Turn WhatsApp voice notes into text with a local Whisper install, so `/pull` and `/push` can work with voice messages. Audio stays on your machine.

## What it does

WhatsApp voice notes arrive as audio with no text. This downloads the audio and runs it through a local Whisper binary, then hands the transcript back to the workflow. No cloud transcription service is used.

## Usage

```
/transcribe <audio-url>          transcribe a pulled voice note
/transcribe ./memo.ogg es        a local file with a language hint
```

Most often this runs automatically inside `/pull`: when a pulled message is a voice note, its audio url is handed here and the transcript appears inline, tagged `[voice, transcribed]`.

## Setup

Install one of:

- whisper.cpp — `whisper-cli` / `main` on PATH, plus a ggml model file. Fast, CPU-only, no Python.
- openai-whisper — `pip install openai-whisper`, gives a `whisper` CLI.

Then set, if needed:

- `WHISPER_BIN` — explicit binary path (else auto-detected).
- `WHISPER_MODEL` — model name or, for whisper.cpp, a path to the ggml model file. Default `base`.
- `WHISPER_LANG` — default language hint. Default: auto-detect.

## Why local

Voice notes are often the most personal content in a chat. Local transcription keeps the audio and the text on hardware you control.
