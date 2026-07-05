# An Analysis of Claude Fable 5's Intelligence

*Created: 2026-07-05*

## Overview

Claude Fable 5 (`claude-fable-5`) is Anthropic's **most capable widely released model**, launched June 9, 2026. It is a Mythos-class (frontier-grade) model made generally available with built-in safety classifiers; its sibling, Claude Mythos 5, shares the same capabilities without the classifiers and is available only through Project Glasswing.

- **Context window**: 1M tokens (default)
- **Max output**: 128k tokens per request
- **Pricing**: $10 / $50 per million input/output tokens
- **Thinking mode**: Adaptive thinking, always on (cannot be disabled)

---

## 1. Why is it smart? — A shift in design philosophy

Fable 5's intelligence is optimized not for "smartness in short Q&A" but for **"sustaining judgment and execution consistently across long, large-scale tasks."** Anthropic states that "the longer and more complex the task, the wider Fable 5's lead over other models grows." The following factors drive this.

### 1.1 Adaptive thinking, always on

- Reasoning cannot be disabled on Fable 5; it **automatically adjusts thinking depth to problem difficulty**
- The `effort` parameter controls the depth/cost trade-off
- Shallow and fast on easy problems, deep and deliberate on hard ones — the direct source of its analytical and verification strength

### 1.2 Very long context + sustained focus

- Maintains **consistent reasoning without losing focus** inside a 1M-token context
- In the "Slay the Spire" experiment, persistent file memory yielded **3x** the performance of Opus 4.8
- Supports the memory tool, compaction, and context editing — it self-manages context across long sessions

### 1.3 Agent-native training

- Built for **multi-day autonomous operation** inside harnesses like Claude Code and Managed Agents
- Runs the loop of staged planning → delegating to subagents → **verifying its own deliverables**
- Full support for programmatic tool calling, code execution, task budgets, and other agent features

---

## 2. Capability-by-capability analysis

### 2.1 Problem-solving (coding / engineering)

- Stripe's measurement: **completed a migration estimated at 2 months, on a 50-million-line Ruby codebase, in 1 day**
- Top score on Cognition's FrontierCode evaluation
- Strongest at large migrations, complex implementations, and multi-day autonomous sessions

### 2.2 Analysis (knowledge work / finance)

- **First model to break 90%** on Anthropic's core analytics benchmark (+10 points over Opus)
- Top score on Hebbia's financial benchmark; high marks on nearly every item of IMC's trading analysis evaluation
- The longer and more complex the analytical task, the wider the gap

### 2.3 Vision

- **Accurate numeric extraction** from scientific figures
- Can **reconstruct a web app's source code from screenshots alone**
- Understands diagrams, charts, and tables nested inside files and PDFs
- **Beat Pokémon FireRed using vision only** (demonstrating operation with minimal tools)
- → Suits document-heavy work in finance, legal, analytics, architecture, and gaming

### 2.4 Verification (self-checking)

- Long agentic runs include a built-in habit of **verifying its own work**
- The plan → implement → verify cycle runs without human intervention — the biggest difference from prior generations

### 2.5 Ideation (scientific research)

- Sibling model Mythos 5's molecular-biology hypotheses were **preferred by scientists ~80% of the time** over Opus-class models in blind comparison
- In protein design, generated promising drug-development candidates for 9 of 14 targets

---

## 3. How it behaves (operational characteristics)

### 3.1 Runtime behavior

1. **On request** → adaptive thinking assesses difficulty and auto-adjusts reasoning depth
2. **On long tasks** → plans in stages, delegates to subagents, self-verifies results
3. **Context management** → maintains context across long sessions via memory tool and compaction
4. **Thinking privacy** → raw chain of thought is never returned (`summarized` gives a readable summary only)

### 3.2 Safety machinery (Fable-specific)

- **Safety classifiers** screen requests and can refuse in high-risk domains: cybersecurity, biology, chemistry, health
- Refusals return `stop_reason: "refusal"` with HTTP 200 (not an error)
- **Fallback**: refused requests can be retried automatically on another Claude model (e.g., Opus 4.8) — server-side, client-side, or manual
- Triggers in **under 5% of sessions** on average
- No billing on refusal; fallback credit refunds the prompt-cache cost of switching

---

## 4. Summary — What the intelligence really is

| Capability | Source |
|-----------|--------|
| Problem-solving | Long-horizon autonomy + agent-native training |
| Analysis | Deep reasoning from adaptive thinking + 1M context |
| Verification | Self-checking built into the agent loop |
| Vision | Frontier-grade vision (figure comprehension, screen→code reconstruction) |
| Ideation | Hypothesis generation at a level scientists prefer |

In one sentence: Fable 5's intelligence is optimized not for **"smart single answers" but for "taking on an entire job and seeing it through."** The essence: the longer and more complex the task, the wider its lead.

---

## 5. Official Fable 5 prompting guide (key points)

Source: [Prompting Claude Fable 5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5)

### 5.1 Improvements over Opus 4.8 (officially stated)

| Area | Detail |
|------|--------|
| Long-horizon autonomy | Completes multi-day goal-directed runs; strong instruction retention across long, complex tasks |
| First-shot correctness | Single-pass implementations of well-specified complex systems (previously days of iteration) |
| Vision | Interprets dense technical images and screenshots accurately with fewer output tokens; trained to use bash/crop tools on flipped, blurry, or noisy images |
| Enterprise workflows | Stays in scope; professional-grade output on financial analysis, spreadsheets, slides, documents |
| Code review / debugging | Noticeably higher bug-finding recall, including search across codebases and repository history |
| Navigating ambiguity | Determines next steps from complex, multi-threaded requests |
| Delegation & collaboration | Far more dependable at dispatching and sustaining parallel subagents; manages ongoing communication with long-running peers |

