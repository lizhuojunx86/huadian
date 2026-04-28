/**
 * Triage GraphQL resolvers — T-P0-028 Sprint K Stage 2.6 / ADR-027 §4.
 *
 * Wires:
 *   - Query.pendingTriageItems / triageItem / triageDecisionsForSurface / personById
 *   - Mutation.recordTriageDecision (project-first Mutation root)
 *   - TriageItem interface __resolveType (SeedMappingTriage / GuardBlockedMergeTriage)
 *   - Per-implementation field resolvers (lazy-load targetPerson / personA / personB /
 *     dictionaryEntry / historicalDecisions / provenanceTier)
 *
 * Parent type strategy:
 *   The generated TS resolver signature expects parent to be the GraphQL
 *   type (e.g. GuardBlockedMergeTriage). At runtime, the service layer
 *   actually flows a PendingItemRow projection wrapped with __typename.
 *   We use `as unknown as TriageItemParent` casts inside each resolver to
 *   narrow safely; codegen mapper override is deferred to a future ADR
 *   to avoid churning the codegen config for one feature.
 */
import type {
  ProvenanceTier,
  QueryResolvers,
  Resolvers,
  TriageDecisionType,
  TriageItemTypeFilter,
} from "../__generated__/graphql.js";
import type { DrizzleClient } from "../context.js";
import { HuadianGraphQLError } from "../errors.js";
import { toGraphQLPerson } from "../services/person.service.js";
import {
  decodeTriageItemId,
  deriveGuardMergeProvenance,
  deriveSeedMappingProvenance,
  findDecisionsForSource,
  findDecisionsForSurface,
  findDictionaryEntry,
  findPersonRowById,
  findTriageItemById,
  listPendingTriageItems,
  recordTriageDecision,
  type PendingItemRow,
} from "../services/triage.service.js";

// ---------------------------------------------------------------------------
// Internal projection shapes — what each TriageItem implementation receives
// as its `parent` in field resolvers (carries the raw PendingItemRow plus a
// __typename discriminator for __resolveType + downcast safety).
// ---------------------------------------------------------------------------

type SeedMappingTriageParent = PendingItemRow & {
  __typename: "SeedMappingTriage";
};

type GuardBlockedMergeTriageParent = PendingItemRow & {
  __typename: "GuardBlockedMergeTriage";
};

type TriageItemParent =
  | SeedMappingTriageParent
  | GuardBlockedMergeTriageParent;

function asTriageParent(parent: unknown): TriageItemParent {
  return parent as unknown as TriageItemParent;
}

function asSeedParent(parent: unknown): SeedMappingTriageParent {
  return parent as unknown as SeedMappingTriageParent;
}

function asGuardParent(parent: unknown): GuardBlockedMergeTriageParent {
  return parent as unknown as GuardBlockedMergeTriageParent;
}

export function rowToParent(row: PendingItemRow): TriageItemParent {
  if (row.kind === "seed_mapping") {
    return { ...row, __typename: "SeedMappingTriage" };
  }
  return { ...row, __typename: "GuardBlockedMergeTriage" };
}

// ---------------------------------------------------------------------------
// Resolvers
// ---------------------------------------------------------------------------

export const triageResolvers: Pick<
  Resolvers,
  | "TriageItem"
  | "SeedMappingTriage"
  | "GuardBlockedMergeTriage"
  | "Mutation"
