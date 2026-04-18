import { render, screen, fireEvent } from "@testing-library/react";
import { describe, it, expect, vi } from "vitest";

const pushMock = vi.fn();

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: pushMock }),
}));

import { HeroSearch } from "@/components/home/HeroSearch";

describe("HeroSearch", () => {
  it("renders search input and button", () => {
    render(<HeroSearch />);
    expect(screen.getByPlaceholderText(/搜索人物/)).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "搜索" })).toBeInTheDocument();
  });

  it("navigates to /persons?search= on submit with text", () => {
    render(<HeroSearch />);
    const input = screen.getByPlaceholderText(/搜索人物/);
    fireEvent.change(input, { target: { value: "黄帝" } });
    fireEvent.submit(input.closest("form")!);
    expect(pushMock).toHaveBeenCalledWith(
      "/persons?search=%E9%BB%84%E5%B8%9D",
    );
  });

  it("navigates to /persons on submit with empty text", () => {
    pushMock.mockClear();
    render(<HeroSearch />);
    const form = screen.getByRole("button", { name: "搜索" }).closest("form")!;
    fireEvent.submit(form);
    expect(pushMock).toHaveBeenCalledWith("/persons");
  });
});
