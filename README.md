# bsmart

**bsmart** is the native Flutter mobile app (Android + iOS) for **Optom Savdo**, a multi-tenant
B2B2C wholesale-trade platform for the Uzbekistan market. It consumes the existing Optom Savdo
NestJS/PostgreSQL API and is being built to reach full feature parity with the web app's
operator/B2B2C workflows before extending beyond it.

> For architecture decisions, the full roadmap, known toolchain caveats, and a running progress
> log, see **[`CLAUDE.md`](./CLAUDE.md)** — read it before resuming work on this project after
> any break.

## Tech Stack

| Concern | Choice |
|---|---|
| Framework | Flutter (mobile only — Android + iOS) |
| State management | `flutter_riverpod` (hand-written `Notifier`/`AsyncNotifier`, no code-gen — see `CLAUDE.md`) |
| Dependency injection | `get_it`, manually wired |
| Architecture | Clean Architecture (`data` / `domain` / `presentation` per feature) + SOLID |
| Networking | `dio`, with a custom auth/active-store/refresh-token interceptor chain |
| Routing | `go_router`, session-driven redirects |
| Local storage | `flutter_secure_storage` (tokens), `shared_preferences` (active store), `hive_ce` (read cache) |
| Forms / scanning / charts | `reactive_forms`, `mobile_scanner` (native camera), `fl_chart` |
| Animation | `flutter_animate`, `lottie`, `shimmer` |

## Project Structure

```
lib/
  main.dart, bootstrap.dart, app.dart   Entry point, DI/env/Hive setup, MaterialApp.router
  core/                                 Cross-cutting: DI, network, storage, router, theme, enums
  features/<name>/
    data/          Datasources, models, repository implementations
    domain/         Entities, abstract repositories, use cases
    presentation/    Riverpod providers, screens, widgets
  shared/widgets/                       Generic cross-feature UI (grows as needed)
```

Every feature follows the same `data` / `domain` / `presentation` shape as `features/auth/` —
see `CLAUDE.md` for the full directory reference and the reasoning behind it.

## Prerequisites

- Flutter SDK (stable channel; see `pubspec.yaml`'s `environment.sdk` for the minimum Dart
  version)
- Xcode (for iOS) and/or Android Studio + an Android SDK (for Android)
- A running instance of the [Optom Savdo backend](../Optom_Savdo) (or access to a deployed one)

## Getting Started

1. **Install dependencies:**

   ```sh
   flutter pub get
   ```

2. **Configure the API base URL** — copy the example env file and point it at your backend:

   ```sh
   cp .env.example .env
   ```

   By default this points at `http://localhost:3000/api`; update `API_BASE_URL` to match your
   running Optom Savdo server (see that project's README — its default dev port is `4004`).

3. **Run the app:**

   ```sh
   flutter run
   ```

   > **iOS Simulator caveat:** `mobile_scanner`'s ML Kit dependency does not ship an arm64
   > iOS-simulator slice, so this app cannot run on an Apple-Silicon iOS Simulator. Use a physical
   > iOS device, or an Android emulator/device, for local verification. Details in `CLAUDE.md`.

## Testing & Static Analysis

```sh
flutter analyze   # must run clean before merging any change
flutter test      # unit tests (see test/)
```

## Roadmap

Development is phased, operator-core first: SELLER/RETAILER workflows (auth, catalog, B2B
ordering, POS, debts, payments, multi-store, staff management, reporting) ship before the
CUSTOMER-facing storefront, the SUPER_ADMIN panel, and the restaurant/waiter/courier vertical. See
the **Roadmap** section of `CLAUDE.md` for the detailed, up-to-date milestone breakdown and status.

## Related Projects

**[`Optom_Savdo`](../Optom_Savdo)** is the existing web platform and backend this app is built
against. It is treated as a **read-only reference** — this app consumes its API as-is and never
modifies that codebase.
