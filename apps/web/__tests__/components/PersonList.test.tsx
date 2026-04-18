import { render, screen } from "@testing-library/react";
import { describe, it, expect } from "vitest";

import { PersonList } from "@/components/person-search/PersonList";

const persons = [
  {
    id: "1",
    slug: "liu-bang",
    name: { zhHans: "刘邦", en: "Liu Bang" },
    dynasty: "西汉",
    realityStatus: "historical",
    provenanceTier: "primary_text",
  },
  {
    id: "2",
    slug: "xiang-yu",
    name: { zhHans: "项羽", en: "Xiang Yu" },
    dynasty: "秦末楚汉",
    realityStatus: "historical",
    provenanceTier: "primary_text",
  },
];

describe("PersonList", () => {
  it("renders all persons", () => {
    render(<PersonList persons={persons} />);
    expect(screen.getByText("刘邦")).toBeInTheDocument();
    expect(screen.getByText("项羽")).toBeInTheDocument();
  });

  it("shows empty message when no persons and has search", () => {
    render(<PersonList persons={[]} search="不存在" />);
    expect(screen.getByText(/未找到与"不存在"相关的人物/)).toBeInTheDocument();
  });

  it("shows generic empty message when no persons and no search", () => {
    render(<PersonList persons={[]} />);
    expect(screen.getByText("暂无人物数据")).toBeInTheDocument();
  });

  it("shows hint for alternative keywords when search yields no results", () => {
    render(<PersonList persons={[]} search="xyz" />);
    expect(screen.getByText(/拼音、别名/)).toBeInTheDocument();
  });
});
