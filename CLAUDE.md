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
  dashboard/           → `GET /reports/{wholesaler,retailer,income-debt-chart}` — role-aware home screen
    data/{datasources,repositories}/          → no separate `models/` split, see "Reporting/dashboard model"
    domain/{entities,repositories,usecases}/  → WholesalerDashboard/RetailerDashboard + shared value objects
    presentation/{providers,screens,widgets}/ → DashboardNotifier, HomeScreen, KpiCard/chart widgets
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
  catalog/            → READ-ONLY buyer-facing B2B browse (a seller's stores + their products),
                         powers order creation; never exposes costPrice (backend strips it)
    data/{datasources,models,repositories}/
    domain/{entities,repositories,usecases}/
  customers/          → a SELLER's/RETAILER's own B2C customer roster (full CRUD)
    data/{datasources,models,repositories}/
    domain/{entities,repositories,usecases}/
    presentation/
      screens/         → CustomersListScreen, CustomerFormScreen (create/edit, also reused by
                          POS checkout's quick-create — see `CustomerPickerSheet`)
  sales/              → POS Sell tab + B2C sale history/returns — no separate "POS" backend
                         service, this feature is a cart-based UI channel over `/sales`
    data/{datasources,models,repositories}/
    domain/{entities,repositories,usecases}/
    presentation/
      providers/       → PosCartNotifier (plain Notifier, mirrors CreateOrderCartNotifier's
                          single-currency guard), SalesListNotifier (paginated)
      screens/          → PosScreen (search/scan + cart), CheckoutScreen (customer picker,
                          PAID/DEBT, discount, payment method), SaleDetailScreen (receipt),
                          SaleReturnScreen, SalesListScreen (history, type filter)
      widgets/          → CustomerPickerSheet (search + quick-create bottom sheet, shared by
                          checkout), sale_status_badge.dart (SaleStatusBadge/SaleTypeBadge)
  debts/              → B2B `Debt` + B2C `SaleDebt` hub, plus `/payments` (single + FIFO pay-down)
    data/{datasources,models,repositories}/   → 3 data sources (debts, sale_debts, payments)
                                                 behind one DebtsRepository
    domain/{entities,repositories,usecases}/
    presentation/
      providers/        → DebtsListNotifier (role toggle for RETAILER), SaleDebtsListNotifier
      screens/           → DebtsListScreen (B2B/Mijozlar tabs, grouped by person), 
                           DebtGroupDetailScreen (FIFO pay-down preview + per-debt payment/close)
      widgets/           → debt_like.dart (DebtLike/DebtGroup — a presentation-only adapter
                           unifying Debt/SaleDebt for one shared list/detail UI; see
                           "B2B Debt / Payment model" below for the viewer-perspective bug this
                           needed a fix for), RecordPaymentSheet, DebtStatusBadge
  orders/             → full B2B order lifecycle: create (RETAILER), list (incoming/outgoing,
                         same endpoint disambiguated server-side), detail + status timeline,
                         approve/reject/mark-delivered (SELLER)
    data/{datasources,models,repositories}/
    domain/{entities,repositories,usecases}/   → OrderQuery/CreateOrderParams/UpdateOrderStatusParams
                                                  mirror the backend DTOs field-for-field
    presentation/
      providers/   → OrdersListNotifier (paginated), CreateOrderCartNotifier (plain Notifier,
                     holds seller/store/line-items map, blocks mixed-currency adds)
      screens/     → SellerPickerScreen, OrderCatalogBrowseScreen, OrderReviewScreen,
                     OrdersListScreen, OrderDetailScreen
      widgets/order_status_badge.dart

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

### Reporting / dashboard model (confirmed against real backend source, 2026-09-22)
- **Unlike `Product`, every numeric field in `reporting.service.ts`'s responses is already a
  plain JSON number** — the service explicitly converts via its own `num()`/`Number()` helper
  before responding, never leaving a raw Prisma `Decimal`. So dashboard entities parse with a
  plain `(json['x'] as num).toDouble()`, never through `core/utils/decimal_parser.dart` — that
  helper is a `Product`/`Category`/`MasterProduct`-specific concern, not a blanket rule.
  `features/dashboard`'s entities carry their own `fromJson` factories directly (no separate
  `data/models` split like `auth`/`products` have) — a deliberate, lighter-weight variation
  since these are pure read-only report DTOs with no write path, so an Entity/Model split adds
  no real value here.
- **The Swagger `@ApiResponse` doc comments on `ReportingController` are stale** for
  `wholesalerDashboard`/`retailerDashboard` — they describe `paymentBreakdown`/`salesTrend` as
  flat (single-currency) shapes, but the actual `reporting.service.ts` implementation returns
  `{uzs: {...}, usd: {...}}` for both (multi-currency support was added after the Swagger
  comments were written and the comments were never updated). Always verify against the real
  `return {...}` statement in the service method, not just the controller's doc comment.
- **Critical, easy-to-miss distinction for the wholesaler dashboard**: `todaySales`/`totalSales`/
  `salesTrend` aggregate from the **`Order`** model (B2B orders to retailers), not from `Sale`
  (POS/register sales) — confirmed by reading `wholesalerDashboard()`'s Prisma queries directly.
  `receivedPayments`/`cardPayments` aggregate from `Payment` generically (any target — order,
  debt, sale, saleDebt), which is why POS `Sale`+`Payment` rows alone showed up there but left
  `todaySales`/`totalSales`/the trend chart at zero during verification — not a bug, just the
  wrong model to seed against. The retailer dashboard's `todaySales`/`totalSales`/`salesTrend`
  **do** come from `Sale` (a retailer's B2C register), matching its actual business role.
- `outstandingDebts` (wholesaler) comes from `Debt` (B2B); `customerDebts`/`wholesalerDebts`
  (retailer) come from `SaleDebt`/`Debt` respectively — no dashboard KPI ever blends B2B and B2C
  debt into one figure.

### B2B Order / Catalog model (confirmed against real backend source, 2026-09-22)
- **`catalog` module is the buyer-facing browse surface**, distinct from `product` (tenant's own
  inventory management, see above). `GET /catalog/sellers` lists sellers a RETAILER can order
  from, `GET /catalog/sellers/:id/stores` their stores, `GET /catalog` the products for a chosen
  seller/store — this is what `OrderCatalogBrowseScreen` walks through, one screen per step
  (`SellerPickerScreen` → store choice folded into the seller pick where only one store exists →
  `OrderCatalogBrowseScreen`).
- **`costPrice` is stripped server-side from every catalog product response** (confirmed in
  `catalog.service.ts`'s `productIncludes()`/select shape) — `CatalogProduct` the domain entity
  has no `costPrice` field at all, unlike `products`' own `Product` entity. Never add it back
  speculatively; a buyer should never see a seller's cost basis.
- **`POST /order` enforces single-currency, single-store-per-order** server-side (confirmed in
  `order.service.ts`) — `CreateOrderCartNotifier.addProduct()` mirrors this client-side as UX
  polish (returns `false`, screen shows a SnackBar) so the user gets instant feedback instead of
  a round-trip 400. This is UX-only; the server remains the actual authority.
- **`VALID_TRANSITIONS`**: `NEW → APPROVED | REJECTED`, `APPROVED → DELIVERED`. `Order` entity's
  `canApproveOrReject`/`canMarkDelivered` getters mirror this for hiding already-invalid actions
  in the UI — again UX polish, not a security boundary (the server re-validates the transition on
  every `PATCH /order/:id/status` regardless).
- **On approve (B2B), the backend does three things atomically**: decrements the seller's
  `Product.stock` for every line item, creates a `Debt` (`creditorId`=seller, `debtorId`=buyer,
  `balance`=order total, `currency` matching the order), and **auto-creates/restocks a mirror
  `Product` row owned by the retailer** (same name/price/currency, `stock` incremented by the
  ordered quantity) — so the retailer's own inventory reflects the incoming goods without them
  re-entering it by hand. All three confirmed by direct DB query after a live approve+deliver,
  not just read from source — see Progress Log below for the exact verified values.
- **List endpoint disambiguates "incoming" vs "outgoing" by role, not by a query param**: a
  SELLER's `GET /order` shows orders where they're the seller (incoming to fulfill); a RETAILER's
  shows orders where they're the buyer (outgoing they placed) — confirmed via
  `TenantFilter.order()`. `OrdersListScreen` therefore never sends a `view=incoming|outgoing`
  param (the plan originally assumed one might be needed; it isn't) — the same endpoint, scoped
  server-side by the caller's own tenant context, is sufficient.

### Customers / POS (B2C Sales) model (confirmed against real backend source, 2026-09-23)
- **POS is not a separate backend service — it's a cart-based UI channel over the existing B2C
  `Sale` flow**, exactly as documented in Optom Savdo's own `CLAUDE.md` ("Point of Sale (POS) &
  Inventory Receiving"). `POST /sales` is the single write path for both a `PAID` and a `DEBT`
  checkout; there is no `POST /pos/*` route to look for. `SaleController`/`CustomerController`
  both accept `SELLER, SELLER_ADMIN, RETAILER, RETAILER_ADMIN` — this milestone works identically
  for a wholesaler's own register and a retailer's, unlike the Milestone 3 order flow which is
  asymmetric (buyer vs. seller side).
- **`WorkDay` does NOT gate POS checkout server-side** — confirmed by reading `work-day.service.ts`
  and `sale.service.ts` directly: `WorkDay` is a pure shift-reporting/analytics-snapshot concept
  (`start`/`end`/`getByDate`, feeding `ReportingService.shiftSummary`), never referenced by
  `SaleService.create()`. The original plan flagged this as an open question ("verify whether an
  open WorkDay gates POS sales") — answer: it doesn't, so bsmart's POS screen never needs to
  check/require an open work day before allowing checkout. `WorkDay` start/end + shift-summary UI
  stays deliberately deferred to Milestone 7 (Reports), per the roadmap.
- **Every `Sale` requires a `Customer`** — there is no anonymous/walk-in checkout path server-side
  (unlike the reference web app's own POS, which lazily creates a "Walk-in" `Customer` via
  `CustomerService.create()`). bsmart's `CheckoutScreen` requires picking one via
  `CustomerPickerSheet`, which offers a "Yangi" quick-create dialog backed by the same
  `POST /customers` endpoint — functionally equivalent to the web app's walk-in pattern, just
  explicit rather than automatic.
- **`CreateCustomerDto.lastName` is `@IsNotEmpty()`** — a real bug was caught live during
  verification: the quick-create dialog only asks for one "Ism" (name) field (by design, for
  speed at the register) and originally sent `lastName: ''`, which the backend correctly rejected
  with `400 lastName should not be empty`. Fixed in `customer_picker_sheet.dart`'s
  `_QuickCreateCustomerDialogState._submit()` — splits the single input on the first space into
  `firstName`/`lastName`, defaulting `lastName` to `'-'` when there's no second word. This is a
  real, permanent backend constraint (not a bsmart-side choice) — any future customer quick-create
  UI must handle it the same way.
- **A `Sale` cannot mix currencies**, same invariant/enforcement pattern as `Order`
  (`sale.service.ts` reduces the fetched products' distinct currencies, rejects if >1) —
  `PosCartNotifier.addProduct()` mirrors this client-side exactly like
  `CreateOrderCartNotifier.addProduct()` does for orders.
- **`SaleItemInputDto.productId` is optional** — a manual/custom line item (no backing `Product`,
  e.g. the reference web app's generic "Mahsulot" card) is a real, supported shape
  (`productName`+`unitPrice` required instead) — modeled in bsmart as
  `CreateSaleItemParams(productId: null, productName: ..., unitPrice: ...)`, though the current
  POS screen only ever adds product-backed items (no generic-amount card built this milestone —
  not required by the original plan's Milestone 4 scope, a possible small follow-up later).
- **PAID vs DEBT, and the `paidAmount` partial-upfront-payment case**: `type: PAID` always creates
  exactly one `Payment` for the full total; `type: DEBT` creates a `SaleDebt` for the total, and
  **additionally** a `Payment` + reduces the debt's opening balance when `paidAmount > 0` — a
  "customer pays part now, owes the rest" checkout in one API call. `CheckoutScreen` exposes this
  as an optional "Oldindan to'lov" field that only appears in DEBT mode; `paymentMethod` is
  included in the request only when relevant (always for PAID, only for DEBT when
  `paidAmount > 0`) — sending it otherwise would be silently ignored server-side but is omitted
  for clarity.
- **Returns (`POST /sales/:id/returns`) are per-`SaleItem`, quantity-capped by
  `quantity - returnedQuantity`**, and `refundMethod` is required only when the original sale was
  `PAID` (a `DEBT` sale's return just reduces the linked `SaleDebt` balance, no money changes
  hands) — `SaleReturnScreen` conditionally shows the refund-method dropdown on exactly that
  condition. A sale stays returnable (`Sale.canReturn`) while `status` is `COMPLETED` or
  `PARTIALLY_RETURNED` — becomes `false` once fully `RETURNED`.
- **Decimal-as-string gotcha applies here too**: `Sale.subtotal/discount/total`,
  `SaleItem.quantity/unitPrice/discount/total/returnedQuantity`, `SaleDebt.*Amount/balance`, and
  `Payment.amount` are all Prisma `Decimal` fields serialized as JSON strings — `sale_model.dart`
  parses every one of them through `parseDecimal`/`parseNullableDecimal`, same as `Product`.

### B2B Debt / Payment model (confirmed against real backend source, 2026-09-23)
- **`Debt` (B2B) is symmetric — the same tenant can be creditor on some rows and debtor on
  others**, unlike `SaleDebt` (B2C) where the viewing tenant is always the `ownerId`/creditor
  side. `DebtController`'s default `GET /debts` (no `role` param) uses `TenantFilter.debt()`,
  which for a RETAILER returns `OR: [{debtorId: self}, {creditorId: self}]` — a genuinely mixed
  list. The `role=debtor`/`role=creditor` query param (`DebtQueryDto.role`) lets a RETAILER split
  the two views explicitly; a SELLER only ever gets the creditor-only default in this app (no
  toggle exposed), matching that role's actual usage (a wholesaler tracks retailers owing them,
  not itself owing someone else, in the mobile app's v1 scope).
- **Real bug found and fixed during live verification**: `groupDebts()` originally grouped every
  `Debt` row by `debt.debtor` and displayed that name — correct when the viewer is the creditor
  (the common case), but when a RETAILER views "Mening qarzim" (their own debts to a wholesaler,
  `role=debtor`), `debt.debtor` **is the viewer themselves**, so the UI showed the retailer's own
  name instead of who they actually owe. Fixed by grouping by the **other party relative to the
  signed-in `currentUserId`** (`debt.debtorId == currentUserId ? debt.creditor : debt.debtor`) —
  `DebtGroup` now carries a `viewerIsDebtor` flag from this same check.
- **Only the creditor may record a payment or close a debt** — `payment.service.ts`'s
  `createForDebt`/`payDown` and `debt.service.ts`'s `close()` all scope their write to
  `creditorId: tenant.tenantId` (self-owed/no-creditor debts are the one exception, handled by a
  separate `OR: [{creditorId: null, debtorId: tenant.tenantId}]` branch not exercised by this
  app's UI). Concretely: a RETAILER viewing their own "Mening qarzim" debts could never
  successfully record a payment against them (that's the wholesaler's job) — `DebtGroupDetailScreen`
  now hides the FIFO pay-down card and every per-debt "To'lov"/"Yopish" button whenever
  `group.viewerIsDebtor` is true, instead of showing buttons that would only ever 404.
- **`SaleDebt` (B2C) has no close endpoint** — `sale-debt.controller.ts` only exposes `GET`
  routes; the only way to fully settle one is paying down its exact remaining balance (which the
  backend auto-transitions to `SETTLED` once `balance <= 0`, same as `Debt`). `DebtGroupDetailScreen`
  only renders the "Yopish" button for `DebtKind.b2b` items, never for `saleDebt` ones.
- **The FIFO pay-down (`POST /payments/pay-down`) allocates oldest-first, capped per-row at that
  row's own balance** — `PaymentService.payDown()`'s loop is `for (const r of rows) { applied =
  min(remaining, balance); remaining -= applied; ... }` over debts/saleDebts sorted by
  `createdAt: 'asc'`. `DebtGroupDetailScreen._previewAllocation()` mirrors this exact loop
  client-side (same sort, same min/subtract) so the preview shown before confirming is
  authoritative, not just illustrative — confirmed live by seeding two debts with staggered
  `createdAt` and checking the preview against the actual post-submit balances, which matched
  exactly on every test (a 40 000 payment across a 30 000 + 50 000 debt pair correctly showed
  "30 000 (yopiladi) / 10 000" and the server applied exactly that).
- **UZS/USD are never pooled in one FIFO pass** — `PayDownDto.currency` (default `UZS`) scopes
  every fetched debt/saleDebt to one currency; `DebtGroup` is itself already keyed by
  `(person, currency)`, so a person with debts in both currencies simply appears as two separate
  groups, each with its own independent FIFO pay-down — no extra client-side logic needed beyond
  the existing per-currency grouping.
- **Decimal-as-string gotcha applies here too**: `Debt`/`SaleDebt`'s `originalAmount`/`paidAmount`/
  `balance` and every nested `Payment.amount` are Prisma `Decimal` fields — `debt_model.dart`
  parses them all through `parseDecimal`. `PaymentService.payDown()`'s own response fields
  (`totalApplied`/`remainingBalance`) are, by contrast, **plain JS numbers** (computed via the
  file's own `round2()` helper, never touching a `Decimal` column directly) — `parseDecimal` still
  works on them since it accepts either a `num` or a numeric string, but it's worth knowing this
  response shape is not itself Decimal-backed, unlike almost everything else in this app's
  "always assume Decimal-as-string" rule.

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
| 1 | Auth + Shell + Dashboard | 🟢 Done 2026-09-22, verified live with real seeded data (see log). Auth + role-aware dashboard (KPI cards, sales-trend line chart, payment-breakdown donut, income/debt bar chart, UZS/USD toggle) all working. **Deferred, not part of this milestone**: `GET /store`-based multi-store switcher visibility (Milestone 6 scope — a single-store owner should see no switcher at all) |
| 2 | Products, Categories, Master-Catalog browse | 🟢 Nearly closed (2026-09-22). Verified live: product CRUD, barcode-generate, receive-stock, delete, the leaf-only category picker, and image upload/delete (real multipart upload to ImageKit, confirmed rendering + delete). **Two remaining gaps, both environment-blocked, not bsmart bugs**: master-catalog picker (blocked by a pre-existing `master_products.unit` DB drift on this machine's local backend, see "Product/Catalog model"), and barcode-scan-to-find (needs a real device with a real barcode — no simulator/emulator camera can supply one) |
| 3 | B2B Orders | 🟢 Done 2026-09-22, verified live end-to-end (create→approve→deliver, DB side-effects confirmed, see log) |
| 4 | Customers + B2C Sales/POS (native barcode scanning) | 🟢 Done 2026-09-23, verified live (create→approve wasn't needed here, but full PAID/DEBT checkout + return lifecycle verified end-to-end, see log). Barcode-scan-to-find remains hardware-blocked (same limitation as Milestone 2), not re-attempted this pass |
| 5 | Debts + Payments | 🟢 Done 2026-09-23, verified live (FIFO pay-down, single-debt payment, close-debt, and two real bugs found+fixed — see log) |
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

### 2026-09-22 — Milestone 1 dashboard (reporting + charts)
- Read `reporting.controller.ts` and the real `reporting.service.ts` implementation directly
  (not just the Swagger doc comments, which turned out to be stale — see "Reporting/dashboard
  model" above) before writing any code, same discipline as every prior milestone.
- Built `features/dashboard`: `WholesalerDashboard`/`RetailerDashboard`/shared value-object
  entities (`MoneyByCurrency`, `CountAndAmountByCurrency`, `DebtSummaryByCurrency`,
  `PaymentBreakdownByCurrency`, `TrendPointsByCurrency`, `InventoryStatsByCurrency`,
  `IncomeDebtChart`), a `DashboardNotifier` that fetches the right dashboard for the session's
  role family and the 6-month income/debt chart together, and a separate
  `selectedDashboardCurrencyProvider` (`StateProvider<Currency>`) for the UZS/USD toggle — pure
  UI state, since every response already carries both currencies split out.
- Rebuilt `HomeScreen` (previously Milestone 0's placeholder) into the real dashboard: welcome
  header, role-specific KPI card grid (`KpiCard`), a 14-day sales-trend line chart
  (`SalesTrendChart`, `fl_chart` `LineChart`), a payment-method donut (`PaymentBreakdownChart`,
  `PieChart`), and a 6-month income-vs-debt grouped bar chart (`IncomeDebtBarChart`,
  `BarChart`) — all switching together via the currency toggle, all with explicit "Ma'lumot yo'q"
  empty states (verified, not just written speculatively).
- `flutter analyze`/`flutter test`: clean.
- **Verified live with real seeded data** (not just an empty-state check, specifically to exercise
  `fl_chart` rendering with actual values): seeded a SELLER with 3 POS `Sale`+`Payment` rows
  (cash/card/bank-transfer) — this alone left `todaySales`/`totalSales`/the trend chart at zero,
  which is how the `Order`-vs-`Sale` distinction above was actually discovered, not guessed at.
  Seeded one B2B `Order` (a throwaway RETAILER buyer → the same SELLER, 90 000 so'm, APPROVED)
  to properly populate those. End result, all confirmed via screenshot: KPI cards showed correct
  values (90 000 so'm / 1 sale for today+total, 0 debt, 120 000 so'm received payments); the
  trend line chart rendered a real spike on today's data point; the payment donut showed exactly
  50%/33%/17% (Naqd/Karta/Bank) matching the seeded split precisely; the income/debt bar chart
  showed a correctly-positioned income bar on the current month with no debt bar. Switched to USD
  and confirmed every KPI/chart correctly showed `$0`/empty state with no cross-currency bleeding
  (all seed data was UZS-only). All seed data (2 test users + stores, product, customer, 3
  sales, 3 payments, 1 order) removed afterward; backend and app stopped; `.env` reset.

**Next up:** Milestone 3 (B2B Orders). The multi-store switcher (`GET /store`-driven visibility)
stays deliberately deferred to Milestone 6, per the roadmap table.

### 2026-09-22 — Milestone 3 (B2B Orders)
- Read the real `order.controller.ts`, `order.service.ts` (full ~600 lines), all 3 order DTOs,
  `catalog.controller.ts`/`catalog.service.ts`, and `tenant.filter.ts`'s `order()` method directly
  before writing any code — see "B2B Order / Catalog model" above for what that surfaced,
  including two corrections to the original plan: the list endpoint disambiguates incoming/
  outgoing by role via `TenantFilter`, not a `view` query param (so `OrderQuery` deliberately
  omits one); and approving an order auto-creates a mirror `Product` in the retailer's own
  inventory, not just a `Debt` (not previously documented anywhere).
- Built `features/catalog` (read-only seller/store/product browse for order creation) and
  `features/orders` (full CRUD-minus-delete lifecycle) with the standard `data`/`domain`/
  `presentation` split: `Order`/`OrderQuery`/`CreateOrderParams`/`UpdateOrderStatusParams`
  entities, `OrdersListNotifier` (paginated `AsyncNotifier`), `CreateOrderCartNotifier` (plain
  `Notifier` cart holding seller/store/line-items, blocking mixed-currency adds client-side as UX
  polish), and 5 screens (`SellerPickerScreen`, `OrderCatalogBrowseScreen`, `OrderReviewScreen`,
  `OrdersListScreen`, `OrderDetailScreen` with approve/reject/mark-delivered actions gated by
  `Order.canApproveOrReject`/`canMarkDelivered`).
- `flutter analyze`/`flutter test`: clean.
- **Verified live, full lifecycle, against a real running backend** with two seeded throwaway
  accounts (SELLER + RETAILER, per "Local Verification Workflow"): RETAILER logs in → empty
  orders list → FAB → seller picker (showed both real sellers already in the DB and the test one
  — confirmed the picker works against real data without needing to touch it) → catalog browse
  showed both seeded products → added both to cart (currency-mixing guard not exercised this
  pass, both products were UZS) → review screen → filled delivery address → submitted →
  order created and detail screen rendered all fields correctly. Logged out, logged in as SELLER
  → dashboard correctly still showed 0 sales (re-confirms the Order-vs-Sale dashboard distinction
  from Milestone 1 — a NEW order doesn't count as a sale) → incoming-orders list showed the order,
  no FAB (buy-side-only action) → detail → tapped Approve → confirm dialog → order moved to
  APPROVED, timeline updated, Approve/Reject buttons correctly replaced by a Deliver button →
  tapped Deliver → confirm dialog → order moved to DELIVERED, timeline showed all three entries,
  action buttons correctly disappeared entirely (terminal state).
- **Confirmed all three approve-time side effects via a direct DB query** (not just "no exception
  thrown" — actual before/after values): seller's two products decremented exactly by the ordered
  quantities (100→99, 50→49); a `Debt` row created with `creditorId`=seller, `debtorId`=retailer,
  `balance`=40000, `currency`=UZS, `status`=ACTIVE; a mirror `Product` pair auto-created under the
  retailer's own `sellerId` with matching name/price/currency and `stock`=1 each (the ordered
  quantities) — this last one is the previously-undocumented auto-restock behavior mentioned
  above, discovered by reading `order.service.ts`'s approve-transition code, not assumed.
- Verification tooling note: screen-tap coordinates for this pass were computed by sampling the
  actual button's pixel color directly from the raw `adb exec-out screencap` PNG (native
  1080×2424 resolution) rather than eyeballing the tool's downscaled preview image — the preview
  is shown at 891×2000 with a "×1.21 to map to original" note, and applying that multiplier a
  *second* time (i.e. treating the raw screenshot file as if it were also downscaled) produced
  several missed taps this session before the mistake was caught. **Screenshot PNG files read
  directly via the file path are always already at native device resolution — never rescale
  them.** `uiautomator dump` bounds were also unreliable for this specific button (returned a
  full-width container bounds instead of the button's own, and once returned a dump with no
  matching node at all despite the button being clearly visible on screen) — direct pixel-color
  sampling proved more reliable than either coordinate-estimation-from-preview or
  `uiautomator dump` bounds for this button. Worth trying pixel-sampling first next time a tap
  needs to be precise.
- All seed data (2 test users + stores, 2 products, the order + its status history, the created
  `Debt`, and the 2 auto-restocked retailer products) removed afterward via a companion cleanup
  script; backend dev server and `flutter run` both stopped; `.env` reset to its checked-in
  default.

**Next up:** Milestone 4 (Customers + B2C Sales/POS, native barcode scanning) — the heaviest
animation-investment milestone per the original plan (§2.7). Barcode-scan-to-find and the
master-catalog picker remain the two opportunistic re-verification items from Milestone 2, still
not blocking further progress.

### 2026-09-23 — Milestone 4 (Customers + B2C Sales/POS)
- Read `customer.controller.ts`/`.service.ts`/DTOs, `sale.controller.ts`/`.service.ts`/DTOs
  (create/query/return), `work-day.controller.ts`/`.service.ts`, `sale-debt.controller.ts`, and
  `shared-cart.controller.ts`/DTO directly before writing any code — see "Customers / POS (B2C
  Sales) model" above for what that surfaced, most importantly: `WorkDay` does not gate checkout
  (an open question from the original plan, now resolved), and `CreateSaleDto.paidAmount` enables
  a partial-upfront-payment DEBT checkout in one call.
- Built `features/customers` (full CRUD: list/search, create, edit, deactivate — following
  `features/products`' exact `data`/`domain`/`presentation` shape) and `features/sales` (POS Sell
  tab, checkout, receipt, returns, history) — new cross-cutting primitives added:
  `core/enums/payment_method.dart`, `core/enums/sale_enums.dart` (`SaleType`/`SaleStatus`/
  `DebtStatus`). Reused the existing `shared/widgets/barcode_scanner_screen.dart` for POS's scan
  action (one-shot scan → `GET /products?barcode=` lookup → add to cart, or a "not found" toast) —
  the original plan's "continuous-scan debounce" refinement was **not** built this pass (the
  scanner still requires re-opening per item); noted here as a known simplification, not a gap
  that blocks the milestone, since the one-shot flow is fully functional.
- **Shared cart (park/resume) was scoped out of this pass** — the original plan listed it under
  Milestone 4, but given the POS core (cart/checkout/returns) was already the bulk of this
  milestone's surface, it was deliberately deferred rather than rushed. Not yet built as of this
  writing; revisit as a small follow-up feature, not a blocker for Milestone 5.
- `flutter analyze`/`flutter test`/`flutter build apk --debug`: all clean.
- **Real bug caught and fixed during live verification, not by static analysis**: the POS
  checkout's customer quick-create dialog sent `lastName: ''`, which `CreateCustomerDto`'s
  `@IsNotEmpty()` correctly rejected with a live `400` the first time it was exercised against the
  real backend — see "Customers / POS (B2C Sales) model" above for the fix
  (`customer_picker_sheet.dart` now splits the one "Ism" field on its first space, defaulting
  `lastName` to `'-'`). This is exactly the kind of bug `flutter analyze`/`flutter test` cannot
  catch — only caught by actually submitting the form against the live server.
- **Verified live, full lifecycle**, against a real running backend with one seeded throwaway
  SELLER account (`+998900000007`) + 2 products (no customer seeded — the quick-create flow was
  exercised live instead, which is what surfaced the bug above): logged in → Kassa (POS) →
  searched/added both products to cart (currency-mixing guard not exercised this pass, both
  products were UZS) → opened checkout → picked "Mijozni tanlang" → quick-created a walk-in
  customer ("Ali -" after the fix) → submitted as **PAID/Naqd** → receipt screen showed correct
  items/subtotal/total/payment line and a "Qaytarish" (Return) action → **returned 1 unit** of one
  product → receipt correctly updated to "Qisman qaytarilgan" (Partially Returned) with
  recalculated subtotal/total, the returned item annotated "qaytarilgan: 1" → went back to Kassa,
  confirmed stock levels reflected both the sale and the return correctly (see below) → added the
  other product, checked out as **DEBT** with no upfront payment → receipt correctly showed a
  "Qarz" card (`To'langan: 0`, `Qoldiq: 12 000 so'm`) and a `Qarzga` status badge, no payments
  section (correct — no `Payment` row should exist for a zero-upfront DEBT sale) → verified
  `Sotuvlar tarixi` (Sales history) lists both sales correctly with type badges → verified
  `Mijozlar` (Customers) list shows the created customer, and its edit form correctly pre-fills
  `firstName`/`lastName`/`phone`.
- **Confirmed all side effects via a direct DB query** (not just "no exception thrown"): both
  products' `stock` correctly reflected two separate 1-unit sale decrements plus one 1-unit return
  increment (50→49→48 for the product sold in both sales, 30→29→30 for the product sold once and
  fully returned); exactly one `Payment` row (20 000 CASH, linked to the PAID sale); exactly one
  `SaleDebt` row (balance 12 000, status ACTIVE, linked to the DEBT sale); exactly one
  `SaleReturn` row (8 000, refundMethod CASH, cashOwed 0); the PAID `Sale`'s own
  `subtotal`/`total` correctly reduced from 20 000 to 12 000 after the return, `status`
  `PARTIALLY_RETURNED`.
- **Verification tooling notes, both newly discovered this pass** (added here so they aren't
  re-discovered from scratch next time):
  - **`adb shell input text` silently drops a leading `+`** when typing directly into a phone-
    number field (observed repeatedly across the login screen and the quick-create-customer
    dialog) — the character before the first digit is lost even though the rest of the string
    types correctly. Workaround: type the digits first, then move the cursor to the start
    (`adb shell input keyevent --longpress KEYCODE_MOVE_HOME`) and type just `+` as a second,
    separate `input text` call — this always lands correctly, whereas retrying the full string
    with the `+` included reproduces the same drop.
  - **`adb shell input text "word1 word2"` (an unescaped space inside one shell-quoted argument)
    does not reliably type both words** — observed dropping the second word entirely, or (once)
    routing it into a different, previously-focused field. Reliable workaround: use the literal
    `%s` token adb documents for a space (`adb shell input text "word1%sword2"`), or split into
    two `input text` calls with an explicit cursor move between them. Bash-level quoting does not
    help here — the space is consumed/mishandled by `adb`/the on-device `input` command itself,
    not by the local shell.
  - Once again (third time this project, after two separate instances in the Milestone 3
    verification pass), a button's true tap target came from a **fresh `uiautomator dump`'s
    `bounds` attribute**, not from visually estimating a coordinate off a screenshot — several
    taps this pass landed on the wrong field/button (the Ism/Telefon dialog fields, the
    Qarzga/To'landi segmented toggle, the Saqlash button, the return screen's +/− steppers) purely
    from eyeballing screenshot pixel positions. **Standing rule going forward: for any tap where
    precision matters (small buttons, adjacent form fields, segmented controls), pull a fresh
    uiautomator dump and read the exact `bounds` first — do not estimate from a screenshot, even a
    native-resolution one.**
- All seed data (1 test SELLER user + store, 2 products, the created customer, both sales + their
  items/payment/debt/return) removed afterward via a companion cleanup script; backend dev server
  and `flutter run` both stopped; `.env` reset to its checked-in default.

**Next up:** Milestone 5 (Debts + Payments) — the FIFO pay-down preview is flagged in the original
plan as the highest-risk pure-logic piece of this whole project; budget real design attention
there, not just a mechanical port of the B2B/B2C debt list screens. Shared cart (park/resume,
deferred above) and the barcode-scan-to-find / master-catalog-picker re-verifications (deferred
since Milestone 2) remain opportunistic, non-blocking follow-ups.

### 2026-09-23 — Milestone 5 (Debts + Payments)
- Read `debt.controller.ts`/`.service.ts` (all 4 create-DTO variants), `payment.controller.ts`/
  `.service.ts` (`create`/`payDown`/`findAll`/`findOne`), `sale-debt.controller.ts`/`.service.ts`,
  and `TenantFilter.debt()`/`.payment()` directly before writing any code — see "B2B Debt /
  Payment model" above for what that surfaced, most importantly the `Debt` model's symmetry (a
  RETAILER can be creditor on some rows, debtor on others) and the creditor-only write scoping on
  every payment/close endpoint.
- Built `features/debts`: `Debt`/`SaleDebt`/`PaymentEntry` entities, `DebtsRepository` fronting 3
  data sources (`/debts`, `/sale-debts`, `/payments`), and a presentation-only `DebtLike`/
  `DebtGroup` adapter (`debt_like.dart`) that unifies both debt types into one shared grouped
  list/detail UI — `DebtsListScreen` (B2B/Mijozlar tabs, each grouped client-side by person +
  currency, since neither list endpoint returns pre-grouped debtor summaries) and
  `DebtGroupDetailScreen` (the FIFO pay-down card + per-debt payment/close actions).
  `RecordPaymentSheet` is the shared single-payment bottom sheet.
- `flutter analyze`/`flutter test`/`flutter build apk --debug`: all clean.
- **Two real bugs caught and fixed during live verification, neither catchable by static
  analysis:**
  1. **Wrong person name shown when the viewer is the debtor** (see "B2B Debt / Payment model"
     above for the full explanation) — `groupDebts()` always displayed `debt.debtor`'s name,
     which is the *viewer's own name* when a RETAILER checks "Mening qarzim." Fixed by grouping on
     the party *other than* `currentUserId`, and added a `DebtGroup.viewerIsDebtor` flag that now
     also hides the FIFO pay-down card and every per-debt payment/close button in that view (they
     would only ever 404 server-side, since only the creditor may write a payment).
  2. **Pull-to-refresh silently doing nothing on every short list/detail screen in the whole
     app** — discovered here first (the Debts B2B tab has just one grouped row in typical test
     data, so it never fills the viewport). Root cause: Android's default `ClampingScrollPhysics`
     doesn't overscroll when content is shorter than the viewport, and `RefreshIndicator` needs
     that overscroll to trigger — so `onRefresh` silently never fired. Fixed by adding
     `physics: const AlwaysScrollableScrollPhysics()` to the scrollable under every
     `RefreshIndicator` in the app — this was **not** scoped to the new Debts screens; a grep
     found the identical gap in `customers_list_screen.dart`, `products_list_screen.dart` +
     `product_detail_screen.dart`, `home_screen.dart` (the dashboard), `orders_list_screen.dart` +
     `order_detail_screen.dart`, and `sales_list_screen.dart` — i.e. every pull-to-refresh built
     since Milestone 1. All 8 fixed in this pass. **Any new `RefreshIndicator` added from now on
     must include this physics override from the start** — it's easy to miss because the bug only
     manifests with short content, which real usage will eventually have but a freshly-seeded test
     account usually doesn't.
- **Verified live, full lifecycle**, against a real running backend with a seeded SELLER
  (`+998900000008`) + RETAILER (`+998900000009`) pair, two B2B `Debt` rows with staggered
  `createdAt` (30 000 then 50 000 UZS) to exercise FIFO ordering, and a customer with two B2C
  `SaleDebt` rows (15 000 then 20 000 UZS):
  - **B2B tab**: correctly grouped both debts under the retailer with a combined 80 000 balance;
    confirmed the wholesaler dashboard's own "Qarzdorlik" stat card independently agreed (80 000)
    — cross-validates this feature's reads against the pre-existing reporting endpoint.
  - **FIFO pay-down**: a 40 000 payment correctly closed the older 30 000 debt and applied the
    remaining 10 000 to the 50 000 debt, exactly matching the client-side preview shown before
    confirming — balance dropped 80 000 → 40 000, statuses updated to `To'langan`/`Qisman
    to'langan` respectively.
  - **Single-debt payment**: a 15 000 payment against the remaining debt correctly reduced its
    balance 40 000 → 25 000 without touching the other (already-settled) row.
  - **Close debt**: closing the remaining 25 000 balance correctly settled it (balance → 0,
    status `To'langan`) and created the expected `Payment` row for the written-off remainder — the
    FIFO card correctly disappeared once the group's total active balance reached zero.
  - **RETAILER role toggle**: switching to "Mening qarzim" (after seeding one more small active
    debt to have something non-settled to check) correctly showed "Bsmart Debt" (the wholesaler)
    as the group name — confirming bug #1's fix — with no FIFO card and no per-debt action buttons
    visible, confirming the creditor-only write gating.
  - **Mijozlar (B2C) tab**: grouped the customer's two `SaleDebt` rows correctly (35 000 combined);
    a 25 000 FIFO pay-down correctly closed the 15 000 row and left 10 000 on the 20 000 row,
    with no "Yopish" button ever rendered for either row (correct — no close endpoint exists for
    `SaleDebt`).
  - Confirmed via direct DB query that every `Payment` row created during this pass (6 total
    across both roles/kinds) had the correct `amount`/`debtId`/`saleDebtId`/`receiverId`, and that
    the final `Debt`/`SaleDebt` balances matched the UI exactly at every step.
- All seed data (2 users + stores, 1 customer, 2 sales + their saleDebts, 3 debts, and all 6
  payments created during testing) removed afterward via a companion cleanup script; backend dev
  server and `flutter run` both stopped; `.env` reset to its checked-in default.

**Next up:** Milestone 6 (Stores/Multi-branch + Staff/Admins management). Shared cart (park/
resume, deferred from Milestone 4) and the barcode-scan-to-find / master-catalog-picker
re-verifications (deferred since Milestone 2) remain opportunistic, non-blocking follow-ups.
