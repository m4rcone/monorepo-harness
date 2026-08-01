---
name: new-endpoint
description: Criar um novo endpoint na API seguindo as convenções da casa
disable-model-invocation: true
argument-hint: [método] [rota]
---

<!-- Skill ANINHADA: só fica disponível quando o Claude trabalha em apps/api/.
     Demonstra o mecanismo de skills por pacote em monorepo. ADAPTE os passos. -->

Crie o endpoint $ARGUMENTS:

1. Leia um handler existente como referência de padrão (se ainda não houver,
   siga `.claude/rules/api.md` da raiz)
2. Handler fino + validação de entrada na borda + formato de erro padrão
3. Teste de contrato cobrindo sucesso e o principal caso de erro
4. Rode os testes do arquivo (`pnpm vitest run <caminho>`) e MOSTRE a saída
