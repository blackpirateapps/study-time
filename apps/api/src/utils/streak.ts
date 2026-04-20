const DAY_IN_MS = 24 * 60 * 60 * 1000;

export const toUtcDayKey = (value: string | Date): string => {
  const date = value instanceof Date ? value : new Date(value);

  if (Number.isNaN(date.getTime())) {
    return "";
  }

  return date.toISOString().slice(0, 10);
};

export const computeCurrentStreak = (
  timestamps: readonly string[],
  now: Date = new Date(),
): number => {
  const daySet = new Set(
    timestamps
      .map((timestamp) => toUtcDayKey(timestamp))
      .filter((day): day is string => day.length > 0),
  );

  if (daySet.size === 0) {
    return 0;
  }

  let streak = 0;
  let cursor = new Date(
    Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()),
  );

  while (daySet.has(cursor.toISOString().slice(0, 10))) {
    streak += 1;
    cursor = new Date(cursor.getTime() - DAY_IN_MS);
  }

  return streak;
};
