---
name: pr
description: Faz push da branch atual e abre o PR com resumo, evidência de verificação e vínculo com spec/issue. Use depois do commit, quando pedirem para abrir o PR.
argument-hint: "[#issue | docs/specs/<slug>.md]"
---

<!-- Push e `gh pr create` pedem aprovação (regras ask do settings.json). O gh só roda fora do
     sandbox (onde o TLS funciona no macOS) quando é o comando inteiro: sem pipe, &&, heredoc ou $(...). -->

Abra o PR da branch atual. Referência (opcional): $ARGUMENTS

1. Pare se estiver na `main` ou se `git status --short` não estiver vazio: sugira a skill `commit`
2. `pnpm run check` (os mesmos passos do CI) e guarde o resultado; falhou → corrija e commite antes
3. `git push -u origin HEAD`
4. Escreva o corpo com a ferramenta Write num arquivo fora do repo (o scratchpad da sessão):
   - **O quê e por quê**: 2-4 linhas
   - **Referência**: `Closes #N` ou o caminho do spec
   - **Como verifiquei**: comandos rodados e resultado
   - **Riscos / fora de escopo**

   Depois rode, como comando único: `gh pr create --title "<tipo(escopo): resumo do conjunto>" --body-file <caminho absoluto>`

5. Mostre o link do PR. Acompanhe o CI com `gh pr checks --watch` em background; se falhar,
   `gh run view <id> --log-failed` (sem pipe) e proponha a correção
