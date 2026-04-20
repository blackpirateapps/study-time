import { Hono } from "hono";
import type { Context } from "hono";

import {
  canAccessProfile,
  ensureUserRecord,
  followUser,
  getFeed,
  getProfileAggregate,
  syncStudyLogs,
  userExists,
} from "../db/repository.js";
import { authMiddleware } from "../middleware/auth.js";
import type { AppBindings } from "../types.js";
import { followPayloadSchema, syncPayloadSchema } from "../validation/schemas.js";

const parseJsonBody = async (c: Context): Promise<unknown | null> => {
  try {
    return await c.req.json();
  } catch {
    return null;
  }
};

export const v1Routes = new Hono<AppBindings>();

v1Routes.use("*", authMiddleware);

v1Routes.post("/sync", async (c) => {
  const body = await parseJsonBody(c);
  if (body === null) {
    return c.json({ error: "Invalid JSON body" }, 400);
  }

  const payload = syncPayloadSchema.safeParse(body);
  if (!payload.success) {
    return c.json(
      {
        error: "Malformed sync payload",
        details: payload.error.flatten(),
      },
      400,
    );
  }

  const user = c.get("user");
  await ensureUserRecord(user);

  const outcome = await syncStudyLogs(user.uid, payload.data);

  return c.json({
    received: payload.data.length,
    inserted: outcome.inserted,
    ignored: outcome.ignored,
  });
});

v1Routes.get("/feed", async (c) => {
  const user = c.get("user");
  await ensureUserRecord(user);

  const sessions = await getFeed(user.uid);

  return c.json({ data: sessions });
});

v1Routes.get("/profile/:uid", async (c) => {
  const requester = c.get("user");
  const targetUid = c.req.param("uid");

  await ensureUserRecord(requester);

  if (!(await userExists(targetUid))) {
    return c.json({ error: "Target user not found" }, 404);
  }

  const allowed = await canAccessProfile(requester.uid, targetUid);
  if (!allowed) {
    return c.json({ error: "Forbidden profile access" }, 403);
  }

  const profile = await getProfileAggregate(targetUid);
  return c.json(profile);
});

v1Routes.post("/follow", async (c) => {
  const body = await parseJsonBody(c);
  if (body === null) {
    return c.json({ error: "Invalid JSON body" }, 400);
  }

  const parsed = followPayloadSchema.safeParse(body);
  if (!parsed.success) {
    return c.json(
      {
        error: "Malformed follow payload",
        details: parsed.error.flatten(),
      },
      400,
    );
  }

  const requester = c.get("user");
  await ensureUserRecord(requester);

  if (requester.uid === parsed.data.target_uid) {
    return c.json({ error: "You cannot follow yourself" }, 400);
  }

  if (!(await userExists(parsed.data.target_uid))) {
    return c.json({ error: "Target user does not exist" }, 404);
  }

  const created = await followUser(requester.uid, parsed.data.target_uid);

  return c.json(
    {
      following_uid: parsed.data.target_uid,
      created,
    },
    created ? 201 : 200,
  );
});
