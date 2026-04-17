import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { PersonHypotheses } from "@/components/person/PersonHypotheses";
import { mockPerson } from "../fixtures";

describe("PersonHypotheses", () => {
  it("renders hypothesis entries", () => {
    render(<PersonHypotheses hypotheses={mockPerson.identityHypotheses} />);
    expect(screen.getByText("同一人物")).toBeInTheDocument();
  });

  it("renders scholarly support", () => {
    render(<PersonHypotheses hypotheses={mockPerson.identityHypotheses} />);
    expect(screen.getByText(/《史记·高祖本纪》/)).toBeInTheDocument();
  });

  it("renders acceptedByDefault badge", () => {
    render(<PersonHypotheses hypotheses={mockPerson.identityHypotheses} />);
    expect(screen.getByText("默认接受")).toBeInTheDocument();
  });

  it("shows empty state placeholder", () => {
    render(<PersonHypotheses hypotheses={[]} />);
    expect(screen.getByText("暂无身份假说")).toBeInTheDocument();
  });
});
