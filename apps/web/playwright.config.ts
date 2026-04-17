import { defineConfig, devices } from "@playwright/test";

/**
 * Playwright E2E config for @huadian/web.
 *
 * Prerequisites: API server (services/api) + DB must be running with
 * seeded data. See T-P0-008 task card for details.
 *
 * Run: pnpm --filter @huadian/web test:e2e
 */
export default defineConfig({
  testDir: "./e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: "html",
  use: {
    baseURL: "http://localhost:3000",
    trace: "on-first-retry",
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
  ],
  webServer: {
    command: "pnpm dev",
    url: "http://localhost:3000",
    reuseExistingServer: !process.env.CI,
    timeout: 30_000,
  },
});
