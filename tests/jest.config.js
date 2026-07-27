// SmartWin Jest Configuration for Vue 3 + TypeScript Frontend Tests
/** @type {import('jest').Config} */
export default {
  // Test environment
  testEnvironment: 'jsdom',

  // Transform configuration
  transform: {
    '^.+\\.vue$': '@vue/vue3-jest',
    '^.+\\.[jt]sx?$': 'babel-jest',
  },

  // Module file extensions
  moduleFileExtensions: ['js', 'jsx', 'ts', 'tsx', 'vue', 'json'],

  // Module name mapping (matches Vite aliases)
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '\\.(css|scss|sass|less)$': 'identity-obj-proxy',
    '\\.(jpg|jpeg|png|gif|svg|ico)$': '<rootDir>/tests/__mocks__/fileMock.js',
  },

  // Setup files
  setupFilesAfterFramework: ['<rootDir>/tests/setup.ts'],

  // Coverage configuration
  collectCoverageFrom: [
    'src/**/*.{js,ts,vue}',
    '!src/main.ts',
    '!src/router/index.ts',
    '!src/**/*.d.ts',
    '!src/**/__tests__/**',
    '!src/**/index.ts',
  ],

  coverageThresholds: {
    global: {
      branches: 70,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },

  coverageReporters: ['text', 'lcov', 'html'],
  coverageDirectory: 'coverage',

  // Test file patterns
  testMatch: [
    '**/__tests__/**/*.[jt]s?(x)',
    '**/?(*.)+(spec|test).[jt]s?(x)',
  ],

  testPathIgnorePatterns: [
    '/node_modules/',
    '/dist/',
    '/e2e/',
  ],

  // Globals
  globals: {
    'vue-jest': {
      compilerOptions: {
        isCustomElement: (tag) => tag.startsWith('el-'),
      },
    },
  },

  // Verbose output
  verbose: true,

  // Timeout
  testTimeout: 10000,
}
