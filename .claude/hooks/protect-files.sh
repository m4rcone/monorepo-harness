#!/bin/bash
# protect-files.sh — PreToolUse (matcher: Edit|Write)
# Bloqueia edição/criação de arquivos protegidos. Camada determinística que complementa
# o deny do settings.json (que também bloqueia a leitura).
# exit 2 + stderr = bloqueado (a mensagem volta ao Claude). Requer: jq

# Sem jq este hook não consegue inspecionar a ação: falha FECHADO por segurança.
command -v jq >/dev/null 2>&1 || {
  echo "protect-files.sh requer jq (brew install jq | apt-get install jq). Bloqueando por segurança até instalar." >&2
  exit 2
}

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE" ] && exit 0

block() {
  echo "Bloqueado: '$FILE' é protegido ($1). Se a mudança for necessária, peça ao humano." >&2
  exit 2
}

# macOS (APFS) e Windows não diferenciam caixa: .ENV é o mesmo arquivo que .env
shopt -s nocasematch
BASE=$(basename "$FILE")

# Segredos e lockfile: o agente nunca edita (inclui .env.example; bloqueio amplo é mais
# seguro que enumerar sufixos)
case "$BASE" in
  .env|.env.*)       block "arquivo de segredos" ;;
  pnpm-lock.yaml)    block "lockfile: use 'pnpm add/remove', que passa por aprovação" ;;
esac

# Internals do git
case "$FILE" in
  */.git/*|.git/*)   block "diretório .git" ;;
esac

# .claude/, .git/, .devcontainer/ etc. são "protected paths" nativos: pedem confirmação em
# default/acceptEdits (em auto mode vão ao classificador; em bypassPermissions passam).
# .github/workflows/ tem regra "ask" no settings.json.

# ADAPTE: acrescente padrões do projeto, ex.:
# case "$FILE" in
#   */migrations/*)      block "migrations são geradas por ferramenta, não editadas" ;;
#   *routes.gen.ts)      block "arquivo gerado: edite a fonte" ;;
# esac

exit 0
