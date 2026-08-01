// ESLint flat config compartilhado do monorepo. ADAPTE as rules ao seu gosto —
// mas lembre: o hook check-ts.sh roda `eslint --fix` a cada edição do Claude,
// então regras daqui são aplicadas automaticamente durante as sessões.
import js from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  { ignores: ["**/dist/**", "**/coverage/**", "**/node_modules/**"] },
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    rules: {
      "@typescript-eslint/no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
      "@typescript-eslint/consistent-type-imports": "error",
    },
  },
);
