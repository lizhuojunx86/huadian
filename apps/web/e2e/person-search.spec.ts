import { test, expect } from "@playwright/test";

/**
 * E2E smoke tests for /persons search/list route.
 *
 * Prerequisites:
 * - API server running at localhost:4000 (services/api)
 * - PostgreSQL with seeded person data
 * - Web dev server running at localhost:3000
 */

test.describe("Person Search/List Page", () => {
  test("displays person list and search bar @smoke", async ({ page }) => {
    await page.goto("/persons");

    // Should display page title
    await expect(page.getByRole("heading", { name: "人物搜索" })).toBeVisible();

    // Should display search input
    await expect(page.getByPlaceholder(/搜索人物/)).toBeVisible();

    // Should display at least one person link
    await expect(page.locator("a[href^='/persons/']").first()).toBeVisible();
  });

  test("shows empty result for nonexistent search @smoke", async ({ page }) => {
    await page.goto("/persons?search=xyzzynonexistent");

    // Should display empty result message
    await expect(page.getByText(/未找到/)).toBeVisible();
  });
});
