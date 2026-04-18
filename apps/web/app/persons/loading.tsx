import { Skeleton } from "@/components/ui/skeleton";

export default function PersonsLoading() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-8">
      <h1 className="mb-6 text-2xl font-bold text-gray-900">人物搜索</h1>

      {/* Search bar skeleton */}
      <Skeleton className="h-10 w-full rounded-md" />

      {/* List skeletons */}
      <div className="mt-6 flex flex-col gap-2">
        {Array.from({ length: 5 }).map((_, i) => (
          <div key={i} className="rounded-md border border-gray-200 px-4 py-3">
            <Skeleton className="mb-2 h-5 w-48" />
            <Skeleton className="h-4 w-32" />
          </div>
        ))}
      </div>
    </div>
  );
}
