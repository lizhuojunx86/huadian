import { test, expect } from "@playwright/test";

/**
 * E2E tests for homepage and global navigation.
 *
 * Prerequisites:
 * - API server running at localhost:4000 (services/api)
 * - PostgreSQL with seeded person data
 * - Web dev server running at localhost:3000
 */

test.describe("Homepage", () => {
  test("displays featured person cards @smoke", async ({ page }) => {
    await page.goto("/");

    // Should display site title in hero
    await expect(
      page.getByRole("heading", { name: "华典智谱" }),
    ).toBeVisible();

    // Should display at least one featured person card
    await expect(page.getByRole("heading", { name: "知名人物" })).toBeVisible();
    await expect(page.locator("a[href^='/persons/']").first()).toBeVisible();
  });

  test("search form navigates to /persons with query @smoke", async ({
    page,
  }) => {
    await page.goto("/");

    const searchInput = page.getByPlaceholder(/搜索人物/);
    await searchInput.fill("黄帝");
    await searchInput.press("Enter");

    await page.waitForURL(/\/persons\?search=/);
    expect(page.url()).toContain("search=%E9%BB%84%E5%B8%9D");
  });

  test("about link navigates to /about @smoke", async ({ page }) => {
    await page.goto("/");

    // Click the "关于" link in the header navigation
    await page.getByRole("link", { name: "关于" }).click();

    await page.waitForURL("/about");
    await expect(
      page.getByRole("heading", { name: "关于华典智谱" }),
    ).toBeVisible();
  });
});
