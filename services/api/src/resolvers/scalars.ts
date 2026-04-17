import {
  DateTimeResolver,
  JSONResolver,
  PositiveIntResolver,
  UUIDResolver,
} from "graphql-scalars";

import type { Resolvers } from "../__generated__/graphql.js";

/**
 * Scalar resolvers. The whitelist below mirrors the R-3 whitelist in
 * src/schema/scalars.graphql — if either side changes, the snapshot
 * diff in CI fails and forces a review.
 */
export const scalarResolvers = {
  DateTime: DateTimeResolver,
  JSON: JSONResolver,
  PositiveInt: PositiveIntResolver,
  UUID: UUIDResolver,
} satisfies Pick<Resolvers, "DateTime" | "JSON" | "PositiveInt" | "UUID">;
