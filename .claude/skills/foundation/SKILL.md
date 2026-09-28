---
name: foundation
description: Entrevista inicial de um projeto novo a partir de uma ideia crua; produz docs/product.md, o ADR de stack e a adaptação do scaffold. Rode uma vez, antes de qualquer /spec.
disable-model-invocation: true
argument-hint: "[ideia-do-produto-em-1-2-frases]"
---

Ideia: $ARGUMENTS

Você está definindo a fundação do projeto. CLAUDE.md, rules, skills e docs trazem defaults
genéricos do template, marcados `ADAPTE`: não os trate como decisões deste projeto. O processo
(hooks, workflow, pnpm) continua valendo.

Entreviste em FASES, uma de cada vez, com AskUserQuestion, confirmando o que foi capturado antes
de avançar:

**Fase 1 — Problema e usuário**: quem usa, que problema resolve, critério de sucesso mensurável.

**Fase 2 — Escopo do MVP**: o que entra no M0 e o que fica para depois; fora de escopo explícito.

**Fase 3 — Restrições**: time, prazo, preferências e aversões técnicas declaradas, alvo de deploy.

**Fase 4 — Stack**: com base nas fases 1-3, proponha 2-3 combinações plausíveis no ecossistema
Node/TS (monorepo pnpm ou pacote único; framework de API; framework de frontend, se houver), com
trade-offs explícitos. NÃO decida sozinho: pergunte, indicando sua recomendação.

Ao final:

1. Escreva `docs/product.md`: problema, usuário, proposta de valor, métrica de sucesso, fora de escopo
2. Registre a stack em `docs/decisions/001-stack.md` (template: `.claude/skills/adr/template.md`)
3. Proponha a adaptação do scaffold como uma lista de mudanças por arquivo e ESPERE minha aprovação
   antes de aplicar:
   - cada placeholder de `git grep -n ADAPTE` e o `name` do `package.json` raiz (JSON não aceita o marcador)
   - encaixe não usado (ex.: sem frontend) → remover `apps/web/` e `.claude/rules/web.md` e atualizar
     cada menção de `git grep -n apps/web` (CLAUDE.md, README)
   - dependências do framework via `pnpm add` (pede aprovação), scripts `dev` e `docs/architecture.md`
     com link para o ADR
   - `WebFetch(domain:...)` da documentação oficial do framework no allow do `.claude/settings.json`
   - `- Produto: docs/product.md` nas Referências do CLAUDE.md
4. Rode `pnpm run check` e mostre a saída
5. Me lembre do próximo passo: skill `commit`, depois `/clear` e `/spec "Milestone 0: fundação"`
