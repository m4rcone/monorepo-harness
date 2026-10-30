# Mantenha a versão do Node em sincronia com o .nvmrc (o CI lê de lá)
FROM node:24-bookworm

# jq: requisito dos hooks · bubblewrap + socat: sandbox do Claude Code no Linux
# (gh e o Claude Code CLI vêm como features no devcontainer.json)
RUN apt-get update \
  && apt-get install -y --no-install-recommends jq bubblewrap socat \
  && rm -rf /var/lib/apt/lists/*

# pnpm na versão do "packageManager", habilitado como root (o usuário node não escreve em /usr/local/bin)
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable pnpm

# Language server do plugin typescript-lsp (enabledPlugins no .claude/settings.json). Ele usa o
# TypeScript do workspace; o global é só fallback. Mantenha o major do typescript igual ao do projeto
RUN npm install -g typescript-language-server@6.0.2 typescript@6.0.3

# Em Docker sem privilégios o bubblewrap não monta um /proc novo e todo Bash sandboxed falha.
# enableWeakerNestedSandbox reaproveita o /proc do container, que passa a ser a fronteira de
# isolamento. /etc/claude-code/managed-settings.json é o caminho das managed settings no Linux.
RUN mkdir -p /etc/claude-code \
  && echo '{"sandbox":{"enableWeakerNestedSandbox":true}}' >/etc/claude-code/managed-settings.json

# Ponto de montagem do volume de ~/.claude (devcontainer.json): sem isto o Docker o cria como root
RUN mkdir -p /home/node/.claude && chown node:node /home/node/.claude

USER node
