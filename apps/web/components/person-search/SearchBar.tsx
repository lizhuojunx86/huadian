"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";

import { useDebounce } from "@/lib/hooks/useDebounce";

const DEBOUNCE_MS = 300;

export function SearchBar() {
  const router = useRouter();
  const searchParams = useSearchParams();

  const initialSearch = searchParams.get("search") ?? "";
  const [query, setQuery] = useState(initialSearch);
  const debouncedQuery = useDebounce(query, DEBOUNCE_MS);

  useEffect(() => {
    const params = new URLSearchParams(searchParams.toString());

    if (debouncedQuery) {
      params.set("search", debouncedQuery);
    } else {
      params.delete("search");
    }
    // Reset to page 1 when search changes
    params.delete("page");

    const qs = params.toString();
    router.replace(`/persons${qs ? `?${qs}` : ""}`);
  }, [debouncedQuery, router, searchParams]);

  return (
    <div className="w-full">
      <input
        type="search"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="搜索人物（如：刘邦、李太白）..."
        className="w-full rounded-md border border-gray-300 px-4 py-2 text-sm focus:border-gray-500 focus:outline-none focus:ring-1 focus:ring-gray-500"
        aria-label="搜索人物"
      />
    </div>
  );
}
