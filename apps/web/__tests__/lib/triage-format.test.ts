import { describe, expect, it } from "vitest";

import {
  formatDecisionLabel,
  provenanceTierLabel,
  provenanceTierVariant,
  summarizeDecisions,
} from "@/lib/triage-format";

describe("provenanceTierLabel", () => {
  it("renders unverified as 未验证 (T-P1-032 Stage 4b ruling Option A)", () => {
    expect(provenanceTierLabel("unverified")).toBe("未验证");
  });

  it("maps the remaining 4 enum values to Chinese labels matching PersonCard", () => {
    expect(provenanceTierLabel("primary_text")).toBe("原始文献");
    expect(provenanceTierLabel("scholarly_consensus")).toBe("学术共识");
    expect(provenanceTierLabel("ai_inferred")).toBe("AI 推断");
    expect(provenanceTierLabel("crowdsourced")).toBe("众包");
  });
});

describe("provenanceTierVariant", () => {
  it("uses destructive for unverified (visual警示 mirrors PersonCard)", () => {
    expect(provenanceTierVariant("unverified")).toBe("destructive");
  });

  it("maps remaining tiers to PersonCard-aligned Badge variants", () => {
    expect(provenanceTierVariant("primary_text")).toBe("default");
    expect(provenanceTierVariant("scholarly_consensus")).toBe("secondary");
    expect(provenanceTierVariant("ai_inferred")).toBe("outline");
    expect(provenanceTierVariant("crowdsourced")).toBe("outline");
  });
});

describe("formatDecisionLabel", () => {
  it("renders three known decision values", () => {
    expect(formatDecisionLabel("APPROVE")).toBe("approve");
    expect(formatDecisionLabel("REJECT")).toBe("reject");
    expect(formatDecisionLabel("DEFER")).toBe("defer");
  });
});

describe("summarizeDecisions", () => {
  it("returns zero summary for empty input", () => {
    const s = summarizeDecisions([]);
    expect(s.total).toBe(0);
    expect(s.dominantDecision).toBeNull();
    expect(s.consistency).toBe(0);
  });

  it("identifies dominant decision and consistency ratio", () => {
    const s = summarizeDecisions([
      { decision: "REJECT" },
      { decision: "REJECT" },
      { decision: "REJECT" },
      { decision: "APPROVE" },
    ]);
    expect(s.total).toBe(4);
    expect(s.reject).toBe(3);
    expect(s.approve).toBe(1);
    expect(s.dominantDecision).toBe("REJECT");
    expect(s.consistency).toBeCloseTo(0.75, 2);
  });

  it("flags 100% consistency when all decisions agree", () => {
    const s = summarizeDecisions([
      { decision: "REJECT" },
      { decision: "REJECT" },
    ]);
    expect(s.consistency).toBe(1);
    expect(s.dominantDecision).toBe("REJECT");
  });
});
