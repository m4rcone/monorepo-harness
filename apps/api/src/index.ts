// ADAPTE: ponto de entrada real da API (Fastify/Hono/Express...).
// Este stub existe para o loop completo do harness (hooks, testes, CI) nascer verde.

export interface Health {
  status: "ok";
}

export function healthcheck(): Health {
  return { status: "ok" };
}
