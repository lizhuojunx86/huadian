import type { GraphQLResolveInfo } from "graphql";
import { describe, expect, it, vi, beforeEach } from "vitest";
import type { QueryPersonArgs, QueryPersonsArgs, Person } from "../src/__generated__/graphql.js";
import type { GraphQLContext } from "../src/context.js";
import { HuadianGraphQLError } from "../src/errors.js";
import { queryResolvers } from "../src/resolvers/query.js";

// Mock the service layer
vi.mock("../src/services/person.service.js", () => ({
  findPersonBySlug: vi.fn(),
  findPersons: vi.fn(),
}));

// Import after mock
import { findPersonBySlug, findPersons } from "../src/services/person.service.js";

const mockFindBySlug = vi.mocked(findPersonBySlug);
const mockFindPersons = vi.mocked(findPersons);

const mockCtx: GraphQLContext = {
  db: {} as GraphQLContext["db"],
  requestId: "test-request-id",
  tracer: null,
};

const mockPerson = {
  __typename: "Person" as const,
  id: "550e8400-e29b-41d4-a716-446655440000",
  slug: "liu-bang",
  name: { zhHans: "刘邦", zhHant: "劉邦", en: "Liu Bang" },
  dynasty: "西汉",
  realityStatus: "historical",
  birthDate: null,
  deathDate: null,
  biography: null,
  provenanceTier: "primary_text",
  sourceEvidenceId: null,
  updatedAt: "2026-04-17T12:00:00.000Z",
  names: [],
  identityHypotheses: [],
  _namesLoaded: true,
  _hypothesesLoaded: true,
} as unknown as Person & { _namesLoaded: boolean; _hypothesesLoaded: boolean };

const emptyParent = {} as Record<PropertyKey, never>;
const info = {} as GraphQLResolveInfo;

beforeEach(() => {
  vi.clearAllMocks();
});

describe("Query.person", () => {
  const personResolver = queryResolvers.person!;

  it("returns person for valid slug", async () => {
    mockFindBySlug.mockResolvedValue(mockPerson);

    const result = await personResolver(
      emptyParent,
      { slug: "liu-bang" } satisfies QueryPersonArgs,
      mockCtx,
      info,
    );

    expect(result).toEqual(mockPerson);
    expect(mockFindBySlug).toHaveBeenCalledWith(mockCtx.db, "liu-bang");
  });

  it("returns null for non-existent slug", async () => {
    mockFindBySlug.mockResolvedValue(null);

    const result = await personResolver(
      emptyParent,
      { slug: "nonexistent" } satisfies QueryPersonArgs,
      mockCtx,
      info,
    );

    expect(result).toBeNull();
  });

  it("throws VALIDATION_ERROR for invalid slug format", async () => {
    try {
      await personResolver(
        emptyParent,
        { slug: "INVALID SLUG!" } satisfies QueryPersonArgs,
        mockCtx,
        info,
      );
      expect.unreachable("should have thrown");
    } catch (e) {
      expect(e).toBeInstanceOf(HuadianGraphQLError);
      expect((e as HuadianGraphQLError).code).toBe("VALIDATION_ERROR");
    }

    expect(mockFindBySlug).not.toHaveBeenCalled();
  });

  it("throws VALIDATION_ERROR for slug with uppercase", async () => {
    try {
      await personResolver(
        emptyParent,
        { slug: "Liu-Bang" } satisfies QueryPersonArgs,
        mockCtx,
        info,
      );
      expect.unreachable("should have thrown");
    } catch (e) {
      expect(e).toBeInstanceOf(HuadianGraphQLError);
      expect((e as HuadianGraphQLError).code).toBe("VALIDATION_ERROR");
    }
  });
});

describe("Query.persons", () => {
  const personsResolver = queryResolvers.persons!;

  it("returns array of persons with default pagination", async () => {
    mockFindPersons.mockResolvedValue([mockPerson] as Awaited<ReturnType<typeof findPersons>>);

    const result = await personsResolver(
      emptyParent,
      { limit: 20, offset: 0 } satisfies QueryPersonsArgs,
      mockCtx,
      info,
    );

    expect(result).toEqual([mockPerson]);
    expect(mockFindPersons).toHaveBeenCalledWith(mockCtx.db, 20, 0);
  });

  it("passes custom limit and offset to service", async () => {
    mockFindPersons.mockResolvedValue([]);

    await personsResolver(
      emptyParent,
      { limit: 5, offset: 10 } satisfies QueryPersonsArgs,
      mockCtx,
      info,
    );

    expect(mockFindPersons).toHaveBeenCalledWith(mockCtx.db, 5, 10);
  });

  it("returns empty array when no persons exist", async () => {
    mockFindPersons.mockResolvedValue([]);

    const result = await personsResolver(
      emptyParent,
      { limit: 20, offset: 0 } satisfies QueryPersonsArgs,
      mockCtx,
      info,
    );

    expect(result).toEqual([]);
  });
});
