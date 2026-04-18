import Link from "next/link";

import { Badge } from "@/components/ui/badge";

interface PersonListItemProps {
  person: {
    slug: string;
    name: { zhHans: string; en?: string | null };
    dynasty?: string | null;
    realityStatus: string;
    provenanceTier: string;
  };
}

export function PersonListItem({ person }: PersonListItemProps) {
  return (
    <Link
      href={`/persons/${person.slug}`}
      className="block rounded-md border border-gray-200 px-4 py-3 transition-colors hover:bg-gray-50"
    >
      <div className="flex items-center justify-between gap-2">
        <div className="min-w-0 flex-1">
          <h3 className="truncate text-base font-medium text-gray-900">
            {person.name.zhHans}
          </h3>
          {person.name.en && (
            <p className="truncate text-sm text-gray-500">{person.name.en}</p>
          )}
        </div>
        <div className="flex shrink-0 items-center gap-2">
          {person.dynasty && (
            <Badge variant="outline" className="text-xs">
              {person.dynasty}
            </Badge>
          )}
          {person.realityStatus !== "historical" && (
            <Badge variant="secondary" className="text-xs">
              {person.realityStatus}
            </Badge>
          )}
        </div>
      </div>
    </Link>
  );
}
