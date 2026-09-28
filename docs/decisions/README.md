# ADRs — registros de decisão arquitetural

Um ADR por decisão **arquitetural e consequente** (fila de eventos, estratégia
de auth, cache, versionamento de API...). Mudança pequena não vira ADR.

- Gerar: `/adr <decisão em uma frase>`, que usa `.claude/skills/adr/template.md`
- Numeração sequencial com 3 dígitos: `001-stack.md` (criado pelo `/foundation`), `002-...`
- ADR não se edita depois de aceito: uma decisão nova o substitui (status `substituída por NNN`)
- A REGRA resultante vai em 1 linha no `CLAUDE.md` ou numa rule, citando o ADR.
  O ADR guarda o porquê; o CLAUDE.md guarda a regra.
