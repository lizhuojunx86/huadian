import type { QueryResolvers } from "../__generated__/graphql.js";
import { notImplemented } from "../errors.js";

/**
 * Query resolvers. Every entity lookup throws NOT_IMPLEMENTED per the
 * architect's Q-10 ruling for T-P0-003; real implementations arrive
 * with T-P0-007 (person) and later tasks.
 *
 * `_schemaVersion` is the exception: it is a permanent health probe
 * that returns a constant string so CI smoke tests and dev-tooling
 * can confirm the server is live without touching the DB.
 */
export const queryResolvers: QueryResolvers = {
  _schemaVersion: () => "T-P0-003 skeleton",

  person: (_parent, _args, ctx) => {
    throw notImplemented("Query.person", ctx);
  },

  persons: (_parent, _args, ctx) => {
    throw notImplemented("Query.persons", ctx);
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
