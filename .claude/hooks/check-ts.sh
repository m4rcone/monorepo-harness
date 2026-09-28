#!/bin/bash
# check-ts.sh — PostToolUse (matcher: Edit|Write)
# ESLint --fix e depois Prettier APENAS no arquivo tocado (rápido; a suíte completa fica no CI).
# Também marca a sessão que editou .ts: é o gatilho do verify-on-stop.
# exit 0 = silencioso · exit 2 + stderr = o erro de lint volta ao Claude como feedback
# Conveniência, não segurança: falha aberto (sem jq, sem dependências ou fora do repo, não faz nada).

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE" ] && exit 0

# Só arquivos deste repositório: checkout principal ou worktree dele (não planos, scratchpad, outros repos)
common_dir() { git -C "$1" rev-parse --path-format=absolute --git-common-dir 2>/dev/null; }
ROOT=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ "$(common_dir "$ROOT")" = "$(common_dir "$CLAUDE_PROJECT_DIR")" ] || exit 0
cd "$ROOT" || exit 0

case "$FILE" in
  *.ts|*.tsx|*.mts|*.cts)
    SESSION=$(echo "$INPUT" | jq -r '.session_id // "default"')
    : >"${TMPDIR:-/tmp}/claude-edited-$SESSION"
    ;;
esac

BIN=node_modules/.bin
[ -x "$BIN/eslint" ] || exit 0 # dependências não instaladas (ex.: worktree nova)

case "$FILE" in
  *.ts|*.tsx|*.mts|*.cts|*.js|*.jsx|*.mjs|*.cjs)
    OUT=$("$BIN/eslint" --fix "$FILE" 2>&1)
    RC=$?
    "$BIN/prettier" --write "$FILE" >/dev/null 2>&1 # por último: formata também o que o --fix reescreveu
    if [ "$RC" -ne 0 ]; then
      echo "ESLint falhou em $FILE (corrija antes de prosseguir):" >&2
      echo "$OUT" >&2
      exit 2
    fi
    ;;
  *.json|*.md|*.yml|*.yaml|*.css)
    "$BIN/prettier" --write "$FILE" >/dev/null 2>&1
    ;;
esac

exit 0
