#!/bin/bash
# protect-files.sh — PreToolUse (matcher: Edit|Write)
# Bloqueia edição/criação de arquivos protegidos. Camada determinística que
# complementa as regras deny do settings.json (deny cobre também leitura).
# exit 2 + stderr = ação bloqueada; a mensagem volta ao Claude como feedback.
# Requer: jq

# Sem jq este hook não consegue inspecionar a ação — falha FECHADO por segurança.
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

BASE=$(basename "$FILE")

# Segredos e lockfile: nunca editados pelo agente
case "$BASE" in
  .env|.env.*)       block "arquivo de segredos" ;;
  pnpm-lock.yaml)    block "lockfile — use 'pnpm add/remove', que passa por aprovação" ;;
esac

# Internals do git
case "$FILE" in
  */.git/*|.git/*)   block "diretório .git" ;;
esac

# ADAPTE: acrescente padrões do seu projeto, ex.:
# case "$FILE" in
#   */migrations/*)      block "migrations são geradas por ferramenta, não editadas" ;;
#   *routes.gen.ts)      block "arquivo gerado — edite a fonte" ;;
# esac

exit 0
