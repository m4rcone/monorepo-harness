// O vitest rodado da raiz (hook Stop, `pnpm vitest run <arquivo>`) usa a config de cada pacote,
// a mesma do `pnpm -F <pacote> test`. O `pnpm run test` também roda daqui: pacote com outro runner
// (Playwright, node:test) precisa entrar no script `test` da raiz.
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: { projects: ["apps/*", "packages/*"] },
});
