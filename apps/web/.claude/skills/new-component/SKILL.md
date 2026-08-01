---
name: new-component
description: Criar um novo componente de UI seguindo as convenções da casa
disable-model-invocation: true
argument-hint: [NomeDoComponente]
---

<!-- Skill ANINHADA: disponível quando o Claude trabalha em apps/web/.
     ADAPTE ao seu framework quando ele for escolhido. -->

Crie o componente $ARGUMENTS:

1. Leia um componente existente como referência de estrutura e nomenclatura
2. Componente pequeno, props tipadas, estado derivável não vira estado armazenado
3. Acessibilidade mínima: elemento interativo nativo, label, foco visível
4. Pelo menos um teste de comportamento; rode-o e MOSTRE a saída
