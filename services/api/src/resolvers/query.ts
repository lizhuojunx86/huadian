import { persons, personNames, books } from "@huadian/db-schema";
import { and, isNull, sql } from "drizzle-orm";

import type { QueryResolvers } from "../__generated__/graphql.js";
import { notImplemented } from "../errors.js";
import {
  findPersonBySlug,
  searchPersons,
} from "../services/person.service.js";
import { validateSlug } from "../utils/slug.js";

import { triageQueryFragment } from "./triage.js";

/**
 * Query resolvers. person/persons are real implementations backed by
 * Drizzle (T-P0-007). Remaining entity lookups remain NOT_IMPLEMENTED
 * stubs for later tasks.
 *
 * `_schemaVersion` is a permanent health probe.
 */
export const queryResolvers: QueryResolvers = {
  _schemaVersion: () => "T-P0-007 person-query",

  person: async (_parent, { slug }, ctx) => {
    validateSlug(slug, ctx.requestId);

    const person = await findPersonBySlug(ctx.db, slug);
    if (!person) return null;
    return person;
  },

  persons: async (_parent, { search, limit, offset }, ctx) => {
    return searchPersons(ctx.db, search ?? null, limit ?? 20, offset ?? 0);
  },

  event: (_parent, _args, ctx) => {
    throw notImplemented("Query.event", ctx);
  },

  place: (_parent, _args, ctx) => {
    throw notImplemented("Query.place", ctx);
  },

  sourceEvidence: (_parent, _args, ctx) => {
    throw notImplemented("Query.sourceEvidence", ctx);
  },

  stats: async (_parent, _args, ctx) => {
    const [personsResult, namesResult, booksResult] = await Promise.all([
      ctx.db
        .select({ count: sql<number>`count(*)::int` })
        .from(persons)
        .where(and(isNull(persons.mergedIntoId), isNull(persons.deletedAt))),
      ctx.db
        .select({ count: sql<number>`count(*)::int` })
        .from(personNames),
      ctx.db
        .select({ count: sql<number>`count(*)::int` })
        .from(books),
    ]);

    return {
      personsCount: personsResult[0]?.count ?? 0,
      namesCount: namesResult[0]?.count ?? 0,
      booksCount: booksResult[0]?.count ?? 0,
    };
  },

  // Triage queries — implementation in resolvers/triage.ts
  pendingTriageItems: triageQueryFragment.pendingTriageItems,
  triageItem: triageQueryFragment.triageItem,
  triageDecisionsForSurface: triageQueryFragment.triageDecisionsForSurface,
  personById: triageQueryFragment.personById,
};
