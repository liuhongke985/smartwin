// SmartWin E2E Test Template using Playwright
// Usage: npx playwright test tests/e2e/

import { test, expect } from '@playwright/test'

// ============================================================
// Configuration
// ============================================================
const BASE_URL = process.env.E2E_BASE_URL || 'http://localhost:5173'
const TEST_USER = {
  email: process.env.E2E_USER_EMAIL || 'test@smartwin.example.com',
  password: process.env.E2E_USER_PASSWORD || 'test_password',
}

// ============================================================
// Fixtures / Helpers
// ============================================================

/**
 * Login helper - reusable across test files
 */
async function login(page, email = TEST_USER.email, password = TEST_USER.password) {
  await page.goto(`${BASE_URL}/login`)
  await page.fill('[data-testid="email-input"]', email)
  await page.fill('[data-testid="password-input"]', password)
  await page.click('[data-testid="login-button"]')
  await page.waitForURL(`${BASE_URL}/dashboard`)
  await expect(page.locator('[data-testid="user-menu"]')).toBeVisible()
}

// ============================================================
// Test Suite: Data Asset Management
// ============================================================
test.describe('Data Asset Management', () => {

  test.beforeEach(async ({ page }) => {
    await login(page)
    await page.goto(`${BASE_URL}/data-assets`)
  })

  test('should display data asset list', async ({ page }) => {
    await expect(page.locator('[data-testid="asset-list"]')).toBeVisible()
    await expect(page.locator('[data-testid="asset-list-item"]')).toHaveCount({ min: 0 })
  })

  test('should create a new data asset', async ({ page }) => {
    // Click create button
    await page.click('[data-testid="create-asset-button"]')
    await expect(page.locator('[data-testid="create-asset-dialog"]')).toBeVisible()

    // Fill form
    await page.fill('[data-testid="asset-name-input"]', 'E2E Test Asset')
    await page.fill('[data-testid="asset-description-input"]', 'Created by E2E test')
    await page.selectOption('[data-testid="asset-category-select"]', 'test_data')

    // Submit
    await page.click('[data-testid="submit-button"]')

    // Verify success
    await expect(page.locator('[data-testid="success-message"]')).toBeVisible()
    await expect(page.locator('text=E2E Test Asset')).toBeVisible()
  })

  test('should show validation error when name is empty', async ({ page }) => {
    await page.click('[data-testid="create-asset-button"]')
    await page.click('[data-testid="submit-button"]')

    await expect(page.locator('[data-testid="name-error"]')).toBeVisible()
    await expect(page.locator('[data-testid="name-error"]')).toContainText('required')
  })

  test('should filter assets by keyword', async ({ page }) => {
    await page.fill('[data-testid="search-input"]', 'test')
    await page.keyboard.press('Enter')

    await page.waitForResponse(resp => resp.url().includes('/api/v1/data-assets'))
    // Results should reflect search
    const items = page.locator('[data-testid="asset-list-item"]')
    const count = await items.count()
    // Each visible item name should contain search term (or list may be empty)
    if (count > 0) {
      for (let i = 0; i < count; i++) {
        await expect(items.nth(i)).toContainText(/test/i)
      }
    }
  })

  test('should navigate to asset detail page', async ({ page }) => {
    const firstAsset = page.locator('[data-testid="asset-list-item"]').first()
    if (await firstAsset.isVisible()) {
      await firstAsset.click()
      await expect(page).toHaveURL(/\/data-assets\/\d+/)
      await expect(page.locator('[data-testid="asset-detail-panel"]')).toBeVisible()
    }
  })
})

// ============================================================
// Test Suite: Authentication
// ============================================================
test.describe('Authentication', () => {

  test('should redirect to login when unauthenticated', async ({ page }) => {
    await page.goto(`${BASE_URL}/data-assets`)
    await expect(page).toHaveURL(/\/login/)
  })

  test('should show error for invalid credentials', async ({ page }) => {
    await page.goto(`${BASE_URL}/login`)
    await page.fill('[data-testid="email-input"]', 'invalid@example.com')
    await page.fill('[data-testid="password-input"]', 'wrong_password')
    await page.click('[data-testid="login-button"]')

    await expect(page.locator('[data-testid="login-error"]')).toBeVisible()
  })

  test('should logout successfully', async ({ page }) => {
    await login(page)
    await page.click('[data-testid="user-menu"]')
    await page.click('[data-testid="logout-button"]')
    await expect(page).toHaveURL(/\/login/)
  })
})
