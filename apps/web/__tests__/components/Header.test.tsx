import { render, screen } from "@testing-library/react";
import { describe, it, expect, vi } from "vitest";

// Mock useSelectedLayoutSegment
vi.mock("next/navigation", () => ({
  useSelectedLayoutSegment: vi.fn(() => null),
}));

import { Header } from "@/components/layout/Header";

describe("Header", () => {
  it("renders site name", () => {
    render(<Header />);
    expect(screen.getByText("华典智谱")).toBeInTheDocument();
  });

  it("renders navigation links", () => {
    render(<Header />);
    expect(screen.getByText("人物")).toBeInTheDocument();
    expect(screen.getByText("关于")).toBeInTheDocument();
  });

  it("links site name to homepage", () => {
    render(<Header />);
    const link = screen.getByText("华典智谱").closest("a");
    expect(link).toHaveAttribute("href", "/");
  });

  it("links persons nav to /persons", () => {
    render(<Header />);
    const link = screen.getByText("人物").closest("a");
    expect(link).toHaveAttribute("href", "/persons");
  });
});
