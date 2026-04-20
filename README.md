# Aura Monorepo

This repository contains a full-stack scaffold for **Aura**, a social study tracker:

- `apps/api`: Hono + TypeScript API for Vercel and Turso (libSQL)
- `apps/flutter_app`: Cupertino-first Flutter client with Riverpod and offline sync

## Architecture

- **Client:** Flutter (Riverpod `AsyncNotifier`, Hive local storage, Workmanager retries)
- **API:** Hono with Firebase bearer auth middleware + Zod validation
- **Database:** Turso/libSQL (`users`, `study_logs`, `follows`)
- **Delivery:** GitHub Actions for API checks and Android release APK generation

## Quick Start

### 1) Backend

```bash
cd apps/api
cp .env.example .env
npm install
npm run typecheck
npm run test
npm run db:migrate
```

Deploy the API directory to Vercel. `vercel.json` routes all traffic to `api/index.ts`.

### 2) Flutter app

```bash
cd apps/flutter_app
flutter pub get
```

Pass runtime values with `--dart-define` (or `--dart-define-from-file=.env` using the same keys as `.env.example`):

```bash
flutter run \
  --dart-define=AURA_API_BASE_URL=https://your-api-domain.vercel.app \
  --dart-define=AURA_PROFILE_UID=your-firebase-uid
```

Optional Firebase Auth runtime values:

- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`

Without Firebase runtime values, the app can use `AURA_DEV_BEARER_TOKEN` for API calls.

## Database Migration

Initial schema lives in `apps/api/src/db/migrations/001_init.sql`.

Run:

```bash
cd apps/api
npm run db:migrate
```

## CI/CD

- `.github/workflows/api-ci.yml`: installs API dependencies, runs type-check + tests.
- `.github/workflows/flutter-release-apk.yml`: prepares Flutter Android scaffold (if missing), generates a keystore in CI, then builds and uploads a release APK artifact.

## Notes

- Session durations are stored in seconds end-to-end.
- `POST /v1/sync` is idempotent via `INSERT OR IGNORE` by log `id`.
- `GET /v1/feed` uses a single join query to avoid N+1 behavior.
