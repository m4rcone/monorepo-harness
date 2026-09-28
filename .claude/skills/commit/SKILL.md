---
name: commit
description: Cria commit(s) em Conventional Commits das mudanças atuais, numa branch (cria uma se estiver na main). Use quando pedirem para commitar.
---

<!-- Sem disable-model-invocation de propósito: /fix-issue e o próprio Claude usam esta skill.
     O humano continua no controle: todo `git commit` pede aprovação (regra ask do settings.json). -->

1. `git branch --show-current`: se estiver na `main`, crie antes uma branch `tipo/descricao-curta`
   (`git checkout -b ...`), num comando separado; o guard-bash bloqueia commit na `main`
2. `git status` e `git diff` (inclusive `--staged`) para entender o escopo; arquivos novos (`??`) contam
3. Um commit por intenção: agrupe as mudanças relacionadas e adicione com `git add <arquivos>`
   (nunca `git add -p`, que é interativo)
4. Mensagem `tipo(escopo): resumo` no imperativo, até 72 caracteres
   - Tipos: `feat|fix|refactor|perf|test|docs|build|ci|chore`
   - Escopo: o pacote (`api`, `web`) ou a área (`harness`) quando a mudança é local a ele
   - Corpo só quando o porquê não é óbvio (um `-m` por parágrafo); `Closes #N` se fecha uma issue
5. Não faça push: o próximo passo é a skill `pr`
6. Mostre `git log --oneline` dos commits criados
