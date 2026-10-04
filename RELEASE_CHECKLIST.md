# Release checklist: courier delivery & tracking (Phase 7 N6)

Run this before shipping the courier/delivery features (Phases 5–7) to production. Sections 1–4
are one-time setup. Section 5 is the device test pass: tick each row on real phones, not the
emulator. Write down anything that doesn't match the expected result next to the row.

---

## 1. Google Maps keys (Google Cloud Console → APIs & Services → Credentials)

Use **two separate keys**. During T6 verification the app key also worked for server Routes calls,
which means it's currently unrestricted.

| Key | Where it goes | Application restriction | API restriction |
|---|---|---|---|
| **App key** | `bsmart/.env.production` → `MAPS_API_KEY` | **Android apps:** package `uz.bsmart.app` + every SHA-1 below. **iOS apps:** bundle id `uz.bsmart.app` | Maps SDK for Android, Maps SDK for iOS — nothing else |
| **Server key** | VPS `.env` → `GOOGLE_MAPS_SERVER_KEY` | **IP addresses:** the VPS public IP | Routes API only |

SHA-1 fingerprints to add to the Android restriction:
- [ ] **Play App Signing key:** Play Console → your app → Setup → App signing → "App signing key
      certificate" SHA-1. Users' installs are signed with this one.
- [ ] **Upload key:** the one you create in section 2, from `keytool -list -v -keystore <file>`.
- [ ] **Debug key (dev builds only):** `1F:D7:46:C5:37:49:AD:D8:13:F7:71:A9:8E:45:17:A8:1B:1F:E6:9C`.
      Better: keep a **third, dev-only key** for this and leave it out of the production key.

After restricting, check that a **release** build still shows map tiles (section 5, row M1). A blank
grey map with the Google logo means the SHA-1 or bundle id doesn't match.

## 2. Android release signing (one time, then keep the files safe)

Release builds now read `android/key.properties`. Without it they fall back to the debug key, and
the build log says so. Google Play rejects debug-signed bundles.

```bash
cd bsmart
mkdir -p keys
keytool -genkeypair -v -keystore keys/bsmart-upload.jks -alias bsmart-upload \
  -keyalg RSA -keysize 2048 -validity 10000
cp android/key.properties.example android/key.properties   # fill in both passwords
```

- [ ] `keys/`, `*.jks` and `android/key.properties` are git-ignored. **Back up the keystore and
      passwords** in a password manager. If you lose the upload key, you need a Play support reset
      before you can ship updates.
- [ ] Enroll in **Play App Signing** at the first upload (the default), then add its SHA-1 to the
      Maps key (section 1).

## 3. Production backend (VPS)

- [ ] Migrations: `prisma migrate deploy`. It applies, among others, the Phase 6/7 migrations up to
      `20261004120100_add_delivery_outcomes_handover`.
      `20261004120000_add_delivery_failed_status` is a lone `ALTER TYPE … ADD VALUE` and must stay
      its own migration.
- [ ] `.env` on the VPS:

| Variable | Value |
|---|---|
| `REDIS_URL` | the VPS Redis (the API runs without it, but live tracking reports itself unavailable) |
| `GOOGLE_MAPS_SERVER_KEY` | the **server** key from section 1 (unset = no road routes / ETAs) |
| `PUBLIC_TRACKING_BASE_URL` | `https://<your API host>`. **Must be https**: Telegram rejects other button URLs, and customer messages then go out without the 🗺 map button |
| `VERFIY_BOT_TOKEN` | verify bot token (the misspelling is the real name; `VERIFY_BOT_TOKEN` also works) |
| `TELEGRAM_BOT_TOKEN` | main bot |
| `TELEGRAM_BOT_POLLING`, `VERIFY_BOT_POLLING`, `DELIVERY_TELEGRAM_NOTIFICATIONS` | **leave unset** in production (all default to on) |

- [ ] nginx: proxy the WebSocket path **and** the public tracking page to the API, next to the
      existing `/api` block:

```nginx
location /socket.io/ {
    proxy_pass http://127.0.0.1:4005;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_read_timeout 120s;
}
location /t/ {
    proxy_pass http://127.0.0.1:4005;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

- [ ] Smoke test: `https://<host>/t/xxxxxxxxxxxxxxxxxxxxxx` returns the tracking page, which says
      the link wasn't found. A 404 from nginx itself means the `/t/` block is missing.

**Local dev machines:** your local `Optom_Savdo/apps/server/.env` currently has **no**
`TELEGRAM_BOT_POLLING=false` / `VERIFY_BOT_POLLING=false`. A local `npm run dev` with production bot
tokens competes with production for users' bot messages. Add both lines locally, never on the VPS.

## 4. Building the release apps

The app bundles `bsmart/.env`, and Gradle and the iOS AppDelegate read the Maps key from it at build
time. Keep your dev `.env` as it is and put production values in `bsmart/.env.production`
(git-ignored):

```
API_BASE_URL=https://<your API host>/api
MAPS_API_KEY=<app key from section 1>
```

```bash
tool/build_release.sh .env.production android   # Play bundle (.aab)
tool/build_release.sh .env.production apk       # sideload / testers
tool/build_release.sh .env.production ios       # needs Xcode signing; then upload with Transporter
```

The script refuses http:// or dev-machine URLs and an empty Maps key, and warns if
`android/key.properties` is missing. It always puts your dev `.env` back.

