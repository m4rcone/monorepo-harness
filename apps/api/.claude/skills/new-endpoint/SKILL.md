---
name: new-endpoint
description: Cria um endpoint HTTP em apps/api no padrão da casa (validação na borda, erro padrão, teste de contrato). Use ao adicionar rotas à API.
argument-hint: "[método] [rota]"
---

<!-- Skill ANINHADA: aparece no menu / depois que o Claude lê um arquivo de apps/api/
     (ou após `/add-dir apps/api`). ADAPTE os passos ao framework escolhido. -->

Crie o endpoint $ARGUMENTS:

1. Se `apps/api/CLAUDE.md` ainda não define o framework (ADAPTE), pare e peça ao humano para
   defini-lo (ou rodar `/foundation`)
2. Use um handler existente como referência; sem nenhum, siga `.claude/rules/api.md`
3. Registre a rota onde as demais são registradas: handler fino, validação de entrada na borda,
   formato de erro padrão
4. Teste de contrato cobrindo o sucesso e o principal caso de erro
5. Rode `pnpm vitest run <teste>` e `pnpm run typecheck` e MOSTRE a saída
