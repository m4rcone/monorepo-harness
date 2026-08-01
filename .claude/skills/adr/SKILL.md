---
name: adr
description: Registrar uma decisão arquitetural (ADR) em docs/decisions/
disable-model-invocation: true
argument-hint: "[decisão-em-uma-frase]"
---

Registre a decisão: $ARGUMENTS

1. Liste `docs/decisions/` para obter o próximo número sequencial NNN
2. Preencha o template em [template.md](template.md), conciso (máx. 1 página):
   contexto, decisão, alternativas consideradas e por que foram rejeitadas, consequências
3. Salve como `docs/decisions/NNN-<slug>.md`
4. Proponha a linha de UMA frase a adicionar no CLAUDE.md ou numa rule,
   referenciando o ADR (o doc guarda o porquê; o CLAUDE.md guarda a regra) —
   e ESPERE minha aprovação antes de editar o CLAUDE.md