### 5.2 Key operational behaviors and mitigations

- **Longer turns**: at high effort a single request can run minutes; autonomous runs for hours. Adjust timeouts, streaming, and progress UI
- **Effort is the primary control**: `high` as default, `xhigh` for capability-critical work; even `low`/`medium` can exceed prior models' `xhigh`
- **Strong instruction following**: one short instruction steers broad behavior — no need to enumerate cases
- **Preventing fabricated progress**: "audit each claim against a tool result before reporting" nearly eliminated fabricated status reports in Anthropic's testing
- **State the boundaries**: prevent unrequested actions with "when the user describes a problem, the deliverable is your assessment; don't fix until asked"
- **Memory system**: performance improves notably when it can record and reference lessons from prior runs — even a single Markdown file
- **Rare early stopping**: deep in long sessions it may state intent ("I'll now run X") without the tool call → add an end-of-turn check instruction for autonomous pipelines
- **Give the reason, not only the request**: performance improves when it knows who the work is for and what it enables
- **Never instruct it to transcribe its reasoning**: doing so can trigger the `reasoning_extraction` refusal category

---

## 6. Playbook: reproducing Fable on Sonnet

Fable's intelligence = (1) raw model capability × (2) behavioral discipline. (1) cannot be ported, but **(2) can be injected into Sonnet as instructions**. Below is Fable's actual behavior decomposed to a granularity that fits into a Sonnet system prompt or skill.

### 6.1 The behavior loop (core algorithm)

Fable's internal loop on receiving a task:

```
1. Grasp intent   : Identify the purpose behind the request. If ambiguous, check whether
                    you have the minimum information needed to act
                    → if yes, act. If not, batch questions into one round
2. Plan           : Split the task into stages, without overplanning
                    "When you have enough information to act, act. Don't re-derive established facts"
3. Delegation     : Send independent subtasks to parallel subagents; keep working while they run
4. Implement      : "Do nothing beyond what the task requires"
                    — no feature creep, refactors, abstractions, or designs for hypothetical futures
                    — validate only at system boundaries (user input, external APIs)
5. Self-verify    : Check deliverables against the spec at intervals
                    Best: fresh-context verifier subagents (more accurate than self-critique)
6. Report         : Audit every claim against a tool result from this session before reporting
                    Mark verified vs. unverified. Report test failures honestly, with output
7. Exit check     : If the final paragraph is a plan/question/promise ("I'll…"),
                    don't end the turn — do that work now
```

### 6.2 The instruction set to inject into Sonnet (copy-paste ready)

The minimal prompt set reproducing Fable's behavior, consolidated from the official guide's recommended language — see `prompts/fable-emulation-prompt.md` for the full text. Blocks:

- **Bias to action** — act once informed; no re-deriving, no re-litigating, recommend rather than survey
- **Scope discipline** — nothing beyond the task; simplest thing that works; validate at boundaries only
- **Boundaries** — assessment is the deliverable when the user describes/asks; verify evidence before state-changing commands
- **Verification** — audit claims against tool results; fresh-context verifier subagents at intervals
- **Delegation** — delegate independent subtasks; keep working; intervene when off track
- **Checkpoints** — pause only for destructive actions, scope changes, or user-only input
- **End-of-turn check** — never end on a promise; do the work with tool calls now
- **Reporting style** — outcome first; select information rather than compress prose; full sentences in final summaries
- **Memory** — one lesson per file, one-line summary, no duplicates, delete wrong notes

### 6.3 What Sonnet can and cannot reproduce

| Item | Reproducible? | How |
|------|--------------|-----|
| Scope discipline & boundaries | ◎ | Instruction set above covers most of it |
| Verification loop (evidence-based reporting) | ◎ | Instructions + verifier subagents |
| Parallel delegation orchestration | ○ | Promptable, but delegation judgment is weaker |
| Reporting style (outcome-first, plain) | ◎ | Reproducible via instructions |
| Memory usage | ○ | Same mechanism works; lesson extraction quality is lower |
| First-shot correctness (complex problems) | △ | Raw capability gap. Compensate with finer task decomposition |
| Multi-day autonomy | △ | Instruction-retention gap. Compensate with more frequent checkpoints |
| Vision (screenshot→code etc.) | ✕ | Raw model capability. Not portable |
| Deciding next steps from ambiguity | △ | Compensate with a brainstorming-style pre-phase |

**Bottom line**: Half of Fable's intelligence is "disciplined behavioral patterns," which port as instructions. The other half (reasoning depth, vision, long-horizon retention) is model-native, so on Sonnet, approximate it by **decomposing tasks more finely, verifying more often, and resolving ambiguity up front**.

---

## Sources

- [Claude Fable 5 and Claude Mythos 5 — Anthropic](https://www.anthropic.com/news/claude-fable-5-mythos-5)
- [Introducing Claude Fable 5 and Claude Mythos 5 — Claude Platform Docs](https://platform.claude.com/docs/en/about-claude/models/introducing-claude-fable-5-and-claude-mythos-5)
- [Claude Fable — Anthropic](https://www.anthropic.com/claude/fable)
- [Anthropic Claude Fable 5 on AWS — AWS Blog (Japanese)](https://aws.amazon.com/jp/blogs/news/anthropic-claude-fable-5-on-aws-mythos-class-capabilities-with-built-in-safeguards-now-available/)
- [The Era of Long-Running Autonomous Agents with Claude Fable 5 — CodeZine (Japanese)](https://codezine.jp/article/detail/24513)
- [Anthropic releases Mythos-like AI model to the public — CNBC](https://www.cnbc.com/2026/06/09/anthropic-mythos-claude-fable-5.html)
- [Prompting Claude Fable 5 — Claude Platform Docs](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5)
