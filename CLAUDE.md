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
  categories/         → READ-ONLY browse (category CRUD is SUPER_ADMIN-only, see "Product/Catalog model")
    data/{datasources,models,repositories}/
    domain/{entities,repositories,usecases}/
    presentation/{providers,widgets}/         → CategoryPickerField (leaf-only picker, used by product form)
  products/           → the tenant's own inventory (full CRUD + images + barcode + receive-stock)
    data/{datasources,models,repositories}/
    domain/{entities,repositories,usecases}/  → one usecase class per repository method (LoginUseCase-style)
    presentation/{providers,screens,widgets}/ → ProductsListNotifier (paginated/filtered list state)
  master_catalog/     → READ-ONLY browse of the shared MasterProduct catalog ("Add from Catalog" picker)
    data/{datasources,models,repositories}/
    domain/{entities,repositories,usecases}/
    presentation/screens/master_catalog_picker_screen.dart

shared/widgets/
  barcode_scanner_screen.dart   → full-screen mobile_scanner camera view, reused by products now and POS later
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

### Product / Catalog model (confirmed against real backend source, 2026-09-22)
- **`GET /products` is always scoped to the caller's own `sellerId`/store** — it is the tenant's
  own inventory-management list, never a browsable market of other sellers' stock. A separate
  `catalog` module (buyer-facing B2B market browsing) exists on the backend but is not yet
  consumed by bsmart — that's Milestone 3's concern.
- **`Category` CRUD is SUPER_ADMIN-only** (`POST`/`PATCH`/`DELETE`/image routes all require
  `@Roles(SUPER_ADMIN)`) — mirrors the "no self-registration" correction from Milestone 1.
  SELLER/RETAILER only ever `GET` categories, so `features/categories` is deliberately read-only
  in Phase 1; full category management is Phase 3, SUPER_ADMIN-panel scope.
- **`MasterProduct` (shared catalog) moderation is SUPER_ADMIN-only** the same way — SELLER/
  RETAILER only browse `APPROVED` entries (enforced server-side, `TenantFilter.masterProduct`
  forces `isActive: true` for non-SUPER_ADMIN roles) to link a new product via "Add from Catalog"
  or to `share-to-catalog` an existing one. Approve/reject queue is Phase 3.
