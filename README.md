# Harness Claude Code — monorepo Node/TS (pnpm)

Base de engenharia de workflow para desenvolver com **Claude Code** num monorepo
Node/TypeScript. Perfil de permissões: **solo dev** (`acceptEdits` + allowlist).
Encaixes incluídos: **API** (`apps/api`) e **Frontend** (`apps/web`).

Tudo marcado com `ADAPTE` é placeholder deliberado — o harness define o
_processo_; as escolhas de framework são suas.

## Pré-requisitos

- Claude Code atualizado (`claude update`) — recursos usados pedem v2.1.2xx+
- `pnpm` (via `corepack enable`), `jq` (requisito dos hooks) e, opcional, `gh`

## Primeiros passos

1. Copie o conteúdo deste diretório para a raiz do seu repositório (ou use-o
   como template repo) e ajuste os `ADAPTE`.
2. `pnpm install` — e **comite o `pnpm-lock.yaml`** (o CI usa `--frozen-lockfile`).
3. `claude` na **raiz do repo**. Aceite o diálogo de confiança do workspace: ele
   lista exatamente as regras `allow` que este `.claude/settings.json` concede
   (as regras só valem depois desse aceite — mecanismo oficial de segurança).
4. Verifique o carregamento: `/context` (CLAUDE.md e rules), `/hooks` (3 hooks),
   `/permissions` (regras) e digite `/` para ver as skills.
5. Smoke test do loop: peça uma mudança pequena num arquivo de `apps/api/src/` —
   o Prettier/ESLint devem rodar sozinhos (hook) e a rule de API deve carregar.
6. CI com Claude (opcional): rode `/install-github-app` num terminal com Claude
   Code e adicione o secret `ANTHROPIC_API_KEY` no repositório.

> **Sessões na raiz, por design**: hooks e permissions do projeto carregam do
> `.claude/` do diretório onde a sessão inicia (sem fallback para pais). Com
> poucos pacotes, inicie sempre na raiz — CLAUDE.md aninhados, rules com
> `paths:` e skills aninhadas fazem o escopo por você. Se o repo crescer a
> ponto de valer iniciar dentro do pacote, replique um `settings.json` mínimo lá.

## O que cada peça faz

| Peça                              | Papel                                                                                                                                                                         |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `CLAUDE.md` (raiz)                | Fatos que valem em toda sessão: comandos, convenções compartilhadas, workflow. Alvo ≤200 linhas.                                                                              |
| `apps/*/CLAUDE.md`                | Contexto local; carrega sob demanda ao trabalhar naquele pacote (aditivo à raiz).                                                                                             |
| `.claude/rules/*.md`              | Convenções com escopo de caminho (`paths:`) — só entram em contexto ao tocar arquivos casados.                                                                                |
| `.claude/settings.json`           | Permissões (allow/ask/deny) + registro dos hooks. Comitado; overrides pessoais em `settings.local.json` (gitignored).                                                         |
| `.claude/hooks/`                  | Determinístico: `check-ts` (format+lint por edição), `protect-files` (bloqueia `.env`/lockfile/`.git`), `guard-bash` (rm -rf amplo, pipe-to-shell, descarte do working tree). |
| `.claude/skills/`                 | Fluxos invocáveis: `/commit`, `/fix-issue N`, `/spec ...`, `/adr ...` (todos só por invocação sua).                                                                           |
| `.claude/agents/code-reviewer.md` | Revisor somente-leitura em contexto isolado; use `@code-reviewer` (ou o bundled `/code-review`) **antes** de `/commit`.                                                       |
| `apps/*/.claude/skills/`          | Skills por pacote (`/new-endpoint`, `/new-component`) — ativam ao trabalhar no pacote.                                                                                        |
| `docs/`                           | `architecture.md` (vivo), `decisions/` (ADRs via `/adr`), `specs/` (specs via `/spec`). Referenciados por caminho, nunca `@`-importados.                                      |
| `.github/workflows/`              | `ci.yml` gateia merge (sem Claude); `claude-review.yml` revisa PRs (advisory); `claude.yml` responde a `@claude`.                                                             |
| `.devcontainer/`                  | Encaixe opcional de padronização. Para `--dangerously-skip-permissions`, use o devcontainer **oficial** com firewall default-deny (link no arquivo).                          |

## O fluxo de trabalho embutido

1. **Explorar/planejar** — plan mode (Shift+Tab); feature grande: `/spec` e
   sessão nova para executar.
2. **Implementar** — prompt referenciando o plano; hooks e rules trabalham no
   fundo; peça sempre a saída de testes como evidência.
3. **Revisar** — `/code-review` ou `@code-reviewer`; corrija achados críticos.
4. **Commitar** — `/commit`; push e PR passam por aprovação (`ask`).
5. `/clear` entre tarefas não relacionadas.

## Fluxo recomendado para milestone 0 (fundação do projeto)

1. Repo vazio, só com este harness (sem apps/api, sem apps/web ainda
2. /model opus ← decisões estruturais, vale o custo
3. /foundation "sua ideia em 1-2 frases"
   → entrevista em fases (problema/usuário → escopo/não-escopo →
   restrições → stack) → docs/product.md
   → propõe 2-3 stacks com trade-offs → você escolhe → docs/decisions/0001-stack.md
4. Com a stack decidida, o Claude adapta o scaffold do harness
   (monorepo vs pacote único, quais encaixes) ao que saiu da entrevista
5. /model sonnet ← volta ao daily driver
6. /spec "Milestone 0: fundação"
   → agora /spec FUNCIONA normalmente, porque já há convenções para seguir
7. /clear → implementar o spec do M0 → /code-review (Dynamic Workflow) → /commit

## Permissões — o racional (perfil solo)

- **allow**: ciclo interno (scripts pnpm, testes, git local, leitura no gh,
  docs oficiais via WebFetch).
- **ask**: o que sai da máquina ou toca supply chain — `git push`,
  `gh pr create`, `pnpm add/remove/update` (postinstall executa código).
- **deny**: segredos (`.env*`, `*.pem`, `*.key` — leitura E edição), força
  destrutiva (`push --force`, `publish`) e rede crua (`curl`/`wget`; use
  WebFetch com domínio permitido).

Deny vence allow em qualquer escopo. Para afrouxar/apertar só na sua máquina:
`.claude/settings.local.json`. Perfil de time: troque `defaultMode` para
`"default"`, mova instalações de `ask` mantendo, e considere
`"disableBypassPermissionsMode": "disable"`.

## Custos de CI

`claude-review.yml` tem teto triplo: `--max-turns 8`, `timeout-minutes: 15` e
`concurrency` com cancelamento. Modelo **fixado** (`claude-sonnet-5`) — aliases
mudam com o tempo; em CI, sempre nome completo. PRs só de docs não disparam review.

## Como estender (gatilhos)

| Sintoma                                | Ação                                               |
| -------------------------------------- | -------------------------------------------------- |
| Claude erra a mesma coisa 2ª vez       | Linha no `CLAUDE.md` (ou rule, se for de uma área) |
| Você cola o mesmo procedimento de novo | Vire skill em `.claude/skills/`                    |
| Algo deve acontecer SEMPRE             | Hook, não instrução                                |
| Investigação enche o contexto          | "use um subagent para investigar X"                |
| Segundo repositório quer este setup    | Empacote como plugin                               |

## Fontes

Padrões deste harness vêm da documentação oficial do Claude Code
(<https://code.claude.com/docs>): memory/CLAUDE.md, rules, skills, hooks,
permissions, subagents, monorepos, GitHub Actions e sandboxing — mais práticas
de comunidade sinalizadas nos comentários como adaptáveis.
