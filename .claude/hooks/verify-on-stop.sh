#!/bin/bash
# verify-on-stop.sh — Stop
# Torna determinístico o "antes de concluir" do CLAUDE.md: se ESTA sessão editou .ts (marcador do
# check-ts), roda typecheck + testes relacionados (vitest --changed), os mesmos do `pnpm run verify`.
# Falhou → exit 2: o Claude não encerra o turno e recebe o erro. Na nova tentativa
# (stop_hook_active) o hook não roda, para não entrar em loop.
# Só roda quando o diff TS mudou desde a última verificação: pula o diff que o `pnpm run verify`
# (ou este hook) já aprovou e o que já falhou nesta sessão (cache por sessão): um erro que o
# Claude só deve relatar não bloqueia todo turno seguinte.
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
. "$(dirname "$0")/lib/ts-diff.sh"

[ -z "$(ts_changed)" ] && exit 0

# Diff já aprovado (pelo `pnpm run verify` ou por este hook) ou que já falhou nesta sessão: pula
HASH=$(ts_diff_hash)
STAMP="${TMPDIR:-/tmp}/claude-verify-$SESSION"
for F in "$VERIFIED" "$STAMP"; do
  [ -f "$F" ] && [ "$(cat "$F")" = "$HASH" ] && exit 0
done

FIX="Corrija o que veio das suas edições; se o erro está em código que você não tocou, apenas relate ao humano."

fail() { # fail <título> <detalhes>: marca o diff como já reportado e devolve o erro ao Claude
  echo "$HASH" >"$STAMP"
  echo "$1 $FIX" >&2
  echo "$2" >&2
  exit 2
}

if ! OUT=$("${VERIFY_TYPECHECK[@]}" 2>&1); then
  ERRS=$(echo "$OUT" | grep -E 'error TS|ERR_' | head -30)
  fail "Typecheck falhou." "${ERRS:-$(echo "$OUT" | tail -30)}"
fi

if ! OUT=$("${VERIFY_TESTS[@]}" 2>&1); then
  fail "Testes relacionados às mudanças falharam." "$(echo "$OUT" | tail -40)"
fi

mark_verified
exit 0
