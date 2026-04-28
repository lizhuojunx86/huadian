"use server";

import { redirect } from "next/navigation";

import { graphqlClient } from "@/lib/graphql/client";
import {
  RecordTriageDecisionDocument,
  type TriageDecisionType,
} from "@/lib/graphql/generated/graphql";
import { requireHistorian } from "@/lib/historian";

export interface DecisionActionState {
  error?: { code: string; message: string };
}

const DECISION_VALUES: ReadonlySet<TriageDecisionType> = new Set([
  "APPROVE",
  "REJECT",
  "DEFER",
]);

function isDecision(value: unknown): value is TriageDecisionType {
  return typeof value === "string" && DECISION_VALUES.has(value as TriageDecisionType);
}

export async function submitDecisionAction(
  _prevState: DecisionActionState,
  formData: FormData,
): Promise<DecisionActionState> {
  const itemId = String(formData.get("itemId") ?? "").trim();
  if (!itemId) {
    return {
      error: { code: "ITEM_NOT_FOUND", message: "missing itemId in form data" },
    };
  }

  const rawDecision = formData.get("decision");
  if (!isDecision(rawDecision)) {
    return {
      error: {
        code: "INVALID_TRANSITION",
        message: "decision must be APPROVE | REJECT | DEFER",
      },
    };
  }

  const reasonText = String(formData.get("reasonText") ?? "").trim() || null;
  const reasonSourceType =
    String(formData.get("reasonSourceType") ?? "").trim() || null;

  let historianId: string;
  try {
    historianId = requireHistorian().id;
  } catch {
    return {
      error: {
        code: "UNAUTHORIZED",
        message: "historian cookie missing — visit /triage?historian=<id>",
      },
    };
  }

  const data = await graphqlClient.request(RecordTriageDecisionDocument, {
    input: {
      itemId,
      decision: rawDecision,
      reasonText,
      reasonSourceType,
      historianId,
    },
  });

  const payload = data.recordTriageDecision;
  if (payload.error) {
    return { error: payload.error };
  }

  const next = payload.nextPendingItemId;
  redirect(next ? `/triage/${encodeURIComponent(next)}` : "/triage");
}
