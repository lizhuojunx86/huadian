import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "关于项目 — 华典智谱",
  description:
    "华典智谱是中国古籍 AI 知识平台，将古籍文本结构化为可探索、可交互、可查询的知识系统。",
  openGraph: {
    title: "关于项目 — 华典智谱",
    description:
      "华典智谱是中国古籍 AI 知识平台，将古籍文本结构化为可探索、可交互、可查询的知识系统。",
  },
};

const TECH_STACK = [
  { category: "前端", items: "Next.js · TypeScript · Tailwind CSS · shadcn/ui" },
  { category: "API", items: "Node.js · GraphQL (Yoga) · Drizzle ORM" },
  { category: "数据管线", items: "Python · Prefect · Anthropic Claude API" },
  { category: "数据库", items: "PostgreSQL 16 · pgvector · PostGIS · pg_trgm" },
  { category: "基础设施", items: "Docker Compose · OpenTelemetry · Turborepo" },
] as const;

export default function AboutPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-12">
      <h1 className="mb-8 text-3xl font-bold">关于华典智谱</h1>

      <section className="mb-10">
        <p className="leading-relaxed text-muted-foreground">
          华典智谱是中国古籍 AI
          知识平台，致力于将古籍文本结构化为可探索、可交互、可查询的知识系统。
          通过 AI 技术从经典古籍中提取人物、事件、地理、时间等实体，
          构建底层 8 类实体知识图谱，实现一次结构化、N 次衍生。
        </p>
      </section>

      <section className="mb-10">
        <h2 className="mb-4 text-xl font-semibold">技术栈</h2>
        <div className="space-y-3">
          {TECH_STACK.map(({ category, items }) => (
            <div key={category} className="flex gap-3">
              <span className="w-20 shrink-0 font-medium">{category}</span>
              <span className="text-muted-foreground">{items}</span>
            </div>
          ))}
        </div>
      </section>

      <section className="mb-10">
        <h2 className="mb-4 text-xl font-semibold">项目状态</h2>
        <p className="text-muted-foreground">
          当前处于 Phase 0（地基阶段）。已完成数据库 schema、GraphQL API 骨架、
          数据管线基础设施、首批古籍 Pilot（史记·本纪前 3 篇）、跨 chunk 身份消歧等核心模块。
        </p>
      </section>

      <section>
        <h2 className="mb-4 text-xl font-semibold">联系方式</h2>
        <p className="text-muted-foreground">
          如有合作意向或反馈建议，欢迎通过 GitHub 联系。
        </p>
      </section>
    </div>
  );
}
