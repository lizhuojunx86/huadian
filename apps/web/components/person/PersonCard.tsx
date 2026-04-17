import type { PersonQuery } from "@/lib/graphql/generated/graphql";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { HistoricalDateDisplay } from "./HistoricalDateDisplay";
import { PersonNames } from "./PersonNames";
import { PersonHypotheses } from "./PersonHypotheses";

type Person = NonNullable<PersonQuery["person"]>;

const provenanceTierLabels: Record<string, string> = {
  primary_text: "原始文献",
  scholarly_consensus: "学术共识",
  ai_inferred: "AI 推断",
  crowdsourced: "众包",
  unverified: "未验证",
};

const provenanceTierVariants: Record<string, "default" | "secondary" | "destructive" | "outline"> = {
  primary_text: "default",
  scholarly_consensus: "secondary",
  ai_inferred: "outline",
  crowdsourced: "outline",
  unverified: "destructive",
};

const realityStatusLabels: Record<string, string> = {
  historical: "历史人物",
  legendary: "传说人物",
  mythical: "神话人物",
  fictional: "虚构人物",
  composite: "复合身份",
  uncertain: "待考",
};

interface PersonCardProps {
  person: Person;
}

export function PersonCard({ person }: PersonCardProps) {
  return (
    <div className="mx-auto max-w-3xl space-y-6 p-4 md:p-8">
      <Card>
        <CardHeader>
          <div className="flex flex-wrap items-start justify-between gap-2">
            <div>
              <CardTitle className="text-3xl">{person.name.zhHans}</CardTitle>
              {person.name.en && (
                <p className="mt-1 text-lg text-muted-foreground">{person.name.en}</p>
              )}
            </div>
            <div className="flex flex-wrap gap-2">
              <Badge variant={provenanceTierVariants[person.provenanceTier] ?? "outline"}>
                {provenanceTierLabels[person.provenanceTier] ?? person.provenanceTier}
              </Badge>
              <Badge variant="secondary">
                {realityStatusLabels[person.realityStatus] ?? person.realityStatus}
              </Badge>
            </div>
          </div>
          {person.dynasty && (
            <p className="text-sm text-muted-foreground">朝代：{person.dynasty}</p>
          )}
        </CardHeader>
        <CardContent className="space-y-4">
          {/* Dates */}
          <div className="space-y-1">
            {person.birthDate && (
              <HistoricalDateDisplay date={person.birthDate} label="生" />
            )}
            {person.deathDate && (
              <HistoricalDateDisplay date={person.deathDate} label="卒" />
            )}
          </div>

          {/* Biography */}
          {person.biography?.zhHans && (
            <div className="space-y-2">
              <h4 className="text-sm font-medium text-muted-foreground">简介</h4>
              <div className="prose prose-sm max-w-none">
                <p>{person.biography.zhHans}</p>
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Names section */}
      <PersonNames names={person.names} />

      {/* Identity hypotheses section */}
      <PersonHypotheses hypotheses={person.identityHypotheses} />
    </div>
  );
}
