import type { PersonResolvers } from "../__generated__/graphql.js";
import {
  findPersonNamesByPersonId,
  findHypothesesByPersonId,
} from "../services/person.service.js";

/**
 * Person field resolvers.
 *
 * For person(slug) queries, names and identityHypotheses are eagerly
 * loaded by the service layer and already present on the parent object.
 * These field resolvers act as a fallback for the persons(limit, offset)
 * list query where only base fields are returned with empty arrays
 * (Q-4 ruling B). The resolver detects this via a `_namesLoaded` flag.
 */
export const personResolvers: PersonResolvers = {
  names: async (parent, _args, ctx) => {
    const p = parent as typeof parent & { _namesLoaded?: boolean };
    if (p._namesLoaded) return parent.names;
    return findPersonNamesByPersonId(ctx.db, parent.id);
  },

  identityHypotheses: async (parent, _args, ctx) => {
    const p = parent as typeof parent & { _hypothesesLoaded?: boolean };
    if (p._hypothesesLoaded) return parent.identityHypotheses;
    return findHypothesesByPersonId(ctx.db, parent.id);
  },
};
