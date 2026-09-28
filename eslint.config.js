// ESLint flat config do monorepo. ADAPTE as rules: o hook check-ts.sh roda `eslint --fix`
// a cada edição do Claude, então o que estiver aqui vale durante as sessões.
import js from "@eslint/js";
import { defineConfig, globalIgnores } from "eslint/config";
import tseslint from "typescript-eslint";

export default defineConfig(
  // O ESLint não lê o .gitignore: sem .claude/worktrees/, `eslint .` lintaria o WIP de outras sessões
  globalIgnores(["**/dist/", "**/coverage/", ".claude/worktrees/"]),
  js.configs.recommended,
  tseslint.configs.recommended,
  {
    rules: {
      "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
      "@typescript-eslint/consistent-type-imports": "error",
    },
  },
);
