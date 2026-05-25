# Intermediate — inference, fan-out, voice notes

Goal: stop naming targets explicitly, send to several chats at once, and read voice notes.

## Target inference

Once your registry has a few targets and some `inference.signals`, you can drop the target:

```
/pull wa
```

The skill scores your targets against the current conversation and picks the most likely one, falling back to `inference.default_target`. Add keyword hints in the registry to bias it:

```json
"signals": [
  { "match": "deploy|incident|on-call", "target": "team", "weight": 8 }
]
```

## Fan-out send

Send the same message to several chats in one call:

```
/push wa team teammate "Maintenance window starts in 10 minutes."
```

The preview shows every recipient before anything goes out. Each send gets its own queue id in the confirmation.

## Voice notes

Install a local Whisper binary (whisper.cpp or openai-whisper). Now when a pulled message is a voice note, its audio is transcribed locally and folded into the output tagged `[voice, transcribed]`. You can also transcribe on demand:

```
/transcribe <audio-url> es
```

The audio is processed on your machine and never sent to a cloud service.

## Grab variants

```
/grab team code     copy the last code block from a group
/grab teammate cmd   copy the last shell command from a DM
```

## What you learned

- Inference resolves targets from context plus registry hints.
- One `/push` can fan out, with every recipient shown first.
- Voice notes become text locally via `/transcribe`.

## Next

The advanced path covers non-Periskope providers and the Discord and email channels.
