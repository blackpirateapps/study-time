# Aura AI Handoff

## Project Snapshot

- Monorepo with:
  - `apps/api`: TypeScript Hono API for Vercel + Turso
  - `apps/flutter_app`: Cupertino-first Flutter app with local-first sync flow
- API and app contracts are aligned on `duration_seconds` and ISO timestamp payloads.

## Implemented Features

### Backend (`apps/api`)

- Firebase bearer-token auth middleware using `firebase-admin`.
- In-memory token cache to reduce repeated `verifyIdToken` overhead.
- Strict CORS with allowlist from `ALLOWED_ORIGINS`.
- Zod validation on all mutation endpoints (`/v1/sync`, `/v1/follow`).
- Turso schema + migration for:
  - `users`
  - `study_logs`
  - `follows`
- `POST /v1/sync`
  - accepts array payload or `{ logs: [...] }`
  - idempotent insert (`INSERT OR IGNORE`) keyed by log `id`
- `GET /v1/feed`
  - single join query for followed users + display names
  - returns 50 most recent sessions
- `GET /v1/profile/:uid`
  - guards access to self or connected users in follow graph
  - returns total hours, current streak, session count
- `POST /v1/follow`
  - blocks self-follow
  - checks target user existence

### Flutter (`apps/flutter_app`)

- Cupertino-only UI and tab flow (`Study`, `Feed`, `Profile`).
- Riverpod `AsyncNotifier` controllers for:
  - study log state/sync
  - feed data
  - profile aggregates
- Local-first session writes via Hive store.
- Background retry scheduler via Workmanager for unsynced logs.
- Haptics:
  - success sync -> `mediumImpact`
  - failure sync -> `heavyImpact`
- "Things-style" wide magic plus button opens a `CupertinoActionSheet` preset flow.

### CI/CD

- API CI workflow (`typecheck`, `test`).
- Flutter release APK workflow:
  - bootstraps Android/iOS scaffold if missing
  - generates release keystore in CI
  - builds release APK
  - uploads APK artifact

## Known Gaps / Risks

- Vercel runtime is configured as Node serverless (`@vercel/node`) due `firebase-admin` requirements; pure edge runtime is not currently feasible with this auth implementation.
- Flutter background sync depends on platform plugin behavior in background isolate; monitor real device behavior.
- No end-to-end integration tests yet (API + Flutter + Turso).
- Profile endpoint authorization rule currently allows self plus direct follow relationship either direction.

## Known Bugs

- None confirmed via runtime execution yet.
- Flutter build and device execution were not run locally in this environment (toolchain unavailable here).

## Operational Guidelines for Future Agents

- Keep `duration_seconds` integer end-to-end; do not convert to minutes in transport layer.
- Maintain idempotency guarantees for `/v1/sync` on retries.
- Preserve API response keys already consumed by Flutter models.
- Keep Flutter UI Cupertino-only unless product requirements change.
- Prefer narrow DB/query changes; feed endpoint must remain single-join and avoid N+1 behavior.

## Recommended Next Enhancements

- Add endpoint-level integration tests with mocked Firebase token verification.
- Add migration tracking table and rollback strategy.
- Add authenticated Flutter onboarding flow (Firebase sign-in UI).
- Add observability (request logs + sync failure metrics).
