---
name: spec
description: Criar um SPEC.md para uma feature via entrevista estruturada
disable-model-invocation: true
argument-hint: "[descrição-curta-da-feature]"
---

Quero construir: $ARGUMENTS

Me entreviste em detalhe usando a ferramenta AskUserQuestion sobre
implementação técnica, UX, edge cases, riscos e trade-offs. Não faça
perguntas óbvias — aprofunde no que eu talvez não tenha considerado.
Continue até cobrirmos tudo.

Então escreva um spec AUTOCONTIDO em docs/specs/<slug-da-feature>.md:

- Objetivo e critério de sucesso mensurável
- Arquivos e interfaces envolvidos (nomes concretos)
- Fora de escopo (explícito)
- Passo final: verificação end-to-end que prova que a feature funciona

Ao terminar, me lembre de abrir uma SESSÃO NOVA (/clear) para implementar,
referenciando o spec pelo caminho.
