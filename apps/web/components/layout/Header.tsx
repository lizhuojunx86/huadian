"use client";

import Link from "next/link";
import { useSelectedLayoutSegment } from "next/navigation";

import { cn } from "@/lib/utils";

const NAV_ITEMS = [
  { label: "人物", segment: "persons", href: "/persons" },
  { label: "关于", segment: "about", href: "/about" },
] as const;

export function Header() {
  const segment = useSelectedLayoutSegment();

  return (
    <header className="sticky top-0 z-50 border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="mx-auto flex h-14 max-w-5xl items-center justify-between px-4">
        <Link href="/" className="flex items-center gap-2 font-bold text-lg">
          <span>华典智谱</span>
        </Link>

        <nav className="flex items-center gap-6">
          {NAV_ITEMS.map(({ label, segment: seg, href }) => (
            <Link
              key={href}
              href={href}
              className={cn(
                "text-sm font-medium transition-colors hover:text-foreground/80",
                segment === seg
                  ? "text-foreground"
                  : "text-muted-foreground",
              )}
            >
              {label}
            </Link>
          ))}
        </nav>
      </div>
    </header>
  );
}
