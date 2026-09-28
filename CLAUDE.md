<!--
  GUIA DE MANUTENÇÃO (comentários HTML são removidos antes de entrar no contexto: custo zero de tokens):
  - Para cada linha pergunte: "remover isto faria o Claude errar?" Se não, corte. Alvo: ≤200 linhas.
  - Procedimento multi-passo → skill em .claude/skills/. Regra de um subdiretório → .claude/rules/ com paths:.
  - Algo que DEVE acontecer sempre → hook (.claude/hooks/) ou lint, não instrução aqui.
  - Referencie docs por caminho em texto puro. `@caminho` importaria o arquivo inteiro em TODA sessão.
-->

# ADAPTE-nome-do-projeto — monorepo

<!-- ADAPTE: 2-3 linhas sobre o que o produto faz e a decisão arquitetural central. -->

Monorepo pnpm com `apps/api` (backend Node/TS) e `apps/web` (frontend TS).

## Comandos

- Instalar: `pnpm install` (SEMPRE pnpm; pede aprovação)
- Testes: um arquivo `pnpm vitest run <arquivo>` · um pacote `pnpm vitest run --project @app/api` · tudo `pnpm run test`
- Typecheck: `pnpm run typecheck` · Lint: `pnpm run lint` · Formatar: `pnpm run format`
- Tudo o que o CI roda: `pnpm run check`
- Mudou algo em `.claude/hooks/`: `pnpm run test:hooks`

## Convenções compartilhadas

- ES Modules apenas (`import`/`export`); nunca `require`
- TypeScript strict; sem `any` sem comentário justificando
- Convenções por área ficam em `.claude/rules/` e carregam por caminho: não as repita aqui

## Workflow

- Tarefa não trivial: plan mode antes de implementar. Feature grande: sugira ao humano `/spec` e implementar numa sessão nova
- Bug: primeiro um teste que falha reproduzindo-o, depois a correção na causa raiz
- Antes de concluir: rode typecheck + testes do escopo alterado e MOSTRE a saída. O hook `Stop` repete a checagem, mas só bloqueia o 1º encerramento com erro: corrija e confirme você mesmo, sem contornar
- Antes de commitar: revise com o subagent `code-reviewer` (convenções); o humano também pode rodar `/code-review` (bugs)
- Commit com a skill `commit` (Conventional Commits, nunca na `main`); PR com a skill `pr`. Push e PR pedem aprovação

## Gotchas

- Bash roda em sandbox (rede: domínios de `sandbox.network`; escrita: o projeto). Negou algo que a tarefa não pede? Não tente de novo sem sandbox: avise o humano (ele ajusta via `/sandbox`)
- `EPERM` ao escrever em `.claude/` via Bash (inclusive `git checkout`/`stash`) é proteção nativa do sandbox: use Edit/Write ou peça ao humano
- `gh` só roda fora do sandbox (onde o TLS funciona no macOS) quando é o comando inteiro: sem pipe, `&&`, heredoc ou `$(...)`. Filtre com `--json`/`--jq` do próprio gh. Liberados: `gh issue|pr view|list`, `gh pr diff|checks`, `gh run list|view`; o resto pede aprovação
- Hook bloqueou (`guard-bash`, `protect-files`)? A regra é intencional: não reformule o comando para escapar dela; explique ao humano e peça que ele execute
- `.env*` (inclusive `.env.example`) é ilegível e ineditável para o Claude, também dentro do sandbox: variável nova → avise o humano para registrá-la no `.env.example`
- Worktree nova (`--worktree`, EnterWorktree) nasce de `origin/main` e sem `node_modules`: rode `pnpm install` nela; o que não está no `origin/main` (WIP, spec, commits locais) não vai junto
- `pnpm install/add/...` pedem aprovação também com `-F`/`--filter`/`-C`; `curl` é negado e WebFetch não alcança localhost: verifique a API local por teste de contrato

<!-- ADAPTE: env vars obrigatórias, portas, peculiaridades de build/CI. Exemplo: -->
<!-- - Testes de integração precisam de `DATABASE_URL`: exporte-a no shell que inicia o `claude` (o sandbox não lê `.env*`) -->

## Referências (ler sob demanda; NÃO importar com @)

- Arquitetura: `docs/architecture.md`
- Decisões (ADRs): `docs/decisions/` · Specs de features: `docs/specs/`

<!-- ADAPTE: o /foundation acrescenta aqui `- Produto: docs/product.md` -->
