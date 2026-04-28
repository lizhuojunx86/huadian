import { Badge } from "@/components/ui/badge";
import type { TriageDecisionsForSurfaceQuery } from "@/lib/graphql/generated/graphql";
import {
  formatDate,
  formatDecisionLabel,
  summarizeDecisions,
} from "@/lib/triage-format";

type Decision = TriageDecisionsForSurfaceQuery["triageDecisionsForSurface"][number];

interface HintBannerProps {
  surface: string;
  decisions: Decision[];
}

export function HintBanner({ surface, decisions }: HintBannerProps) {
  if (decisions.length === 0) {
    return (
      <section
        aria-label="Cross-sprint hint banner"
        className="rounded-md border border-gray-200 bg-gray-50 p-4 text-sm text-muted-foreground"
      >
        无该 surface 的跨 sprint 历史决策记录（首次 triage）。
      </section>
    );
  }

  const summary = summarizeDecisions(decisions);
  const consistencyPct = Math.round(summary.consistency * 100);

  // Sort by decidedAt DESC so the most recent ruling is first; capped to
  // first 6 to keep banner concise (full list is server-side via the query
  // limit param, default 10).
  const sorted = [...decisions].sort(
    (a, b) => new Date(b.decidedAt).getTime() - new Date(a.decidedAt).getTime(),
  );
  const visible = sorted.slice(0, 6);

  return (
    <section
      aria-label="Cross-sprint hint banner"
      className="rounded-md border border-blue-200 bg-blue-50 p-4"
    >
      <div className="mb-3 flex flex-wrap items-center gap-2">
        <h2 className="text-sm font-semibold text-blue-900">
          同 surface{" "}
          <span className="font-mono">&quot;{surface}&quot;</span>{" "}
          历史决策 ({summary.total} 次)
        </h2>
        {summary.dominantDecision ? (
          <Badge variant={summary.consistency >= 0.99 ? "default" : "secondary"}>
            {summary.total === 1
              ? `${formatDecisionLabel(summary.dominantDecision)} (单次)`
              : summary.consistency >= 0.99
                ? `${summary.total}/${summary.total} ${formatDecisionLabel(summary.dominantDecision)} (高一致性)`
                : `${formatDecisionLabel(summary.dominantDecision)} 占多数 (${consistencyPct}%)`}
          </Badge>
        ) : null}
      </div>

      <ul className="space-y-1 text-sm">
        {visible.map((d) => (
          <li key={d.id} className="flex flex-wrap items-baseline gap-1.5">
            <span className="font-mono text-xs text-blue-700">
              {formatDate(d.decidedAt)}
            </span>
            <Badge
              variant={
                d.decision === "APPROVE"
                  ? "default"
                  : d.decision === "REJECT"
                    ? "destructive"
                    : "secondary"
              }
              className="text-[10px]"
            >
              {formatDecisionLabel(d.decision)}
            </Badge>
            <span className="text-xs text-blue-900">by {d.historianId}</span>
            {d.historianCommitRef ? (
              <span className="font-mono text-[10px] text-blue-700">
                ({d.historianCommitRef.slice(0, 7)})
              </span>
            ) : null}
            {d.reasonText ? (
              <span className="ml-1 truncate text-xs text-blue-900">
                — {d.reasonText}
              </span>
            ) : null}
          </li>
        ))}
        {sorted.length > visible.length ? (
          <li className="text-xs text-blue-700">
            ... 另 {sorted.length - visible.length} 条历史决策（query limit 已截）
          </li>
        ) : null}
      </ul>
    </section>
  );
}
