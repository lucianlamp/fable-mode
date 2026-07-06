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

One-liner (installs both Claude Code and Codex CLI integration, idempotent):

```bash
git clone https://github.com/lucianlamp/fable-mode && cd fable-mode && ./install.sh
```

Options: `./install.sh --claude-only` or `./install.sh --codex-only`.

<details>
<summary>Manual install</summary>

```bash
# Claude Code: prompt + skill
cp prompts/fable-emulation-prompt.md ~/.claude/
mkdir -p ~/.claude/skills/fable-mode
cp skills/fable-mode/SKILL.md ~/.claude/skills/fable-mode/

# Launchers, somewhere on PATH
cp bin/claude-fable bin/claude-fable.cmd ~/.local/bin/
chmod +x ~/.local/bin/claude-fable
```

</details>

## Usage

```bash
claude-fable                    # Launch Claude Code with Fable discipline
claude-fable --model sonnet     # Launch on Sonnet (arguments pass through to claude)
```

Or as a skill inside a session:

```
/fable-mode
```

### Always-on via CLAUDE.md (recommended)

`install.sh` appends a section to `~/.claude/CLAUDE.md` (skipped if already present) instructing Claude to read `~/.claude/fable-emulation-prompt.md` at session start. This applies the discipline to every session — including Fable itself: the instruction set originates from the official Fable 5 prompting guide, so making it explicit stabilizes Fable's own behavior too. Also include the key rules in subagent prompts when delegating quality-critical work to Sonnet-class models.

**Note**: with the CLAUDE.md section in place, the `claude-fable` launcher becomes redundant (the discipline would be applied twice — harmless, but unnecessary). Keep the launcher for machines where you skip the CLAUDE.md integration, or for one-off use without touching global config.

### Codex CLI

`install.sh` copies the Codex edition to `~/.codex/fable-emulation-prompt.md` and appends a section to `~/.codex/AGENTS.md` that instructs Codex to read it at session start (skipped if already present). The Codex edition routes delegation and verification through the `codex-dynamic-workflows` skill (work packets, approval gates, goal mode).

## Key behavioral rules

- **Bias to action**: Act once you have enough information. Never re-derive established facts
- **Scope discipline**: No unrequested refactors, abstractions, or defensive code
- **Boundaries**: When the user describes a problem or asks a question, the deliverable is your assessment. Fix only when asked
- **Evidence-based reporting**: Only report claims backed by tool results; mark unverified items as unverified
- **End-of-turn check**: Never end on a promise ("I'll…") — do the work now
- **Reporting style**: Outcome first, complete sentences, no arrow chains

See section 6 of [docs/claude-fable-5-analysis.md](docs/claude-fable-5-analysis.md) for details.

## Autonomous-run integration

The discipline is designed to coexist with loop engineering (Ralph loops, `/loop`, goal mode, long agentic runs). Three rules make this work — the installer injects them into `CLAUDE.md` / `AGENTS.md`:

- **Precedence**: user instructions > process skills (Superpowers, codex-dynamic-workflows) > this discipline. A mandated pre-phase (brainstorming, TDD) runs first; the discipline governs behavior within each phase.
- **Approval gates don't stall the loop**: during autonomous runs, an operation that needs approval is recorded and skipped, and work continues on everything that doesn't. The pending-approval list is reported when everything else is done or blocked — safety is unchanged (nothing unapproved executes), but the loop never idles.
- **Git ceiling**: autonomous runs go as far as commit / push / PR creation on a feature branch. Merges and destructive operations (force push, hard reset, branch deletion) always wait for the user. The morning-after workflow is: review the queued PRs, merge what you approve.

One companion change worth making in your own global config: if you have a rule like "present next-step options when work completes," scope it to interactive sessions only — otherwise each loop iteration ends with a menu nobody reads and the run stalls.

## Verification

That `--append-system-prompt-file` actually reaches the model was confirmed with a sentinel test:

```bash
printf 'Always end your answer with [FABLE-OK].' > /tmp/sentinel.md
claude --append-system-prompt-file /tmp/sentinel.md --print "What is 1+1?"
# => 2
#    [FABLE-OK]
```

## Attribution

The instruction language is adapted from Anthropic's official [Prompting Claude Fable 5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5) guide. The review-mode standards are inspired by the [thermo-nuclear-code-quality-review](https://github.com/cursor/plugins/blob/main/cursor-team-kit/skills/thermo-nuclear-code-quality-review/SKILL.md) skill from Cursor's plugin kit.

## License

[MIT](LICENSE)

## Sources

Primary reference: [Prompting Claude Fable 5 (official)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5). Full source list at the end of the analysis document.
