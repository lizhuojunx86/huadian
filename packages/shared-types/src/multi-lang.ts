import { z } from "zod";

/**
 * Multi-language text structure for user-facing fields (C-12).
 * At minimum, zh-Hans is required. Other languages are optional.
 */
export const multiLangTextSchema = z.object({
  "zh-Hans": z.string().min(1),
  "zh-Hant": z.string().optional(),
  en: z.string().optional(),
});

export type MultiLangText = z.infer<typeof multiLangTextSchema>;
