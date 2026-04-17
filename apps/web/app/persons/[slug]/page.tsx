import type { Metadata } from "next";
import { notFound } from "next/navigation";

import { PersonCard } from "@/components/person/PersonCard";
import { graphqlClient } from "@/lib/graphql/client";
import { PersonDocument } from "@/lib/graphql/generated/graphql";

interface PersonPageProps {
  params: { slug: string };
}

async function fetchPerson(slug: string) {
  try {
    const data = await graphqlClient.request(PersonDocument, { slug });
    return data.person ?? null;
  } catch {
    return null;
  }
}

export async function generateMetadata({ params }: PersonPageProps): Promise<Metadata> {
  const person = await fetchPerson(params.slug);
  if (!person) {
    return { title: "人物未找到 — 华典智谱" };
  }

  const description = person.biography?.zhHans
    ? person.biography.zhHans.slice(0, 160)
    : `${person.name.zhHans} — 华典智谱人物详情`;

  return {
    title: `${person.name.zhHans} — 华典智谱`,
    description,
  };
}

export default async function PersonPage({ params }: PersonPageProps) {
  const person = await fetchPerson(params.slug);

  if (!person) {
    notFound();
  }

  return <PersonCard person={person} />;
}
