import type { GraphQLResolveInfo } from "graphql";
import { describe, expect, it, vi, beforeEach } from "vitest";
import type { QueryPersonArgs, QueryPersonsArgs, Person } from "../src/__generated__/graphql.js";
import type { GraphQLContext } from "../src/context.js";
import { HuadianGraphQLError } from "../src/errors.js";
import { queryResolvers } from "../src/resolvers/query.js";

// Mock the service layer
vi.mock("../src/services/person.service.js", () => ({
  findPersonBySlug: vi.fn(),
  searchPersons: vi.fn(),
}));

// Import after mock
import { findPersonBySlug, searchPersons } from "../src/services/person.service.js";

const mockFindBySlug = vi.mocked(findPersonBySlug);
const mockSearchPersons = vi.mocked(searchPersons);

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

  const searchResult = {
    items: [mockPerson],
    total: 1,
    hasMore: false,
  };

  it("returns PersonSearchResult with default pagination", async () => {
    mockSearchPersons.mockResolvedValue(searchResult as Awaited<ReturnType<typeof searchPersons>>);

    const result = await personsResolver(
      emptyParent,
      { limit: 20, offset: 0, search: null } satisfies QueryPersonsArgs,
      mockCtx,
      info,
    );

    expect(result).toEqual(searchResult);
    expect(mockSearchPersons).toHaveBeenCalledWith(mockCtx.db, null, 20, 0);
  });

  it("passes search term, limit and offset to service", async () => {
    mockSearchPersons.mockResolvedValue({ items: [], total: 0, hasMore: false });

    await personsResolver(
      emptyParent,
      { search: "刘邦", limit: 5, offset: 10 } satisfies QueryPersonsArgs,
      mockCtx,
      info,
    );

    expect(mockSearchPersons).toHaveBeenCalledWith(mockCtx.db, "刘邦", 5, 10);
  });

  it("returns empty result when no persons match", async () => {
    const emptyResult = { items: [], total: 0, hasMore: false };
    mockSearchPersons.mockResolvedValue(emptyResult);

    const result = await personsResolver(
      emptyParent,
      { limit: 20, offset: 0, search: null } satisfies QueryPersonsArgs,
      mockCtx,
      info,
    );

    expect(result).toEqual(emptyResult);
  });

  it("treats undefined search as null", async () => {
    mockSearchPersons.mockResolvedValue({ items: [], total: 0, hasMore: false });

    await personsResolver(
      emptyParent,
      { limit: 20, offset: 0 } as QueryPersonsArgs,
      mockCtx,
      info,
    );

    expect(mockSearchPersons).toHaveBeenCalledWith(mockCtx.db, null, 20, 0);
  });
});
