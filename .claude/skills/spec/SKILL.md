---
name: spec
description: Criar o spec de uma feature em docs/specs/<slug>.md via entrevista estruturada
disable-model-invocation: true
argument-hint: "[descrição-curta-da-feature]"
---

Quero construir: $ARGUMENTS

1. Antes de perguntar, leia `docs/architecture.md`, `docs/product.md` (se existir), os ADRs
   relevantes e o código que a feature toca (use um subagent se for amplo). Não pergunte o que
   eles já respondem.
2. Me entreviste com AskUserQuestion sobre implementação técnica, UX, edge cases, riscos e
   trade-offs. Não faça perguntas óbvias: aprofunde no que eu talvez não tenha considerado.
   Continue até cobrirmos tudo.
3. Escreva um spec AUTOCONTIDO (a sessão que vai implementar só terá ele) em `docs/specs/<slug>.md`:
   - Objetivo e critério de sucesso mensurável
   - Fora de escopo (explícito)
   - Plano: passos pequenos e ordenados, cada um com arquivos/interfaces concretos e o comando
     que o verifica (inclua os testes a escrever)
   - Critérios de aceite em checklist `- [ ]`
   - Verificação final end-to-end que prova que a feature funciona
4. Termine com o caminho do spec e, prontos para colar depois do `/clear`:
   - `git checkout -b feat/<slug>`
   - o prompt: "Implemente docs/specs/<slug>.md passo a passo: rode a verificação de cada passo e
     marque [x] no spec. Divergiu do spec? Pare e pergunte. Só conclua com todos os critérios [x]
     e a verificação final mostrada."
