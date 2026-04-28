// ⚠️ Generated/mirrored from apps/web/lib/historian-allowlist.yaml.
// If updating, edit the YAML first then sync this .ts file.
//
// Why both files:
// - YAML is the human-readable source of truth (git blame friendly)
// - Next.js middleware runs in edge runtime which cannot import .yaml at
//   request time (no fs / no yaml loader without webpack rewrite). This .ts
//   mirror is consumed by middleware.ts and any server-side validator.
//
// V2 SSO upgrade path: replace allowlist check with SSO assertion; this
// mirror file is then deleted along with the YAML.

export interface HistorianEntry {
  id: string;
  displayName: string;
}

export const HISTORIAN_ALLOWLIST: readonly HistorianEntry[] = [
  { id: "chief-historian", displayName: "Chief Historian (default)" },
  { id: "backfill-script", displayName: "Historical Backfill Script (system)" },
  { id: "e2e-test", displayName: "E2E Test Account (Playwright smoke)" },
] as const;

const ALLOWED_IDS = new Set(HISTORIAN_ALLOWLIST.map((h) => h.id));

export function isAllowedHistorian(id: string | null | undefined): boolean {
  if (!id) return false;
  return ALLOWED_IDS.has(id);
}

export function findHistorian(id: string): HistorianEntry | undefined {
  return HISTORIAN_ALLOWLIST.find((h) => h.id === id);
}
