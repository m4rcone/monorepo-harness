---
name: adr
description: Registrar uma decisão arquitetural (ADR) em docs/decisions/
disable-model-invocation: true
argument-hint: "[decisão-em-uma-frase]"
---

Registre a decisão: $ARGUMENTS

1. NNN = maior número em `docs/decisions/NNN-*.md` + 1, com 3 dígitos (nenhum ADR ainda → `001`)
2. Preencha o template [template.md](template.md), conciso (máx. 1 página): contexto, decisão,
   alternativas consideradas e por que foram rejeitadas, consequências. Status `aceita`, data de hoje
3. Salve como `docs/decisions/NNN-<slug>.md`
4. Se substitui um ADR anterior, mude o Status dele para `substituída por NNN`. Se a decisão é
   estrutural, adicione o link em `docs/architecture.md` § Decisões estruturais em vigor
5. Proponha a linha de UMA frase para o CLAUDE.md ou uma rule, citando o ADR (o ADR guarda o
   porquê; o CLAUDE.md guarda a regra), e ESPERE minha aprovação antes de editar
