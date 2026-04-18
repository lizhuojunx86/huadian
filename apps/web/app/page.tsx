import { FeaturedPersonCard } from "@/components/home/FeaturedPersonCard";
import { HeroSearch } from "@/components/home/HeroSearch";
import { graphqlClient } from "@/lib/graphql/client";
import { FeaturedPersonDocument } from "@/lib/graphql/generated/graphql";

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

export default async function Home() {
  const persons = await fetchFeaturedPersons();

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
    </>
  );
}
