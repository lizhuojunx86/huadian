import type { Metadata } from "next";
import { Suspense } from "react";

import { Pagination } from "@/components/person-search/Pagination";
import { PersonList } from "@/components/person-search/PersonList";
import { SearchBar } from "@/components/person-search/SearchBar";
import { graphqlClient } from "@/lib/graphql/client";
import { PersonsSearchDocument } from "@/lib/graphql/generated/graphql";

const PAGE_SIZE = 20;

export const metadata: Metadata = {
  title: "人物搜索 — 华典智谱",
  description: "搜索和浏览中国古籍中的历史人物",
};

interface PersonsPageProps {
  searchParams: { search?: string; page?: string };
}

async function fetchPersons(search?: string, page?: number) {
  const offset = ((page ?? 1) - 1) * PAGE_SIZE;
  const data = await graphqlClient.request(PersonsSearchDocument, {
    search: search || null,
    limit: PAGE_SIZE,
    offset,
  });
  return data.persons;
}

export default async function PersonsPage({ searchParams }: PersonsPageProps) {
  const search = searchParams.search ?? "";
  const page = Math.max(1, parseInt(searchParams.page ?? "1", 10) || 1);

  const result = await fetchPersons(search || undefined, page);

  return (
    <main className="mx-auto max-w-3xl px-4 py-8">
      <h1 className="mb-6 text-2xl font-bold text-gray-900">人物搜索</h1>

      <Suspense>
        <SearchBar />
      </Suspense>

      <div className="mt-6">
        <PersonList persons={result.items} search={search || undefined} />
      </div>

      <Pagination
        total={result.total}
        pageSize={PAGE_SIZE}
        currentPage={page}
      />
    </main>
  );
}
