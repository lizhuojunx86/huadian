import { z } from "zod";
import { multiLangTextSchema } from "./multi-lang.js";
import { historicalDateSchema } from "./historical-date.js";

/**
 * Structured JSONB schemas for event_accounts fields.
 * Required by architect review R-7: JSONB fields must have zod schema constraints.
 */

// Participant reference within an event account
export const eventParticipantRefSchema = z.object({
  person_id: z.string().uuid(),
  role: z.string().min(1),
  action: z.string().optional(),
});

export type EventParticipantRef = z.infer<typeof eventParticipantRefSchema>;

// Place reference within an event account
export const eventPlaceRefSchema = z.object({
  place_id: z.string().uuid(),
  role: z.string().min(1),
});

export type EventPlaceRef = z.infer<typeof eventPlaceRefSchema>;

// Sequence step within an event account
export const eventSequenceStepSchema = z.object({
  order: z.number().int().nonnegative(),
  description: multiLangTextSchema,
  time: historicalDateSchema.optional(),
});

export type EventSequenceStep = z.infer<typeof eventSequenceStepSchema>;
