import { z } from "zod";

export const studyLogInputSchema = z.object({
  id: z.string().uuid(),
  subject: z.string().trim().min(1).max(50),
  tag: z.string().trim().max(50).optional(),
  duration_seconds: z.number().int().min(1).max(43_200),
  timestamp: z.string().datetime({ offset: true }),
});

const syncArraySchema = z.array(studyLogInputSchema).min(1).max(50);

export const syncPayloadSchema = z
  .union([
    syncArraySchema,
    z.object({
      study_logs: syncArraySchema,
    }),
    z.object({
      logs: syncArraySchema,
    }),
  ])
  .transform((payload) => {
    if (Array.isArray(payload)) {
      return payload;
    }

    return "study_logs" in payload ? payload.study_logs : payload.logs;
  });

export const followPayloadSchema = z.object({
  target_uid: z.string().trim().min(1).max(128),
});

export type StudyLogInput = z.infer<typeof studyLogInputSchema>;
export type SyncPayload = z.infer<typeof syncPayloadSchema>;
export type FollowPayload = z.infer<typeof followPayloadSchema>;
