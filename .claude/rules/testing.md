---
paths:
  - "**/*.test.ts"
  - "**/*.test.tsx"
  - "**/*.spec.ts"
  - "**/*.spec.tsx"
  - "**/tests/**"
---

# Regras de testes (vitest)

- Estrutura AAA (arrange / act / assert); um comportamento por teste
- Importar de `vitest` explicitamente (`import { describe, it, expect } from "vitest"`); sem globals
- Nada de mock ad-hoc de infra (banco, fetch): use as fixtures/factories compartilhadas (ADAPTE: onde ficam, ex. `<pacote>/tests/fixtures/`)
