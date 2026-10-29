# Harness Claude Code — monorepo Node/TS (pnpm)

Template para começar projetos com **Claude Code** num monorepo Node/TypeScript: `apps/api`
(backend) e `apps/web` (frontend), com o processo (hooks, permissões, skills, CI) já montado e as
escolhas de framework deixadas para você. Tudo marcado com `ADAPTE` é placeholder deliberado.

## Pré-requisitos

- Claude Code recente (`claude update`); validado na v2.1.312
- Node 24 (`.nvmrc`) e pnpm via `corepack enable` (assume a versão de `packageManager`)
- `npm install -g typescript-language-server typescript`: o plugin `typescript-lsp` (habilitado no
  `settings.json`) dá ao Claude diagnósticos após cada edição e navegação por símbolo
- `jq` (os hooks de segurança bloqueiam sem ele) e `gh` autenticado (`gh auth login`)
- Linux/WSL2: `bubblewrap` e `socat` para o sandbox (macOS não precisa; o devcontainer já traz)

## Começando

1. Crie o repo a partir deste (GitHub → _Use this template_) e rode `pnpm install`. Comite o
   `pnpm-lock.yaml` sempre que as dependências mudarem (o CI usa `--frozen-lockfile`). Versões
   publicadas há menos de 24h são recusadas de propósito (`pnpm-workspace.yaml`).
2. `claude` na **raiz** e aceite o diálogo de confiança (as regras `allow` e os hooks só valem
   depois dele). Confira com `/hooks` (5 hooks), `/sandbox` (ativo) e `/permissions`.
3. Smoke test: peça uma mudança pequena em `apps/api/src/`. ESLint e Prettier rodam no arquivo
   (hook) e, ao terminar, o hook `Stop` roda typecheck + testes relacionados.
4. **Ideia ainda crua?** `/foundation "sua ideia em 1-2 frases"`: entrevista,
   `docs/product.md`, 2-3 stacks para você escolher, ADR `001-stack.md` e a adaptação do scaffold
   (só aplica com a sua aprovação). **Stack decidida?** Resolva os `git grep -n ADAPTE` e o `name`
   do `package.json`, e registre a stack com `/adr`.
5. **Proteja a `main`** (Settings → Rules → Rulesets): exija PR e o check `checks` do CI e bloqueie
   force push. Sem isso o CI só informa. Em repo privado, rulesets exigem GitHub Pro/Team.
6. _Opcional_, Claude no GitHub: `/install-github-app` (app + secret) e depois
   `gh variable set CLAUDE_CI --body true`. Sem a variável os workflows com Claude ficam _skipped_.
   Se o comando oferecer sobrescrever `claude.yml`/`claude-code-review.yml`, recuse: os daqui têm o
   opt-in `CLAUDE_CI` e a proteção contra forks.

Inicie as sessões sempre na raiz: `settings.json` e hooks não são herdados de diretórios pais, e os
`CLAUDE.md` dos pacotes e as rules com `paths:` já fazem o escopo por pasta.

## O que cada peça faz

| Peça                              | Papel                                                                                                      |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `CLAUDE.md`                       | O que vale em toda sessão: comandos, workflow, gotchas. Curto de propósito.                                |
| `apps/*/CLAUDE.md`                | Convenções do pacote; carregam quando o Claude lê ou edita algo ali.                                       |
| `.claude/rules/*.md`              | Convenções transversais por glob (`paths:`): typescript, testing e harness.                                |
| `.claude/settings.json`           | Permissões (allow/ask/deny), sandbox e hooks. Ajustes pessoais: `settings.local.json` (gitignored).        |
| `.claude/hooks/`                  | O que precisa acontecer sempre (abaixo). Cada script explica a si mesmo no cabeçalho.                      |
| `.claude/skills/`                 | `/foundation`, `/spec`, `/adr`, `/fix-issue` (só você inicia); `/commit`, `/pr` (você ou o Claude).        |
| `.claude/agents/code-reviewer.md` | Revisor de convenções em contexto isolado (`@agent-code-reviewer`); complementa o `/code-review` (bugs).   |
| `docs/`                           | `architecture.md` (vivo), `decisions/` (ADRs), `specs/`. Referenciados por caminho, nunca `@`-importados.  |
| `.github/`                        | `ci.yml` (gate de merge, sem Claude), `claude-code-review.yml` e `claude.yml` (advisory), `dependabot.yml` |
| `.devcontainer/`                  | Ambiente padronizado, opcional. Não é isolamento: para `--dangerously-skip-permissions`, use o oficial.    |
| `scripts/test-hooks.sh`           | Regressão dos hooks (roda no CI). Mudou um hook? Acrescente o caso.                                        |

