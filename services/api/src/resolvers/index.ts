import type { Resolvers } from "../__generated__/graphql.js";

import { personResolvers } from "./person.js";
import { queryResolvers } from "./query.js";
import { scalarResolvers } from "./scalars.js";
import { traceableResolvers } from "./traceable.js";

/**
 * Root resolver map. T-P0-007 wires Person field resolvers (names,
 * identityHypotheses) alongside the real Query.person / Query.persons
 * implementations. Other entity resolvers remain stubs.
 */
export const resolvers: Resolvers = {
  ...scalarResolvers,
  ...traceableResolvers,
  Query: queryResolvers,
  Person: personResolvers,
};
