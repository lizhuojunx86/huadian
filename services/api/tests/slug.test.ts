import { describe, expect, it } from "vitest";
import { validateSlug } from "../src/utils/slug.js";
import { HuadianGraphQLError } from "../src/errors.js";

const TRACE_ID = "test-trace-id";

describe("validateSlug", () => {
  it("accepts valid slugs", () => {
    expect(() => validateSlug("liu-bang", TRACE_ID)).not.toThrow();
    expect(() => validateSlug("sima-qian", TRACE_ID)).not.toThrow();
    expect(() => validateSlug("abc", TRACE_ID)).not.toThrow();
    expect(() => validateSlug("a1-b2-c3", TRACE_ID)).not.toThrow();
    expect(() => validateSlug("x", TRACE_ID)).not.toThrow();
    expect(() => validateSlug("a123", TRACE_ID)).not.toThrow();
  });

  it("rejects uppercase characters", () => {
    expect(() => validateSlug("Liu-Bang", TRACE_ID)).toThrow(HuadianGraphQLError);
  });

  it("rejects spaces", () => {
    expect(() => validateSlug("liu bang", TRACE_ID)).toThrow(HuadianGraphQLError);
  });

  it("rejects leading hyphen", () => {
    expect(() => validateSlug("-start", TRACE_ID)).toThrow(HuadianGraphQLError);
  });

  it("rejects trailing hyphen", () => {
    expect(() => validateSlug("end-", TRACE_ID)).toThrow(HuadianGraphQLError);
  });

  it("rejects consecutive hyphens", () => {
    expect(() => validateSlug("a--b", TRACE_ID)).toThrow(HuadianGraphQLError);
  });

  it("rejects empty string", () => {
    expect(() => validateSlug("", TRACE_ID)).toThrow(HuadianGraphQLError);
  });

  it("rejects special characters", () => {
    expect(() => validateSlug("a@b", TRACE_ID)).toThrow(HuadianGraphQLError);
    expect(() => validateSlug("a/b", TRACE_ID)).toThrow(HuadianGraphQLError);
  });

  it("includes VALIDATION_ERROR code in thrown error", () => {
    try {
      validateSlug("INVALID!", TRACE_ID);
      expect.unreachable("should have thrown");
    } catch (e) {
      expect(e).toBeInstanceOf(HuadianGraphQLError);
      expect((e as HuadianGraphQLError).code).toBe("VALIDATION_ERROR");
      expect((e as HuadianGraphQLError).traceId).toBe(TRACE_ID);
    }
  });
});