> = {
  // -------------------------------------------------------------------------
  // Interface __resolveType — discriminator for the GraphQL executor
  // -------------------------------------------------------------------------
  TriageItem: {
    __resolveType: (parent: unknown) => {
      if (
        parent !== null &&
        typeof parent === "object" &&
        "__typename" in parent
      ) {
        const t = (parent as { __typename: unknown }).__typename;
        if (t === "SeedMappingTriage" || t === "GuardBlockedMergeTriage") {
          return t;
        }
      }
      return null;
    },
  },

  // -------------------------------------------------------------------------
  // SeedMappingTriage field resolvers
  // -------------------------------------------------------------------------
  SeedMappingTriage: {
    id: (parent) => asTriageParent(parent).itemId,
    sourceTable: (parent) => asTriageParent(parent).sourceTable,
    sourceId: (parent) => asTriageParent(parent).sourceId,
    surface: (parent) => asTriageParent(parent).surface,
    pendingSince: (parent) =>
      asTriageParent(parent).pendingSince.toISOString(),
    suggestedDecision: (): TriageDecisionType | null => null,
    historicalDecisions: async (parent, _args, ctx) => {
      const p = asTriageParent(parent);
      return findDecisionsForSource(ctx.db, p.sourceTable, p.sourceId);
    },
    updatedAt: async (parent, _args, ctx) => {
      const p = asTriageParent(parent);
      const decisions = await findDecisionsForSource(
        ctx.db,
        p.sourceTable,
        p.sourceId,
      );
      const latest = decisions[0];
      if (latest) return latest.decidedAt;
      return p.pendingSince.toISOString();
    },

    // SeedMapping-specific
    confidence: (parent) => {
      const raw = asSeedParent(parent).rawConfidence;
      return raw == null ? 0 : Number(raw);
    },
    mappingMethod: (parent) =>
      asSeedParent(parent).rawMappingMethod ?? "unknown",
    mappingMetadata: (parent) =>
      asSeedParent(parent).rawMappingNotes ?? null,

    targetPerson: async (parent, _args, ctx) => {
      const targetId = asSeedParent(parent).rawTargetEntityId;
      if (!targetId) {
        throw new HuadianGraphQLError(
          "SeedMappingTriage.targetPerson cannot be resolved (no target_entity_id)",
          { code: "INTERNAL_ERROR", traceId: ctx.requestId },
        );
      }
      const row = await findPersonRowById(ctx.db, targetId);
      if (!row) {
        throw new HuadianGraphQLError(
          "SeedMappingTriage.targetPerson not found (canonical resolution failed)",
          { code: "NOT_FOUND", traceId: ctx.requestId },
        );
      }
      return {
        ...toGraphQLPerson(row),
        names: [],
        identityHypotheses: [],
      };
    },

    dictionaryEntry: async (parent, _args, ctx) => {
      const entryId = asSeedParent(parent).rawDictionaryEntryId;
      if (!entryId) {
        throw new HuadianGraphQLError(
          "SeedMappingTriage.dictionaryEntry cannot be resolved (no dictionary_entry_id)",
          { code: "INTERNAL_ERROR", traceId: ctx.requestId },
        );
      }
      const dto = await findDictionaryEntry(ctx.db, entryId);
      if (!dto) {
        throw new HuadianGraphQLError(
          "SeedMappingTriage.dictionaryEntry not found",
          { code: "NOT_FOUND", traceId: ctx.requestId },
        );
      }
      return dto;
    },

    // Provenance derivation per architect ACK
    provenanceTier: async (parent, _args, ctx): Promise<ProvenanceTier> => {
      const targetId = asSeedParent(parent).rawTargetEntityId;
      if (!targetId) return "unverified" as ProvenanceTier;
      const { provenanceTier } = await deriveSeedMappingProvenance(
        ctx.db,
        targetId,
      );
      return provenanceTier;
    },
    sourceEvidenceId: async (parent, _args, ctx) => {
      const targetId = asSeedParent(parent).rawTargetEntityId;
      if (!targetId) return null;
      const { sourceEvidenceId } = await deriveSeedMappingProvenance(
        ctx.db,
        targetId,
      );
      return sourceEvidenceId;
    },
  },

  // -------------------------------------------------------------------------
  // GuardBlockedMergeTriage field resolvers
  // -------------------------------------------------------------------------
  GuardBlockedMergeTriage: {
    id: (parent) => asTriageParent(parent).itemId,
    sourceTable: (parent) => asTriageParent(parent).sourceTable,
    sourceId: (parent) => asTriageParent(parent).sourceId,
    surface: (parent) => asTriageParent(parent).surface,
    pendingSince: (parent) =>
      asTriageParent(parent).pendingSince.toISOString(),
    suggestedDecision: (): TriageDecisionType | null => null,
    historicalDecisions: async (parent, _args, ctx) => {
      const p = asTriageParent(parent);
      return findDecisionsForSource(ctx.db, p.sourceTable, p.sourceId);
    },
    updatedAt: async (parent, _args, ctx) => {
      const p = asTriageParent(parent);
      const decisions = await findDecisionsForSource(
        ctx.db,
        p.sourceTable,
        p.sourceId,
      );
      const latest = decisions[0];
      if (latest) return latest.decidedAt;
      return p.pendingSince.toISOString();
    },

    // GuardBlockedMerge-specific
    proposedRule: (parent) => asGuardParent(parent).rawProposedRule ?? "unknown",
    guardType: (parent) => asGuardParent(parent).rawGuardType ?? "unknown",
    guardPayload: (parent) => asGuardParent(parent).rawGuardPayload ?? {},
    evidence: (parent) => asGuardParent(parent).rawEvidence ?? {},

    personA: async (parent, _args, ctx) => {
      const id = asGuardParent(parent).rawPersonAId;
      if (!id) {
        throw new HuadianGraphQLError(
          "GuardBlockedMergeTriage.personA cannot be resolved",
          { code: "INTERNAL_ERROR", traceId: ctx.requestId },
        );
      }
      const row = await findPersonRowById(ctx.db, id);
      if (!row) {
        throw new HuadianGraphQLError(
          "GuardBlockedMergeTriage.personA not found",
          { code: "NOT_FOUND", traceId: ctx.requestId },
        );
      }
      return {
        ...toGraphQLPerson(row),
        names: [],
        identityHypotheses: [],
      };
    },

    personB: async (parent, _args, ctx) => {
      const id = asGuardParent(parent).rawPersonBId;
      if (!id) {
        throw new HuadianGraphQLError(
          "GuardBlockedMergeTriage.personB cannot be resolved",
          { code: "INTERNAL_ERROR", traceId: ctx.requestId },
        );
      }
      const row = await findPersonRowById(ctx.db, id);
      if (!row) {
        throw new HuadianGraphQLError(
          "GuardBlockedMergeTriage.personB not found",
          { code: "NOT_FOUND", traceId: ctx.requestId },
        );
      }
      return {
        ...toGraphQLPerson(row),
        names: [],
        identityHypotheses: [],
      };
    },

    // Provenance derivation per architect ACK — uses pending_merge_reviews.evidence JSONB
    provenanceTier: async (parent, _args, ctx): Promise<ProvenanceTier> => {
      const evidence = asGuardParent(parent).rawEvidence;
      const { provenanceTier } = await deriveGuardMergeProvenance(
        ctx.db,
        evidence,
      );
      return provenanceTier;
    },
    sourceEvidenceId: async (parent, _args, ctx) => {
      const evidence = asGuardParent(parent).rawEvidence;
      const { sourceEvidenceId } = await deriveGuardMergeProvenance(
        ctx.db,
        evidence,
      );
      return sourceEvidenceId;
    },
  },

  // -------------------------------------------------------------------------
  // Mutation root (project-first)
  // -------------------------------------------------------------------------
  Mutation: {
    recordTriageDecision: async (_parent, { input }, ctx) => {
      return recordTriageDecision(ctx.db, input);
    },
  },
};

