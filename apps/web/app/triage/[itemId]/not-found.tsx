import Link from "next/link";

import { buttonVariants } from "@/components/ui/button";

export default function TriageItemNotFound() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-12 text-center">
      <h1 className="mb-3 text-2xl font-bold">Triage 项不存在</h1>
      <p className="mb-6 text-sm text-muted-foreground">
        该 item 已被处理或不在 pending 队列中。
      </p>
      <Link href="/triage" className={buttonVariants({ variant: "outline" })}>
        ← 返回队列
      </Link>
    </div>
  );
}
