// ESLint flat config do monorepo. ADAPTE as rules: o hook check-ts.sh roda `eslint --fix`
// a cada edição do Claude, então o que estiver aqui vale durante as sessões.
import js from "@eslint/js";
import { defineConfig, globalIgnores } from "eslint/config";
import tseslint from "typescript-eslint";

export default defineConfig(
  // O ESLint não lê o .gitignore: sem .claude/worktrees/, `eslint .` lintaria o WIP de outras sessões
  globalIgnores(["**/dist/", "**/coverage/", ".claude/worktrees/"]),
  js.configs.recommended,
  // Com type info: pega `await` esquecido (no-floating-promises), promise passada onde se espera
  // função síncrona (no-misused-promises) e `throw` de algo que não é Error (only-throw-error).
  // Cada .ts precisa estar no `include` de um tsconfig.json (o projectService usa o mais próximo).
  tseslint.configs.recommendedTypeChecked,
  {
    languageOptions: {
      parserOptions: { projectService: true, tsconfigRootDir: import.meta.dirname },
    },
  },
  { files: ["**/*.js", "**/*.mjs", "**/*.cjs"], extends: [tseslint.configs.disableTypeChecked] },
  {
    files: ["**/*.ts", "**/*.tsx", "**/*.mts", "**/*.cts"],
    rules: {
      "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
      "@typescript-eslint/consistent-type-imports": "error",
      // Tipo de retorno explícito em exports: o lint garante, por isso fora de .claude/rules/typescript.md
      "@typescript-eslint/explicit-module-boundary-types": "error",
    },
  },
);
