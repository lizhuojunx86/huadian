import { z } from "zod";

/**
 * Example shared type — Person entity stub.
 * This will be expanded in T-P0-002 (DB Schema) with real fields.
 * Demonstrates: zod definition → JSON Schema export → Pydantic generation.
 */
export const personSchema = z.object({
  id: z.string().uuid(),
  name: z.object({
    zh: z.string().min(1),
    en: z.string().optional(),
  }),
  dynasty: z.string().optional(),
  birthYear: z.number().int().optional(),
  deathYear: z.number().int().optional(),
});

export type Person = z.infer<typeof personSchema>;
