FROM node:22-bookworm

# jq é requisito dos hooks do harness; gh habilita /fix-issue e PRs
RUN apt-get update \
  && apt-get install -y --no-install-recommends jq gh git \
  && rm -rf /var/lib/apt/lists/*

USER node
