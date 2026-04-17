import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { PersonNames } from "@/components/person/PersonNames";
import { mockPerson } from "../fixtures";

describe("PersonNames", () => {
  it("renders name entries", () => {
    render(<PersonNames names={mockPerson.names} />);
    expect(screen.getByText("刘季")).toBeInTheDocument();
    expect(screen.getByText("汉高祖")).toBeInTheDocument();
  });

  it("renders pinyin", () => {
    render(<PersonNames names={mockPerson.names} />);
    expect(screen.getByText("Liú Jì")).toBeInTheDocument();
  });

  it("renders nameType badge", () => {
    render(<PersonNames names={mockPerson.names} />);
    expect(screen.getByText("本名")).toBeInTheDocument();
    expect(screen.getByText("庙号")).toBeInTheDocument();
  });

  it("renders isPrimary badge", () => {
    render(<PersonNames names={mockPerson.names} />);
    expect(screen.getByText("主要")).toBeInTheDocument();
  });

  it("shows empty state placeholder", () => {
    render(<PersonNames names={[]} />);
    expect(screen.getByText("暂无别名记录")).toBeInTheDocument();
  });
});
