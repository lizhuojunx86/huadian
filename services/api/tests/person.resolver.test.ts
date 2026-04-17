import { describe, expect, it, vi, beforeEach } from "vitest";
import { queryResolvers } from "../src/resolvers/query.js";
import { HuadianGraphQLError } from "../src/errors.js";
import type { GraphQLContext } from "../src/context.js";

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
  db: {} as any,
  requestId: "test-request-id",
  tracer: null,
};

const mockPerson = {
  __typename: "Person" as const,
  id: "550e8400-e29b-41d4-a716-446655440000",
  slug: "liu-bang",
  name: { zhHans: "刘邦", zhHant: "劉邦", en: "Liu Bang" },
  dynasty: "西汉",
  realityStatus: "historical" as any,
  birthDate: null,
  deathDate: null,
  biography: null,
  provenanceTier: "primary_text" as any,
  sourceEvidenceId: null,
  updatedAt: "2026-04-17T12:00:00.000Z",
  names: [],
  identityHypotheses: [],
  _namesLoaded: true,
  _hypothesesLoaded: true,
};

beforeEach(() => {
  vi.clearAllMocks();
});

describe("Query.person", () => {
  const parent = {} as any;

  it("returns person for valid slug", async () => {
    mockFindBySlug.mockResolvedValue(mockPerson);

    const result = await (queryResolvers.person as Function)(
      parent,
      { slug: "liu-bang" },
      mockCtx,
      {} as any,
    );

    expect(result).toEqual(mockPerson);
    expect(mockFindBySlug).toHaveBeenCalledWith(mockCtx.db, "liu-bang");
  });

  it("returns null for non-existent slug", async () => {
    mockFindBySlug.mockResolvedValue(null);

    const result = await (queryResolvers.person as Function)(
      parent,
      { slug: "nonexistent" },
      mockCtx,
      {} as any,
    );

    expect(result).toBeNull();
  });

  it("throws VALIDATION_ERROR for invalid slug format", async () => {
    try {
      await (queryResolvers.person as Function)(
        parent,
        { slug: "INVALID SLUG!" },
        mockCtx,
        {} as any,
      );
      expect.unreachable("should have thrown");
    } catch (e) {
      expect(e).toBeInstanceOf(HuadianGraphQLError);
      expect((e as HuadianGraphQLError).code).toBe("VALIDATION_ERROR");
    }

    // Service should not be called for invalid slugs
    expect(mockFindBySlug).not.toHaveBeenCalled();
  });

  it("throws VALIDATION_ERROR for slug with uppercase", async () => {
    try {
      await (queryResolvers.person as Function)(
        parent,
        { slug: "Liu-Bang" },
        mockCtx,
        {} as any,
      );
      expect.unreachable("should have thrown");
    } catch (e) {
      expect(e).toBeInstanceOf(HuadianGraphQLError);
      expect((e as HuadianGraphQLError).code).toBe("VALIDATION_ERROR");
    }
  });
});

describe("Query.persons", () => {
  const parent = {} as any;

  it("returns array of persons with default pagination", async () => {
    mockFindPersons.mockResolvedValue([mockPerson]);

    const result = await (queryResolvers.persons as Function)(
      parent,
      { limit: 20, offset: 0 },
      mockCtx,
      {} as any,
    );

    expect(result).toEqual([mockPerson]);
    expect(mockFindPersons).toHaveBeenCalledWith(mockCtx.db, 20, 0);
  });

  it("passes custom limit and offset to service", async () => {
    mockFindPersons.mockResolvedValue([]);

    await (queryResolvers.persons as Function)(
      parent,
      { limit: 5, offset: 10 },
      mockCtx,
      {} as any,
    );

    expect(mockFindPersons).toHaveBeenCalledWith(mockCtx.db, 5, 10);
  });

  it("returns empty array when no persons exist", async () => {
    mockFindPersons.mockResolvedValue([]);

    const result = await (queryResolvers.persons as Function)(
      parent,
      { limit: 20, offset: 0 },
      mockCtx,
      {} as any,
    );

    expect(result).toEqual([]);
  });
});
