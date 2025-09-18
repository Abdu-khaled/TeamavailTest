import js from "@eslint/js";
import globals from "globals";
import { defineConfig } from "eslint/config";

export default defineConfig([
  {
    files: ["**/*.{js,mjs,cjs}"], // all JavaScript files
    languageOptions: {
      globals: {
        ...globals.node,   // allow Node.js globals (require, __dirname, etc.)
        ...globals.browser // allow browser globals (window, document, etc.)
      }
    },
    extends: [js.configs.recommended], // base recommended ESLint rules
    rules: {
      "no-unused-vars": "warn",  // unused vars = warning
      "no-undef": "error"        // undefined vars = error
    }
  }
]);
