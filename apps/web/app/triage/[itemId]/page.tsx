import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";

import { DecisionForm } from "@/components/triage/DecisionForm";
import { HintBanner } from "@/components/triage/HintBanner";
import { ItemDetail } from "@/components/triage/ItemDetail";
import { buttonVariants } from "@/components/ui/button";
import { graphqlClient } from "@/lib/graphql/client";
import {
  TriageDecisionsForSurfaceDocument,
  TriageItemDocument,
} from "@/lib/graphql/generated/graphql";
import { getHistorianFromCookie } from "@/lib/historian";

export const metadata: Metadata = {
  title: "Triage Item — 华典智谱",
  robots: { index: false, follow: false },
};

interface TriageItemPageProps {
  params: { itemId: string };
}

async function fetchItem(id: string) {
  try {
    const data = await graphqlClient.request(TriageItemDocument, { id });
    return data.triageItem ?? null;
  } catch {
    return null;
  }
}

async function fetchDecisionsForSurface(surface: string) {
  try {
    const data = await graphqlClient.request(
      TriageDecisionsForSurfaceDocument,
      { surface, limit: 10 },
    );
    return data.triageDecisionsForSurface ?? [];
  } catch {
    return [];
  }
}

export default async function TriageItemPage({ params }: TriageItemPageProps) {
  const itemId = decodeURIComponent(params.itemId);
  const historian = getHistorianFromCookie();

  const item = await fetchItem(itemId);
  if (!item) notFound();

  const decisions = await fetchDecisionsForSurface(item.surface);

  return (
    <div className="mx-auto max-w-4xl space-y-5 px-4 py-8">
      <header className="flex flex-wrap items-center justify-between gap-2">
        <Link
          href="/triage"
          className={buttonVariants({ variant: "outline", size: "sm" })}
        >
          ← Back to queue
        </Link>
        <p className="text-sm text-muted-foreground">
          historian:{" "}
          <span className="font-mono">{historian?.id ?? "unknown"}</span>
        </p>
      </header>

      <HintBanner surface={item.surface} decisions={decisions} />

      <ItemDetail item={item} />

      <DecisionForm
        itemId={item.id}
        suggestedDecision={item.suggestedDecision ?? null}
      />
    </div>
  );
}
