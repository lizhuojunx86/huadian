import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import type { PersonQuery } from "@/lib/graphql/generated/graphql";

type IdentityHypothesis = NonNullable<PersonQuery["person"]>["identityHypotheses"][number];

const relationTypeLabels: Record<string, string> = {
  same_person: "同一人物",
  possibly_same: "可能同一",
  conflated: "混淆",
  distinct_despite_similar_name: "同名异人",
};

interface PersonHypothesesProps {
  hypotheses: IdentityHypothesis[];
}

export function PersonHypotheses({ hypotheses }: PersonHypothesesProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-lg">身份假说</CardTitle>
      </CardHeader>
      <CardContent>
        {hypotheses.length === 0 ? (
          <p className="text-sm text-muted-foreground">暂无身份假说</p>
        ) : (
          <div className="space-y-3">
            {hypotheses.map((h) => (
              <div key={h.id} className="rounded-md border p-3 space-y-2">
                <div className="flex flex-wrap items-center gap-2">
                  <Badge variant="outline">
                    {relationTypeLabels[h.relationType] ?? h.relationType}
                  </Badge>
                  {h.acceptedByDefault && (
                    <Badge variant="default" className="text-xs">
                      默认接受
                    </Badge>
                  )}
                </div>
                {h.scholarlySupport && (
                  <p className="text-sm">
                    <span className="font-medium text-muted-foreground">学术支持：</span>
                    {h.scholarlySupport}
                  </p>
                )}
                {h.notes && (
                  <p className="text-sm text-muted-foreground">{h.notes}</p>
                )}
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
