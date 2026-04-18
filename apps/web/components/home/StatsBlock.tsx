import { Card, CardContent } from "@/components/ui/card";

interface StatsBlockProps {
  personsCount: number;
  namesCount: number;
  booksCount: number;
}

const STAT_LABELS = [
  { key: "personsCount", label: "历史人物" },
  { key: "namesCount", label: "人物别名" },
  { key: "booksCount", label: "典籍来源" },
] as const;

export function StatsBlock({ personsCount, namesCount, booksCount }: StatsBlockProps) {
  const values = { personsCount, namesCount, booksCount };

  return (
    <div className="grid gap-4 sm:grid-cols-3">
      {STAT_LABELS.map(({ key, label }) => (
        <Card key={key}>
          <CardContent className="flex flex-col items-center py-6">
            <span className="text-3xl font-bold">{values[key]}</span>
            <span className="mt-1 text-sm text-muted-foreground">{label}</span>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
