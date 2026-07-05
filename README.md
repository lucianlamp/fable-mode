# fable-mode

A toolkit for reproducing Claude Fable 5's behavioral discipline on Sonnet-class or smaller models.

Fable 5's intelligence is the product of (1) raw model-specific capability (vision, first-shot correctness, long-horizon instruction retention) and (2) disciplined behavioral patterns. (1) cannot be transplanted, but (2) can be injected as a system prompt or skill — this repository extracts that second half.

## Layout

```
fable-mode/
├── docs/
│   └── claude-fable-5-analysis.md   # Analysis of what makes Fable 5 smart (with sources)
├── prompts/
│   ├── fable-emulation-prompt.md    # The system prompt (10 behavioral rule blocks)
│   └── fable-emulation-codex.md     # Codex CLI edition (delegation/verification wired to codex-dynamic-workflows)
├── skills/
│   └── fable-mode/SKILL.md          # Claude Code skill version (behavior loop + gap-compensation table)
└── bin/
    ├── claude-fable                 # Launcher for Git Bash / WSL
    └── claude-fable.cmd             # Launcher for cmd / PowerShell
```

## Install

```bash
# Place the prompt and skill
cp prompts/fable-emulation-prompt.md ~/.claude/
mkdir -p ~/.claude/skills/fable-mode
cp skills/fable-mode/SKILL.md ~/.claude/skills/fable-mode/

# Place the launchers somewhere on PATH
cp bin/claude-fable bin/claude-fable.cmd ~/.local/bin/
chmod +x ~/.local/bin/claude-fable
```

## Usage

```bash
claude-fable                    # Launch Claude Code with Fable discipline
claude-fable --model sonnet     # Launch on Sonnet (arguments pass through to claude)
```

Or as a skill inside a session:

```
/fable-mode
```

### Codex CLI

```bash
# Place the Codex edition and reference it from global AGENTS.md
cp prompts/fable-emulation-codex.md ~/.codex/fable-emulation-prompt.md
```

Then add a section to `~/.codex/AGENTS.md` instructing Codex to read `~/.codex/fable-emulation-prompt.md` at session start. The Codex edition routes delegation and verification through the `codex-dynamic-workflows` skill (work packets, approval gates, goal mode) instead of Claude Code subagents.

## Key behavioral rules

- **Bias to action**: Act once you have enough information. Never re-derive established facts
- **Scope discipline**: No unrequested refactors, abstractions, or defensive code
- **Boundaries**: When the user describes a problem or asks a question, the deliverable is your assessment. Fix only when asked
- **Evidence-based reporting**: Only report claims backed by tool results; mark unverified items as unverified
- **End-of-turn check**: Never end on a promise ("I'll…") — do the work now
- **Reporting style**: Outcome first, complete sentences, no arrow chains

See section 6 of [docs/claude-fable-5-analysis.md](docs/claude-fable-5-analysis.md) for details.

## Verification

That `--append-system-prompt-file` actually reaches the model was confirmed with a sentinel test:

```bash
printf 'Always end your answer with [FABLE-OK].' > /tmp/sentinel.md
claude --append-system-prompt-file /tmp/sentinel.md --print "What is 1+1?"
# => 2
#    [FABLE-OK]
```

## Sources

Primary reference: [Prompting Claude Fable 5 (official)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5). Full source list at the end of the analysis document.
