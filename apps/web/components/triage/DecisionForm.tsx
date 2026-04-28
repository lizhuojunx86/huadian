"use client";

import { useState } from "react";
import { useFormState, useFormStatus } from "react-dom";

import {
  type DecisionActionState,
  submitDecisionAction,
} from "@/app/triage/[itemId]/actions";
import { Button } from "@/components/ui/button";
import type { TriageDecisionType } from "@/lib/graphql/generated/graphql";
import { cn } from "@/lib/utils";

const DECISIONS: Array<{ value: TriageDecisionType; label: string }> = [
  { value: "APPROVE", label: "approve" },
  { value: "REJECT", label: "reject" },
  { value: "DEFER", label: "defer" },
];

const SOURCE_TYPES = [
  { value: "in_chapter", label: "in_chapter" },
  { value: "other_classical", label: "other_classical" },
  { value: "wikidata", label: "wikidata" },
  { value: "scholarly", label: "scholarly" },
  { value: "structural", label: "structural" },
] as const;

interface QuickTemplate {
  key: string;
  label: string;
  reasonText: string;
  sourceType: (typeof SOURCE_TYPES)[number]["value"];
}

const QUICK_TEMPLATES: QuickTemplate[] = [
  {
    key: "ref-recent",
    label: "参考最近裁决",
    reasonText: "参考 [Sprint X G_id] 同 surface 已 [decision] (commit [hash])",
    sourceType: "structural",
  },
  {
    key: "in-chapter",
    label: "in_chapter",
    reasonText: '见 [章节] §[段落 id] 原文: "[quote]"',
    sourceType: "in_chapter",
  },
  {
    key: "other-classical",
    label: "other_classical",
    reasonText: "见《[书名]·[篇名]》",
    sourceType: "other_classical",
  },
  {
    key: "slug-dedup",
    label: "slug-dedup",
    reasonText: "slug 重复 (pinyin + unicode 共存清理)",
    sourceType: "structural",
  },
  {
    key: "commit-ref",
    label: "commit hash 引用",
    reasonText: "引用 commit [hash] 中的 [section/group]",
    sourceType: "structural",
  },
  {
    key: "adr-ref",
    label: "ADR 引用",
    reasonText: "per ADR-[NNN] §[X.Y]",
    sourceType: "structural",
  },
];

interface DecisionFormProps {
  itemId: string;
  suggestedDecision?: TriageDecisionType | null;
}

const INITIAL_STATE: DecisionActionState = {};

export function DecisionForm({
  itemId,
  suggestedDecision,
}: DecisionFormProps) {
  const [state, formAction] = useFormState(submitDecisionAction, INITIAL_STATE);

  const [decision, setDecision] = useState<TriageDecisionType>(
    suggestedDecision ?? "REJECT",
  );
  const [reasonSourceType, setReasonSourceType] = useState<string>("structural");
  const [reasonText, setReasonText] = useState<string>("");

  function applyTemplate(t: QuickTemplate) {
    setReasonText(t.reasonText);
    setReasonSourceType(t.sourceType);
  }

  return (
    <form
      action={formAction}
      className="space-y-4 rounded-md border border-gray-200 bg-white p-5"
      aria-label="Decision form"
    >
      <h2 className="text-base font-semibold">Decision</h2>

      <input type="hidden" name="itemId" value={itemId} />

      <fieldset className="space-y-1">
        <legend className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
          Decision
        </legend>
        <div className="flex flex-wrap gap-3">
          {DECISIONS.map(({ value, label }) => (
            <label
              key={value}
              className={cn(
                "flex cursor-pointer items-center gap-2 rounded-md border px-3 py-1.5 text-sm transition-colors",
                decision === value
                  ? "border-foreground bg-foreground text-background"
                  : "border-gray-300 bg-white hover:bg-gray-50",
              )}
            >
              <input
                type="radio"
                name="decision"
                value={value}
                checked={decision === value}
                onChange={() => setDecision(value)}
                className="sr-only"
              />
              {label}
              {suggestedDecision === value ? (
                <span className="ml-1 text-[10px] opacity-80">(建议)</span>
              ) : null}
            </label>
          ))}
        </div>
      </fieldset>

      <div className="space-y-1">
        <label
          htmlFor="reasonSourceType"
          className="text-xs font-medium uppercase tracking-wide text-muted-foreground"
        >
          Source Type
        </label>
        <select
          id="reasonSourceType"
          name="reasonSourceType"
          value={reasonSourceType}
          onChange={(e) => setReasonSourceType(e.target.value)}
          className="block w-full max-w-xs rounded-md border border-gray-300 bg-white px-3 py-1.5 text-sm focus:border-gray-500 focus:outline-none focus:ring-1 focus:ring-gray-500"
        >
          {SOURCE_TYPES.map(({ value, label }) => (
            <option key={value} value={value}>
              {label}
            </option>
          ))}
        </select>
      </div>

      <div className="space-y-1">
        <label
          htmlFor="reasonText"
          className="text-xs font-medium uppercase tracking-wide text-muted-foreground"
        >
          Reason (markdown)
        </label>
        <textarea
          id="reasonText"
          name="reasonText"
          value={reasonText}
          onChange={(e) => setReasonText(e.target.value)}
          rows={5}
          placeholder="决策理由（可用下方快捷模板预填，[X] 占位符自行替换）"
          className="block w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm focus:border-gray-500 focus:outline-none focus:ring-1 focus:ring-gray-500"
        />
      </div>

      <fieldset className="space-y-2">
        <legend className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
          Quick Templates
        </legend>
        <div className="flex flex-wrap gap-2">
          {QUICK_TEMPLATES.map((t) => (
            <Button
              key={t.key}
              type="button"
              variant="outline"
              size="sm"
              onClick={() => applyTemplate(t)}
              data-template-key={t.key}
            >
              {t.label}
            </Button>
          ))}
        </div>
      </fieldset>

      {state.error ? (
        <div className="rounded-md border border-red-300 bg-red-50 p-3 text-sm text-red-800">
          <p className="font-medium">提交失败</p>
          <p className="mt-1 text-xs">
            <span className="font-mono">{state.error.code}</span> —{" "}
            {state.error.message}
          </p>
        </div>
      ) : null}

      <SubmitButton />
    </form>
  );
}

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <Button type="submit" disabled={pending}>
      {pending ? "提交中..." : "Submit Decision"}
    </Button>
  );
}
