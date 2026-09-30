# Contributing

PRs welcome, especially for provider adapters, the stubbed channels, and transcription back ends.

## Ways to contribute

Everything here stays draft first and consent first: Claude drafts, you see a preview, and nothing is sent until you say yes. Contributions keep it that way.

### Take a Menu item

[`pantry/MENU.md`](pantry/MENU.md) lists the next pieces of work, each with a Done-when anyone can check, and names one as up next. The research behind it lives in [`pantry/`](pantry/). Open items are also filed as issues with the [`menu` label](https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code/issues?q=is%3Aopen+label%3Amenu), and smaller ones show up under [good first issues](https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code/contribute). To claim one, comment on the issue that you are taking it, then open a pull request that says `Closes #N`.

### Report or fix a routing miss

Every command and skill has a `description` that tells Claude when to use it. When you asked in plain words ("what did the team say?", "draft a reply", "copy the command they sent") and Claude picked the wrong plugin, or none, open a [routing miss](https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code/issues/new?template=routing-miss.yml) with the prompt you used, with real names, numbers and ids replaced. The fix is usually a sharper `description` in `plugins/<name>/skills/<skill-name>/SKILL.md`, which makes it a good first pull request.

### Propose or build a plugin

Open a [plugin proposal](https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code/issues/new?template=plugin-proposal.yml) first, so the job it does and its Done-when are agreed before you build. A plugin here has this layout (details in [Plugin layout](#plugin-layout) below):

```text
plugins/<name>/.claude-plugin/plugin.json   name, version, description, author, homepage, repository, license, keywords
plugins/<name>/commands/<name>.md           the slash command; frontmatter: description (+ argument-hint)
plugins/<name>/skills/<skill-name>/SKILL.md the method; frontmatter: name, description (when to use it), user-invocable: false
plugins/<name>/agents/<agent-name>.md       optional (none ship today); frontmatter: name, description, model: inherit
plugins/<name>/bin/                         optional helpers, called through ${CLAUDE_PLUGIN_ROOT}/bin/
.claude-plugin/marketplace.json             add an entry for the plugin with the same description as its plugin.json
```

A plugin that sends anything must preview the exact message and wait for an explicit yes, and must keep message bodies out of logs. Check the name against the sibling Libre packs: LibreSessionFlow also ships a plugin named `grab`.

### Translate

The docs are English only. Translations of `QUICK_START.md`, `TROUBLESHOOTING.md` and the `learning-paths/` guides are welcome as `<file>.<lang>.md` next to the English file. Keep every command and code block identical to the English one.

### Share what you built

Wired a new provider, ran the Discord or email channel against a real server, or built a workflow on `/pull` and `/push`? Post it in [Discussions](https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code/discussions) under Show and tell, with real numbers, ids and message text replaced, or send it as a [feedback issue](https://github.com/HermeticOrmus/LibreWhatsApp-Claude-Code/issues/new?template=feedback.yml).

### Test your change locally

Load one plugin from your clone for a single session, without installing it (`--plugin-dir plugins` loads all four):

```bash
claude --plugin-dir plugins/<name>
```

Validate the marketplace and the plugin you changed:

```bash
claude plugin validate .
claude plugin validate plugins/<name>
```

Install it into a clean, throwaway config, the way a new user would, and check that its command and skill are listed:

```bash
export CLAUDE_CONFIG_DIR=$(mktemp -d)
claude plugin marketplace add ./
claude plugin install <name>@libre-whatsapp
claude plugin details <name>@libre-whatsapp
```

To check the send gate without a provider, run `plugins/push/bin/wa-send.sh <chat-id> <message-file>` without `--yes`: it must refuse and exit 2.

CI runs the same checks on every pull request (the marketplace, every plugin, and a clean-config install of all four). A second `grok` job checks that `.grok-plugin/marketplace.json` matches the Claude manifest, validates every plugin with `grok plugin validate`, and installs all four into a clean Grok Build home; after you change `.claude-plugin/marketplace.json`, run `python3 scripts/sync-grok-manifest.py` and commit the file it writes. If this is your first contribution, the CI run waits until a maintainer approves it.

## Welcome

- Provider adapters beyond Periskope (self-hosted, Baileys-based, other aggregators).
- Hardening the Discord (`ds`) and email (`em`) channels in `/pull` and `/push` against real servers.
- Transcription back ends for `/transcribe` (faster-whisper, remote-but-self-hosted).
- Bug fixes and clearer docs.

## Not accepted

- Any committed file containing a real phone number, group id, or API key. Target resolution belongs in the user's local `~/.claude/wa-registry.json`, never in the repo.
- A `/push` change that weakens the preview-and-confirm gate or the credential scan.
- Cloud transcription fallbacks in `/transcribe`. Local-only is the design.
- AI-generated content that has not been run against a real chat.

## Design rules

- The skills carry provider-agnostic logic. Provider specifics live behind the two operations: list-messages and send-message.
- Keep message bodies out of audit logs. Log metadata only.
- Quote verbatim in `/pull` output. Never paraphrase someone's message.

## Branch and PR

Branches: `feat/`, `fix/`, `adapter/<provider>`, `channel/<code>`. Commit format: `type(scope): description`. MIT, no CLA.

## Plugin layout

Each plugin:

```
plugins/<name>/
  .claude-plugin/plugin.json      name, version, description, author, homepage, repository, license, keywords
  commands/<name>.md              the slash command; frontmatter: description (+ argument-hint)
  skills/<skill-name>/SKILL.md    the method; frontmatter: name, description, user-invocable: false
  bin/                            optional helpers, called through ${CLAUDE_PLUGIN_ROOT}/bin/
  README.md
```

The command is the user entry point and reads its skill by path. The skill has a different name from the command (two components with the same name collide) and is hidden from the slash menu, so each plugin shows one entry. Add the plugin to `.claude-plugin/marketplace.json` with the same description as its `plugin.json`, then run `claude plugin validate .` and `claude plugin validate plugins/<name>`. See `plugins/pull/` for the reference.
