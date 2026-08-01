#!/bin/bash
# guard-bash.sh — PreToolUse (matcher: Bash)
# Defesa em profundidade para comandos destrutivos. Roda ANTES de qualquer
# checagem de modo de permissão — bloqueia mesmo em bypassPermissions.
# As regras deny do settings.json já cobrem curl/wget/force-push;
# aqui ficam padrões que regras de prefixo não capturam bem.
# Padrões conservadores: AJUSTE conforme o projeto. Requer: jq

# Sem jq este hook não consegue inspecionar o comando — falha FECHADO por segurança.
command -v jq >/dev/null 2>&1 || {
  echo "guard-bash.sh requer jq (brew install jq | apt-get install jq). Bloqueando por segurança até instalar." >&2
  exit 2
}

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$CMD" ] && exit 0

block() {
  echo "Bloqueado pelo guard-bash: $1. Se for realmente necessário, peça ao humano executar." >&2
  exit 2
}

# 1) rm recursivo apontando para alvo amplo (/, ~, $HOME, ., ..)
if echo "$CMD" | grep -qE '(^|[;&|]|[[:space:]])rm[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*-[a-zA-Z]*r' \
   && echo "$CMD" | grep -qE '[[:space:]](/|~|\$HOME|\.\.?)([[:space:]]|$|;)'; then
  block "rm recursivo em alvo amplo"
fi

# 2) download canalizado direto para um shell (curl ... | sh)
if echo "$CMD" | grep -qE '(curl|wget)[^|]*\|[[:space:]]*(ba|z)?sh'; then
  block "download canalizado para shell"
fi

# 3) descarte de TODAS as mudanças do working tree
if echo "$CMD" | grep -qE 'git[[:space:]]+(checkout|restore)[[:space:]]+(--[[:space:]]+)?\.([[:space:]]*$)'; then
  block "descarte total do working tree (use git stash ou /rewind)"
fi

exit 0
