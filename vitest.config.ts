// O vitest rodado da raiz (hook Stop, `pnpm vitest run <arquivo>`) usa a config de cada pacote,
// a mesma do `pnpm -F <pacote> test`.
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: { projects: ["apps/*", "packages/*"] },
});
