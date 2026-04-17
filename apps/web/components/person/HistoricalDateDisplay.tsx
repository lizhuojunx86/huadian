import type { PersonQuery } from "@/lib/graphql/generated/graphql";

type HistoricalDate = NonNullable<
  NonNullable<PersonQuery["person"]>["birthDate"]
>;

interface HistoricalDateDisplayProps {
  date: HistoricalDate;
  label: string;
}

/**
 * Format a year number for display.
 * Negative years → "公元前 X 年", positive → "公元 X 年" or just "X 年".
 */
export function formatYear(year: number): string {
  if (year < 0) {
    return `公元前 ${Math.abs(year)} 年`;
  }
  return `${year} 年`;
}

/**
 * Format a HistoricalDate for display.
 * Priority: originalText > yearMin~yearMax range > yearMin alone.
 */
export function formatHistoricalDate(date: HistoricalDate): string {
  if (date.originalText) {
    return date.originalText;
  }

  if (date.yearMin != null && date.yearMax != null && date.yearMin !== date.yearMax) {
    return `${formatYear(date.yearMin)} ~ ${formatYear(date.yearMax)}`;
  }

  if (date.yearMin != null) {
    return formatYear(date.yearMin);
  }

  if (date.yearMax != null) {
    return formatYear(date.yearMax);
  }

  return "不详";
}

export function HistoricalDateDisplay({ date, label }: HistoricalDateDisplayProps) {
  return (
    <div className="flex items-baseline gap-2">
      <span className="text-sm font-medium text-muted-foreground">{label}</span>
      <span className="text-sm">{formatHistoricalDate(date)}</span>
      {date.reignEra && (
        <span className="text-xs text-muted-foreground">
          （{date.reignEra}
          {date.reignYear != null && ` ${date.reignYear} 年`}）
        </span>
      )}
    </div>
  );
}
