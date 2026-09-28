# Harness Claude Code — monorepo Node/TS (pnpm)

Template de engenharia de workflow para começar projetos novos com **Claude Code** num monorepo
Node/TypeScript. Perfil de permissões: **solo dev** (`acceptEdits` + allowlist + sandbox).
Encaixes incluídos: **API** (`apps/api`) e **Frontend** (`apps/web`).

Tudo marcado com `ADAPTE` é placeholder deliberado: o harness define o _processo_; as escolhas de
framework são suas.

## Pré-requisitos

- Claude Code recente (`claude update`); validado na v2.1.284
- Node 24 LTS (versão no `.nvmrc`) e pnpm: `corepack enable` (Node 24) ou `npm i -g pnpm`. O pnpm
  assume sozinho a versão fixada em `packageManager`
- `jq` (requisito dos hooks) e `gh` autenticado (`gh auth login`), usado por `/fix-issue`, `/pr` e
  `/install-github-app`
- Linux/WSL2: `bubblewrap` e `socat` para o sandbox (o macOS não precisa de nada; o devcontainer já traz)

## Começando um projeto novo

1. **Crie o repo** a partir deste (GitHub → _Use this template_, ou copie o conteúdo para um repo vazio).
2. `pnpm install`. O `pnpm-lock.yaml` já vem versionado: comite-o sempre que as dependências mudarem
   (o CI usa `--frozen-lockfile`). Versões publicadas há menos de 24h são recusadas de propósito
   (`minimumReleaseAge` em `pnpm-workspace.yaml`).
3. `claude` na **raiz do repo** e aceite o diálogo de confiança. Ele lista o que o
   `.claude/settings.json` libera: as regras `allow` só valem após o aceite; `deny` e `ask` valem desde já.
4. Verifique o carregamento:
   - `/context`: o CLAUDE.md (as rules têm `paths:` e só aparecem depois que o Claude lê um arquivo
     do caminho delas; o smoke test do passo 5 carrega typescript e api)
   - `/hooks`: 5 hooks (SessionStart, 2× PreToolUse, PostToolUse, Stop)
   - `/sandbox`: sandbox ativo, sem dependências faltando
   - `/permissions`: regras allow/ask/deny · digite `/` para ver as skills
5. Smoke test do loop: peça uma mudança pequena num arquivo de `apps/api/src/`. ESLint e Prettier
   rodam sozinhos (hook), a rule de API carrega e, ao terminar, o hook `Stop` roda typecheck + testes
   relacionados.
