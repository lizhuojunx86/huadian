import { PersonListItem } from "./PersonListItem";

interface PersonListProps {
  persons: Array<{
    id: string;
    slug: string;
    name: { zhHans: string; en?: string | null };
    dynasty?: string | null;
    realityStatus: string;
    provenanceTier: string;
  }>;
  search?: string;
}

export function PersonList({ persons, search }: PersonListProps) {
  if (persons.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-12 text-center text-gray-500">
        <p className="text-lg">
          {search ? `未找到与"${search}"相关的人物` : "暂无人物数据"}
        </p>
        <p className="mt-2 text-sm">
          {search ? "请尝试其他关键词，或使用拼音、别名搜索" : ""}
        </p>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-2">
      {persons.map((person) => (
        <PersonListItem key={person.id} person={person} />
      ))}
    </div>
  );
}
