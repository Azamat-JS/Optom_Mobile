# bsmart — Project Reference

Single source of truth for this Flutter app's architecture, roadmap, and progress.
**Before resuming work after any break, read this file first.**
**After any significant decision or milestone, update this file.**

---

## Project Overview

**What this is:** `bsmart` is a native Flutter mobile app (Android + iOS) for **Optom Savdo**, a
multi-tenant B2B2C wholesale-trade platform for the Uzbekistan market. Today Optom Savdo's only
"mobile" surface is a thin Telegram Bot + Mini App bolted onto its Next.js web app — bsmart is
meant to become the real native app that replaces that.

**Business domain** (inherited from Optom Savdo — see reference doc pointer below): wholesalers
(`SELLER`) sell in bulk to retailers (`RETAILER`, 8 business verticals), who resell to end
customers (`CUSTOMER`). **Debt tracking is the core value proposition** — every unpaid sale creates
a debt record, at either the B2B (wholesaler↔retailer) or B2C (retailer↔customer) hop.

**Reference project — READ-ONLY, NEVER MODIFY:** `../Optom_Savdo` (sibling directory,
`/Users/azamatabdullayev/Desktop/optom-mobile/Optom_Savdo`). It is a Next.js + NestJS/Prisma/
PostgreSQL monorepo that bsmart consumes as its backend API. Its own `CLAUDE.md` (very large,
~1300 lines) is the authoritative doc for backend/business-domain details — read it (or spot-check
its source files directly) whenever a screen needs an exact endpoint path, DTO shape, or business
rule not already captured below. **bsmart's own backend calls must never assume a shape — verify
against the actual controller/DTO/Prisma schema in that repo, or its Swagger docs at `/api/docs`,
before writing a data-layer model.**

**Rollout strategy (see "Roadmap" below):** phased, **operator-core first**. Build SELLER/RETAILER
(+ their `_ADMIN` staff) screens before CUSTOMER, SUPER_ADMIN, or the WAITER/COURIER/restaurant
vertical. Reach full feature parity with the web app before extending beyond it (push
notifications, real payment gateway, OTP login — see "Backend-Enhancement Track" below).

---

## Technology Stack

- **Flutter** (mobile only — Android + iOS; `web`/`linux`/`macos`/`windows` platform folders were
  deliberately removed from this project, see `.metadata`).
- **State management:** `flutter_riverpod`, **hand-written** `Notifier`/`AsyncNotifier` classes —
  **not** `@riverpod` code-gen. See "Known Toolchain Deviations" below for why.
- **Dependency injection:** `get_it`, manually wired in `lib/core/di/injection.dart` (not
  `injectable` code-gen — same reason, see below). One `GetIt` instance; Riverpod providers are the
  only consumers of it (`getIt<X>()` inside a provider/notifier body) — DI wiring and reactive UI
  state are kept as separate concerns on purpose.
- **Architecture style:** **Clean Architecture + SOLID**, feature-first. Every feature folder under
  `lib/features/<name>/` has its own `data/` (datasources, models, repository impl) / `domain/`
  (entities, abstract repository, use cases) / `presentation/` (providers, screens, widgets) split.
  Presentation and data never talk directly — always through the domain's abstract repository,
  resolved via `get_it` (Dependency Inversion).
- **Networking:** `dio`, with a hand-rolled interceptor chain in `lib/core/network/` mirroring the
  reference web app's `apps/frontend/src/lib/api/client.ts` exactly: `AuthInterceptor` (Bearer
  token), `ActiveStoreInterceptor` (`X-Store-Id` header for owner roles), `RefreshInterceptor`
  (single-flight 401 refresh + retry, via a separate interceptor-free "bare" Dio instance).
- **Routing:** `go_router`, single source of truth for "where should the user be right now" via
  its `redirect` callback reacting to `sessionNotifierProvider` — screens never call
  `context.go(...)` after login/logout themselves.
- **Local storage:** `flutter_secure_storage` for JWT tokens (sensitive); `shared_preferences` for
  the non-sensitive active-store selection; `hive_ce`/`hive_ce_flutter` reserved for **read-cache
  only** (see "Offline Strategy" below) — not yet wired into any feature as of this writing.
