import { Skeleton } from "@/components/ui/skeleton";

export default function TriageLoading() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-8">
      <Skeleton className="mb-2 h-8 w-48" />
      <Skeleton className="mb-6 h-4 w-64" />

      <div className="flex flex-col gap-3">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="rounded-md border border-gray-200 px-4 py-3">
            <Skeleton className="mb-2 h-5 w-48" />
            <Skeleton className="mb-1 h-4 w-full" />
            <Skeleton className="h-4 w-32" />
          </div>
        ))}
      </div>
    </div>
  );
}