- **`POST /products/:id/barcode` generates a random barcode server-side** — the client never
  supplies a barcode value here. Native camera scanning (`mobile_scanner`) is instead used to
  *find* an existing product by exact-barcode search (`ProductQuery.barcode`, wired through the
  product list's scan action) — the natural POS-scanning groundwork for Milestone 4.
- **Prisma `Decimal` fields serialize as JSON strings, not numbers** — `Product.price`,
  `.costPrice`, `.stock` all come over the wire as strings (e.g. `"15000.00"`). Every model parsing
  one of these fields must go through `core/utils/decimal_parser.dart`'s `parseDecimal`/
  `parseNullableDecimal` — casting `as num`/`as double` directly will throw.
- **Pagination envelope is identical across `category`/`product`/`master-product`**: `{data: T[],
  meta: {total, page, limit, totalPages, hasNext, hasPrev}}` — modeled once as
  `core/network/paginated_result.dart`'s `PaginatedResult<T>`, reused by every list endpoint.
- For a catalog-linked product (`masterProductId != null`), the backend's `resolveDisplay()`
  already overwrites `name`/`description`/`images`/`brand` with the linked `MasterProduct`'s
  values before the JSON reaches the client — `product_model.dart` never needs to resolve this
  itself, and the edit form correctly treats `name`/`description` as read-only for linked products.
- **Known pre-existing backend/DB issue (not a bsmart bug, do not try to fix it here):** on this
  machine's local dev DB, `GET /master-products` currently 500s with `{"message":"Database
  error"}` — confirmed live 2026-09-22 by calling it directly. Root cause: the local Postgres
  table is missing the `unit` column that `schema.prisma` declares on `MasterProduct` (any
  `prisma.masterProduct` query touches it via the default all-columns select). This is the exact
  `master_products.unit` local-dev-DB drift Optom Savdo's own `CLAUDE.md` already documents as
  found-but-unresolved (search that file for "master_products.unit" for the full history) —
  it predates and is unrelated to bsmart. **Effect on this app**: the master-catalog picker
  (`features/master_catalog`) cannot be verified against this local DB until that drift is fixed
  on the Optom Savdo side (or against a different environment where it isn't present) — re-check
  next time `GET /master-products` is needed rather than assuming it's still broken forever.

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
| 2 | Products, Categories, Master-Catalog browse | 🟢 Nearly closed (2026-09-22). Verified live: product CRUD, barcode-generate, receive-stock, delete, the leaf-only category picker, and image upload/delete (real multipart upload to ImageKit, confirmed rendering + delete). **Two remaining gaps, both environment-blocked, not bsmart bugs**: master-catalog picker (blocked by a pre-existing `master_products.unit` DB drift on this machine's local backend, see "Product/Catalog model"), and barcode-scan-to-find (needs a real device with a real barcode — no simulator/emulator camera can supply one) |
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

## Local Verification Workflow

Every milestone should be verified against the **real, running** Optom Savdo backend, not mocked
(matches that project's own dev practice). Steps, repeatable each session:

1. **Start the backend**: `cd ../Optom_Savdo && pnpm --filter server dev` (reads its own `.env` —
   check the printed `PORT` in the startup log; it's not always 4004, e.g. it ran on 4005 during
   Milestone 2 verification because something else already held 4004 locally).
2. **Point bsmart at it**: edit `bsmart/.env`'s `API_BASE_URL`. From an Android emulator, the host
   machine's `localhost` is reachable at `10.0.2.2` — e.g. `http://10.0.2.2:4005/api`. Revert to
   the `.env.example` default (`http://localhost:3000/api`) when done, so the repo's checked-in
   default stays sane for the next session.
3. **You need a real SELLER/RETAILER account** — there is no self-registration for these roles
   (see "Session / auth model"). If none exists in the local dev DB yet, create one directly via
   Prisma (mirrors the exact pattern the reference backend's own `CLAUDE.md` documents for its
   verification passes): a scratch Node script using `apps/server`'s own `generated/prisma` client,
   `@prisma/adapter-pg`'s `PrismaPg` + a `pg.Pool` built from `DATABASE_URL` (matching
   `prisma.service.ts`'s exact construction — a bare `new PrismaClient()` throws in Prisma 7
   without the adapter), and `bcrypt.hash()` for the password. Create both a `User` (`role:
   'SELLER'`) and its default `Store` (`isDefault: true`) — the backend's own `UserService.create`
   does both together for real signups, and any store-scoped write will fail without one.
4. **Clean up afterward**: hard-delete any `Product`/etc. rows created by the test account, then
   delete the `User` row itself (cascades to its `Store` — confirm the relevant relation's
   `onDelete` in `schema.prisma` before assuming cascade elsewhere). Never leave test data behind
   in the shared local dev DB. Stop the backend process when done.
5. Local dev Postgres for this project lives at `localhost:5432/optom` (see `apps/server/.env`) —
   safe for throwaway test data, unlike a shared staging/production database.

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

### 2026-09-22 — Milestone 2 (Products, Categories, Master-Catalog)
- Read the real `category`/`product`/`product-image`/`master-product` controllers, every DTO, and
  the relevant Prisma models directly (not a prior research summary) before writing any data-layer
  code — see "Product/Catalog model" above for what that surfaced, including two corrections to
  the original plan (category/catalog CRUD is SUPER_ADMIN-only; barcode-assign generates
  server-side rather than accepting a scanned value).
- Built `features/categories` (read-only tree browse + `CategoryPickerField`), `features/products`
  (full CRUD, list with search/category-filter/infinite-scroll, detail, create/edit form with an
  "Add from Catalog" vs. custom-product choice, image upload/delete, quick stock-adjust sheet,
  barcode generation, share-to-catalog), and `features/master_catalog` (read-only search picker) —
  all following `features/auth`'s exact `data`/`domain`/`presentation` shape, one usecase class per
  repository method.
- Added `shared/widgets/barcode_scanner_screen.dart` (`mobile_scanner` full-screen camera view) and
  `core/utils/{decimal_parser,currency_formatter}.dart`, `core/network/paginated_result.dart` as
  new cross-cutting primitives.
- Added the required iOS (`NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`) and Android
  (`CAMERA` permission + optional camera feature) manifest entries for `mobile_scanner`/
  `image_picker` — missing these would have crashed the app on first camera/gallery access.
- `flutter analyze`: clean. `flutter test`: passing (unchanged from Milestone 1's suite; no new
  pure-logic units were extracted this milestone beyond what's already covered).
- **Verified live** against a real running Optom Savdo backend (see "Local Verification Workflow"
  above) with a throwaway test SELLER account: login → empty product list renders correctly →
  create a product (custom, not catalog-linked) → detail screen renders correctly with currency
  formatting → generate barcode (server-assigned, UI updates and hides the button correctly) →
  receive stock via the quick-adjust sheet (0 → 25, confirmed) → edit (price 15000 → 20000,
  confirmed) → delete (soft-delete, list correctly empties again). All steps screenshotted and
  confirmed against the actual rendered UI, not just "no exception thrown." Test data fully cleaned
  up from the local DB afterward (product hard-deleted, test user deleted cascading its store).
- **Not runtime-verified this pass** (see roadmap table): category picker and master-catalog picker
  (the fresh test DB had zero categories/catalog entries to pick from), product image upload/delete
  (needs a real photo available to the test device's gallery), and barcode-scan-to-find (needs a
  real device with a real barcode to point a camera at — the Android emulator's simulated camera
  has nothing to scan, and iOS Simulator can't run `mobile_scanner` at all). These are built and
  analyzer-clean but should be exercised for real before considering Milestone 2 fully closed —
  particularly image upload, since multipart form upload is new code with no prior verified
  precedent in this app to lean on.

**Next up:** finish verifying the three gaps above (ideally on a real device, or a seeded dev DB
with categories/catalog entries and a gallery photo), then Milestone 1's dashboard, then Milestone
3 (B2B Orders).

### 2026-09-22 — Milestone 2 gap-closing verification pass
- Seeded throwaway data directly via Prisma (per "Local Verification Workflow") to close three of
  the four gaps left open by the first pass: a second test SELLER, a root category + subcategory,
  and a `MasterProduct` entry — plus pushed a test image into the Android emulator's gallery via
  `adb push` + a media-scanner broadcast for the image-upload test.
- **Seeding the `MasterProduct` surfaced a real, pre-existing backend/DB issue**: `prisma
  .masterProduct.create()` failed with `P2022 ColumnNotFound` on `unit` — the local Postgres
  table is missing a column `schema.prisma` declares. Confirmed this isn't just a seeding
  inconvenience by calling the live `GET /master-products` endpoint directly: it 500s the same
  way for real traffic, not just raw Prisma access. This is the exact `master_products.unit`
  local-dev-DB drift Optom Savdo's own `CLAUDE.md` already flags as found-but-unresolved — not a
  new bug, not a bsmart bug, and out of scope to fix here (would mean altering that project's
  database). Documented in "Product/Catalog model" above so it isn't re-discovered from scratch
  next time. Worked around the *seeding* step with an explicit `select` omitting `unit`; the
  master-catalog picker itself remains genuinely blocked until that drift is fixed or a different
  DB is used.
- **Verified live, closing three of the four gaps:**
  - **Category picker**: opened correctly, showed the real leaf-only list (pre-existing
    categories in this DB plus the two seeded ones — the picker correctly excluded parent
    categories that have children, exactly per its documented design), search field present,
    selection persisted correctly onto the created product and displayed on its detail screen.
  - **Image upload**: native Android Photo Picker opened via `image_picker`, a photo was selected,
    the UI correctly showed the busy state (`_isBusy`, buttons disabled) during upload, and the
    uploaded image rendered correctly in the gallery strip afterward — a real multipart request
    to the backend's `product-image` module succeeded end-to-end (ImageKit-backed).
  - **Image delete**: tapping the image's delete overlay removed it correctly, confirmed via
    screenshot.
  - Also re-confirmed product create/detail/currency-display still work correctly with the second
    test account, incidentally re-validating Milestone 1's login flow against a different account.
- **Still not verified** (both are environment/hardware limits, not code gaps): master-catalog
  picker (see the DB drift above) and barcode-scan-to-find (no simulator/emulator can present a
  real barcode to a virtual camera — needs a physical device).
- All seed data (second test user + store, both categories, the `MasterProduct`, and the one
  product created through the app with its uploaded image) removed afterward via a companion
  cleanup script; test image removed from the emulator's gallery; backend dev server and app both
  stopped; `.env` reset to its checked-in default.

**Next up:** Milestone 1's dashboard (reporting endpoints + charts + UZS/USD toggle), then
Milestone 3 (B2B Orders). Re-attempt the master-catalog picker and barcode-scan-to-find
verification opportunistically if a fixed DB or a real device becomes available, but don't block
further milestones on either.
