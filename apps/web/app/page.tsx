import { HeroSearch } from "@/components/home/HeroSearch";

export default function Home() {
  return (
    <section className="flex flex-col items-center justify-center gap-6 px-4 py-20 text-center md:py-28">
      <h1 className="text-4xl font-bold tracking-tight md:text-5xl">
        华典智谱
      </h1>
      <p className="max-w-lg text-lg text-muted-foreground">
        探索中国古籍中的人物、事件与地理
      </p>
      <HeroSearch />
    </section>
  );
}
