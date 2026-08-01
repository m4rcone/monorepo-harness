# apps/api

<!-- ADAPTE: framework (Fastify? Hono? Express?), porta, banco, como sobe local. -->
<!-- Este arquivo carrega SOB DEMANDA quando o Claude trabalha em arquivos daqui,
     somando-se ao CLAUDE.md raiz (carregamento é aditivo). Mantenha só o local. -->

## Comandos (deste pacote)

- Testes: `pnpm run test` (rode DAQUI; não a suíte inteira da raiz)
- Typecheck: `pnpm run typecheck` · Build: `pnpm run build`

## Convenções locais

- As regras de API carregam sozinhas de `.claude/rules/api.md` (raiz) ao tocar arquivos daqui
- Workflow: `/new-endpoint <método> <rota>` cria endpoint no padrão da casa

## Gotchas

<!-- ADAPTE: ex. `DATABASE_URL` de teste vem de `.env.test`; seeds em scripts/seed.ts -->
