"use client";

import { useRouter, useSearchParams } from "next/navigation";

import { Button } from "@/components/ui/button";

interface PaginationProps {
  total: number;
  pageSize: number;
  currentPage: number;
}

export function Pagination({ total, pageSize, currentPage }: PaginationProps) {
  const router = useRouter();
  const searchParams = useSearchParams();

  const totalPages = Math.ceil(total / pageSize);

  if (totalPages <= 1) return null;

  function goToPage(page: number) {
    const params = new URLSearchParams(searchParams.toString());
    if (page <= 1) {
      params.delete("page");
    } else {
      params.set("page", String(page));
    }
    const qs = params.toString();
    router.replace(`/persons${qs ? `?${qs}` : ""}`);
  }

  return (
    <div className="flex items-center justify-between pt-4">
      <p className="text-sm text-gray-500">
        共 {total} 个结果，第 {currentPage}/{totalPages} 页
      </p>
      <div className="flex gap-2">
        <Button
          variant="outline"
          size="sm"
          disabled={currentPage <= 1}
          onClick={() => goToPage(currentPage - 1)}
        >
          上一页
        </Button>
        <Button
          variant="outline"
          size="sm"
          disabled={currentPage >= totalPages}
          onClick={() => goToPage(currentPage + 1)}
        >
          下一页
        </Button>
      </div>
    </div>
  );
}
