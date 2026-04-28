import { expect, test } from "@playwright/test";

/**
 * E2E tests for /triage UI (Sprint K T-P0-028).
 *
 * Prerequisites:
 * - API server running at localhost:4000 (services/api with migration 0014
 *   applied + triage resolvers loaded per Sprint K BE Stage 2)
 * - PostgreSQL with at least zero pending triage rows (queue-empty path is
 *   exercised; non-zero pending rows are exercised opportunistically)
 * - Web dev server running at localhost:3000
 *
 * Auth: tests use the e2e-test allowlist entry (apps/web/lib/historian-allowlist.yaml).
 *
 * Coverage (per Stage 1 design doc §6 + brief S3.7):
 * 1. Auth gate — 401 without token, 307+cookie with valid query token, 200
 *    after cookie set (entire flow without dependence on backend data).
 * 2. List page renders queue + Tabs filter selection works (depends on API
 *    being up; resilient to either populated queue or empty-state body).
 * 3. Queue-empty edge — surface filter that cannot match yields the
 *    EmptyState block (depends on API).
 *
 * Notes:
 * - Inbox flow (decision submission + nextPendingItemId redirect) is not
 *   covered in V1 e2e because it mutates DB state; deferred to Hist E2E
 *   stage 5 with PE-backfilled data + dedicated rollback fixture (Sprint K
 *   Stage 5).
 */

const HISTORIAN_ID = "e2e-test";

test.describe("Triage UI — auth gate", () => {
  test("rejects unauthenticated request to /triage @smoke", async ({
    request,
  }) => {
    const res = await request.get("/triage", { maxRedirects: 0 });
    expect(res.status()).toBe(401);
    const body = await res.text();
    expect(body).toContain("Unauthorized");
    expect(body).toContain(HISTORIAN_ID);
  });

  test("rejects unauthenticated request to /triage/[itemId] @smoke", async ({
    request,
  }) => {
    const res = await request.get("/triage/some-fake-id", {
      maxRedirects: 0,
    });
    expect(res.status()).toBe(401);
  });

  test("rejects invalid token without falling through to cookie @smoke", async ({
    request,
  }) => {
    const res = await request.get("/triage?historian=not-in-allowlist", {
      maxRedirects: 0,
    });
    expect(res.status()).toBe(401);
  });

  test("valid query token sets cookie and redirects to /triage @smoke", async ({
    request,
  }) => {
    const res = await request.get(`/triage?historian=${HISTORIAN_ID}`, {
      maxRedirects: 0,
    });
    expect(res.status()).toBe(307);
    expect(res.headers()["location"]).toContain("/triage");
    expect(res.headers()["location"]).not.toContain("historian=");
    const setCookie = res.headers()["set-cookie"];
    expect(setCookie).toContain("historian_id=" + HISTORIAN_ID);
    expect(setCookie).toContain("HttpOnly");
    expect(setCookie).toContain("Path=/triage");
  });
});

test.describe("Triage UI — authenticated flow", () => {
  test.beforeEach(async ({ context }) => {
    await context.addCookies([
      {
        name: "historian_id",
        value: HISTORIAN_ID,
        domain: "localhost",
        path: "/triage",
        httpOnly: true,
        sameSite: "Lax",
      },
    ]);
  });

  test("list page renders queue header + tabs + (cluster | empty)", async ({
    page,
  }) => {
    await page.goto("/triage");

    await expect(page.getByRole("heading", { name: "Triage Queue" })).toBeVisible();
    await expect(page.getByText("historian:")).toBeVisible();
    await expect(page.getByText(HISTORIAN_ID)).toBeVisible();

    // Tab nav exists with three known labels.
    await expect(page.getByRole("link", { name: "全部" })).toBeVisible();
    await expect(page.getByRole("link", { name: "Seed Mappings" })).toBeVisible();
    await expect(page.getByRole("link", { name: "Guard Blocks" })).toBeVisible();

    // Either at least one cluster (<details>) renders or EmptyState is
    // visible. Both are valid V1 outcomes depending on backfill state.
    const clusterCount = await page.locator("details").count();
    if (clusterCount === 0) {
      await expect(page.getByText("Queue empty")).toBeVisible();
    } else {
      await expect(page.locator("details").first()).toBeVisible();
    }
  });

  test("filter to a non-existent surface yields empty state", async ({
    page,
  }) => {
    await page.goto("/triage?surface=__never_a_real_surface_zzzzzz__");

    await expect(page.getByText("Queue empty")).toBeVisible();
    await expect(
      page.getByText("__never_a_real_surface_zzzzzz__"),
    ).toBeVisible();
  });

  test("Tabs filter Seed Mappings → URL ?type=SEED_MAPPING", async ({
    page,
  }) => {
    await page.goto("/triage");
    await page.getByRole("link", { name: "Seed Mappings" }).click();
    await page.waitForURL(/\/triage\?type=SEED_MAPPING/);
    expect(page.url()).toContain("type=SEED_MAPPING");
  });
});
