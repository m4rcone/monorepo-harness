#!/bin/bash
# verify-on-stop.sh — Stop
# Torna determinístico o "rodar typecheck + testes antes de concluir" do CLAUDE.md: se ESTA
# sessão editou .ts (marcador do check-ts), roda typecheck + testes relacionados (vitest --changed).
# Falhou → exit 2: o Claude não encerra o turno e recebe o erro. Na nova tentativa
# (stop_hook_active) o hook não roda, para não entrar em loop.
# Só roda de novo quando o diff TS muda desde a última verificação, OK ou não (cache por sessão):
# um erro que o Claude só deve relatar não bloqueia todo turno seguinte.
# Conveniência, não segurança: falha aberto (sem jq, sem dependências ou fora de um repo git).

command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
[ "$(echo "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0
SESSION=$(echo "$INPUT" | jq -r '.session_id // "default"')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# Sessão que não editou .ts (perguntas, planejamento, WIP anterior do humano): nada a verificar
[ -f "${TMPDIR:-/tmp}/claude-edited-$SESSION" ] || exit 0

# cwd acompanha o Claude numa worktree; CLAUDE_PROJECT_DIR fica no checkout original
ROOT=$(git -C "${CWD:-$CLAUDE_PROJECT_DIR}" rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$ROOT" || exit 0
[ -x node_modules/.bin/tsc ] || exit 0

# Arquivos TS alterados vs HEAD + TS novos (pathspec entre aspas: seguro com espaços no nome)
TS=('*.ts' '*.tsx' '*.mts' '*.cts')
CHANGED=$( { git diff --name-only HEAD -- "${TS[@]}" 2>/dev/null
  git ls-files --others --exclude-standard -- "${TS[@]}"; })
[ -z "$CHANGED" ] && exit 0

# Mesmo diff já verificado nesta sessão: pula
STAMP="${TMPDIR:-/tmp}/claude-verify-$SESSION"
HASH=$( { echo "$ROOT"
  git diff HEAD -- "${TS[@]}" 2>/dev/null
  git ls-files --others --exclude-standard -z -- "${TS[@]}" | xargs -0 cat 2>/dev/null; } \
  | git hash-object --stdin)
[ -f "$STAMP" ] && [ "$(cat "$STAMP")" = "$HASH" ] && exit 0

FIX="Corrija o que veio das suas edições; se o erro está em código que você não tocou, apenas relate ao humano."

fail() { # fail <título> <detalhes>: marca o diff como verificado e devolve o erro ao Claude
  echo "$HASH" >"$STAMP"
  echo "$1 $FIX" >&2
  echo "$2" >&2
  exit 2
}

if ! OUT=$(pnpm run typecheck 2>&1); then
  ERRS=$(echo "$OUT" | grep -E 'error TS|ERR_' | head -30)
  fail "Typecheck falhou." "${ERRS:-$(echo "$OUT" | tail -30)}"
fi

if ! OUT=$(pnpm exec vitest run --changed HEAD --passWithNoTests 2>&1); then
  fail "Testes relacionados às mudanças falharam." "$(echo "$OUT" | tail -40)"
fi

echo "$HASH" >"$STAMP"
exit 0
