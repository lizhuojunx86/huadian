import { Badge } from "@/components/ui/badge";
import type { TriageItemQuery } from "@/lib/graphql/generated/graphql";

import { HighlightText } from "./HighlightText";

type Item = NonNullable<TriageItemQuery["triageItem"]>;

interface ItemDetailProps {
  item: Item;
}

export function ItemDetail({ item }: ItemDetailProps) {
  return (
    <section
      aria-label="Triage item detail"
      className="rounded-md border border-gray-200 bg-white p-5"
    >
      <header className="mb-4 flex flex-wrap items-center gap-2">
        {item.__typename === "SeedMappingTriage" ? (
          <Badge variant="secondary">Seed Mapping</Badge>
        ) : item.__typename === "GuardBlockedMergeTriage" ? (
          <Badge variant="destructive">Guard Block</Badge>
        ) : (
          <Badge variant="outline">Unknown</Badge>
        )}
        <Badge variant="outline" className="text-xs">
          {item.provenanceTier}
        </Badge>
        <span className="text-xs text-muted-foreground">
          surface=<span className="font-mono">{item.surface}</span>
        </span>
        {item.suggestedDecision ? (
          <Badge variant="outline" className="text-xs">
            建议: {item.suggestedDecision.toLowerCase()}
          </Badge>
        ) : null}
      </header>

      {item.__typename === "SeedMappingTriage" ? (
        <SeedMappingDetail item={item} />
      ) : item.__typename === "GuardBlockedMergeTriage" ? (
        <GuardBlockedMergeDetail item={item} />
      ) : (
        <p className="text-sm text-muted-foreground">
          Unknown triage item type. FE codegen out of sync with BE schema?
        </p>
      )}
    </section>
  );
}

function SeedMappingDetail({
  item,
}: {
  item: Extract<Item, { __typename: "SeedMappingTriage" }>;
}) {
  return (
    <dl className="grid gap-2 text-sm sm:grid-cols-[max-content_1fr] sm:gap-x-4">
      <DT>Surface</DT>
      <DD className="font-mono">{item.surface}</DD>

      <DT>Target Person</DT>
      <DD>
        {item.targetPerson.name.zhHans}
        {item.targetPerson.name.en ? (
          <span className="ml-1 text-muted-foreground">
            ({item.targetPerson.name.en})
          </span>
        ) : null}{" "}
        <span className="text-xs text-muted-foreground">
          slug={item.targetPerson.slug}
          {item.targetPerson.dynasty ? ` · ${item.targetPerson.dynasty}` : ""} ·{" "}
          {item.targetPerson.realityStatus}
        </span>
      </DD>

      {item.targetPerson.biography?.zhHans ? (
        <>
          <DT>Biography</DT>
          <DD>
            <HighlightText
              text={item.targetPerson.biography.zhHans}
              needle={item.surface}
              className="text-muted-foreground"
            />
          </DD>
        </>
      ) : null}

      <DT>Mapping</DT>
      <DD>
        confidence={item.confidence.toFixed(3)} · method={item.mappingMethod}
      </DD>

      <DT>Dictionary Entry</DT>
      <DD>
        <span className="font-medium">
          {item.dictionaryEntry.primaryName ?? "—"}
        </span>{" "}
        <span className="text-xs text-muted-foreground">
          ({item.dictionaryEntry.externalId} · {item.dictionaryEntry.entryType} ·
          source={item.dictionaryEntry.source.sourceName} v
          {item.dictionaryEntry.source.sourceVersion} ·{" "}
          license={item.dictionaryEntry.source.license})
        </span>
      </DD>

      {item.mappingMetadata ? (
        <>
          <DT>Mapping Metadata</DT>
          <DD>
            <JsonBlock value={item.mappingMetadata} highlight={item.surface} />
          </DD>
        </>
      ) : null}

      {item.dictionaryEntry.aliases ? (
        <>
          <DT>Aliases</DT>
          <DD>
            <JsonBlock
              value={item.dictionaryEntry.aliases}
              highlight={item.surface}
            />
          </DD>
        </>
      ) : null}

      <DT>Attributes</DT>
      <DD>
        <JsonBlock
          value={item.dictionaryEntry.attributes}
          highlight={item.surface}
        />
      </DD>
    </dl>
  );
}

function GuardBlockedMergeDetail({
  item,
}: {
  item: Extract<Item, { __typename: "GuardBlockedMergeTriage" }>;
}) {
  return (
    <dl className="grid gap-2 text-sm sm:grid-cols-[max-content_1fr] sm:gap-x-4">
      <DT>Surface</DT>
      <DD className="font-mono">{item.surface}</DD>

      <DT>Person A</DT>
      <DD>
        {item.personA.name.zhHans}
        {item.personA.name.en ? (
          <span className="ml-1 text-muted-foreground">
            ({item.personA.name.en})
          </span>
        ) : null}{" "}
        <span className="text-xs text-muted-foreground">
          slug={item.personA.slug}
          {item.personA.dynasty ? ` · ${item.personA.dynasty}` : ""} ·{" "}
          {item.personA.realityStatus}
        </span>
      </DD>

      <DT>Person B</DT>
      <DD>
        {item.personB.name.zhHans}
        {item.personB.name.en ? (
          <span className="ml-1 text-muted-foreground">
            ({item.personB.name.en})
          </span>
        ) : null}{" "}
        <span className="text-xs text-muted-foreground">
          slug={item.personB.slug}
          {item.personB.dynasty ? ` · ${item.personB.dynasty}` : ""} ·{" "}
          {item.personB.realityStatus}
        </span>
      </DD>

      <DT>Proposed Rule</DT>
      <DD>{item.proposedRule}</DD>

      <DT>Guard Type</DT>
      <DD>
        <code className="text-xs">{item.guardType}</code>
      </DD>

      <DT>Guard Payload</DT>
      <DD>
        <JsonBlock value={item.guardPayload} highlight={item.surface} />
      </DD>

      <DT>Evidence</DT>
      <DD>
        <JsonBlock value={item.evidence} highlight={item.surface} />
      </DD>
    </dl>
  );
}

function DT({ children }: { children: React.ReactNode }) {
  return (
    <dt className="text-xs font-medium uppercase tracking-wide text-muted-foreground sm:pt-0.5">
      {children}
    </dt>
  );
}

function DD({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return <dd className={className}>{children}</dd>;
}

function JsonBlock({
  value,
  highlight,
}: {
  value: unknown;
  highlight: string;
}) {
  const text = JSON.stringify(value, null, 2);
  return (
    <pre className="max-h-64 overflow-auto rounded-md border border-gray-200 bg-gray-50 p-3 text-xs leading-relaxed">
      <code>
        <HighlightText text={text} needle={highlight} />
      </code>
    </pre>
  );
}
