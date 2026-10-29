---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---

# Regras TypeScript

<!-- Carrega quando o Claude trabalha em arquivos .ts/.tsx. ADAPTE aos seus padrões.
     Fora daqui porque o ESLint já garante (com --fix no hook): `import type`, tipo de retorno
     explícito em exports, `throw` de algo que não é Error e promise sem `await`. -->

- Erros: lance subclasses de `Error` com nome próprio
- Preferir `unknown` a `any` em fronteiras de dados; validar antes de estreitar
