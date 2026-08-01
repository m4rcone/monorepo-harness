#!/bin/bash
# check-ts.sh — PostToolUse (matcher: Edit|Write)
# Formata e linta APENAS o arquivo tocado (rápido; a suíte completa fica no CI).
# exit 0 = silencioso · exit 2 + stderr = o erro volta ao Claude como feedback
# Requer: jq (brew install jq | apt-get install jq)

# Formatação não é camada de segurança: sem jq, sai silencioso (o CI pega o lint).
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FILE" ] && exit 0

cd "$CLAUDE_PROJECT_DIR" || exit 0

# Repo recém-clonado, sem dependências instaladas: não faz nada.
[ -d node_modules ] || exit 0

case "$FILE" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs)
    pnpm exec prettier --write "$FILE" >/dev/null 2>&1
    OUT=$(pnpm exec eslint --fix "$FILE" 2>&1) || {
      echo "ESLint falhou em $FILE (corrija antes de prosseguir):" >&2
      echo "$OUT" >&2
      exit 2
    }
    ;;
  *.json|*.md|*.yml|*.yaml|*.css)
    pnpm exec prettier --write "$FILE" >/dev/null 2>&1
    ;;
esac

exit 0