**iOS note:** the app can't run on the Apple-Silicon **Simulator** (`mobile_scanner`). iOS has only
been checked by reading the config (When-In-Use text, `UIBackgroundModes: location`, blue
indicator), so every iOS row below is the first real test.

## 5. Device test pass

Phones to cover: **one stock Android** (Pixel or Android One), **one Xiaomi/Redmi** (MIUI/HyperOS),
**one Samsung** (One UI), **one iPhone**. Use the release build from section 4 against production or
a staging server. You need a business owner with couriers enabled, one courier account, and one
customer account whose phone is verified through the verify bot.

Legend: ✅ pass · ❌ fail (write what happened) · — not applicable

### Location sharing (courier phone)

| # | Step | Expected | Pixel | Xiaomi | Samsung | iPhone |
|---|---|---|---|---|---|---|
| L1 | First "Onlayn" | Disclosure screen → system prompt offers **While using the app** (never "Always") | | | | |
| L2 | Deny permission | "Ruxsat berilmagan" banner with a fix-it button; never asks repeatedly | | | | |
| L3 | Online, then **lock the phone** and walk/drive 10 min | Owner's fleet map keeps moving; persistent notification (Android) or blue location pill (iOS) the whole time | | | | |
| L4 | Online, then **switch to another app** for 10 min | Same as L3 | | | | |
| L5 | Online, then **swipe the app away** from recents | Write down what happens. Expected: sharing stops and the owner sees "aloqasiz" after ~60 s. It must **not** silently keep sharing with no notification | | | | |
| L6 | Go indoors / basement, no GPS for > 45 s | Amber "GPS signali yo'q" (`noGpsFix`); green again outdoors without touching anything | | | | |
| L7 | Turn device location off while online | "GPS o'chirilgan" banner with "GPS ni yoqish"; sharing stops | | | | |
| L8 | **Airplane mode 2–3 min** while moving, then off | Route history has **no gap** (query below); same session | | | | |
| L9 | Switch Wi-Fi ↔ mobile data while moving | Keeps sharing; no new session | | | | |
| L10 | Xiaomi: battery saver on, autostart **off** (default), screen off 15 min | If it stops: set **Autostart on** + battery saver **"No restrictions"** for bsmart, repeat, and note which setting fixed it | — | | — | — |
| L11 | Samsung: default battery settings, screen off 15 min | If it stops: Battery → Background usage limits → add bsmart to **Never sleeping apps**, repeat | — | — | | — |
| L12 | Tracking details sheet → "Batareya tejash rejimi" → Sozlamalar | Opens bsmart's app settings | | | | — |

Route-gap check for L8 (on the server; replace the courier phone):
```sql
select "recordedAt", "createdAt" - "recordedAt" as delay from location_points
where "subjectId" = (select id from users where phone = '+998…')
  and "recordedAt" > now() - interval '30 minutes' order by "recordedAt";
```
Expected: steady `recordedAt` spacing through the outage. The outage rows show a large `delay` (they
were sent after reconnect).

### Maps, delivery flow, customer side

| # | Step | Expected | Android | iPhone |
|---|---|---|---|---|
| M1 | Open the courier delivery map and the customer tracking map on the **release** build | Real map tiles (not grey), road route line, ETA row | | |
| M2 | Customer opens a shared public link (`/t/…`) on a phone browser | Live map, moving courier, no courier phone shown | | |
| D1 | Store with **Topshirish kodi** on → courier picks up | Customer sees the 4-digit code in the app **and** in Telegram | | |
| D2 | Courier enters a wrong code, then the right one | "Yana N ta urinish qoldi", then delivered | | |
| D3 | 5 wrong tries → owner taps "Kodsiz topshirishga ruxsat" | Courier's open sheet switches to "ruxsat berdi" by itself | | |
| D4 | Courier → "Yetkazib bo'lmadi" with a reason | Owner card shows the reason; customer gets a Telegram message | | |

### Telegram (first real round trip; everything so far used a stubbed Telegram)

| # | Step | Expected | ✓ |
|---|---|---|---|
| T1 | Customer verifies their phone via the verify bot from the app | App continues by itself; Profil → "Telegram bildirishnomalari" is on | |
| T2 | Run one delivery | Customer gets: qabul qildi → yo'lda (+ code if on) → yetib keldi → yetkazildi, each with 🗺 while active | |
| T3 | Tap 🗺 in Telegram | Public tracking page opens over https | |
| T4 | Tap 🔕 in a message, then run a delivery | No messages; `/start` turns them back on | |
| T5 | Courier links via the bell icon → "Ulash" | Bell shows on | |
| T6 | Owner assigns a delivery to that courier / offers one to all | Courier gets "Sizga yangi yetkazish biriktirildi" / "Yangi yetkazish taklifi" | |
| T7 | Owner reassigns away / cancels | Courier gets "endi sizga biriktirilmagan" / "bekor qilindi" | |

## 6. Sign-off

| Area | Result | Notes | Date |
|---|---|---|---|
| Keys restricted + release maps OK | | | |
| Release signing + Play App Signing | | | |
| Backend env + nginx + migrations | | | |
| Android stock | | | |
| Xiaomi | | | |
| Samsung | | | |
| iPhone | | | |
| Telegram round trip | | | |

Open items carried into this release:
- A restaurant courier can mark an order DELIVERED from the restaurant board (web or bsmart), which
  bypasses the handover code. The code is only enforced on the courier delivery screen.
- Customers verified only through the Mini App get no Telegram messages until they verify once
  through the verify bot.
