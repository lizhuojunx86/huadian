import Link from "next/link";

import { Badge } from "@/components/ui/badge";
import { buttonVariants } from "@/components/ui/button";
import type { PendingTriageItemsQuery } from "@/lib/graphql/generated/graphql";
import { formatRelativeDate, summarizeDecisions } from "@/lib/triage-format";

type Item = PendingTriageItemsQuery["pendingTriageItems"]["items"][number];

interface TriageCardProps {
  item: Item;
}

export function TriageCard({ item }: TriageCardProps) {
  const summary = summarizeDecisions(item.historicalDecisions);

  return (
    <article className="rounded-md border border-gray-200 bg-white p-4">
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0 flex-1 space-y-2">
          <div className="flex flex-wrap items-center gap-2">
            <TypeBadge typename={item.__typename} />
            <span className="text-xs text-muted-foreground">
              pending {formatRelativeDate(item.pendingSince)}
            </span>
            {summary.total > 0 ? (
              <HintBadge summary={summary} />
            ) : null}
          </div>

          {item.__typename === "SeedMappingTriage" ? (
            <SeedMappingSummary item={item} />
          ) : item.__typename === "GuardBlockedMergeTriage" ? (
            <GuardBlockedMergeSummary item={item} />
          ) : (
            <UnknownTypeSummary />
          )}
        </div>

        <Link
          href={`/triage/${encodeURIComponent(item.id)}`}
          className={buttonVariants({ size: "sm", variant: "outline" })}
          aria-label={`Triage ${item.surface}`}
        >
          Triage →
        </Link>
      </div>
    </article>
  );
}

function TypeBadge({ typename }: { typename: Item["__typename"] }) {
  if (typename === "SeedMappingTriage") {
    return <Badge variant="secondary">Seed Mapping</Badge>;
  }
  if (typename === "GuardBlockedMergeTriage") {
    return <Badge variant="destructive">Guard Block</Badge>;
  }
  return <Badge variant="outline">Unknown</Badge>;
}

function HintBadge({
  summary,
}: {
  summary: ReturnType<typeof summarizeDecisions>;
}) {
  const dom = summary.dominantDecision;
  if (!dom) return null;
  const consistency = Math.round(summary.consistency * 100);
  const label =
    summary.consistency >= 0.99
      ? `跨 sprint 历史 ${summary.total} 次一致 ${dom.toLowerCase()}`
      : `跨 sprint ${summary.total} 次（${dom.toLowerCase()} ${consistency}%）`;
  return (
    <Badge variant="outline" className="text-xs">
      {label}
    </Badge>
  );
}

function SeedMappingSummary({
  item,
}: {
  item: Extract<Item, { __typename: "SeedMappingTriage" }>;
}) {
  return (
    <div className="space-y-1 text-sm">
      <p>
        <span className="text-muted-foreground">→</span>{" "}
        <span className="font-medium">
          {item.dictionaryEntry.primaryName ?? item.dictionaryEntry.externalId}
        </span>{" "}
        <span className="text-muted-foreground">
          ({item.dictionaryEntry.externalId} · {item.dictionaryEntry.source.sourceName})
        </span>{" "}
        <span className="text-xs text-muted-foreground">
          conf={item.confidence.toFixed(2)} · {item.mappingMethod}
        </span>
      </p>
      <p className="text-xs text-muted-foreground">
        target: {item.targetPerson.name.zhHans}
        {item.targetPerson.dynasty ? ` (${item.targetPerson.dynasty})` : ""}
      </p>
    </div>
  );
}

function GuardBlockedMergeSummary({
  item,
}: {
  item: Extract<Item, { __typename: "GuardBlockedMergeTriage" }>;
}) {
  return (
    <div className="space-y-1 text-sm">
      <p>
        <span className="font-medium">A:</span> {item.personA.name.zhHans}
        {item.personA.dynasty ? ` (${item.personA.dynasty})` : ""}{" "}
        <span className="text-muted-foreground">↔</span>{" "}
        <span className="font-medium">B:</span> {item.personB.name.zhHans}
        {item.personB.dynasty ? ` (${item.personB.dynasty})` : ""}
      </p>
      <p className="text-xs text-muted-foreground">
        rule={item.proposedRule} · guard={item.guardType}
      </p>
    </div>
  );
}

function UnknownTypeSummary() {
  return (
    <p className="text-sm text-muted-foreground">
      Unknown triage item type — fallback render.
    </p>
  );
}
