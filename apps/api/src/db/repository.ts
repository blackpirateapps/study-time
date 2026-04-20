import { db } from "./client.js";
import type { AuthUser } from "../types.js";
import { computeCurrentStreak } from "../utils/streak.js";
import type { StudyLogInput } from "../validation/schemas.js";

export type FeedSession = {
  id: string;
  user_id: string;
  display_name: string;
  subject: string;
  tag: string;
  duration_seconds: number;
  timestamp: string;
};

export type ProfileAggregate = {
  uid: string;
  total_hours: number;
  current_streak: number;
  total_sessions: number;
};

const safeNumber = (value: unknown): number => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : 0;
};

const safeString = (value: unknown): string => {
  if (typeof value === "string") {
    return value;
  }

  if (value === null || value === undefined) {
    return "";
  }

  return String(value);
};

const fallbackEmail = (user: AuthUser): string => {
  if (user.email && user.email.trim().length > 0) {
    return user.email.trim().toLowerCase();
  }

  return `${user.uid}@placeholder.local`;
};

const fallbackDisplayName = (user: AuthUser): string => {
  if (user.name && user.name.trim().length > 0) {
    return user.name.trim();
  }

  return "Aura Learner";
};

export const ensureUserRecord = async (user: AuthUser): Promise<void> => {
  await db.execute({
    sql: `
      INSERT INTO users (id, email, display_name, created_at)
      VALUES (?, ?, ?, ?)
      ON CONFLICT(id)
      DO UPDATE SET
        email = excluded.email,
        display_name = excluded.display_name
    `,
    args: [
      user.uid,
      fallbackEmail(user),
      fallbackDisplayName(user),
      new Date().toISOString(),
    ],
  });
};

export const userExists = async (uid: string): Promise<boolean> => {
  const result = await db.execute({
    sql: "SELECT id FROM users WHERE id = ? LIMIT 1",
    args: [uid],
  });

  return result.rows.length > 0;
};

export const syncStudyLogs = async (
  userId: string,
  logs: readonly StudyLogInput[],
): Promise<{ inserted: number; ignored: number }> => {
  // Why: write batches in libSQL run as one transaction, so the whole sync batch
  // commits atomically. Combined with ON CONFLICT(id) DO NOTHING this keeps retries
  // idempotent when clients resend after timeouts.
  const statements = logs.map((log) => ({
    sql: `
      INSERT INTO study_logs
        (id, user_id, subject, tag, duration_seconds, timestamp)
      VALUES (?, ?, ?, ?, ?, ?)
      ON CONFLICT(id) DO NOTHING
    `,
    args: [
      log.id,
      userId,
      log.subject,
      log.tag ?? "",
      log.duration_seconds,
      log.timestamp,
    ],
  }));

  const results = await db.batch(statements, "write");
  const inserted = results.reduce(
    (count, result) => count + safeNumber(result.rowsAffected),
    0,
  );

  return {
    inserted,
    ignored: logs.length - inserted,
  };
};

export const getFeed = async (requesterId: string): Promise<FeedSession[]> => {
  const result = await db.execute({
    sql: `
      SELECT
        sl.id,
        sl.user_id,
        u.display_name,
        sl.subject,
        sl.tag,
        sl.duration_seconds,
        sl.timestamp
      FROM follows f
      JOIN study_logs sl
        ON sl.user_id = f.following_id
      JOIN users u
        ON u.id = sl.user_id
      WHERE f.follower_id = ?
      ORDER BY sl.timestamp DESC
      LIMIT 50
    `,
    args: [requesterId],
  });

  return result.rows.map((row) => ({
    id: safeString(row.id),
    user_id: safeString(row.user_id),
    display_name: safeString(row.display_name),
    subject: safeString(row.subject),
    tag: safeString(row.tag),
    duration_seconds: safeNumber(row.duration_seconds),
    timestamp: safeString(row.timestamp),
  }));
};

export const canAccessProfile = async (
  requesterId: string,
  targetId: string,
): Promise<boolean> => {
  if (requesterId === targetId) {
    return true;
  }

  const result = await db.execute({
    sql: `
      SELECT 1 AS allowed
      FROM follows
      WHERE
        (follower_id = ? AND following_id = ?)
        OR
        (follower_id = ? AND following_id = ?)
      LIMIT 1
    `,
    args: [requesterId, targetId, targetId, requesterId],
  });

  return result.rows.length > 0;
};

export const getProfileAggregate = async (
  targetId: string,
): Promise<ProfileAggregate> => {
  const totalsResult = await db.execute({
    sql: `
      SELECT
        COALESCE(SUM(duration_seconds), 0) AS total_seconds,
        COUNT(*) AS total_sessions
      FROM study_logs
      WHERE user_id = ?
    `,
    args: [targetId],
  });

  const totals = totalsResult.rows[0];
  const totalSeconds = safeNumber(totals?.total_seconds);
  const totalSessions = safeNumber(totals?.total_sessions);

  const timestampsResult = await db.execute({
    sql: `
      SELECT timestamp
      FROM study_logs
      WHERE user_id = ?
      ORDER BY timestamp DESC
      LIMIT 400
    `,
    args: [targetId],
  });

  const timestamps = timestampsResult.rows.map((row) => safeString(row.timestamp));
  const currentStreak = computeCurrentStreak(timestamps);

  return {
    uid: targetId,
    total_hours: Number((totalSeconds / 3_600).toFixed(2)),
    current_streak: currentStreak,
    total_sessions: totalSessions,
  };
};

export const followUser = async (
  followerId: string,
  followingId: string,
): Promise<boolean> => {
  const result = await db.execute({
    sql: `
      INSERT OR IGNORE INTO follows (follower_id, following_id)
      VALUES (?, ?)
    `,
    args: [followerId, followingId],
  });

  return safeNumber(result.rowsAffected) > 0;
};
