#!/bin/bash
# session-start.sh — SessionStart (matcher: startup|resume|clear|compact|fork)
# Checa pré-requisitos do harness e avisa o Claude (o stdout vira contexto da sessão).
# Silencioso quando está tudo certo: custo zero de tokens no caso comum. Roda de novo
# após compactação para o aviso não sumir do contexto.

# cwd acompanha o Claude numa worktree; CLAUDE_PROJECT_DIR fica no checkout original
CWD=$(jq -r '.cwd // empty' 2>/dev/null)
ROOT=$(git -C "${CWD:-$CLAUDE_PROJECT_DIR}" rev-parse --show-toplevel 2>/dev/null || echo "$CLAUDE_PROJECT_DIR")
cd "$ROOT" || exit 0
WARN=()

command -v jq >/dev/null 2>&1 \
  || WARN+=("jq ausente: os hooks guard-bash/protect-files vão BLOQUEAR Bash e edições até o humano instalar (brew install jq | apt-get install jq).")
[ -x node_modules/.bin/tsc ] \
  || WARN+=("Dependências não instaladas em $ROOT: rode 'pnpm install' (pede aprovação; até lá, os hooks de lint e verificação ficam inativos).")

BRANCH=$(git branch --show-current 2>/dev/null)
case "$BRANCH" in
  main|master) WARN+=("Sessão na branch '$BRANCH': crie uma branch (git checkout -b tipo/descricao) antes de commitar; commit na $BRANCH é bloqueado.") ;;
esac

[ ${#WARN[@]} -eq 0 ] && exit 0
echo "Avisos do harness (session-start):"
printf -- '- %s\n' "${WARN[@]}"
exit 0
