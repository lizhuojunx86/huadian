import Link from "next/link";

export default function PersonNotFound() {
  return (
    <div className="mx-auto max-w-3xl p-4 md:p-8">
      <div className="rounded-lg border p-8 text-center">
        <h2 className="text-xl font-semibold">人物未找到</h2>
        <p className="mt-2 text-sm text-muted-foreground">
          该人物不存在或已被移除。请检查 URL 是否正确。
        </p>
        <Link
          href="/"
          className="mt-4 inline-block rounded-md border px-4 py-2 text-sm hover:bg-accent"
        >
          返回首页
        </Link>
      </div>
    </div>
  );
}
