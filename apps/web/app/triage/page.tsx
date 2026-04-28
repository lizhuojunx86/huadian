import type { Metadata } from "next";

import { SurfaceCluster } from "@/components/triage/SurfaceCluster";
import { TriagePagination } from "@/components/triage/TriagePagination";
import { TriageTabs } from "@/components/triage/TriageTabs";
import { graphqlClient } from "@/lib/graphql/client";
import {
  PendingTriageItemsDocument,
  type PendingTriageItemsQuery,
  type TriageItemTypeFilter,
} from "@/lib/graphql/generated/graphql";
import { getHistorianFromCookie } from "@/lib/historian";

export const metadata: Metadata = {
  title: "Triage Queue — 华典智谱",
  description:
    "Historian triage queue for pending seed mappings and guard-blocked merges.",
  robots: { index: false, follow: false },
};

const PAGE_SIZE = 50;

interface TriagePageProps {
  searchParams: { type?: string; surface?: string; page?: string };
}

type Item = PendingTriageItemsQuery["pendingTriageItems"]["items"][number];

function parseTypeFilter(raw?: string): TriageItemTypeFilter {
  if (raw === "SEED_MAPPING") return "SEED_MAPPING";
  if (raw === "GUARD_BLOCKED_MERGE") return "GUARD_BLOCKED_MERGE";
  return "ALL";
}

function groupBySurface(items: Item[]): Array<{ surface: string; items: Item[] }> {
  // BE already orders items by surface cluster + FIFO; FE preserves order
  // and only groups consecutive same-surface runs (Map iteration order also
  // preserves insertion order, so any encountered surface stays in original
  // position even if a duplicate appears later).
  const groups = new Map<string, Item[]>();
  for (const item of items) {
    const arr = groups.get(item.surface) ?? [];
    arr.push(item);
    groups.set(item.surface, arr);
  }
  return Array.from(groups, ([surface, items]) => ({ surface, items }));
}

export default async function TriagePage({ searchParams }: TriagePageProps) {
  const historian = getHistorianFromCookie();
  const filterByType = parseTypeFilter(searchParams.type);
  const filterBySurface = searchParams.surface || undefined;
  const page = Math.max(1, parseInt(searchParams.page ?? "1", 10) || 1);
  const offset = (page - 1) * PAGE_SIZE;

  const data = await graphqlClient.request(PendingTriageItemsDocument, {
    limit: PAGE_SIZE,
    offset,
    filterByType,
    filterBySurface,
  });

  const { items, totalCount } = data.pendingTriageItems;
  const clusters = groupBySurface(items as Item[]);

  return (
    <div className="mx-auto max-w-4xl px-4 py-8">
      <header className="mb-6">
        <h1 className="text-2xl font-bold">Triage Queue</h1>
        <p className="mt-1 text-sm text-muted-foreground">
          historian:{" "}
          <span className="font-mono">{historian?.id ?? "unknown"}</span>
          {historian?.displayName ? ` · ${historian.displayName}` : null}
        </p>
      </header>

      <TriageTabs activeType={filterByType} />

      {filterBySurface ? (
        <p className="mt-3 text-xs text-muted-foreground">
          surface filter: <span className="font-mono">{filterBySurface}</span>
        </p>
      ) : null}

      <div className="mt-4 flex flex-col gap-3">
        {clusters.length === 0 ? (
          <EmptyState filterByType={filterByType} />
        ) : (
          clusters.map((cluster, idx) => (
            <SurfaceCluster
              key={cluster.surface}
              surface={cluster.surface}
              items={cluster.items}
              defaultOpen={idx === 0}
            />
          ))
        )}
      </div>

      <TriagePagination
        total={totalCount}
        pageSize={PAGE_SIZE}
        currentPage={page}
      />
    </div>
  );
}

function EmptyState({ filterByType }: { filterByType: TriageItemTypeFilter }) {
  const label =
    filterByType === "SEED_MAPPING"
      ? "Seed Mapping"
      : filterByType === "GUARD_BLOCKED_MERGE"
        ? "Guard Block"
        : "";
  return (
    <div className="rounded-md border border-dashed border-gray-300 bg-gray-50 p-8 text-center text-sm text-muted-foreground">
      <p className="font-medium">Queue empty</p>
      <p className="mt-1">
        {label
          ? `没有 pending 的 ${label} 项。`
          : "没有 pending 项 — 全部已 triage 完毕。"}
      </p>
    </div>
  );
}
