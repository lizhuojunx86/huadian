"use client";

import { Button } from "@/components/ui/button";

interface ErrorProps {
  error: Error & { digest?: string };
  reset: () => void;
}

export default function TriageError({ error, reset }: ErrorProps) {
  return (
    <div className="mx-auto max-w-3xl px-4 py-8">
      <h1 className="mb-6 text-2xl font-bold">Triage Queue</h1>

      <div className="flex flex-col items-center justify-center py-12 text-center">
        <p className="text-lg text-red-600">Triage 加载失败</p>
        <p className="mt-2 text-sm text-gray-500">
          {error.message || "请稍后重试"}
        </p>
        <Button variant="outline" className="mt-4" onClick={reset}>
          重试
        </Button>
      </div>
    </div>
  );
}
