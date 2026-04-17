import { test, expect } from "@playwright/test";

/**
 * E2E smoke tests for /persons/[slug] route.
 *
 * Prerequisites:
 * - API server running at localhost:4000 (services/api)
 * - PostgreSQL with seeded person data (at least liu-bang)
 * - Web dev server running at localhost:3000
 */

test.describe("Person Card Page", () => {
  test("displays person data for valid slug @smoke", async ({ page }) => {
    await page.goto("/persons/liu-bang");

    // Should display the person's Chinese name
    await expect(page.locator("h3").first()).toContainText("刘邦");

    // Should have at least one name entry in the names section
    await expect(page.getByText("别名与称号")).toBeVisible();
  });

  test("shows 404 for nonexistent slug @smoke", async ({ page }) => {
    await page.goto("/persons/nonexistent-person-slug");

    // Should display not-found page
    await expect(page.getByText("人物未找到")).toBeVisible();
  });
});
