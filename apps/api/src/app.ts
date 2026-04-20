import { Hono } from "hono";

import { corsMiddleware } from "./middleware/cors.js";
import { v1Routes } from "./routes/v1.js";
import type { AppBindings } from "./types.js";

const app = new Hono<AppBindings>();

app.use("*", corsMiddleware);

app.get("/", (c) =>
  c.json({
    service: "aura-api",
    status: "ok",
    docs_hint: "Use /v1/* endpoints with Firebase Bearer tokens.",
  }),
);

app.get("/health", (c) => c.json({ status: "ok" }));

app.route("/v1", v1Routes);

app.notFound((c) => c.json({ error: "Route not found" }, 404));

app.onError((error, c) => {
  console.error("Unhandled error:", error);
  return c.json({ error: "Internal server error" }, 500);
});

export default app;
