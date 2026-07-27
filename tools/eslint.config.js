export default [
  {
    files: ["**/*.{js,mjs,cjs,ts,tsx,vue}"],
    ignores: ["node_modules/**", "dist/**"],
    rules: {
      "no-unused-vars": "warn",
      "no-undef": "error"
    }
  }
];
