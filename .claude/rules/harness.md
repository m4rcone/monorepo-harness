---
paths:
  - "**/.claude/**"
  - "scripts/test-hooks.sh"
  - ".github/workflows/**"
---

# Mantendo o harness (hooks, settings, skills, CI)

- Hook de segurança (guard-bash, protect-files) falha FECHADO sem `jq`; hook de conveniência (check-ts, verify-on-stop, session-start) falha aberto
- Bloquear = `exit 2` + motivo no stderr (volta ao Claude como feedback); nunca `exit 1` para bloquear
- Hook que atua no diretório de trabalho usa o `.cwd` do JSON de entrada (acompanha worktrees); `$CLAUDE_PROJECT_DIR` só para localizar os scripts
- Todo padrão novo ou alterado num hook ganha caso em `scripts/test-hooks.sh` (o que deve bloquear E um vizinho que deve passar); rode `pnpm run test:hooks`
- Temp em teste de hook: `mktemp -d "${TMPDIR:-/tmp}/x.XXXXXX"` (sem template, o macOS usa /var/folders, bloqueado pelo sandbox). Nunca crie `node_modules/` (engana os guardas); prefira repo real (`git init` no temp) a stub de git
- O sandbox bloqueia escrita via Bash em `.claude/` (settings, skills, agents, hooks): edite com Edit/Write, que pedem confirmação
- `settings.json`: `deny` vence tudo; `ask` explícito nunca é auto-aprovado; deny de `Read` também bloqueia Edit/Write. Caminhos: nome solto (`.env`, `*.pem`) casa em qualquer nível; `/x` = raiz do projeto; `dir/**` casa em qualquer nível em deny/ask, mas só na raiz em allow
- Skill: `argument-hint` SEMPRE entre aspas (`[a] [b]` sem aspas é YAML inválido e a skill não carrega). `disable-model-invocation: true` só em fluxo que o humano inicia: com ela o Claude não invoca a skill, nem a partir de outra skill
- Regras de permissão estão escritas como `Bash(...)`. Se o tool PowerShell for ligado (`CLAUDE_CODE_USE_POWERSHELL_TOOL`), replique as de ask/deny como `PowerShell(...)`
- Workflows com Claude são advisory; modelo sempre pelo ID completo, com `timeout-minutes` e `concurrency`
