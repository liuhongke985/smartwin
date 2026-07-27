// SmartWin Prettier Configuration
/** @type {import("prettier").Config} */
export default {
  // Basic formatting
  printWidth: 100,
  tabWidth: 2,
  useTabs: false,
  semi: false,
  singleQuote: true,
  quoteProps: 'as-needed',
  jsxSingleQuote: false,
  trailingComma: 'es5',
  bracketSpacing: true,
  bracketSameLine: false,
  arrowParens: 'always',
  endOfLine: 'lf',

  // Vue specific
  vueIndentScriptAndStyle: false,
  singleAttributePerLine: false,

  // File-specific overrides
  overrides: [
    {
      files: ['*.json', '*.yml', '*.yaml'],
      options: {
        tabWidth: 2,
      },
    },
    {
      files: ['*.md'],
      options: {
        printWidth: 80,
        proseWrap: 'always',
      },
    },
    {
      files: ['*.vue'],
      options: {
        printWidth: 100,
      },
    },
  ],
};
