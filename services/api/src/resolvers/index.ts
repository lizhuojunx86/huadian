import type { Resolvers } from "../__generated__/graphql.js";

import { queryResolvers } from "./query.js";
import { scalarResolvers } from "./scalars.js";
import { traceableResolvers } from "./traceable.js";

/**
 * Root resolver map. Entity-level field resolvers (e.g. Person.names,
 * Book.provenanceTier defaulting, SourceEvidence.sourceEvidenceId
 * self-reference) are deliberately NOT defined here in Phase 0 — since
 * no concrete entity ever flows through these resolvers (Query throws
 * NOT_IMPLEMENTED first), wiring them now would be dead code.
 *
 * T-P0-007 adds BookResolvers, PersonResolvers, etc. as real data
 * starts flowing.
 */
export const resolvers: Resolvers = {
  ...scalarResolvers,
  ...traceableResolvers,
  Query: queryResolvers,
};
