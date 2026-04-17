import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { PersonCard } from "@/components/person/PersonCard";
import { mockPerson, mockPersonMinimal } from "../fixtures";

describe("PersonCard", () => {
  it("renders person name in zhHans", () => {
    render(<PersonCard person={mockPerson} />);
    expect(screen.getByText("刘邦")).toBeInTheDocument();
  });

  it("renders English name when available", () => {
    render(<PersonCard person={mockPerson} />);
    expect(screen.getByText("Liu Bang")).toBeInTheDocument();
  });

  it("renders dynasty", () => {
    render(<PersonCard person={mockPerson} />);
    expect(screen.getByText(/西汉/)).toBeInTheDocument();
  });

  it("renders provenance tier badge", () => {
    render(<PersonCard person={mockPerson} />);
    expect(screen.getByText("原始文献")).toBeInTheDocument();
  });

  it("renders reality status badge", () => {
    render(<PersonCard person={mockPerson} />);
    expect(screen.getByText("历史人物")).toBeInTheDocument();
  });

  it("renders biography", () => {
    render(<PersonCard person={mockPerson} />);
    expect(screen.getByText(/汉太祖高皇帝/)).toBeInTheDocument();
  });

  it("renders minimal person without errors", () => {
    render(<PersonCard person={mockPersonMinimal} />);
    expect(screen.getByText("佚名")).toBeInTheDocument();
    expect(screen.getByText("暂无别名记录")).toBeInTheDocument();
    expect(screen.getByText("暂无身份假说")).toBeInTheDocument();
  });
});