**Hooks**: `session-start` avisa (só quando há problema) sobre `jq`, `typescript-language-server`
(fora do CI), dependências e sessão na `main` · `protect-files` bloqueia edição de `.env*`, `pnpm-lock.yaml` e `.git/` · `guard-bash`
bloqueia `rm -r` amplo, `curl | sh`, descarte de trabalho (`checkout .`, `reset --hard`, `clean -f`,
`stash drop`) e commit na `main` · `check-ts` roda ESLint `--fix` + Prettier no arquivo editado ·
`verify-on-stop` roda typecheck + `vitest --changed` se a sessão editou `.ts` e bloqueia o 1º
encerramento com erro. Os de segurança falham fechado sem `jq`; os de conveniência, aberto.

## Fluxo de trabalho

1. **Planejar**: plan mode (Shift+Tab). Feature grande: `/spec`, que entrega a branch e o prompt
   para implementar numa sessão nova (`/clear`).
2. **Implementar**: hooks e convenções trabalham no fundo.
3. **Revisar**: `/code-review` (bugs) e `@agent-code-reviewer` (convenções; sugere candidatos a regra).
4. **Entregar**: `/commit` → `/pr` (roda `pnpm run check`, faz push, abre o PR e acompanha o CI).
   Commit, push e PR sempre pedem aprovação.

## Segurança em camadas

Nenhuma camada basta sozinha; juntas cobrem erro do modelo e comando indireto.

1. **Modo de permissão**: o projeto não fixa `defaultMode`, então vale o padrão do Claude Code
   (auto mode desde a v2.1.283: um classificador revisa as ações). Quer aprovar cada ação? Ponha
   `"defaultMode": "default"` no seu `settings.local.json` (`acceptEdits` aprova edições sozinho e
   pede só comandos).
2. **Regras** (`settings.json`), que valem em qualquer modo e antes do classificador. `allow`: o
   ciclo interno (scripts pnpm, vitest/tsc/eslint/prettier, git local, leitura no `gh`, docs
   oficiais). `ask`: o que sai da máquina, toca supply chain ou muda o CI (commit/push, escrita no
   GitHub, instalar ou executar pacotes, editar `.github/workflows/`). `deny`: segredos (`.env*`,
   `secrets/`, `*.pem`, `*.key`), force push, `publish` e `curl`/`wget`.
3. **Sandbox do Bash**, em modo estrito: escrita só no projeto (+ cache do pnpm); rede só para o npm
   registry e o GitHub; `sandbox.credentials` esconde `~/.ssh`, `~/.aws`, `~/.kube` etc. e tokens
   do ambiente. Com `allowUnsandboxedCommands: false` o Claude não consegue sair dele: comando
   barrado volta para você (`/sandbox` ou `! comando`), em vez de ir ao classificador do auto mode.
   Só o `gh` roda fora (o TLS falha no macOS), e passa pelas regras. No macOS o dev server
   sobe dentro do sandbox (`allowLocalBinding`); no Linux essa chave não tem efeito: rode-o num
   terminal seu. Domínio novo:
   `sandbox.network.allowedDomains`, nunca desligar o sandbox. Registry privado: tire o
   `NPM_TOKEN` de `credentials.envVars`. `git push` por SSH falha no sandbox: use HTTPS.
4. **Protected paths nativos**: edição em `.claude/`, `.git/`, `.devcontainer/` etc. pede
   confirmação em `default`/`acceptEdits`; no auto mode vai ao classificador. Para revisar cada
   mudança no harness, use o modo `default` e não libere a pasta `.claude` para a sessão.
5. **Hooks**: padrões que regras de prefixo não capturam. **CI**: gate de merge via ruleset.

Perfil de time: `"permissions": { "disableBypassPermissionsMode": "disable" }`, de preferência em
managed settings.

## Custos de CI

Os workflows com Claude só sobem runner com `CLAUDE_CI=true`. O review roda uma vez por PR (pula
rascunho, fork, bot e PR só de docs) e o `@claude` só responde a quem tem acesso ao repo, nunca em
PR de fork. Ambos têm `timeout-minutes`, `concurrency` e modelo fixado pelo ID completo.

## Como estender

| Sintoma                                     | Ação                                                                                              |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Claude erra a mesma coisa pela 2ª vez       | Uma linha no `CLAUDE.md` (ou no do pacote)                                                        |
| Precisa valer sempre, sem exceção           | Lint ou hook (com caso em `scripts/test-hooks.sh`), não instrução                                 |
| Você cola o mesmo procedimento de novo      | Vire skill em `.claude/skills/`                                                                   |
| Novo pacote em `packages/` ou `apps/`       | `tsconfig.json` como o de `apps/api` (sem ele o ESLint falha); `CLAUDE.md` só com convenção local |
| Instruções parecem velhas ou contraditórias | `/doctor prompt-audit`                                                                            |
| Segundo repositório quer este setup         | Empacote como plugin                                                                              |

Fonte dos padrões: a documentação oficial do Claude Code (<https://code.claude.com/docs>),
principalmente _Best practices_, _Memory_, _Permissions_, _Sandboxing_, _Hooks_ e _Monorepos_.
