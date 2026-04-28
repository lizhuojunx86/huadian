import type { PendingTriageItemsQuery } from "@/lib/graphql/generated/graphql";

import { TriageCard } from "./TriageCard";

type Item = PendingTriageItemsQuery["pendingTriageItems"]["items"][number];

interface SurfaceClusterProps {
  surface: string;
  items: Item[];
  defaultOpen?: boolean;
}

export function SurfaceCluster({
  surface,
  items,
  defaultOpen = false,
}: SurfaceClusterProps) {
  return (
    <details
      open={defaultOpen}
      className="rounded-md border border-gray-200 bg-gray-50 open:bg-white"
    >
      <summary className="cursor-pointer select-none px-4 py-3 text-sm font-medium hover:bg-gray-100">
        Surface: <span className="font-mono">{surface}</span>{" "}
        <span className="ml-1 text-xs font-normal text-muted-foreground">
          ({items.length} {items.length > 1 ? "items" : "item"})
        </span>
      </summary>
      <div className="flex flex-col gap-2 border-t border-gray-200 p-3">
        {items.map((item) => (
          <TriageCard key={item.id} item={item} />
        ))}
      </div>
    </details>
  );
}
