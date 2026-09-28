# apps/web

<!-- ADAPTE: framework (React? Vue? Svelte?), bundler, como sobe local. -->
<!-- Carrega sob demanda quando o Claude trabalha em arquivos daqui, somando-se ao CLAUDE.md raiz
     (junto com .claude/rules/web.md). Mantenha só o que é local ao pacote. -->

## Comandos (da raiz, sem `cd`)

- Testes do pacote: `pnpm vitest run --project @app/web`
- Typecheck: `pnpm run typecheck` · Build: `pnpm run build`

## Convenções locais

- Componente novo: skill `new-component`
- Mudança visual: suba o dev server e confira no navegador (ferramenta de browser, se houver); sem ela, peça ao humano para conferir

## Gotchas

<!-- ADAPTE: ex. variáveis VITE_* obrigatórias; mocks de API em tests/msw/ -->
