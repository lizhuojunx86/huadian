import type { Resolvers } from "../__generated__/graphql.js";

/**
 * Traceable interface resolver.
 *
 * Phase 0 skeleton: no Query resolver ever returns a concrete Traceable
 * instance (they all throw NOT_IMPLEMENTED), so __resolveType is never
 * hit at runtime. It still MUST be defined for the generated Resolvers
 * type to type-check.
 *
 * The real implementation arrives with T-P0-007 and will inspect a
 * runtime discriminator (either parent.__typename set by the service
 * layer, or a synthetic tag column from the DB query) to pick one of
 * Book / SourceEvidence / Person / Event / Place.
 */
export const traceableResolvers = {
  Traceable: {
    __resolveType: (parent: unknown) => {
      if (
        parent !== null &&
        typeof parent === "object" &&
        "__typename" in parent &&
        typeof (parent as { __typename: unknown }).__typename === "string"
      ) {
        const typename = (parent as { __typename: string }).__typename;
        if (
          typename === "Book" ||
          typename === "SourceEvidence" ||
          typename === "Person" ||
          typename === "Event" ||
          typename === "Place"
        ) {
          return typename;
        }
      }
      // No concrete instance can reach here in Phase 0; returning null
      // signals the GraphQL executor that the runtime type cannot be
      // resolved, which surfaces as an error — acceptable, because any
      // Traceable value flowing through Phase 0 is a bug.
      return null;
    },
  },
} satisfies Pick<Resolvers, "Traceable">;
