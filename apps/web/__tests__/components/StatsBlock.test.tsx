import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";

import { StatsBlock } from "@/components/home/StatsBlock";

describe("StatsBlock", () => {
  it("renders all three stat values", () => {
    render(
      <StatsBlock personsCount={157} namesCount={272} booksCount={3} />,
    );
    expect(screen.getByText("157")).toBeInTheDocument();
    expect(screen.getByText("272")).toBeInTheDocument();
    expect(screen.getByText("3")).toBeInTheDocument();
  });

  it("renders stat labels", () => {
    render(
      <StatsBlock personsCount={0} namesCount={0} booksCount={0} />,
    );
    expect(screen.getByText("历史人物")).toBeInTheDocument();
    expect(screen.getByText("人物别名")).toBeInTheDocument();
    expect(screen.getByText("典籍来源")).toBeInTheDocument();
  });
});
