import { describe, expect, it } from "vitest";

import { syncPayloadSchema } from "../src/validation/schemas.js";

describe("syncPayloadSchema", () => {
  it("rejects logs when id is missing", () => {
    const result = syncPayloadSchema.safeParse({
      study_logs: [
        {
          subject: "Math",
          duration_seconds: 1500,
          timestamp: "2026-04-20T10:00:00.000Z",
        },
      ],
    });

    expect(result.success).toBe(false);
  });

  it("accepts optional tag and study_logs payload shape", () => {
    const result = syncPayloadSchema.safeParse({
      study_logs: [
        {
          id: "fd772f20-57c4-45e9-bf8d-7af623ea9b11",
          subject: "Math",
          duration_seconds: 1500,
          timestamp: "2026-04-20T10:00:00.000Z",
        },
      ],
    });

    expect(result.success).toBe(true);
    if (!result.success) {
      return;
    }

    expect(result.data).toHaveLength(1);
    expect(result.data[0]?.tag).toBeUndefined();
  });
});
