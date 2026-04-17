import type { QueryResolvers } from "../__generated__/graphql.js";
import { notImplemented } from "../errors.js";
import {
  findPersonBySlug,
  findPersons,
} from "../services/person.service.js";
import { validateSlug } from "../utils/slug.js";

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

  persons: async (_parent, { limit, offset }, ctx) => {
    return findPersons(ctx.db, limit ?? 20, offset ?? 0);
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
};
