---
name: foundation
description: Entrevista inicial de um projeto novo a partir de uma ideia crua — produz docs/product.md e uma decisão de stack registrada como ADR. Rode uma única vez, antes de qualquer /spec.
disable-model-invocation: true
argument-hint: "[ideia-do-produto-em-1-2-frases]"
---

Ideia: $ARGUMENTS

Este projeto ainda não tem convenções — você está definindo a fundação.
NÃO leia CLAUDE.md/rules em busca de padrões existentes: eles ainda não existem.

Entreviste em FASES, uma de cada vez, confirmando o que foi capturado antes
de avançar (use AskUserQuestion):

**Fase 1 — Problema e usuário**
Quem usa, que problema resolve, qual é o critério de sucesso mensurável.

**Fase 2 — Escopo do MVP**
O que entra no M0 vs. o que fica para depois. Fora de escopo explícito.

**Fase 3 — Restrições**
Time (solo/pequeno), prazo, preferências e aversões técnicas
declaradas, alvo de deploy.

**Fase 4 — Stack**
Com base nas fases 1-3, proponha 2-3 combinações plausíveis dentro do
ecossistema Node/TS (ex.: monorepo pnpm vs. pacote único; framework de API;
framework de frontend se houver) com trade-offs explícitos — NÃO decida
sozinho. Pergunte via AskUserQuestion, indicando sua recomendação.

Ao final:

1. Escreva docs/product.md (problema, usuário, proposta de valor, métrica
   de sucesso, fora de escopo)
2. Registre a decisão de stack como ADR (siga .claude/skills/adr/template.md)
3. Proponha os ajustes necessários no CLAUDE.md raiz e na estrutura de pastas
   para refletir a stack escolhida — espere minha aprovação antes de aplicar
4. Me lembre: próximo passo é `/spec "Milestone 0: fundação"` numa sessão nova
