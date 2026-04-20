import { z } from "zod";

export const studyLogInputSchema = z.object({
  id: z.string().uuid(),
  subject: z.string().trim().min(1).max(120),
  tag: z.string().trim().min(1).max(60),
  duration_seconds: z.number().int().min(1).max(43_200),
  timestamp: z.string().datetime({ offset: true }),
});

const syncArraySchema = z.array(studyLogInputSchema).min(1).max(500);

export const syncPayloadSchema = z
  .union([
    syncArraySchema,
    z.object({
      logs: syncArraySchema,
    }),
  ])
  .transform((payload) => (Array.isArray(payload) ? payload : payload.logs));

export const followPayloadSchema = z.object({
  target_uid: z.string().trim().min(1).max(128),
});

export type StudyLogInput = z.infer<typeof studyLogInputSchema>;
export type SyncPayload = z.infer<typeof syncPayloadSchema>;
export type FollowPayload = z.infer<typeof followPayloadSchema>;
