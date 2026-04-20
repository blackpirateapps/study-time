import { cors } from "hono/cors";

import { env } from "../config/env.js";

const allowedOrigins = new Set(env.ALLOWED_ORIGINS);

export const corsMiddleware = cors({
  origin: (origin) => {
    if (!origin) {
      return undefined;
    }

    if (allowedOrigins.has(origin)) {
      return origin;
    }

    return undefined;
  },
  allowHeaders: ["Authorization", "Content-Type"],
  allowMethods: ["GET", "POST", "PUT", "OPTIONS"],
  maxAge: 86_400,
});
