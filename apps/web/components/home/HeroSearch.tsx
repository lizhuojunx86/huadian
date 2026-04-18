"use client";

import { useRouter } from "next/navigation";
import { type FormEvent, useRef } from "react";

import { Button } from "@/components/ui/button";

export function HeroSearch() {
  const router = useRouter();
  const inputRef = useRef<HTMLInputElement>(null);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    const q = inputRef.current?.value.trim();
    if (q) {
      router.push(`/persons?search=${encodeURIComponent(q)}`);
    } else {
      router.push("/persons");
    }
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="mx-auto flex w-full max-w-md gap-2"
    >
      <input
        ref={inputRef}
        type="text"
        placeholder="搜索人物，如：黄帝、尧、禹..."
        className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
      />
      <Button type="submit">搜索</Button>
    </form>
  );
}
