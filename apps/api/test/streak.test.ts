import { describe, expect, it } from "vitest";

import { computeCurrentStreak } from "../src/utils/streak.js";

describe("computeCurrentStreak", () => {
  it("returns 0 when no sessions exist", () => {
    expect(computeCurrentStreak([], new Date("2026-01-10T10:00:00.000Z"))).toBe(0);
  });

  it("counts a streak that includes today", () => {
    const timestamps = [
      "2026-01-10T08:00:00.000Z",
      "2026-01-09T08:00:00.000Z",
      "2026-01-08T08:00:00.000Z",
    ];

    expect(computeCurrentStreak(timestamps, new Date("2026-01-10T10:00:00.000Z"))).toBe(3);
  });

  it("breaks streak when today is missing", () => {
    const timestamps = [
      "2026-01-09T08:00:00.000Z",
      "2026-01-08T08:00:00.000Z",
      "2026-01-06T08:00:00.000Z",
    ];

    expect(computeCurrentStreak(timestamps, new Date("2026-01-10T10:00:00.000Z"))).toBe(0);
  });
});
