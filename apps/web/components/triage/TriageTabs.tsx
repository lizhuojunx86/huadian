import Link from "next/link";

import { cn } from "@/lib/utils";

const TABS = [
  { key: "ALL", label: "全部" },
  { key: "SEED_MAPPING", label: "Seed Mappings" },
  { key: "GUARD_BLOCKED_MERGE", label: "Guard Blocks" },
] as const;

type TabKey = (typeof TABS)[number]["key"];

interface TriageTabsProps {
  activeType: TabKey;
  counts?: Partial<Record<TabKey, number>>;
}

export function TriageTabs({ activeType, counts }: TriageTabsProps) {
  return (
    <nav
      className="flex gap-1 border-b border-gray-200"
      aria-label="Triage type filter"
    >
      {TABS.map(({ key, label }) => {
        const active = key === activeType;
        const href = key === "ALL" ? "/triage" : `/triage?type=${key}`;
        const count = counts?.[key];
        return (
          <Link
            key={key}
            href={href}
            className={cn(
              "-mb-px border-b-2 px-4 py-2 text-sm font-medium transition-colors",
              active
                ? "border-foreground text-foreground"
                : "border-transparent text-muted-foreground hover:text-foreground",
            )}
            aria-current={active ? "page" : undefined}
          >
            {label}
            {count !== undefined ? (
              <span className="ml-1 text-xs text-muted-foreground">
                ({count})
              </span>
            ) : null}
          </Link>
        );
      })}
    </nav>
  );
}
