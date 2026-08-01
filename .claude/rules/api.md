---
paths:
  - "apps/api/**"
---

# Convenções da API

<!-- ADAPTE aos padrões reais do seu backend; abaixo, defaults razoáveis. -->

- Rotas kebab-case; JSON camelCase; versão no path (`/v1/...`)
- Erros no formato `{ "error": { "code", "message" } }`; códigos centralizados num módulo de erros
- Toda rota de lista pagina com `cursor` + `limit`
- Endpoint novo exige: validação de entrada na borda + teste de contrato
- Handlers finos: regra de negócio fora da camada HTTP
