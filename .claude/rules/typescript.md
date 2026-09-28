---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# Regras TypeScript

<!-- Carrega quando o Claude trabalha em arquivos .ts/.tsx. ADAPTE aos seus padrões.
     `import type` não está aqui: o ESLint (consistent-type-imports, com --fix no hook) e o
     verbatimModuleSyntax do tsconfig já o garantem. -->

- Erros: lance subclasses de `Error` com nome próprio; nunca `throw` de string
- Funções exportadas: tipo de retorno explícito
- Preferir `unknown` a `any` em fronteiras de dados; validar antes de estreitar
