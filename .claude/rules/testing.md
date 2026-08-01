---
paths:
  - "**/*.test.ts"
  - "**/*.spec.ts"
  - "**/tests/**"
---

# Regras de testes (vitest)

- Estrutura AAA (arrange / act / assert); um comportamento por teste
- Importar de `vitest` explicitamente (`import { describe, it, expect } from "vitest"`) — sem globals
- Nada de mock ad-hoc de infra (banco, fetch): use fixtures/factories compartilhadas
- Rodar o arquivo alterado (`pnpm vitest run <caminho>`), não a suíte inteira
- Teste que reproduz um bug vem ANTES da correção
