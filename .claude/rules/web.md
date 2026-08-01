---
paths:
  - "apps/web/**"
---

# Convenções do frontend

<!-- ADAPTE ao framework escolhido (React/Vue/etc.); abaixo, o que vale para qualquer um. -->

- Componentes pequenos e nomeados pela função, não pela aparência
- Estado derivável não vira estado armazenado
- Acessibilidade mínima obrigatória: elementos interativos nativos (button/a), labels em inputs, foco visível
- Nada de fetch direto em componente: usar a camada de dados do app
- Todo componente novo com pelo menos um teste de comportamento
