import Link from "next/link";

export function Footer() {
  return (
    <footer className="border-t bg-muted/40">
      <div className="mx-auto flex max-w-5xl flex-col items-center gap-2 px-4 py-6 text-center text-sm text-muted-foreground md:flex-row md:justify-between md:text-left">
        <p>华典智谱 — 中国古籍 AI 知识平台</p>
        <div className="flex items-center gap-4">
          <Link
            href="/about"
            className="transition-colors hover:text-foreground"
          >
            关于项目
          </Link>
          <a
            href="https://github.com"
            target="_blank"
            rel="noopener noreferrer"
            className="transition-colors hover:text-foreground"
          >
            GitHub
          </a>
        </div>
        <p>© 2026 华典智谱</p>
      </div>
    </footer>
  );
}
