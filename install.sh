#!/usr/bin/env bash
# fable-mode installer — Claude Code + Codex CLI
# Usage: ./install.sh [--claude-only|--codex-only]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DO_CLAUDE=true
DO_CODEX=true
case "${1:-}" in
  --claude-only) DO_CODEX=false ;;
  --codex-only)  DO_CLAUDE=false ;;
  "") ;;
  *) echo "Usage: ./install.sh [--claude-only|--codex-only]" >&2; exit 1 ;;
esac

if $DO_CLAUDE; then
  echo "== Claude Code =="

  # Prompt + skill
  mkdir -p "$HOME/.claude/skills/fable-mode"
  cp "$REPO_DIR/prompts/fable-emulation-prompt.md" "$HOME/.claude/fable-emulation-prompt.md"
  cp "$REPO_DIR/skills/fable-mode/SKILL.md" "$HOME/.claude/skills/fable-mode/SKILL.md"
  echo "  installed prompt -> ~/.claude/fable-emulation-prompt.md"
  echo "  installed skill  -> ~/.claude/skills/fable-mode/SKILL.md"

  # Launchers
  mkdir -p "$HOME/.local/bin"
  cp "$REPO_DIR/bin/claude-fable" "$HOME/.local/bin/claude-fable"
  cp "$REPO_DIR/bin/claude-fable.cmd" "$HOME/.local/bin/claude-fable.cmd"
  chmod +x "$HOME/.local/bin/claude-fable"
  echo "  installed launchers -> ~/.local/bin/claude-fable{,.cmd}"

  # PATH check (informational; ~/.local/bin is commonly already on PATH)
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) echo "  NOTE: ~/.local/bin is not on PATH in this shell. Add it to your rc file:"
       echo '        export PATH="$HOME/.local/bin:$PATH"' ;;
  esac
fi

if $DO_CODEX; then
  echo "== Codex CLI =="

  mkdir -p "$HOME/.codex"
  cp "$REPO_DIR/prompts/fable-emulation-codex.md" "$HOME/.codex/fable-emulation-prompt.md"
  echo "  installed prompt -> ~/.codex/fable-emulation-prompt.md"

  # Idempotent AGENTS.md section injection
  AGENTS="$HOME/.codex/AGENTS.md"
  if [ -f "$AGENTS" ] && grep -qF 'Fable-class behavioral discipline' "$AGENTS"; then
    echo "  AGENTS.md already references fable discipline (skipped)"
  else
    [ -f "$AGENTS" ] || printf '# AGENTS.md\n' > "$AGENTS"
    cat >> "$AGENTS" <<'EOF'

## Fable-class behavioral discipline

- At session start, read `~/.codex/fable-emulation-prompt.md` and follow every section.
- Key rules: act once informed / do nothing beyond the task / when the user describes a problem or asks a question, the deliverable is your assessment (fix only when asked) / only report claims backed by tool results from this session / never end a turn on a promise ("I'll…") — do the work now / lead reports with the outcome, in complete sentences.
- For tasks large enough to need orchestrated delegation and verification, follow the `codex-dynamic-workflows` skill's decision rule and use work packets, approval gates, and goal mode.
EOF
    echo "  appended fable section -> ~/.codex/AGENTS.md"
  fi
fi

echo "Done."
