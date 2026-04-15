/**
 * TraceGuard QC rule input/output schemas — Phase 0 stub.
 * These zod schemas will be exported to Pydantic for the pipeline.
 */
import { z } from "zod";

export const qcCheckpointSchema = z.object({
  checkpointId: z.string(),
  pipelineRunId: z.string().uuid(),
  stepName: z.string(),
  status: z.enum(["pass", "fail", "warn", "skip"]),
  message: z.string().optional(),
  metadata: z.record(z.unknown()).optional(),
  timestamp: z.string().datetime(),
});

export type QcCheckpoint = z.infer<typeof qcCheckpointSchema>;
