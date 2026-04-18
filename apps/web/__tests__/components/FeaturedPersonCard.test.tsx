import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";

import { FeaturedPersonCard } from "@/components/home/FeaturedPersonCard";

describe("FeaturedPersonCard", () => {
  it("renders person name", () => {
    render(
      <FeaturedPersonCard slug="huang-di" name="黄帝" dynasty="上古" />,
    );
    expect(screen.getByText("黄帝")).toBeInTheDocument();
  });

  it("renders dynasty when provided", () => {
    render(
      <FeaturedPersonCard slug="huang-di" name="黄帝" dynasty="上古" />,
    );
    expect(screen.getByText("上古")).toBeInTheDocument();
  });

  it("links to person detail page", () => {
    render(
      <FeaturedPersonCard slug="huang-di" name="黄帝" dynasty="上古" />,
    );
    const link = screen.getByRole("link");
    expect(link).toHaveAttribute("href", "/persons/huang-di");
  });

  it("renders biography excerpt when provided", () => {
    const bio = "黄帝者，少典之子，姓公孙，名曰轩辕。";
    render(
      <FeaturedPersonCard slug="huang-di" name="黄帝" biography={bio} />,
    );
    expect(screen.getByText(bio)).toBeInTheDocument();
  });

  it("truncates long biography to 60 chars", () => {
    const longBio = "这是一段非常长的人物传记，需要被截断以适应卡片布局。这是一段非常长的人物传记，需要被截断以适应卡片布局。还有更多内容在后面，所以必须超过六十个字符才行。";
    render(
      <FeaturedPersonCard slug="huang-di" name="黄帝" biography={longBio} />,
    );
    const text = screen.getByText(/这是一段非常长的人物传记/);
    expect(text.textContent).toContain("...");
  });
});
