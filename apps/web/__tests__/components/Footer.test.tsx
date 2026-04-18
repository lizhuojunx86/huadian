import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";

import { Footer } from "@/components/layout/Footer";

describe("Footer", () => {
  it("renders project tagline", () => {
    render(<Footer />);
    expect(
      screen.getByText("华典智谱 — 中国古籍 AI 知识平台"),
    ).toBeInTheDocument();
  });

  it("renders copyright", () => {
    render(<Footer />);
    expect(screen.getByText("© 2026 华典智谱")).toBeInTheDocument();
  });

  it("renders about link", () => {
    render(<Footer />);
    const link = screen.getByText("关于项目").closest("a");
    expect(link).toHaveAttribute("href", "/about");
  });
});
