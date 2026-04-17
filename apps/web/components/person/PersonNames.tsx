import type { PersonQuery } from "@/lib/graphql/generated/graphql";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";

type PersonName = NonNullable<PersonQuery["person"]>["names"][number];

const nameTypeLabels: Record<string, string> = {
  primary: "本名",
  courtesy: "字",
  art: "号",
  studio: "斋号",
  posthumous: "谥号",
  temple: "庙号",
  nickname: "绰号",
  self_ref: "自称",
  alias: "别名",
};

interface PersonNamesProps {
  names: PersonName[];
}

export function PersonNames({ names }: PersonNamesProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-lg">别名与称号</CardTitle>
      </CardHeader>
      <CardContent>
        {names.length === 0 ? (
          <p className="text-sm text-muted-foreground">暂无别名记录</p>
        ) : (
          <div className="space-y-3">
            {names.map((n) => (
              <div
                key={n.id}
                className="flex flex-wrap items-center gap-2 rounded-md border p-3"
              >
                <span className="font-medium">{n.name}</span>
                {n.namePinyin && (
                  <span className="text-sm text-muted-foreground">
                    {n.namePinyin}
                  </span>
                )}
                <Badge variant="secondary" className="text-xs">
                  {nameTypeLabels[n.nameType] ?? n.nameType}
                </Badge>
                {n.isPrimary && (
                  <Badge variant="default" className="text-xs">
                    主要
                  </Badge>
                )}
                {(n.startYear != null || n.endYear != null) && (
                  <span className="text-xs text-muted-foreground">
                    {n.startYear ?? "?"} ~ {n.endYear ?? "?"}
                  </span>
                )}
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
