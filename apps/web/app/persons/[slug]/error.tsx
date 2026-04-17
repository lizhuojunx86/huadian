"use client";

import { Button } from "@/components/ui/button";

interface ErrorPageProps {
  error: Error & { digest?: string };
  reset: () => void;
}

export default function PersonError({ error, reset }: ErrorPageProps) {
  return (
    <div className="mx-auto max-w-3xl p-4 md:p-8">
      <div className="rounded-lg border border-destructive/50 bg-destructive/5 p-8 text-center">
        <h2 className="text-xl font-semibold text-destructive">加载失败</h2>
        <p className="mt-2 text-sm text-muted-foreground">
          无法加载人物信息，请稍后重试。
        </p>
        {error.digest && (
          <p className="mt-1 text-xs text-muted-foreground">
            错误代码：{error.digest}
          </p>
        )}
        <Button variant="outline" className="mt-4" onClick={reset}>
          重试
        </Button>
      </div>
    </div>
  );
}