// ---------------------------------------------------------------------------
// Query resolver fragments — merged into queryResolvers in resolvers/query.ts
//
// Return types are cast to QueryResolvers field types because we ferry
// PendingItemRow projections (with __typename) where the generated types
// expect concrete GraphQL types. __resolveType + field resolvers downcast
// the parent at runtime; codegen mapper override deferred.
// ---------------------------------------------------------------------------

export const triageQueryFragment: Pick<
  QueryResolvers,
  "pendingTriageItems" | "triageItem" | "triageDecisionsForSurface" | "personById"
> = {
  pendingTriageItems: (async (
    _parent: unknown,
    args: {
      limit?: number | null;
      offset?: number | null;
      filterByType?: TriageItemTypeFilter | null;
      filterBySurface?: string | null;
    },
    ctx: { db: DrizzleClient },
  ) => {
    const result = await listPendingTriageItems(
      ctx.db,
      args.limit ?? 50,
      args.offset ?? 0,
      {
        filterByType: args.filterByType ?? null,
        filterBySurface: args.filterBySurface ?? null,
      },
    );
    return {
      items: result.rawRows.map(rowToParent),
      totalCount: result.totalCount,
      hasMore: result.hasMore,
    };
  }) as unknown as QueryResolvers["pendingTriageItems"],

  triageItem: (async (
    _parent: unknown,
    { id }: { id: string },
    ctx: { db: DrizzleClient },
  ) => {
    if (!decodeTriageItemId(id)) return null;
    const row = await findTriageItemById(ctx.db, id);
    if (!row) return null;
    return rowToParent(row);
  }) as unknown as QueryResolvers["triageItem"],

  triageDecisionsForSurface: (async (
    _parent: unknown,
    {
      surface,
      limit,
    }: { surface: string; limit?: number | null },
    ctx: { db: DrizzleClient },
  ) => findDecisionsForSurface(ctx.db, surface, limit ?? 10)) as unknown as QueryResolvers["triageDecisionsForSurface"],

  personById: (async (
    _parent: unknown,
    { id }: { id: string },
    ctx: { db: DrizzleClient },
  ) => {
    const row = await findPersonRowById(ctx.db, id);
    if (!row) return null;
    return {
      ...toGraphQLPerson(row),
      names: [],
      identityHypotheses: [],
    };
  }) as unknown as QueryResolvers["personById"],
};
