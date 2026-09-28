# apps/api

<!-- ADAPTE: framework (Fastify? Hono? Express?), porta, banco, como sobe local. -->
<!-- Carrega sob demanda quando o Claude trabalha em arquivos daqui, somando-se ao CLAUDE.md raiz
     (junto com .claude/rules/api.md). Mantenha só o que é local ao pacote. -->

## Comandos (da raiz, sem `cd`)

- Testes do pacote: `pnpm vitest run --project @app/api`
- Typecheck: `pnpm run typecheck` · Build: `pnpm run build`

## Convenções locais

- Imports relativos com extensão `.js` (`./db.js`): a API usa NodeNext e o tsc acusa a falta
- Endpoint novo: skill `new-endpoint`

## Gotchas

<!-- ADAPTE: ex. `DATABASE_URL` de teste exportada no shell (o sandbox não lê `.env*`); seeds em scripts/seed.ts -->
