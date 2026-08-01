<!--
  GUIA DE MANUTENÇÃO (comentários HTML são removidos antes de entrar no contexto — custo zero de tokens):
  - Para cada linha pergunte: "remover isto faria o Claude errar?" Se não, corte. Alvo: ≤200 linhas.
  - Procedimento multi-passo → skill em .claude/skills/. Regra de um subdiretório → .claude/rules/ com paths:.
  - Algo que DEVE acontecer sempre → hook (.claude/hooks/), não instrução aqui.
  - Referencie docs por caminho em texto puro. `@caminho` importaria o arquivo inteiro em TODA sessão.
-->

# ADAPTE-nome-do-projeto — monorepo

<!-- ADAPTE: 2-3 linhas sobre o que o produto faz e a decisão arquitetural central. -->

Monorepo pnpm com `apps/api` (backend Node/TS) e `apps/web` (frontend TS).

## Comandos

- Instalar: `pnpm install` (SEMPRE pnpm — o lockfile é `pnpm-lock.yaml`)
- Testes de tudo: `pnpm run test` · de um pacote: `cd apps/api && pnpm run test`
- Um arquivo de teste: `pnpm vitest run <caminho>` (prefira teste único; a suíte completa fica para o CI)
- Typecheck: `pnpm run typecheck` · Lint: `pnpm run lint`

## Convenções compartilhadas

- ES Modules apenas (`import`/`export`); nunca `require`
- TypeScript strict; sem `any` sem comentário justificando
- Convenções por área carregam sozinhas de `.claude/rules/` (typescript, testing, api, web) — não as repita aqui

## Workflow

- Tarefa não trivial: plan mode antes de implementar; feature grande: `/spec` e sessão nova para executar
- Antes de considerar concluído: rodar typecheck + testes do escopo alterado e MOSTRAR a saída
- Revisão antes de commit: `/code-review` ou `@code-reviewer`
- Commits via `/commit` (Conventional Commits). Nunca commitar direto na `main`; PRs sempre

## Gotchas

<!-- ADAPTE: env vars obrigatórias, portas, peculiaridades de build/CI. Exemplos: -->
<!-- - `DATABASE_URL` de teste vem de `.env.test` (hooks bloqueiam leitura de `.env`) -->

## Referências (ler sob demanda; NÃO importar com @)

- Arquitetura: `docs/architecture.md`
- Decisões (ADRs): `docs/decisions/` · Specs de features: `docs/specs/`
