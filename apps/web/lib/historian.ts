import { cookies } from "next/headers";

import {
  findHistorian,
  isAllowedHistorian,
  type HistorianEntry,
} from "./historian-allowlist";

export const HISTORIAN_COOKIE_NAME = "historian_id";

/**
 * Read the historian id from the request cookie. Server-side only (RSC /
 * Server Action). Returns null if cookie absent or value not in allowlist.
 *
 * Middleware (apps/web/middleware.ts) guards the /triage segment, so under
 * normal flow this should always return a valid entry on /triage routes.
 * Outside /triage the cookie is not set; callers must handle null.
 */
export function getHistorianFromCookie(): HistorianEntry | null {
  const cookieValue = cookies().get(HISTORIAN_COOKIE_NAME)?.value;
  if (!isAllowedHistorian(cookieValue)) return null;
  return findHistorian(cookieValue!) ?? null;
}

/**
 * Like getHistorianFromCookie but throws if the cookie is missing or invalid.
 * Use inside Server Actions for /triage mutations where the middleware
 * guarantee should hold; the throw acts as defense-in-depth.
 */
export function requireHistorian(): HistorianEntry {
  const entry = getHistorianFromCookie();
  if (!entry) {
    throw new Error(
      "historian cookie missing or not in allowlist; middleware should have redirected to ?historian= flow",
    );
  }
  return entry;
}