- **Forms:** `reactive_forms`. **Barcode scanning:** `mobile_scanner` (native camera, ML Kit —
  replaces the web app's ZXing-WASM workaround; see its iOS simulator caveat below). **Charts:**
  `fl_chart`. **Animation:** `flutter_animate`, `lottie`, `shimmer` — animations are a first-class
  requirement per the user's explicit ask, not decoration; see `core/theme/app_motion.dart` for the
  shared timing/curve constants every screen should use.
- **Backend:** the *existing* Optom Savdo NestJS/PostgreSQL API, consumed as-is (never modified).
  No Firebase, no third-party BaaS — the explicit user decision is that any future backend
  extension (push, payments, OTP) stays on the **same self-hosted NestJS + PostgreSQL stack**, as a
  new sibling service, not a Firebase dependency. See "Backend-Enhancement Track" below.
- **API base URL / config:** `flutter_dotenv`, reading `.env` (gitignored; copy from `.env.example`
  — currently just `API_BASE_URL`). Declared as a Flutter asset in `pubspec.yaml` — **if you ever
  rewrite `pubspec.yaml` wholesale, do not drop the `flutter: assets: - .env` section**; doing so
  once already caused a runtime `FileNotFoundError` on app launch (caught by actually running the
  app on an emulator, not by `flutter analyze`).

---

## Known Toolchain Deviations (read before adding code-gen back)

As of this writing (Flutter 3.41.8 / Dart 3.11.5), **`riverpod_generator`'s dependency chain is
broken**: `riverpod_generator` → `riverpod_analyzer_utils` → `custom_lint_core` → `analyzer_plugin
0.12.0`, and `analyzer_plugin 0.12.0` fails to compile against the `analyzer 7.6.0` this SDK
resolves (uses old `Element` APIs the newer analyzer no longer fully supports internally in that
file). This broke `dart run build_runner build` entirely (fails at the "compiling the build
script" stage, before any of our own code is even touched) — not just riverpod_lint's own analysis.

**Resolution taken:** removed `riverpod_generator`, `riverpod_annotation`, `custom_lint`,
`riverpod_lint`, `injectable`, `injectable_generator`, `freezed`, `freezed_annotation`,
`json_annotation`, `json_serializable`, `hive_ce_generator`, and `build_runner` entirely from
`pubspec.yaml`. Every provider in this codebase is a **hand-written** `class Foo extends
AsyncNotifier<T> { ... }` + `final fooProvider = AsyncNotifierProvider<Foo, T>(Foo.new);` pair —
functionally identical to the generated form, just without the annotation sugar. Every domain
entity/data model is a **plain hand-written Dart class** with a manual `fromJson`/`toJson` where
needed — no `freezed`/`json_serializable` codegen.

**Do not re-add these packages without first checking whether the upstream incompatibility is
fixed** (try `dart run build_runner build --delete-conflicting-outputs` in a scratch branch; if it
fails at "Compiling the build script" citing `analyzer_plugin`/`Element2`, it's still broken).
`analysis_options.yaml` has a comment recording this too.

**Second toolchain gotcha (device-specific, not fixable):** `mobile_scanner`'s iOS podspec
(`GoogleMLKit/BarcodeScanning`) excludes `arm64` for the `iphonesimulator` SDK
(`EXCLUDED_ARCHS[sdk=iphonesimulator*] = 'i386 armv7 arm64'`) — Google's MLKit XCFrameworks don't
ship an arm64-simulator slice. **This means the app cannot run on an Apple-Silicon iOS Simulator
at all** (fails with "Module 'mobile_scanner' not found") as long as `mobile_scanner` is a
dependency. It works fine on: real iOS devices, and Android (emulator or device) — verification
during development should default to the **Android emulator** for this reason. Confirmed via an
actual `flutter run` attempt, not a hypothetical — see Progress Log 2026-09-22.

---

## App Architecture

### Directory layout (`lib/`)
```
main.dart          → just calls bootstrap()
bootstrap.dart      → env load, Hive init, DI setup, runApp(ProviderScope(BsmartApp()))
app.dart            → MaterialApp.router, theme

core/
  di/injection.dart           → the one GetIt instance + setupDependencyInjection()
  network/
    dio_client.dart           → createBareDio() / createMainDio() (+interceptors)
    interceptors/             → auth, active-store, refresh
    api_exception.dart        → typed failures (Validation/Unauthorized/Forbidden/NotFound/Conflict/Network/Unknown)
    dio_error_mapper.dart     → DioException -> ApiException
    result.dart               → Result<T> (Ok/Err) sealed type every repository returns
    auth_event_bus.dart       → lets RefreshInterceptor signal forced-logout to SessionNotifier
                                 without core depending on features/auth
  storage/
    secure_token_storage.dart → JWT tokens (flutter_secure_storage)
    active_store_storage.dart → active store id (shared_preferences)
    hive_boxes.dart           → Hive box registry (read-cache, not yet used by any feature)
  router/
    app_router.dart           → go_router + redirect logic (the single source of navigation truth)
    route_names.dart, transitions.dart
  theme/app_theme.dart, app_motion.dart
  config/env.dart             → API_BASE_URL from .env
  enums/user_role.dart, business_type.dart, currency.dart   → mirror backend Prisma enums exactly
  utils/jwt_decoder.dart      → local JWT payload decode (no signature check needed client-side)

features/
  auth/
    data/{datasources,models,repositories}/
    domain/{entities,repositories,usecases}/
    presentation/{providers,screens,widgets}/
  active_store/
    presentation/active_store_notifier.dart   → thin, will grow real data/domain layers in Milestone 6
  dashboard/
    presentation/screens/home_screen.dart     → placeholder landing screen (see Progress Log)

shared/widgets/    → empty so far; put generic cross-feature widgets here (empty states, error views, shimmer lists, currency badges, role gates) as they're needed
```

Every future feature (`products`, `categories`, `orders`, `customers`, `sales_pos`, `debts`,
`payments`, `stores`, `staff_admins`, `expenditures`, `reports`, ...) follows the exact same
`data/domain/presentation` shape as `features/auth/` — copy its structure rather than inventing a
new one. This mirrors the reference web app's own proven module boundary (its 24
`lib/api/endpoints/*.api.ts` files ↔ the backend's 24 NestJS modules) — one Flutter feature folder
per backend module.

### Session / auth model
`Session` (`features/auth/domain/entities/session.dart`) mirrors the backend JWT payload exactly:
`userId` (`sub`), `role`, `managedUserId?` (set for `_ADMIN`/`WAITER`/`COURIER` — means "this
session shares its owner's tenant data"), `storeId?` (set only for locked staff), `canAccessPos`,
`ownerRole?`, `businessType?`. `User` (`domain/entities/user.dart`) is the richer profile object
(name, phone, shopName, courier settings, ...) from the login response or `GET /auth/me`.

`SessionNotifier` (`features/auth/presentation/providers/session_notifier.dart`) is the single
source of truth for auth state app-wide (`AuthState { session, user }`) — `sessionNotifierProvider`
is watched by `app_router.dart`'s redirect logic and should be watched by any screen/`RoleGate`
widget that needs to know the current role or hide owner-only actions from `_ADMIN` staff.

**No self-registration for SELLER/RETAILER.** `POST /auth/register` on the backend always creates
a `CUSTOMER`-role account (confirmed by reading `auth.service.ts` directly — `role:
UserRole.CUSTOMER` is hardcoded in that method). SELLER/RETAILER accounts are provisioned by
SUPER_ADMIN via the `user` module. So `AuthRepository` deliberately has no `register()` method and
there is no Register screen in Phase 1 — only `LoginScreen`. Customer self-registration
(`POST /auth/register`) is Phase 2 scope, when the `CUSTOMER` role and public storefront are built.

### Offline strategy
Hive is a **read-cache layer only** — write-through on a successful remote fetch, fall back to the
cached value on a `NetworkApiException`. **No offline writes** (no queuing an order/sale/payment
made while offline) — the debt-tracking domain (FIFO pay-down, stock decrements, currency-locked
ledgers) carries too much correctness risk to fake client-side in v1. Revisit only if real usage
data justifies it after Phase 1 ships. Not yet implemented for any feature as of this writing —
`HiveBoxes` just declares the box names.

---

## Roadmap

### Phase 1 — Operator core (SELLER + RETAILER + `_ADMIN` staff)
Cross-cutting rules that apply to every milestone: multi-currency (UZS/USD are two parallel,
never-summed ledgers, currency locked per-product), multi-store (any store-scoped list must
refetch when the active store changes; switcher invisible to locked staff), soft-delete/inactive
filtering, staff-inherits-owner-data (hide owner-only actions via a `RoleGate`, don't refetch
different data), Uzbek-only UI (no i18n framework needed yet, but route strings through one
`strings.dart` eventually so a future i18n pass isn't a rewrite).

| # | Milestone | Status |
|---|---|---|
| 0 | Project setup & housekeeping (bundle id, platform trim, deps, folder skeleton) | ✅ Done 2026-09-22 |
| 1 | Auth + Shell + Dashboard | 🟡 Auth done (login/splash/session restore/logout); role-aware dashboard (reporting charts, KPI cards, UZS/USD toggle, `GET /store`-based switcher visibility) **not yet built** — `HomeScreen` is a placeholder |
| 2 | Products, Categories, Master-Catalog browse | ⬜ Not started |
| 3 | B2B Orders | ⬜ Not started |
| 4 | Customers + B2C Sales/POS (native barcode scanning) | ⬜ Not started |
| 5 | Debts + Payments | ⬜ Not started |
| 6 | Stores/multi-branch + Staff (Admins) management | ⬜ Not started |
| 7 | Expenditures + Reports/dashboard charts | ⬜ Not started |

Endpoint-to-screen mapping, edge cases, and per-milestone detail live in the original plan
conversation — re-derive from the reference backend's controllers/DTOs/Swagger docs at
implementation time rather than trusting a stale summary here; this table is a status tracker, not
the spec.

### Phase 2 — CUSTOMER role + public storefront
Guest-eligible catalog/product-detail/cart (own `publicDioProvider`, no auth interceptor), customer
self-registration (`POST /auth/register` — finally applicable), favorites, CUSTOMER dashboard (own
orders/debts). New `CustomerShell` (Catalog/Cart/Favorites/Profile). Router redirect must become
allowlist-aware (guest browsing allowed pre-login, login required only at checkout).

### Phase 3 — SUPER_ADMIN panel
Platform analytics, wholesalers/retailers management, one generic `BusinessType`-filtered
retailer-list screen (not 7 separate ones), master-product moderation queue. Separate, simpler
`SuperAdminShell` (list/drill-down, not bottom-nav-heavy).

### Phase 4 — WAITER/COURIER + restaurant vertical
Products re-skins as "Menu" for RESTAURANT vertical (reuse Milestone 2, don't rewrite),
restaurant-tables, restaurant-orders board, narrow `WaiterShell`/`CourierShell` (explicit
allow-lists — these roles are NOT admin-inherited server-side). No WebSocket layer exists
server-side — isolate polling behind one repository abstraction from day one so it's a contained
swap if the real-time backend track ever lands.

### Backend-Enhancement Track (new, separate service — same stack, no Firebase)
Push notifications, a real Click/Payme payment gateway, working OTP/SMS login, and (lowest
priority) a real-time layer — all as **new NestJS + PostgreSQL infrastructure**, never a
modification of `Optom_Savdo`, and explicitly **not** built on Firebase/any BaaS (own Postgres
stays the single source of truth for device tokens, payment records, OTP codes, etc.). Push
delivery would still need to talk to APNs/FCM as pure transports — that's an inherent fact of
mobile push, not an adoption of the Firebase platform. Sequenced to start after Phase 1 is stable
in the field; bsmart must never hard-depend on this track (every integration point is additive).

---

## Progress Log

### 2026-09-22 — Milestone 0 + Auth foundation
- Set Android `applicationId`/iOS `PRODUCT_BUNDLE_IDENTIFIER` to `uz.bsmart.app`; moved
  `MainActivity.kt` to the matching package path.
- Removed `web/`, `linux/`, `macos/`, `windows/` platform folders; trimmed `.metadata` accordingly.
- Bumped iOS deployment target to 15.5 (`Podfile` + `project.pbxproj`) — required by
  `mobile_scanner`; see "Known Toolchain Deviations."
- Built the core cross-cutting layer (DI, Dio client + interceptors, secure/active-store storage,
  Hive box registry, go_router + redirect, theme/motion constants) and the full `auth` feature
  (Clean Architecture layers, hand-written Riverpod notifier, Login/Splash screens) against the
  **real** Optom Savdo backend source (read `auth.controller.ts`, all 5 auth DTOs, and
  `auth.service.ts`'s exact response shapes directly — not the earlier research summary — before
  writing the data layer).
- Discovered and corrected a plan assumption: no Register screen for SELLER/RETAILER in Phase 1
  (see "Session / auth model" above).
- `flutter analyze`: clean. `flutter test` (unit tests for `decodeJwtPayload` and `UserRole`
  wire-format round-tripping): passing.
- **Verified on a real Android emulator** (not just static analysis): app launches, session-restore
  correctly finds no session and redirects to `/login`, login screen renders correctly (screenshot
  confirmed). Caught and fixed two real runtime bugs this way that `flutter analyze` could not have
  caught: (1) `mobile_scanner` incompatible with Apple-Silicon iOS Simulator — worked around by
  testing on Android instead, real device needed for iOS verification going forward; (2) an
  accidentally-dropped `flutter: assets: - .env` section in `pubspec.yaml` caused a
  `FileNotFoundError` crash on launch.
- iOS Simulator run is expected to fail as long as `mobile_scanner` is a dependency — this is
  expected/known, not a regression to chase.

**Next up:** Milestone 1's actual dashboard (reporting endpoints + charts + UZS/USD toggle), then
Milestone 2 (Products/Categories/Master-Catalog).
