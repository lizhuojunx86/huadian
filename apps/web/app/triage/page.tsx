import type { Metadata } from "next";

import { getHistorianFromCookie } from "@/lib/historian";

export const metadata: Metadata = {
  title: "Triage Queue — 华典智谱",
  description:
    "Historian triage queue for pending seed mappings and guard-blocked merges.",
  robots: { index: false, follow: false },
};

// Stage 3 placeholder. Real list page (per design doc §3.1 wireframe) is
// implemented in S3.4 once BE GraphQL SDL ships and codegen syncs typed
// documents to lib/graphql/generated/. Until then this stub proves the
// route + middleware + cookie pipeline.

export default function TriagePage() {
  const historian = getHistorianFromCookie();

  return (
    <div className="mx-auto max-w-3xl px-4 py-8">
      <h1 className="mb-2 text-2xl font-bold">Triage Queue</h1>
      <p className="mb-6 text-sm text-muted-foreground">
        historian: <span className="font-mono">{historian?.id ?? "unknown"}</span>
        {historian?.displayName ? ` (${historian.displayName})` : null}
      </p>

      <div className="rounded-md border border-dashed border-gray-300 bg-gray-50 p-6 text-sm text-gray-600">
        <p className="font-medium">Scaffold placeholder (S3.2c)</p>
        <p className="mt-2">
          List page implementation gated on BE GraphQL SDL ready signal
          (S3.3+S3.4). When SDL ships, this page renders pendingTriageItems
          query results with surface-cluster grouping per design doc §3.1.
        </p>
      </div>
    </div>
  );
}
