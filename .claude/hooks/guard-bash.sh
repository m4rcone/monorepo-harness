#!/bin/bash
# guard-bash.sh — PreToolUse (matcher: Bash|Monitor|PowerShell, os tools que executam shell)
# Defesa em profundidade contra comandos destrutivos cometidos por engano. Hooks rodam antes da
# checagem de modo de permissão: bloqueia inclusive em bypassPermissions. Não é fronteira contra
# entrada maliciosa (essa é o sandbox + permissões). O deny do settings.json cobre curl/wget e
# `git push --force|-f`; aqui ficam padrões que regras de prefixo não capturam.
# exit 2 + stderr = bloqueado (a mensagem volta ao Claude). AJUSTE os padrões ao projeto.
# Requer: jq

# Sem jq este hook não consegue inspecionar o comando: falha FECHADO por segurança.
command -v jq >/dev/null 2>&1 || {
  echo "guard-bash.sh requer jq (brew install jq | apt-get install jq). Bloqueando por segurança até instalar." >&2
  exit 2
}

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
[ -z "$CMD" ] && exit 0

block() {
  echo "Bloqueado pelo guard-bash: $1. Se for realmente necessário, peça ao humano para executar." >&2
  exit 2
}

# Texto entre aspas de -m/-am/--message/--body/--title é mensagem, não comando: sai antes de casar
C=$(printf '%s' "$CMD" | tr '\n' ' ' \
  | sed -E "s/(^|[[:space:]])(-[a-zA-Z]*m|--message|--body|--title)(=|[[:space:]]+)(\"([^\"\\\\]|\\\\.)*\"|'[^']*')/\\1/g")
# `git` com opções globais antes do subcomando (-C <dir>, -c <k=v>, --no-pager, -p...)
G='git([[:space:]]+(-[Cc][[:space:]]*("[^"]*"|'"'"'[^'"'"']*'"'"'|[^[:space:]]+)|--[a-z][a-z-]*(=[^[:space:]]+)?|-[pP]))*[[:space:]]+'
# Fim de um argumento: espaço, separador, fecha-parêntese, aspas/backtick ou fim da linha
END="([[:space:];&|)\`'\"]|$)"

# 1) remoção recursiva em alvo amplo (/, ~, $HOME, $PWD, ., .., .git, *), segmento a segmento
#    (assim `rm -rf dist && cd ..` não é falso positivo). Inclui Remove-Item do PowerShell.
RM="(rm|[Rr]emove-[Ii]tem)"
while IFS= read -r SEG; do
  echo "$SEG" | grep -qE "(^|[[:space:](\`'\"\\\\])${RM}[\"']?[[:space:]]" || continue
  # Só os argumentos do rm: o `.` de `find . -exec rm -rf {} +` não conta
  ARGS=" $(echo "$SEG" | sed -E "s/^(.*[[:space:](\`'\"\\\\])?${RM}[\"']?[[:space:]]+//")"
  echo "$ARGS" | grep -qE '[[:space:]](-[a-zA-Z]*[rR][a-zA-Z]*|--recursive)([[:space:]]|$)' || continue
  if echo "$ARGS" | grep -qE "[[:space:]][\"']?(/|~|\\\$HOME|\\\$\{HOME\}|\\\$PWD|\.\.?(/\.\.)*|(\./)?\.git)[\"']?/?\.?\*?[\"']?${END}" \
     || echo "$ARGS" | grep -qE "[[:space:]]\\*${END}"; then
    block "remoção recursiva em alvo amplo"
  fi
done <<< "$(echo "$C" | tr ';&|' '\n\n\n')"

# 2) download canalizado direto para um interpretador (curl ... | [sudo] sh/python/node...)
if echo "$CMD" | grep -qE '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?((ba|z|da|k)?sh|python[0-9.]*|node|perl|ruby)([[:space:]]|$)'; then
  block "download canalizado para interpretador"
fi

# 3) descarte de mudanças não commitadas ou do stash
A="([^;&|]*[[:space:]])?" # outros argumentos antes do que interessa
if echo "$C" | grep -qE "${G}(checkout|restore)[[:space:]]+(HEAD[^[:space:]]*[[:space:]]+)?(--[[:space:]]+)?\.${END}" \
   || echo "$C" | grep -qE "${G}checkout[[:space:]]+${A}--[[:space:]]+\.${END}" \
   || echo "$C" | grep -qE "${G}restore[[:space:]]+${A}(-W|--worktree|-s[^[:space:]]*|--source[= ][^[:space:]]+)${A}\.${END}" \
   || echo "$C" | grep -qE "${G}(checkout|switch)[[:space:]]+${A}(-f|--force|--discard-changes)([[:space:]]|$)" \
   || echo "$C" | grep -qE "${G}reset[[:space:]]+${A}--hard" \
   || echo "$C" | grep -qE "${G}clean[[:space:]]+${A}(-[a-zA-Z]*f|--force)" \
   || echo "$C" | grep -qE "${G}stash[[:space:]]+(drop|clear)"; then
  block "descarte de mudanças não commitadas ou do stash (use git stash ou /rewind)"
fi

# 4) commit direto na branch principal (CLAUDE.md: "nunca commitar direto na main").
#    Se o próprio comando cria a branch antes (checkout -b / switch -c), deixa passar.
if echo "$C" | grep -qE "(^|[;&|[:space:](])${G}commit([[:space:]]|$)" \
   && ! echo "$C" | grep -qE "${G}(checkout[[:space:]]+-[bB]|switch[[:space:]]+-[cC])[[:space:]]"; then
  BRANCH=$(git -C "${CWD:-$CLAUDE_PROJECT_DIR}" branch --show-current 2>/dev/null)
  case "$BRANCH" in
    main|master) block "commit direto na '$BRANCH': crie uma branch antes (git checkout -b tipo/descricao) e repita o commit" ;;
  esac
fi

exit 0
