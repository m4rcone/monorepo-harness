# ts-diff.sh — lido com `.` pelo verify-on-stop.sh e pelo scripts/verify.sh, na raiz do repo.
# Os dois precisam dos mesmos comandos e do mesmo hash: é o hash que deixa o hook Stop pular o
# diff que um `pnpm run verify` já aprovou.

VERIFY_TYPECHECK=(pnpm run typecheck)
VERIFY_TESTS=(pnpm exec vitest run --changed HEAD --passWithNoTests)

TS=('*.ts' '*.tsx' '*.mts' '*.cts')
# Hash do último diff TS aprovado. Fica no repo, não no $TMPDIR: o Bash do sandbox e os hooks
# enxergam $TMPDIR diferentes
VERIFIED=node_modules/.cache/claude-verified

ts_changed() { # arquivos TS alterados vs HEAD + TS novos (pathspec entre aspas: seguro com espaços no nome)
  git diff --name-only HEAD -- "${TS[@]}" 2>/dev/null
  git ls-files --others --exclude-standard -- "${TS[@]}"
}

ts_diff_hash() {
  { git rev-parse --show-toplevel
    git diff HEAD -- "${TS[@]}" 2>/dev/null
    git ls-files --others --exclude-standard -z -- "${TS[@]}" | xargs -0 cat 2>/dev/null; } \
    | git hash-object --stdin
}

mark_verified() { mkdir -p "${VERIFIED%/*}" && ts_diff_hash >"$VERIFIED"; }
