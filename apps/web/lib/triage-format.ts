// Shared formatting helpers for triage UI (list + detail).

import type {
  ProvenanceTier,
  TriageDecisionType,
} from "./graphql/generated/graphql";

// ProvenanceTier enum mapping. Keys mirror the 5 enum values declared in
// services/api/src/schema/enums.graphql + apps/web/components/person/
// PersonCard.tsx (T-P1-032 will unify into a single source-of-truth
// module; until then triage UI consumes via these helpers and PersonCard
// keeps its own inline copy intentionally — see Sprint K Stage 4b
// architect ruling on Option A "状态描述符 vs 行动指令" semantics).

const PROVENANCE_TIER_LABEL: Record<ProvenanceTier, string> = {
  primary_text: "原始文献",
  scholarly_consensus: "学术共识",
  ai_inferred: "AI 推断",
  crowdsourced: "众包",
  unverified: "未验证",
};

const PROVENANCE_TIER_VARIANT: Record<
  ProvenanceTier,
  "default" | "secondary" | "destructive" | "outline"
> = {
  primary_text: "default",
  scholarly_consensus: "secondary",
  ai_inferred: "outline",
  crowdsourced: "outline",
  unverified: "destructive",
};

export function provenanceTierLabel(tier: ProvenanceTier): string {
  return PROVENANCE_TIER_LABEL[tier] ?? tier;
}

export function provenanceTierVariant(
  tier: ProvenanceTier,
): "default" | "secondary" | "destructive" | "outline" {
  return PROVENANCE_TIER_VARIANT[tier] ?? "outline";
}

const DECISION_LABEL: Record<TriageDecisionType, string> = {
  APPROVE: "approve",
  REJECT: "reject",
  DEFER: "defer",
};

export function formatDecisionLabel(decision: TriageDecisionType): string {
  return DECISION_LABEL[decision] ?? decision;
}

/**
 * Render an ISO datetime as a coarse Chinese relative label
 * ('3 天前' / '2 月前'). Caller should pass the source ISO directly.
 */
export function formatRelativeDate(iso: string): string {
  const ms = Date.now() - new Date(iso).getTime();
  if (ms < 0) return "刚刚";
  const minutes = Math.floor(ms / 60_000);
  if (minutes < 60) return minutes <= 1 ? "刚刚" : `${minutes} 分钟前`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours} 小时前`;
  const days = Math.floor(hours / 24);
  if (days < 30) return `${days} 天前`;
  const months = Math.floor(days / 30);
  if (months < 12) return `${months} 月前`;
  const years = Math.floor(months / 12);
  return `${years} 年前`;
}

/**
 * Format an ISO datetime as YYYY-MM-DD (UTC) for compact stable display.
 */
export function formatDate(iso: string): string {
  return new Date(iso).toISOString().slice(0, 10);
}

interface DecisionSummary {
  total: number;
  approve: number;
  reject: number;
  defer: number;
  dominantDecision: TriageDecisionType | null;
  consistency: number; // 0..1 ratio of dominantDecision over total
}

export function summarizeDecisions(
  decisions: ReadonlyArray<{ decision: TriageDecisionType }>,
): DecisionSummary {
  const total = decisions.length;
  if (total === 0) {
    return {
      total: 0,
      approve: 0,
      reject: 0,
      defer: 0,
      dominantDecision: null,
      consistency: 0,
    };
  }

  let approve = 0;
  let reject = 0;
  let defer = 0;
  for (const d of decisions) {
    if (d.decision === "APPROVE") approve++;
    else if (d.decision === "REJECT") reject++;
    else if (d.decision === "DEFER") defer++;
  }

  const counts: Array<[TriageDecisionType, number]> = [
    ["APPROVE", approve],
    ["REJECT", reject],
    ["DEFER", defer],
  ];
  counts.sort((a, b) => b[1] - a[1]);
  const top = counts[0]!;
  const dominantDecision = top[1] > 0 ? top[0] : null;
  const consistency = dominantDecision ? top[1] / total : 0;

  return { total, approve, reject, defer, dominantDecision, consistency };
}
