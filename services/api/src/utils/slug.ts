import { HuadianGraphQLError, type HuadianErrorCode } from "../errors.js";

/**
 * Slug format: lowercase alphanumeric segments separated by single hyphens.
 * Matches C-13 URL stability requirement.
 *
 * Valid:   "liu-bang", "sima-qian", "abc", "a1-b2"
 * Invalid: "Liu-Bang", "a--b", "-start", "end-", "has space", ""
 */
const SLUG_RE = /^[a-z0-9]+(-[a-z0-9]+)*$/;

/**
 * Validate a slug string. Throws VALIDATION_ERROR if invalid.
 * Reusable across person / event / place resolvers.
 */
export function validateSlug(
  slug: string,
  traceId: string,
): void {
  if (!SLUG_RE.test(slug)) {
    throw new HuadianGraphQLError(
      `Invalid slug format: "${slug}". Slugs must be lowercase alphanumeric segments separated by hyphens.`,
      {
        code: "VALIDATION_ERROR" satisfies HuadianErrorCode,
        traceId,
        extra: { fields: ["slug"] },
      },
    );
  }
}
