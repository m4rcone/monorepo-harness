# apps/web

<!-- ADAPTE: framework (React? Vue? Svelte?), bundler, como sobe local. -->
<!-- Carrega sob demanda quando o Claude lê ou edita arquivos daqui, somando-se ao CLAUDE.md raiz.
     Só o que é local ao pacote; convenções abaixo valem para qualquer framework: ADAPTE. -->

## Comandos (da raiz, sem `cd`)

- Testes do pacote: `pnpm vitest run --project @app/web`

## Convenções

- Componentes pequenos e nomeados pela função, não pela aparência
- Estado derivável não vira estado armazenado
- Acessibilidade mínima: elementos interativos nativos (button/a), labels em inputs, foco visível
- Nada de fetch direto em componente: usar a camada de dados do app
- Todo componente novo com pelo menos um teste de comportamento
- Mudança visual: suba o dev server e confira no navegador (ferramenta de browser, se houver); sem ela, peça ao humano para conferir

## Gotchas

<!-- ADAPTE: ex. variáveis VITE_* obrigatórias; mocks de API em tests/msw/ -->
