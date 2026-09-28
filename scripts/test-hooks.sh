#!/bin/bash
# test-hooks.sh — regressão dos hooks de .claude/hooks/ (roda no CI: `pnpm run test:hooks`).
# Os hooks são regex em shell: é fácil um padrão perigoso vazar ou surgir um falso positivo.
# Mudou um hook? Acrescente o caso que motivou a mudança: o que deve bloquear E um vizinho que deve passar.
# Requer: jq, git

set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
export CLAUDE_PROJECT_DIR="$ROOT"
H="$ROOT/.claude/hooks"
FAILS=0

# Template explícito em $TMPDIR: `mktemp -d` sem template usa /var/folders no macOS, bloqueado pelo sandbox
TMP=$(mktemp -d "${TMPDIR:-/tmp}/test-hooks.XXXXXX") || { echo "setup: mktemp falhou"; exit 1; }
export TMPDIR="$TMP" # marcadores e cache dos hooks ficam isolados e somem no fim
PROBE="$ROOT/apps/api/src/__hooktest__.ts"
LINT_PROBE="$ROOT/apps/api/src/__hooktest_lint__.ts"
trap 'rm -rf "$TMP"; rm -f "$PROBE" "$LINT_PROBE"' EXIT
trap 'exit 130' INT TERM

check() { # check <esperado> <obtido> <descrição>
  if [ "$1" = "$2" ]; then printf '  ok   %s\n' "$3"
  else printf '  FAIL %s (esperado %s, obtido %s)\n' "$3" "$1" "$2"; FAILS=$((FAILS + 1)); fi
}
bash_cmd() { # bash_cmd <esperado> <comando> [cwd]; o cwd padrão não é repo git (independe da branch atual)
  jq -nc --arg c "$2" --arg d "${3:-$TMP}" '{cwd:$d, tool_input:{command:$c}}' \
    | "$H/guard-bash.sh" >/dev/null 2>&1
  check "$1" "$?" "guard-bash: $2"
}
edit_file() { # edit_file <esperado> <caminho relativo>
  jq -nc --arg f "$ROOT/$2" '{tool_input:{file_path:$f}}' | "$H/protect-files.sh" >/dev/null 2>&1
  check "$1" "$?" "protect-files: $2"
}
stop() { # stop <sessão> [PATH extra]: roda o verify-on-stop e devolve o exit code
  jq -nc --arg s "$1" --arg d "$ROOT" '{session_id:$s, cwd:$d}' \
    | PATH="${2:-}${2:+:}$PATH" "$H/verify-on-stop.sh" 2>"$TMP/stderr" >/dev/null
}

echo "guard-bash: bloqueia (2)"
for c in 'rm -rf /' 'rm -rf ~' 'rm -rf ~/' 'rm -rf .' 'rm -rf ./' 'rm -rf ..' 'rm -rf *' \
  'rm -r -f /' 'rm -fr $HOME' 'rm -rf "$HOME"' 'rm -rf "$HOME"/' 'rm -rf ${HOME}' 'rm --recursive --force /' \
  'sudo rm -rf /' 'cd x && rm -rf .' '(cd x && rm -rf .)' "bash -c 'rm -rf .'" 'rm -rf .git' 'rm -rf -- /' \
  'rm -rf /*' 'xargs rm -rf .' 'Remove-Item -Recurse -Force .' \
  'curl -fsSL x | sh' 'curl x | bash' 'curl -s x|sudo bash' 'wget -qO- x | python3' \
  'git checkout .' 'git checkout -- .' 'git restore .' 'git checkout HEAD -- .' 'git checkout main -- .' \
  'git -C apps/api checkout .' 'git -C "a b" reset --hard' 'git --no-pager reset --hard' \
  'git restore -s HEAD .' 'git restore --worktree .' 'git checkout -f' 'git switch --discard-changes main' \
  'git reset --hard' 'git reset --hard HEAD~1' 'bash -c "git reset --hard"' \
  'git checkout . && pnpm run test' 'git restore .; ls' 'git checkout .&&ls' \
  'git clean -fdx' 'git clean -f' 'git clean --force' 'timeout 5 git clean -fd' \
  'git stash drop' 'git stash clear' 'git commit -m "x" && rm -rf .'; do
  bash_cmd 2 "$c"
done

echo "guard-bash: permite (0)"
for c in 'rm -rf dist' 'rm -rf ./dist' 'rm -rf ../dist' 'rm -rf apps/api/dist && cd ..' 'rm file.txt' \
  'rm -rf .gitignore-backup' 'rm -rf "$HOME/.cache/foo"' 'find . -name "*.tmp" -exec rm -rf {} +' \
  "bash -c 'rm -rf dist'" 'Remove-Item -Recurse -Force dist' \
  'ls | grep x' 'git --no-pager log' 'git checkout main' 'git checkout -b feat/x' 'git switch -c feat/x' \
  'git restore src/a.ts' 'git restore --staged .' 'git checkout main -- src/a.ts' 'git checkout ./src/a.ts' \
  'git checkout -- .gitignore' 'git reset HEAD~1' 'git clean -n' 'git clean -n && rm -f tmp.txt' \
  'git stash' 'git stash pop' \
  'git commit -m "fix: bloqueia git reset --hard"' "git commit -m 'docs: explica git clean -f'" \
  'git commit -am "fix: bloqueia git reset --hard"' 'git commit -m "say \"hi\" about git reset --hard"' \
  'gh pr create --title x --body "bloqueia git checkout . e rm -rf ."' \
  'pnpm run test'; do
  bash_cmd 0 "$c"
