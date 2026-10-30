# apps/api

<!-- ADAPTE: framework (Fastify? Hono? Express?), porta, banco, como sobe local. -->
<!-- Carrega sob demanda quando o Claude lê ou edita arquivos daqui, somando-se ao CLAUDE.md raiz.
     Só o que é local ao pacote; convenções abaixo são defaults: ADAPTE ao seu backend. -->

## Comandos (da raiz, sem `cd`)

- Testes do pacote: `pnpm vitest run --project @app/api`

## Convenções

- Imports relativos com extensão `.js` (`./db.js`): a API usa NodeNext e o tsc acusa a falta
- Rotas kebab-case; JSON camelCase; versão no path (`/v1/...`)
- Erros no formato `{ "error": { "code", "message" } }`; códigos centralizados num módulo de erros
- Toda rota de lista pagina com `cursor` + `limit`
- Endpoint novo exige validação de entrada na borda + teste de contrato (chama a rota via HTTP e confere status e formato do corpo, inclusive o de erro)
- Handlers finos: regra de negócio fora da camada HTTP

## Gotchas

<!-- ADAPTE: ex. `DATABASE_URL` de teste exportada no shell (o sandbox não lê `.env*`); seeds em scripts/seed.ts -->
