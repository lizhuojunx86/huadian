import { randomUUID } from "node:crypto";

import type { PostgresJsDatabase } from "drizzle-orm/postgres-js";

/**
 * Drizzle ORM client handle. The generic record is intentionally kept
 * empty here so that wiring the real schema from @huadian/db-schema in
 * T-P0-007 does not need to touch resolver call sites; resolvers access
 * tables through typed queries, not through this generic.
 */
export type DrizzleClient = PostgresJsDatabase<Record<string, never>>;

/**
 * Minimal Tracer contract. The real type will be @opentelemetry/api
 * Tracer once T-TG-002 lands; Phase 0 resolvers do not use it, so the
 * shape is kept deliberately narrow to avoid premature coupling.
 */
export interface Tracer {
  startSpan(name: string): { end(): void };
}

/**
 * GraphQL request-scoped context. One instance per incoming HTTP request;
 * produced by `createContext` and fed into graphql-yoga.
 *
 * Phase 0 skeleton:
 *   - db          injected but never queried (resolvers throw NOT_IMPLEMENTED)
 *   - requestId   uuid v4 generated here; surfaced to clients as
 *                 extensions.traceId on every HuadianGraphQLError
 *   - tracer      null until T-TG-002 wires OTel
 */
export interface GraphQLContext {
  db: DrizzleClient;
  requestId: string;
  tracer: Tracer | null;
}

export interface ContextDeps {
  db: DrizzleClient;
  tracer?: Tracer | null;
}

/**
 * Factory used by src/index.ts. Separated from `index.ts` so that unit
 * tests (future) can build a context without starting an HTTP server.
 */
export function createContext(deps: ContextDeps): GraphQLContext {
  return {
    db: deps.db,
    requestId: randomUUID(),
    tracer: deps.tracer ?? null,
  };
}
