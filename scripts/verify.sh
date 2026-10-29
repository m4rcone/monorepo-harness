#!/bin/bash
# verify.sh — `pnpm run verify`: typecheck + testes afetados pelo diff (vitest --changed), o "antes
# de concluir" do CLAUDE.md. Mesmos comandos do hook verify-on-stop: passou → grava o hash do diff
# TS e o hook Stop não repete a checagem enquanto o diff não mudar.

cd "$(git rev-parse --show-toplevel)" || exit 1
. .claude/hooks/lib/ts-diff.sh

"${VERIFY_TYPECHECK[@]}" && "${VERIFY_TESTS[@]}" || exit
mark_verified
