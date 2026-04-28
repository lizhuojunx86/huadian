import type { Resolvers } from "../__generated__/graphql.js";

import { personResolvers } from "./person.js";
import { queryResolvers } from "./query.js";
import { scalarResolvers } from "./scalars.js";
import { traceableResolvers } from "./traceable.js";
import { triageResolvers } from "./triage.js";

/**
 * Root resolver map. T-P0-007 wires Person field resolvers (names,
 * identityHypotheses) alongside the real Query.person / Query.persons
 * implementations. T-P0-028 (Sprint K) adds Triage* + Mutation roots
 * via triageResolvers.
 */
export const resolvers: Resolvers = {
  ...scalarResolvers,
  ...traceableResolvers,
  ...triageResolvers,
  Query: queryResolvers,
  Person: personResolvers,
};
