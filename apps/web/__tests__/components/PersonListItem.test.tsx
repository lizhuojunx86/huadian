import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";

import { PersonListItem } from "@/components/person-search/PersonListItem";

const person = {
  slug: "liu-bang",
  name: { zhHans: "刘邦", en: "Liu Bang" },
  dynasty: "西汉",
  realityStatus: "historical",
  provenanceTier: "primary_text",
};

describe("PersonListItem", () => {
  it("renders Chinese name", () => {
    render(<PersonListItem person={person} />);
    expect(screen.getByText("刘邦")).toBeInTheDocument();
  });

  it("renders English name", () => {
    render(<PersonListItem person={person} />);
    expect(screen.getByText("Liu Bang")).toBeInTheDocument();
  });

  it("renders dynasty badge", () => {
    render(<PersonListItem person={person} />);
    expect(screen.getByText("西汉")).toBeInTheDocument();
  });

  it("links to person detail page", () => {
    render(<PersonListItem person={person} />);
    const link = screen.getByRole("link");
    expect(link).toHaveAttribute("href", "/persons/liu-bang");
  });

  it("does not render dynasty badge when null", () => {
    render(<PersonListItem person={{ ...person, dynasty: null }} />);
    expect(screen.queryByText("西汉")).not.toBeInTheDocument();
  });

  it("does not show reality status for historical persons", () => {
    render(<PersonListItem person={person} />);
    expect(screen.queryByText("historical")).not.toBeInTheDocument();
  });

  it("shows reality status for non-historical persons", () => {
    render(<PersonListItem person={{ ...person, realityStatus: "legendary" }} />);
    expect(screen.getByText("legendary")).toBeInTheDocument();
  });
});
