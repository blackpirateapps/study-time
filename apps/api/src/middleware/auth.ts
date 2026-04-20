import { createMiddleware } from "hono/factory";

import { firebaseAuth } from "../lib/firebase.js";
import type { AppBindings, AuthUser } from "../types.js";

type CachedToken = {
  user: AuthUser;
  expiresAtMs: number;
};

const TOKEN_CACHE = new Map<string, CachedToken>();
const CACHE_SKEW_SECONDS = 30;
const MAX_CACHE_ENTRIES = 2_000;

const cleanExpiredTokens = (now: number): void => {
  for (const [token, value] of TOKEN_CACHE.entries()) {
    if (value.expiresAtMs <= now) {
      TOKEN_CACHE.delete(token);
    }
  }
};

const parseBearerToken = (authorizationHeader: string | undefined): string => {
  if (!authorizationHeader) {
    return "";
  }

  const [scheme, token] = authorizationHeader.split(" ");
  if (scheme !== "Bearer" || !token) {
    return "";
  }

  return token;
};

const verifyAccessToken = async (token: string): Promise<AuthUser> => {
  const now = Date.now();
  const cached = TOKEN_CACHE.get(token);

  if (cached && cached.expiresAtMs > now) {
    return cached.user;
  }

  const decodedToken = await firebaseAuth.verifyIdToken(token);
  const verifiedUser: AuthUser = {
    uid: decodedToken.uid,
    email: decodedToken.email,
    name: decodedToken.name,
  };

  const expiresAtMs = (decodedToken.exp - CACHE_SKEW_SECONDS) * 1000;

  if (TOKEN_CACHE.size >= MAX_CACHE_ENTRIES) {
    cleanExpiredTokens(now);

    if (TOKEN_CACHE.size >= MAX_CACHE_ENTRIES) {
      TOKEN_CACHE.clear();
    }
  }

  TOKEN_CACHE.set(token, {
    user: verifiedUser,
    expiresAtMs,
  });

  return verifiedUser;
};

export const authMiddleware = createMiddleware<AppBindings>(async (c, next) => {
  const token = parseBearerToken(c.req.header("Authorization"));

  if (!token) {
    return c.json({ error: "Missing or invalid Authorization header" }, 401);
  }

  try {
    const verifiedUser = await verifyAccessToken(token);
    c.set("user", verifiedUser);
    await next();
  } catch {
    return c.json({ error: "Unauthorized" }, 401);
  }
});
