---
paths:
  - "**/*.{ts,tsx}"
---

# Regras TypeScript

<!-- Carrega quando o Claude trabalha em arquivos .ts/.tsx. ADAPTE aos seus padrões. -->

- Imports de tipo com `import type { ... }` quando só o tipo é usado
- Erros: lance subclasses de `Error` com nome próprio; nunca `throw` de string
- Funções exportadas: tipo de retorno explícito
- Preferir `unknown` a `any` em fronteiras de dados; validar antes de estreitar
