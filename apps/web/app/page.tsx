import Link from "next/link";

import { FeaturedPersonCard } from "@/components/home/FeaturedPersonCard";
import { HeroSearch } from "@/components/home/HeroSearch";
import { StatsBlock } from "@/components/home/StatsBlock";
import { buttonVariants } from "@/components/ui/button";
import { graphqlClient } from "@/lib/graphql/client";
import {
  FeaturedPersonDocument,
  StatsDocument,
} from "@/lib/graphql/generated/graphql";

const FEATURED_SLUGS = [
  "huang-di",
  "yao",
  "shun",
  "yu",
  "tang",
  "xi-bo-chang",
] as const;

async function fetchFeaturedPersons() {
  const results = await Promise.all(
    FEATURED_SLUGS.map((slug) =>
      graphqlClient
        .request(FeaturedPersonDocument, { slug })
        .then((d) => d.person)
        .catch(() => null),
    ),
  );
  return results.filter(
    (p): p is NonNullable<typeof p> => p != null,
  );
}

async function fetchStats() {
  try {
    const data = await graphqlClient.request(StatsDocument);
    return data.stats;
  } catch {
    return null;
  }
}

export default async function Home() {
  const [persons, stats] = await Promise.all([
    fetchFeaturedPersons(),
    fetchStats(),
  ]);

  return (
    <>
      {/* Hero */}
      <section className="flex flex-col items-center justify-center gap-6 px-4 py-20 text-center md:py-28">
        <h1 className="text-4xl font-bold tracking-tight md:text-5xl">
          华典智谱
        </h1>
        <p className="max-w-lg text-lg text-muted-foreground">
          探索中国古籍中的人物、事件与地理
        </p>
        <HeroSearch />
      </section>

      {/* Featured persons */}
      {persons.length > 0 && (
        <section className="mx-auto max-w-5xl px-4 pb-16">
          <h2 className="mb-6 text-center text-2xl font-semibold">
            知名人物
          </h2>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {persons.map((p) => (
              <FeaturedPersonCard
                key={p.slug}
                slug={p.slug}
                name={p.name.zhHans ?? p.slug}
                dynasty={p.dynasty}
                biography={p.biography?.zhHans}
              />
            ))}
          </div>
        </section>
      )}

      {/* Stats */}
      {stats && (
        <section className="mx-auto max-w-5xl px-4 pb-16">
          <h2 className="mb-6 text-center text-2xl font-semibold">
            数据概览
          </h2>
          <StatsBlock
            personsCount={stats.personsCount}
            namesCount={stats.namesCount}
            booksCount={stats.booksCount}
          />
        </section>
      )}

      {/* CTA */}
      <section className="flex justify-center px-4 pb-20">
        <Link href="/persons" className={buttonVariants({ size: "lg" })}>
          探索全部人物 →
        </Link>
      </section>
    </>
  );
}
