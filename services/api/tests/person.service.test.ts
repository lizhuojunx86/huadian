import { describe, expect, it, vi } from "vitest";
import {
  toGraphQLPerson,
  toGraphQLPersonName,
  toGraphQLHypothesis,
} from "../src/services/person.service.js";

// ----------------------------------------------------------------
// Mock data matching Drizzle row shape
// ----------------------------------------------------------------

const now = new Date("2026-04-17T12:00:00Z");

const mockPersonRow = {
  id: "550e8400-e29b-41d4-a716-446655440000",
  slug: "liu-bang",
  name: { "zh-Hans": "刘邦", "zh-Hant": "劉邦", en: "Liu Bang" },
  dynasty: "西汉",
  realityStatus: "historical" as const,
  birthDate: {
    year_min: -256,
    year_max: -256,
    precision: "year",
    reign_era: null,
    original_text: "前256年",
  },
  deathDate: {
    year_min: -195,
    year_max: -195,
    precision: "year",
  },
  biography: { "zh-Hans": "汉高祖", en: "First emperor of Han" },
  provenanceTier: "primary_text" as const,
  createdAt: now,
  updatedAt: now,
  deletedAt: null,
};

const mockPersonNameRow = {
  id: "660e8400-e29b-41d4-a716-446655440001",
  personId: "550e8400-e29b-41d4-a716-446655440000",
  name: "刘季",
  namePinyin: "Liu Ji",
  nameType: "alias" as const,
  startYear: null,
  endYear: null,
  isPrimary: false,
  sourceEvidenceId: null,
  createdAt: now,
};

const mockHypothesisRow = {
  id: "770e8400-e29b-41d4-a716-446655440002",
  canonicalPersonId: "550e8400-e29b-41d4-a716-446655440000",
  hypothesisPersonId: null,
  relationType: "same_person" as const,
  scholarlySupport: "Sima Qian, Shiji",
  evidenceIds: ["aaa-bbb"],
  acceptedByDefault: true,
  notes: "Well established identity",
  createdAt: now,
};

// ----------------------------------------------------------------
// DTO mapper tests
// ----------------------------------------------------------------

describe("toGraphQLPerson", () => {
  it("maps Drizzle row to GraphQL Person shape", () => {
    const result = toGraphQLPerson(mockPersonRow);

    expect(result.__typename).toBe("Person");
    expect(result.id).toBe(mockPersonRow.id);
    expect(result.slug).toBe("liu-bang");
    expect(result.name).toEqual({ zhHans: "刘邦", zhHant: "劉邦", en: "Liu Bang" });
    expect(result.dynasty).toBe("西汉");
    expect(result.realityStatus).toBe("historical");
    expect(result.sourceEvidenceId).toBeNull();
    expect(result.provenanceTier).toBe("primary_text");
    expect(result.updatedAt).toBe("2026-04-17T12:00:00.000Z");
  });

  it("maps birthDate JSONB snake_case to GraphQL camelCase", () => {
    const result = toGraphQLPerson(mockPersonRow);
    expect(result.birthDate).not.toBeNull();
    expect(result.birthDate!.yearMin).toBe(-256);
    expect(result.birthDate!.yearMax).toBe(-256);
    expect(result.birthDate!.precision).toBe("year");
    expect(result.birthDate!.originalText).toBe("前256年");
  });

  it("maps null biography to null", () => {
    const row = { ...mockPersonRow, biography: null };
    const result = toGraphQLPerson(row);
    expect(result.biography).toBeNull();
  });

  it("maps null birthDate/deathDate to null", () => {
    const row = { ...mockPersonRow, birthDate: null, deathDate: null };
    const result = toGraphQLPerson(row);
    expect(result.birthDate).toBeNull();
    expect(result.deathDate).toBeNull();
  });
});

describe("toGraphQLPersonName", () => {
  it("maps Drizzle PersonName row correctly", () => {
    const result = toGraphQLPersonName(mockPersonNameRow);

    expect(result.id).toBe(mockPersonNameRow.id);
    expect(result.personId).toBe(mockPersonNameRow.personId);
    expect(result.name).toBe("刘季");
    expect(result.namePinyin).toBe("Liu Ji");
    expect(result.nameType).toBe("alias");
    expect(result.isPrimary).toBe(false);
    expect(result.sourceEvidenceId).toBeNull();
    expect(result.createdAt).toBe("2026-04-17T12:00:00.000Z");
  });
});

describe("toGraphQLHypothesis", () => {
  it("maps Drizzle IdentityHypothesis row correctly", () => {
    const result = toGraphQLHypothesis(mockHypothesisRow);

    expect(result.id).toBe(mockHypothesisRow.id);
    expect(result.canonicalPersonId).toBe(mockHypothesisRow.canonicalPersonId);
    expect(result.hypothesisPersonId).toBeNull();
    expect(result.relationType).toBe("same_person");
    expect(result.scholarlySupport).toBe("Sima Qian, Shiji");
    expect(result.evidenceIds).toEqual(["aaa-bbb"]);
    expect(result.acceptedByDefault).toBe(true);
    expect(result.notes).toBe("Well established identity");
  });

  it("handles null evidenceIds gracefully", () => {
    const row = { ...mockHypothesisRow, evidenceIds: null };
    const result = toGraphQLHypothesis(row as any);
    expect(result.evidenceIds).toEqual([]);
  });
});
