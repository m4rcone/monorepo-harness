---
name: commit
description: Stage e commit das mudanças atuais com Conventional Commits
disable-model-invocation: true
allowed-tools: Bash(git add *) Bash(git status *) Bash(git diff *) Bash(git commit *)
---

1. `git status` e `git diff` para entender o escopo completo
2. Agrupe mudanças logicamente relacionadas — um commit por intenção
3. Mensagem em Conventional Commits: `feat|fix|chore|refactor|test|docs(escopo): resumo`
   - Escopo = pacote tocado (`api`, `web`) quando a mudança é local a um deles
4. NÃO faça push — push é um passo humano separado (e passa por aprovação)