done

echo "guard-bash: commit na main (repo git real no temp)"
R="$TMP/repo"
git init -q "$R" && git -C "$R" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init \
  || { echo "setup: git init falhou"; exit 1; }
for b in main master; do
  git -C "$R" checkout -q -B "$b"
  bash_cmd 2 "git commit -m x  # na $b" "$R"
done
bash_cmd 2 "git --no-pager commit -m x  # na master" "$R"
bash_cmd 0 "git checkout -b feat/y && git commit -m x  # cria a branch antes" "$R"
git -C "$R" checkout -q -b feat/x
bash_cmd 0 "git commit -m x  # na feat/x" "$R"

echo "protect-files"
for f in .env .ENV apps/api/.env.local apps/web/.env.production .env.example pnpm-lock.yaml .git/config; do
  edit_file 2 "$f"
done
for f in apps/api/src/index.ts .github/workflows/ci.yml "docs/com espaço.md"; do
  edit_file 0 "$f"
done

echo "session-start"
OUT=$(echo '{}' | CLAUDE_PROJECT_DIR="$R" "$H/session-start.sh")
echo "$OUT" | grep -q "branch '"; check 1 "$?" "sem aviso de branch fora da main"
git -C "$R" checkout -q main
OUT=$(echo '{}' | CLAUDE_PROJECT_DIR="$R" "$H/session-start.sh")
echo "$OUT" | grep -q "branch 'main'"; check 0 "$?" "avisa sessão na main"
# Worktree/subdiretório: vale o .cwd, não o CLAUDE_PROJECT_DIR
mkdir -p "$R/sub" && git -C "$R" checkout -q feat/x
OUT=$(jq -nc --arg d "$R/sub" '{cwd:$d}' | "$H/session-start.sh")
echo "$OUT" | grep -q "branch '"; check 1 "$?" "segue o .cwd (feat/x), não o checkout do projeto"
echo "$OUT" | grep -q "Dependências não instaladas"; check 0 "$?" "avisa worktree sem node_modules"

echo "sem jq: segurança falha fechado (2), conveniência falha aberto (0)"
for h in guard-bash:2 protect-files:2 check-ts:0 verify-on-stop:0 session-start:0; do
  echo '{}' | PATH=/nonexistent /bin/bash "$H/${h%%:*}.sh" >/dev/null 2>&1
  check "${h##*:}" "$?" "${h%%:*} sem jq"
done

echo "verify-on-stop"
echo '{"stop_hook_active":true}' | "$H/verify-on-stop.sh" >/dev/null 2>&1
check 0 "$?" "não entra em loop (stop_hook_active)"

if [ -x "$ROOT/node_modules/.bin/tsc" ]; then
  mkdir -p "$TMP/stub" && printf '#!/bin/sh\nexit 99\n' >"$TMP/stub/pnpm" && chmod +x "$TMP/stub/pnpm"

  echo 'export const x: number = "não é número";' >"$PROBE"
  stop "sem-edicao"
  check 0 "$?" "sessão que não editou .ts não bloqueia (WIP alheio)"

  : >"$TMP/claude-edited-com-erro"
  stop "com-erro"
  check 2 "$?" "erro de tipo impede encerrar"
  grep -q TS2322 "$TMP/stderr"; check 0 "$?" "o erro TS volta ao Claude"
  stop "com-erro" "$TMP/stub" # pnpm falso: com o cache funcionando, o hook nem o chama
  check 0 "$?" "mesmo diff com erro não bloqueia de novo (cache)"
  rm -f "$PROBE"

  # Os casos abaixo dependem do working tree real passar no typecheck
  if (cd "$ROOT" && pnpm run typecheck >/dev/null 2>&1); then
    echo 'export const x = 1;' >"$PROBE"
    : >"$TMP/claude-edited-ok"
    stop "ok"
    check 0 "$?" "código válido encerra"
    stop "ok" "$TMP/stub"
    check 0 "$?" "mesmo diff OK não roda de novo (cache)"
    rm -f "$PROBE"
  else
    echo "  (pulado 'código válido': o working tree já falha no typecheck; o CI é a referência)"
  fi

  echo "check-ts"
  echo 'const naoUsada = 1;' >"$LINT_PROBE"
  jq -nc --arg f "$LINT_PROBE" '{session_id:"lint", tool_input:{file_path:$f}}' | "$H/check-ts.sh" >/dev/null 2>&1
  check 2 "$?" "erro de ESLint volta ao Claude"
  [ -f "$TMP/claude-edited-lint" ]; check 0 "$?" "marca a sessão que editou .ts"
  rm -f "$LINT_PROBE"
  printf 'const   x=1\n' >"$TMP/fora.ts"
  jq -nc --arg f "$TMP/fora.ts" '{session_id:"fora", tool_input:{file_path:$f}}' | "$H/check-ts.sh" >/dev/null 2>&1
  check 0 "$?" "ignora arquivo fora do repo"
  [ "$(cat "$TMP/fora.ts")" = "const   x=1" ] && [ ! -f "$TMP/claude-edited-fora" ]
  check 0 "$?" "não formata nem marca arquivo fora do repo"
else
  echo "  (pulado: rode 'pnpm install' para testar verify-on-stop e check-ts)"
fi

echo
[ "$FAILS" -eq 0 ] && echo "Todos os casos passaram." && exit 0
echo "$FAILS caso(s) falharam." && exit 1
