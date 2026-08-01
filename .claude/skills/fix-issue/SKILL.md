---
name: fix-issue
description: Corrigir uma issue do GitHub pelo número
disable-model-invocation: true
argument-hint: "[número-da-issue]"
---

Corrija a issue $ARGUMENTS seguindo os padrões do projeto:

1. `gh issue view $ARGUMENTS` para os detalhes
2. Localize o código relevante (use subagents se a investigação for ampla)
3. Escreva um teste que REPRODUZ o problema antes de corrigir
4. Implemente a correção na causa raiz, não no sintoma
5. Rode o teste + typecheck do escopo alterado e MOSTRE a saída
6. Use /commit; depois proponha `gh pr create` referenciando a issue (passa por aprovação)
