import { GraphQLError, type GraphQLErrorExtensions } from "graphql";

import type { GraphQLContext } from "./context.js";

/**
 * HuadianErrorCode — every error surfaced to GraphQL clients carries one
 * of these values in `extensions.code`. The set is intentionally small;
 * adding a code requires a PR review so the frontend can update its
 * handling table.
 *
 * The doc comments below are written for frontend consumers: they
 * describe trigger conditions, not server-side causes.
 */
export type HuadianErrorCode =
  /**
   * The resolver is deliberately unimplemented in the current phase.
   * Frontend should treat this as "feature not yet available" and
   * should NOT retry. The error disappears once the backing data path
   * is wired (T-P0-007 and later tasks).
   */
  | "NOT_IMPLEMENTED"
  /**
   * Entity lookup (by slug / id) returned no rows. The entity either
   * never existed or has been soft-deleted. Safe to surface as a
   * user-visible "not found" state.
   */
  | "NOT_FOUND"
  /**
   * Input arguments failed shape or domain validation (format, range,
   * zod schema). Typically maps to a form-level error on the client.
   * `extensions.extra.fields` SHOULD list the failing field paths when
   * known.
   */
  | "VALIDATION_ERROR"
  /**
   * Unexpected server-side failure: unhandled exception, DB outage,
   * upstream dependency degraded. Always correlated with a server-side
   * log line via `extensions.traceId`. Do not show raw `message` to
   * end users.
   */
  | "INTERNAL_ERROR"
  /**
   * Requester lacks the auth state / permission required for this
   * operation. Phase 0 does not enforce auth, so this code MUST NOT be
   * produced by current resolvers; it is reserved for Phase 1 rollout.
   */
  | "UNAUTHORIZED"
  /**
   * Requester exceeded a documented rate limit. Phase 0 does not
   * enforce rate limiting; reserved for Phase 1.
   */
  | "RATE_LIMITED";

/** Shape of the `extensions` object emitted by `HuadianGraphQLError`. */
export interface HuadianErrorExtensions extends GraphQLErrorExtensions {
  code: HuadianErrorCode;
  /**
   * Per-request correlation id. Sourced from GraphQLContext.requestId
   * (uuid v4). Renamed to `traceId` on the wire so it can later map to
   * an OTel trace-id without a breaking change (T-TG-002).
   */
  traceId: string;
  [key: string]: unknown;
}

export interface HuadianGraphQLErrorOptions {
  code: HuadianErrorCode;
  traceId: string;
  /** Optional extra fields merged into `extensions` alongside code/traceId. */
  extra?: Record<string, unknown>;
  /** Original error for server-side logging; NOT sent to the client. */
  cause?: unknown;
}

/**
 * The ONLY error class resolvers in this service should throw. Wraps
 * `GraphQLError` so that every error on the wire carries a stable
 * `code` + `traceId`. Raw `new Error(...)` or `new GraphQLError(...)`
 * in resolvers should be flagged in code review.
 */
export class HuadianGraphQLError extends GraphQLError {
  public readonly code: HuadianErrorCode;
  public readonly traceId: string;

  constructor(message: string, opts: HuadianGraphQLErrorOptions) {
    const extensions: HuadianErrorExtensions = {
      code: opts.code,
      traceId: opts.traceId,
      ...opts.extra,
    };

    const originalError =
      opts.cause instanceof Error
        ? opts.cause
        : opts.cause !== undefined
          ? new Error(String(opts.cause))
          : undefined;

    super(message, { extensions, originalError });

    this.code = opts.code;
    this.traceId = opts.traceId;
  }
}

/**
 * Phase-0 convenience factory: build a NOT_IMPLEMENTED error that
 * reports the GraphQL operation path (e.g. "Query.person") and pulls
 * traceId from the request context.
 */
export function notImplemented(
  operation: string,
  ctx: Pick<GraphQLContext, "requestId">,
): HuadianGraphQLError {
  return new HuadianGraphQLError(
    `${operation} is not implemented in Phase 0 (T-P0-003).`,
    { code: "NOT_IMPLEMENTED", traceId: ctx.requestId },
  );
}
