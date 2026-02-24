# LeoConnect — AGENTS.md

Leo Clubs social platform for MD 306 (Sri Lanka & Maldives). Instagram-style app with a feed, chat, clubs directory, follow/unfollow, and Google Auth.

## Project Structure

```
leo_app_flutter/
├── frontend/          Flutter mobile app (Android-first, Pixel 7 Pro dev device)
│   └── lib/
│       ├── main.dart
│       ├── layout/    Bottom nav shell
│       ├── models/    Data models (User, Post, Club, Event)
│       ├── screens/   All UI screens
│       ├── services/  ApiService, StorageService
│       ├── theme/     AppTheme
│       └── widgets/   Shared widget components
└── backend/backend/   Cloudflare Workers API
    └── src/
        ├── index.js         Workers entry (fetch handler)
        ├── app.js           Manual router
        ├── controllers/     Route handlers
        ├── middleware/       Auth middleware
        ├── models/          D1 SQL models
        └── routes/          (Express routes — legacy, unused by Workers)
```

## Tech Stack

- **Frontend:** Flutter 3.41.1, Dart 3.11.0, Riverpod (state), Google Fonts, Phosphor icons
- **Backend:** Cloudflare Workers (ESM), Cloudflare D1 (SQLite), JWT auth, bcryptjs
- **Package manager:** Bun (NOT npm/npx — always use `bun` or `bunx`)
- **Dev device:** Google Pixel 7 Pro via USB (ADB device ID: `36121FDH3001MJ`)

## Local Development Commands

```bash
# Backend — Terminal 1
cd backend/backend && bun run dev         # wrangler dev on :8787

# ADB tunnel — run once per cable reconnect
adb reverse tcp:8787 tcp:8787

# Frontend — Terminal 2
cd frontend && flutter run -d 36121FDH3001MJ

# DB migrations (local)
cd backend/backend && bun run db:migrate

# DB migrations (remote/production)
cd backend/backend && bun run db:migrate:remote
```

## Critical Architecture Rules

### Backend
- The backend runs as a **Cloudflare Worker** — never use Node.js-only APIs (fs, net, process.env via dotenv, etc.)
- `src/index.js` is the Workers entry point. `src/app.js` is the router. `src/server.js` is legacy — do not add to it.
- `src/routes/authRoutes.js` is dead code (Express Router, never imported by Workers). Do not add new routes there. All routes go in `src/app.js`.
- Environment variables come from `env` (the second argument to `fetch(request, env, ctx)`), forwarded as `req.env`. Never use `process.env`.
- D1 is accessed via `req.env.DB` — always use parameterized queries (`?` placeholders), never string interpolation.
- `package.json` has `"type": "commonjs"` but `index.js` and `app.js` use ESM. Wrangler/esbuild bridges this. New files in `src/` should use `export default` / `export const` (ESM) for consistency with the Workers entry.
- JWT secret: always `req.env.JWT_SECRET` with NO fallback. If it's undefined, throw — never silently use a default.

### Frontend
- State management: **Riverpod only**. Do not use `setState` for anything that crosses widget boundaries. Use providers.
- API calls: always go through `ApiService`. Never use `http.get/post` directly in widgets or screens.
- Storage: use `StorageService` for all local persistence. The token key is `auth_token`.
- `baseUrl` in `api_service.dart` is `http://localhost:8787/api/auth` for local dev (ADB reverse handles routing). For production builds, switch to the Workers URL. Never hardcode IPs.
- Images: never store base64 in the database. Use Cloudflare R2 for media — store only the R2 URL.
- Navigation: use `Navigator.pushReplacement` for auth transitions. Avoid `pushAndRemoveUntil` except for logout.

## Code Standards

### Dart / Flutter
- Null safety is required everywhere — no `!` force-unwrap without a null check guard
- All `TextEditingController`, `AnimationController`, `ScrollController` must be disposed in `dispose()`
- Prefer `const` constructors wherever possible
- Widgets over 100 lines should be extracted into separate widget files in `widgets/`
- No hardcoded colors — use `Theme.of(context).colorScheme.*`
- No hardcoded strings in UI — all user-facing strings should be constants or localizable
- `fromJson` / `toJson` required on all model classes
- Use `withValues(alpha: x)` not `.withOpacity(x)` (deprecated)

### JavaScript / Cloudflare Workers
- All async operations must be awaited — no floating promises
- Every route handler must have a try/catch — errors caught in `app.js` top-level handler
- No `console.log` in production code paths — use structured error logging only
- Input validation: all POST/PUT body fields must be validated for type, length, and format before DB access
- SQL: parameterized queries only. No string concatenation into SQL.
- Error responses: never include `error.message` or stack traces in production responses — log internally, return generic message to client

## Security Non-Negotiables

- JWT: no fallback secret. `JWT_SECRET` must be set in `.dev.vars` (local) and Cloudflare dashboard (production)
- Passwords: bcrypt with minimum cost factor 10. Never log or return passwords.
- Tokens: stored in `flutter_secure_storage` (NOT `SharedPreferences`) once migrated
- CORS: `Access-Control-Allow-Methods` must include all methods used (`GET, POST, PUT, DELETE, OPTIONS`)
- Schema migrations: NEVER use `DROP TABLE` in production migrations. Use `ALTER TABLE` or additive-only migrations.
- Media: validate MIME type before storing. Only allow `image/jpeg`, `image/png`, `image/webp`.
- Rate limiting: apply Cloudflare rate limiting on `/api/auth/login` and `/api/auth/register`

## Feature Status (v1 Targets)

### Done (working end-to-end)
- Email register + login
- JWT auth middleware
- Get profile from API
- Bottom nav shell + tab switching
- Dark/light theme

### Broken (fix before v1)
- `updateProfile` reads `req.userId` — must be `req.user.id` (CRIT)
- JWT hardcoded fallback secret (CRIT)
- Google Sign-In is a 2s mock delay — must be real OAuth (CRIT)
- Base64 avatar in DB — must use R2 (CRIT)
- `localhost` baseUrl ships in release build (HIGH)
- Token stored in SharedPreferences — must use flutter_secure_storage (HIGH)
- App always starts at LoginScreen — must check stored token on startup (HIGH)
- No logout button anywhere (HIGH)

### Not yet built (v1 required)
- Posts: create, feed, like, comment
- Clubs: list from DB, follow/unfollow
- Google OAuth (real)
- Token refresh / expiry handling
- R2 media upload
- Messages screen (Phase 2 — can be placeholder in v1)

## D1 Database Schema Reference

Current tables: `users`

Planned tables for v1: `posts`, `post_likes`, `post_comments`, `clubs`, `club_followers`, `events`, `event_attendees`, `follows`

Always add new columns as nullable or with defaults. Never break existing columns.

## Deployment

- Backend: `cd backend/backend && bun run deploy` (runs `wrangler deploy`)
- Frontend: `cd frontend && flutter build apk --release` then distribute via Firebase App Distribution or direct APK
- Production backend URL: `https://leo-app-backend.leo-connect-usj.workers.dev`
