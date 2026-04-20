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
  - accepts array payload or object payload (`{ study_logs: [...] }` / `{ logs: [...] }`)
  - uses transaction-backed libSQL batch writes with `ON CONFLICT(id) DO NOTHING`
  - returns `created_count` so clients can confirm newly inserted rows
  - enforces max batch size 50 and strict UUID requirement for `id`
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
- Phase 2 Core Sync Engine:
  - Isar-backed `StudyLogModel` local persistence (`remoteId`, `isSynced`, `subject`, `tag`, `durationSeconds`, `startTime`)
  - `StudyRepository` source-of-truth methods: `saveSession`, `getUnsyncedLogs`, `markAsSynced`
  - `SyncProvider` orchestrator with offline paused state via `connectivity_plus`
  - Dio-based sync client with Firebase JWT auth for `/v1/sync`
  - exponential backoff retries on 5xx and fixed batch size 50
  - sync triggers on session end, app foreground resume, and pull-to-refresh
  - sync status indicator in `CupertinoSliverNavigationBar` + pending count chip
- Haptics:
  - successful sync completion -> `lightImpact`
- "Things-style" wide magic plus button opens a `CupertinoActionSheet` preset flow.

### CI/CD

- API CI workflow (`typecheck`, `test`).
- Flutter release APK workflow:
  - bootstraps Android/iOS scaffold if missing
  - runs `build_runner` to generate Isar/Freezed code
  - runs `flutter analyze` before artifact generation
  - generates release keystore in CI
  - builds release APK
  - uploads APK artifact

## Known Gaps / Risks

- Vercel runtime is configured as Node serverless (`@vercel/node`) due `firebase-admin` requirements; pure edge runtime is not currently feasible with this auth implementation.
- Foreground/session-triggered sync is implemented; background job scheduling is not part of the current Isar sync engine.
- No end-to-end integration tests yet (API + Flutter + Turso).
- Profile endpoint authorization rule currently allows self plus direct follow relationship either direction.
- Isar and Freezed generated files are CI-generated during workflow; local runs must execute `build_runner` before analyze/build.

## Known Bugs

- Resolved: Flutter release compile error from const-evaluation on `CupertinoTabBar` in `home_screen.dart` (tab bar is now non-const for compatibility with current stable toolchain).
- Resolved: CI build failed with "Cannot run Project.afterEvaluate(Action) when the project is already evaluated." Fixed `.github/workflows/flutter-release-apk.yml` to check `project.state.executed` before applying the Isar namespace patch.
- Resolved: CI build failed with "AAPT: error: resource android:attr/lStar not found" in `isar_flutter_libs` because of incompatible `compileSdkVersion` mixed with new `core-ktx` versions. Fixed by forcing `compileSdkVersion 34` for all subprojects in `.github/workflows/flutter-release-apk.yml`.
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
