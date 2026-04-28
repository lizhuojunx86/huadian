import { NextResponse, type NextRequest } from "next/server";

import {
  HISTORIAN_ALLOWLIST,
  isAllowedHistorian,
} from "@/lib/historian-allowlist";

// V1 simplified auth for /triage segment (per ADR-027 §2.4 + Stage 1
// design doc §4). URL token (?historian=<id>) is exchanged for a 30-day
// httpOnly cookie. Subsequent requests on /triage/* read the cookie via
// next/headers cookies() in RSC and Server Actions.
//
// Edge runtime constraint: this middleware runs in edge runtime by default
// (next.js 14). YAML import is not available here, so we consume the .ts
// mirror at apps/web/lib/historian-allowlist.ts (synced from .yaml).
//
// V2 upgrade path: replace this middleware body with an SSO assertion call;
// the cookie protocol stays. The allowlist files (yaml + ts mirror) retire.

const HISTORIAN_QUERY = "historian";
const HISTORIAN_COOKIE = "historian_id";
const COOKIE_MAX_AGE_SECONDS = 30 * 24 * 60 * 60;

const UNAUTHORIZED_BODY =
  "Unauthorized: visit /triage?historian=<your-id>\n\n" +
  `Allowed ids: ${HISTORIAN_ALLOWLIST.map((h) => h.id).join(", ")}\n`;

export function middleware(request: NextRequest) {
  const url = request.nextUrl.clone();
  const tokenFromQuery = url.searchParams.get(HISTORIAN_QUERY);
  const tokenFromCookie = request.cookies.get(HISTORIAN_COOKIE)?.value;

  // Path A: query token present and valid → set cookie, strip query, redirect.
  if (tokenFromQuery && isAllowedHistorian(tokenFromQuery)) {
    url.searchParams.delete(HISTORIAN_QUERY);
    const response = NextResponse.redirect(url);
    response.cookies.set(HISTORIAN_COOKIE, tokenFromQuery, {
      httpOnly: true,
      sameSite: "lax",
      maxAge: COOKIE_MAX_AGE_SECONDS,
      path: "/triage",
    });
    return response;
  }

  // Path B: query token present but invalid → 401 (don't fall through to
  // cookie check; explicit invalid token is a hard fail to surface typos).
  if (tokenFromQuery && !isAllowedHistorian(tokenFromQuery)) {
    return new NextResponse(UNAUTHORIZED_BODY, {
      status: 401,
      headers: { "content-type": "text/plain; charset=utf-8" },
    });
  }

  // Path C: no query token → cookie must be present and valid.
  if (isAllowedHistorian(tokenFromCookie)) {
    return NextResponse.next();
  }

  // Path D: no query, no/invalid cookie → 401.
  return new NextResponse(UNAUTHORIZED_BODY, {
    status: 401,
    headers: { "content-type": "text/plain; charset=utf-8" },
  });
}

export const config = {
  matcher: "/triage/:path*",
};
