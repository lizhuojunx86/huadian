import type { Metadata } from "next";

import { getHistorianFromCookie } from "@/lib/historian";

export const metadata: Metadata = {
  title: "Triage Item — 华典智谱",
  robots: { index: false, follow: false },
};

interface TriageItemPageProps {
  params: { itemId: string };
}

// Stage 3 placeholder. Real detail page (per design doc §3.2 wireframe)
// implemented in S3.5+S3.6 once BE GraphQL SDL ships. Sections to come:
// - Hint Banner (triageDecisionsForSurface query)
// - Item Detail (union switch on __typename)
// - Decision Form with 6 quick templates + Server Action

export default function TriageItemPage({ params }: TriageItemPageProps) {
  const historian = getHistorianFromCookie();

  return (
    <div className="mx-auto max-w-3xl px-4 py-8">
      <h1 className="mb-2 text-2xl font-bold">Triage Item</h1>
      <p className="mb-1 text-sm text-muted-foreground">
        item id: <span className="font-mono">{params.itemId}</span>
      </p>
      <p className="mb-6 text-sm text-muted-foreground">
        historian: <span className="font-mono">{historian?.id ?? "unknown"}</span>
      </p>

      <div className="rounded-md border border-dashed border-gray-300 bg-gray-50 p-6 text-sm text-gray-600">
        <p className="font-medium">Scaffold placeholder (S3.2c)</p>
        <p className="mt-2">
          Detail page implementation gated on BE GraphQL SDL ready signal
          (S3.3+S3.5+S3.6). When SDL ships, this page renders triageItem
          query result with hint banner, item detail union switch, and
          decision form (6 quick templates) per design doc §3.2 / §3.3.
        </p>
      </div>
    </div>
  );
}
