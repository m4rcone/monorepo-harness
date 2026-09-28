---
name: new-component
description: Cria um componente de UI em apps/web no padrão da casa (props tipadas, acessibilidade, teste de comportamento). Use ao adicionar componentes.
argument-hint: "[NomeDoComponente]"
---

<!-- Skill ANINHADA: aparece no menu / depois que o Claude lê um arquivo de apps/web/
     (ou após `/add-dir apps/web`). ADAPTE os passos ao framework escolhido. -->

Crie o componente $ARGUMENTS:

1. Se `apps/web/CLAUDE.md` ainda não define o framework (ADAPTE), pare e peça ao humano para
   defini-lo (ou rodar `/foundation`)
2. Use um componente existente como referência de estrutura e nomenclatura; sem nenhum, siga
   `.claude/rules/web.md`
3. Crie o componente (props tipadas) e, ao lado, um teste de comportamento
4. Rode `pnpm vitest run <teste>` e `pnpm run typecheck` e MOSTRE a saída
