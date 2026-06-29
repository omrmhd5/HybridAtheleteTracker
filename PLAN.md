# Hybrid Athlete Tracker — Working Plan

A living scratchpad for what's done and what's next. Edit freely; check items off
as we go. Last updated: 2026-06-29.

---

## Where things stand

**Architecture:** Flutter app → Node/Express API (`backend/`) → Supabase
(Postgres + Supabase Auth). AI tips/coach via Google Gemini (`gemini-3.1-flash-lite`).

**Done & verified**
- ✅ Backend migrated MongoDB → Supabase. API contract unchanged (`_id`,
  camelCase, ISO dates) via `backend/src/utils/mappers.js`.
- ✅ Supabase Auth with `register` / `login` / `refresh` → `{ token, refreshToken }`.
- ✅ Flutter refresh-token support (storage + Dio 401-retry interceptor).
- ✅ Hi-fi UI redesign (onboarding, plan, food camera/fuel-detail, live lift log,
  shared `widgets/common` library, new theme/constants).
- ✅ Android cleartext-HTTP fix (`network_security_config.xml`).
- ✅ API smoke test passes end-to-end (register → CRUD → dashboard → refresh → 401).
- ✅ AI Coach responds via Gemini.
- ✅ Merged to `main` (commit `239b790`) and pushed.

**Supabase project:** `hybrid-athlete-tracker` (ref `dffojymvzlcvpndqccey`,
eu-west-1, org Hazem23H). Secrets in `backend/.env` (gitignored); template in
`backend/.env.example`. Schema: `backend/supabase/schema.sql`.

**Not yet done**
- ❌ Full app end-to-end run on the emulator (onboarding → register → log →
  reload-persistence → token-refresh).
- ❌ Backend is local-only (`localhost:3000`); not deployed.
- ❌ Several screens are still UI-only / mock data (see below).
- ❌ No automated tests, no CI.

---

## Open questions (decide before building)
- **Hosting:** where should the backend live? (Railway / Render / Fly.io /
  Supabase Edge Functions). Affects `ApiConstants.baseUrl`.
- **Plan feature:** is the weekly "plan" a real backend feature or staying mock
  for the demo? (`plan_screen.dart` notes "no backend plan endpoint yet".)
- **Food camera:** is `camera_screen.dart` meant to do real photo→macro
  estimation (e.g. Gemini vision), or is it a mock for now?
- **Security:** the Supabase service-role key and Gemini key were pasted in chat.
  They're gitignored, but consider rotating them in the dashboards if this repo
  or chat is ever shared.

---

## Candidate next steps

### A. Verify the app actually works (fast, high value)
- [ ] Run on `emulator-5554` against the local backend (full rebuild, not hot
      reload — cleartext fix needs it).
- [ ] Walk the flow: onboarding → register → log a meal/workout → reload to
      confirm persistence → force a 401 to confirm refresh.
- [ ] Fix whatever breaks.

### B. Deploy the backend (so the app isn't tied to one laptop)
- [ ] Pick a host; deploy `backend/`.
- [ ] Set env vars on the host (Supabase URL/keys, Gemini key).
- [ ] Point `ApiConstants.baseUrl` at the deployed URL (keep local override for dev).

### C. Wire up the mock screens
- [ ] Plan screen → real endpoint, or confirm it stays mock.
- [ ] Food camera → real macro estimation (Gemini vision?) or confirm mock.
- [ ] Fuel detail screen → confirm data source.
- [ ] Onboarding → persist answers (`onboarding_service.dart`) and feed targets.

### D. Robustness & polish
- [ ] Single-flight token refresh (avoid parallel 401s each firing a refresh).
- [ ] Consistent loading/error states across screens.
- [ ] Backend input validation on write endpoints.

### E. Quality / infra
- [ ] Backend tests (auth + one CRUD path + dashboard aggregation).
- [ ] Flutter widget/unit tests for providers.
- [ ] CI (lint + test on push).

---

## Decisions log
- 2026-06-29: Migrated backend MongoDB → Supabase; kept Express + Flutter
  contract; added refresh tokens. New dedicated Supabase project (the existing
  org project `quauyzfaswwdjihdnnpp` belongs to an unrelated app — leave it).
- 2026-06-29: AI model = `gemini-3.1-flash-lite`.
