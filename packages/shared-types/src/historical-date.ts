import { z } from "zod";

/**
 * HistoricalDate — JSONB structure for all date fields.
 * Supports ranges, lunar calendar, sexagenary cycle, and multi-polity eras.
 * See docs/02 §2.6.
 */
export const historicalDateSchema = z.object({
  year_min: z.number().int().optional(),
  year_max: z.number().int().optional(),
  month: z.number().int().min(1).max(12).optional(),
  day: z.number().int().min(1).max(31).optional(),
  precision: z.enum([
    "day",
    "month",
    "year",
    "year_range",
    "decade",
    "era",
    "unknown",
  ]),
  reign_era: z.string().optional(),
  reign_year: z.number().int().positive().optional(),
  polity_id: z.string().uuid().optional(),
  lunar_month: z.number().int().min(1).max(13).optional(),
  lunar_day: z.number().int().min(1).max(30).optional(),
  sexagenary_year: z.string().optional(),
  season: z.string().optional(),
  original_text: z.string().optional(),
});

export type HistoricalDate = z.infer<typeof historicalDateSchema>;
