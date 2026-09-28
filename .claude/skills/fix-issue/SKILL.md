---
name: fix-issue
description: Corrigir uma issue do GitHub pelo número, com teste que reproduz o bug antes da correção
disable-model-invocation: true
argument-hint: "[número-da-issue]"
---

Corrija a issue #$ARGUMENTS:

1. `gh issue view $ARGUMENTS` para os detalhes; se estiver na `main`, crie a branch `fix/$ARGUMENTS-<slug>`
2. Localize o código relevante (use um subagent se a investigação for ampla)
3. Escreva um teste que REPRODUZ o problema e mostre que ele falha
4. Corrija na causa raiz, não no sintoma
5. Rode o teste + `pnpm run typecheck` e MOSTRE a saída
6. Revise com o subagent `code-reviewer` e corrija os achados críticos
7. Use a skill `commit` (corpo com `Closes #$ARGUMENTS`) e depois a skill `pr` com `#$ARGUMENTS`