6. **Ideia ainda crua?** Siga o [milestone 0](#milestone-0-fundação-do-projeto): `/foundation`
   entrevista você, propõe stacks para você escolher e adapta o scaffold com a sua aprovação.
   **Stack já decidida?** Resolva os `ADAPTE` (`git grep -n ADAPTE`), no mínimo: nome e descrição no
   `CLAUDE.md`, os `CLAUDE.md` dos apps, os scripts `dev`, `docs/architecture.md` e o `name` do
   `package.json`. Registre a stack com `/adr`.
7. CI com Claude (opcional): `/install-github-app` instala o app e o secret. Os workflows já estão
   aqui, com os nomes que o comando gera (`claude.yml`, `claude-code-review.yml`): se ele oferecer
   sobrescrevê-los, compare antes.
8. **Proteja a `main`** (Settings → Rules → Rulesets → New branch ruleset, alvo `main`): exija PR,
   exija o check `checks` do CI e bloqueie force push. Sem isso o CI só informa, não bloqueia. Em
   repositório privado, rulesets exigem GitHub Pro/Team.

> **Sessões na raiz, por design**: hooks e permissions carregam do `.claude/` do diretório onde a
> sessão inicia, sem fallback para os pais. Inicie sempre na raiz: CLAUDE.md aninhados, rules com
> `paths:` e skills aninhadas fazem o escopo por você. Se um dia valer iniciar dentro de um pacote,
> crie ali um `.claude/settings.json` cujos hooks apontem para os scripts da raiz; copiar o da raiz
> sem ajuste deixa os hooks sem efeito.

## O que cada peça faz

| Peça                              | Papel                                                                                                                                                  |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `CLAUDE.md` (raiz)                | Fatos que valem em toda sessão: comandos, convenções, workflow, gotchas. Alvo ≤200 linhas.                                                             |
| `apps/*/CLAUDE.md`                | Contexto do pacote; carrega sob demanda ao trabalhar nele (soma-se à raiz).                                                                            |
| `.claude/rules/*.md`              | Convenções por caminho (`paths:`): typescript, testing, api, web e harness (para quem edita o próprio harness).                                        |
| `.claude/settings.json`           | Permissões (allow/ask/deny), sandbox e registro dos hooks. Versionado; ajustes pessoais em `settings.local.json` (gitignored).                         |
| `.claude/hooks/`                  | Determinístico; veja [Hooks](#hooks). Todos têm casos em `scripts/test-hooks.sh` (roda no CI).                                                         |
| `.claude/skills/`                 | Fluxos: `/foundation`, `/spec`, `/adr`, `/fix-issue` (só você invoca) e `/commit`, `/pr` (você ou o Claude; commit, push e PR sempre pedem aprovação). |
| `.claude/agents/code-reviewer.md` | Revisor de convenções em contexto isolado, instruído a não editar. Chame com `@agent-code-reviewer`; complementa o `/code-review` (bugs).              |
| `apps/*/.claude/skills/`          | Skills por pacote (`/new-endpoint`, `/new-component`). Aparecem no `/` depois que o Claude lê um arquivo do pacote, ou já no início com `/add-dir`.    |
| `docs/`                           | `architecture.md` (vivo), `decisions/` (ADRs via `/adr`), `specs/` (via `/spec`). Referenciados por caminho, nunca `@`-importados.                     |
| `.github/`                        | `ci.yml` gateia merge (sem Claude); `claude-code-review.yml` revisa PRs (advisory); `claude.yml` responde a `@claude`; `dependabot.yml`.               |
| `.devcontainer/`                  | Ambiente padronizado com Claude Code, `gh` e sandbox. Não é isolamento: para `--dangerously-skip-permissions`, use o devcontainer **oficial**.         |
| `vitest.config.ts`                | Faz o vitest da raiz (hook `Stop`, `pnpm vitest run`) usar a config de cada pacote.                                                                    |
| `.worktreeinclude`                | Arquivos gitignored (`.env` locais) copiados para worktrees criadas pelo Claude Code. A worktree nasce sem `node_modules`: rode `pnpm install` nela.   |

### Hooks

| Hook                | Evento                                 | O que garante                                                                                                                                                                                |
| ------------------- | -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `session-start.sh`  | SessionStart                           | Avisa, só quando há problema, se falta `jq`, se faltam dependências ou se a sessão está na `main`. Roda de novo após `/clear`, retomada, fork e compactação, seguindo o `cwd` (worktree).    |
| `protect-files.sh`  | PreToolUse `Edit\|Write`               | Bloqueia edição de `.env*`, `pnpm-lock.yaml` e `.git/`.                                                                                                                                      |
| `guard-bash.sh`     | PreToolUse `Bash\|Monitor\|PowerShell` | Bloqueia `rm -r` em alvo amplo (inclusive `.git`), download canalizado para interpretador, descarte de trabalho (`checkout .`, `reset --hard`, `clean -f`, `stash drop`) e commit na `main`. |
| `check-ts.sh`       | PostToolUse `Edit\|Write`              | ESLint `--fix` + Prettier no arquivo tocado; erro de lint volta ao Claude. Marca a sessão que editou `.ts`.                                                                                  |
| `verify-on-stop.sh` | Stop                                   | Se a sessão editou `.ts`, roda typecheck + `vitest --changed`; falhou, bloqueia o 1º encerramento e devolve o erro. WIP que o Claude não tocou não dispara.                                  |

Hooks de segurança falham **fechado** sem `jq`; os de conveniência falham aberto. Os hooks seguem o
`cwd` do Claude, então funcionam também em worktrees. Mudou um hook? Acrescente o caso em
`scripts/test-hooks.sh` e rode `pnpm run test:hooks`.

## O fluxo de trabalho embutido

1. **Explorar/planejar**: plan mode (Shift+Tab). Feature grande: `/spec`, que termina com a branch e
   o prompt para a sessão nova.
2. **Implementar**: hooks e rules trabalham no fundo; o hook `Stop` bloqueia o primeiro encerramento
   com typecheck/teste quebrado e devolve o erro ao Claude (a nova tentativa não é reverificada).
3. **Revisar**: `/code-review` (bugs de corretude; `--fix` aplica) e `@agent-code-reviewer`
   (aderência a CLAUDE.md/rules; sugere candidatos a regra). Corrija os críticos.
4. **Commitar e abrir PR**: `/commit` (cria branch se estiver na `main`) → `/pr` (roda
   `pnpm run check`, faz push, abre o PR com a evidência de verificação e acompanha o CI). Commit,
   push e PR pedem aprovação.
5. `/clear` entre tarefas não relacionadas.

## Milestone 0 (fundação do projeto)

1. Repo novo, com os passos 1–5 de [Começando](#começando-um-projeto-novo) feitos
2. `/model opus`: decisões estruturais valem o custo
3. `/foundation "sua ideia em 1-2 frases"` → entrevista em fases (problema/usuário → escopo →
   restrições → stack) → `docs/product.md` → 2-3 stacks com trade-offs, você escolhe →
   `docs/decisions/001-stack.md`
4. O Claude propõe a adaptação do scaffold (`ADAPTE`s, encaixes, dependências, scripts `dev`) e só
   aplica após a sua aprovação → `/commit`
5. `/clear` e `/model sonnet` (volta ao modelo do dia a dia)
6. `/spec "Milestone 0: fundação"`: agora há convenções para seguir
7. `/clear` → cole o prompt que o `/spec` entregou → `/code-review` → `/commit` → `/pr`

## Segurança em camadas (perfil solo)

Nenhuma camada sozinha é suficiente; juntas, cobrem erro do modelo e comando indireto.

1. **Regras de permissão** (`settings.json`). Com o sandbox em auto-allow, o Bash sandboxed roda sem
   prompt: quem separa o seguro do arriscado são `ask` e `deny`.
   - **allow**: ciclo interno (scripts pnpm, vitest/tsc/eslint/prettier, git local, leitura de
     issues, PRs e CI no `gh`, docs oficiais via WebFetch).
   - **ask**: o que sai da máquina, toca supply chain ou muda o CI: `git commit/push`,
     `git branch -D`, escrita no GitHub (`gh pr create/merge/review`, `gh issue create/comment/close`,
     `gh api`, `gh release`, `gh repo`), instalar ou executar pacotes (`pnpm install/add/remove/update`,
     inclusive com `-F`/`--filter`; `pnpm dlx/create`, `npx`, `npm install/ci/exec`) e edição de
     `.github/workflows/` pela ferramenta Edit (escrita via Bash não passa por essa regra). Regra
     `ask` explícita nunca é auto-aprovada, em nenhum modo. Os demais comandos `gh` que não estão no
     allow (ex.: `gh pr comment`) também pedem aprovação, porque o `gh` roda fora do sandbox.
   - **deny**: segredos do projeto (`.env*`, `secrets/`, `*.pem`, `*.key`; o deny de leitura também
     bloqueia edição), `git push --force`/`-f` (outras formas caem no `ask` de `git push`),
     `publish` e rede crua (`curl`/`wget`; use WebFetch).
2. **Protected paths nativos**: edições em `.claude/`, `.git/`, `.devcontainer/`, `.vscode/` etc.
   pedem confirmação em Manual/acceptEdits, vão ao classificador em auto mode e só passam direto em
   `bypassPermissions`. Para revisar cada mudança no harness, não aceite a opção de liberar a pasta
   `.claude` pelo resto da sessão.
3. **Sandbox do Bash**: escrita só no projeto (+ store e cache do pnpm); rede só para
   `registry.npmjs.org` e GitHub (+ domínios do WebFetch). A leitura fora do projeto é livre por
   padrão, então `sandbox.credentials` bloqueia `~/.ssh`, `~/.aws`, `~/.config/gcloud`, `~/.kube` e
   `~/.docker/config.json` e tira do ambiente `GITHUB_TOKEN`, `GH_TOKEN`, `NPM_TOKEN` e credenciais
   AWS. ADAPTE: registry privado precisa de `NPM_TOKEN` (tire-o de `credentials.envVars`); com
   `git push` por SSH, o push sandboxed não lê `~/.ssh`, falha e é refeito fora do sandbox, com
   aprovação (ou use HTTPS). O `gh` roda fora do sandbox (`excludedCommands`, porque o TLS falha no
   macOS) quando é o comando inteiro, sem pipe nem `&&`, e passa pelas regras de permissão. No macOS, o servidor local
   (`pnpm dev`) sobe dentro do sandbox via `allowLocalBinding`; no Linux essa chave não tem efeito:
   rode o dev server num terminal seu. Domínio novo? `/sandbox` ou `sandbox.network.allowedDomains`.
4. **Hooks**: padrões que regras de prefixo não capturam (veja [Hooks](#hooks)).
5. **CI**: `ci.yml` gateia merge via ruleset da `main` (passo 8); os workflows com Claude são advisory.

Deny vence allow em qualquer escopo. Ajustes só na sua máquina: `.claude/settings.local.json`.

**Perfil de time**: `"defaultMode": "default"` (Manual; com o sandbox em auto-allow, o Bash segue sem
prompts) e `"permissions": { "disableBypassPermissionsMode": "disable" }` (de preferência em managed
settings); as regras `ask` já valem como estão. **Alternativa**: auto mode, o modo inicial do Claude Code desde
a v2.1.283 quando o projeto não fixa `defaultMode`: um classificador revisa as ações, e as regras
`ask` continuam perguntando.

## Custos de CI

- `claude-code-review.yml`: plugin oficial `code-review` com comentários inline. Uma revisão por PR
  (abertura, _ready for review_, reabertura); pula rascunhos, forks (sem o secret), bots e PRs que já
  têm comentário do Claude (revisão anterior ou resposta a um `@claude`);
  `timeout-minutes: 15` e `concurrency`. Só PRs de docs para humanos (`docs/`, `README.md`) não
  disparam: CLAUDE.md, rules, skills e workflows são revisados.
- `claude.yml`: só roda com `@claude` de quem tem acesso ao repo e nunca em PR de fork (código de
  terceiros com secrets); instala as dependências do PR para o Claude rodar lint, typecheck e testes;
  commits pela API do GitHub; `--max-turns 25`, `timeout-minutes: 30`.
- Modelo **fixado** pelo ID completo (`claude-sonnet-5-5`): aliases mudam com o tempo.
- `dependabot.yml`: actions e dependências npm, semanal e agrupado.

## Como estender (gatilhos)

| Sintoma                                         | Ação                                                                         |
| ----------------------------------------------- | ---------------------------------------------------------------------------- |
| Claude erra a mesma coisa pela 2ª vez           | Linha no `CLAUDE.md` (ou na rule, se for de uma área)                        |
| O `code-reviewer` listou um "candidato a regra" | Idem: a linha e o destino já vêm prontos                                     |
| Você cola o mesmo procedimento de novo          | Vire skill em `.claude/skills/` (`argument-hint` entre aspas)                |
| Algo deve acontecer SEMPRE                      | Hook ou lint, não instrução, com caso em `scripts/test-hooks.sh`             |
| Investigação enche o contexto                   | "use um subagent para investigar X"                                          |
| Comando precisa de um domínio novo              | `sandbox.network.allowedDomains` (não desligue o sandbox)                    |
| Instruções parecem velhas ou contraditórias     | `/doctor prompt-audit` (audita CLAUDE.md, rules, skills e agents; só propõe) |
| Segundo repositório quer este setup             | Empacote como plugin                                                         |

## Fontes

Os padrões deste harness vêm da documentação oficial do Claude Code (<https://code.claude.com/docs>):
memory/CLAUDE.md, rules, skills, hooks, permissions, permission modes, sandboxing, subagents,
monorepos, worktrees, devcontainer e GitHub Actions. O que é escolha do template, e não regra da
ferramenta, está marcado com `ADAPTE`.
