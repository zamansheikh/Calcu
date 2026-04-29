# In-App Purchases — Setup Guide

This guide walks you end-to-end from **zero** to **selling theme packs**
through Google Play, using RevenueCat as the billing layer. The app code is
already wired — you only need to configure dashboards and paste an API key.

> **App ID:** `com.decodersfamily.calcu`
> **SDK:** `purchases_flutter ^10.0.1`
> **Free pack:** `classic` (always owned, never charged)
> **Paid packs:** `midnight`, `sunset`, `forest`, `ocean`, `monochrome`

---

## Table of contents

1. [How the integration is structured](#1-how-the-integration-is-structured)
2. [Prerequisites](#2-prerequisites)
3. [Step 1 — Sign your release build](#step-1--sign-your-release-build)
4. [Step 2 — Upload a build to Google Play](#step-2--upload-a-build-to-google-play)
5. [Step 3 — Create products in Play Console](#step-3--create-products-in-play-console)
6. [Step 4 — Create a RevenueCat project](#step-4--create-a-revenuecat-project)
7. [Step 5 — Connect Google Play to RevenueCat](#step-5--connect-google-play-to-revenuecat)
8. [Step 6 — Create entitlements, products, offering](#step-6--create-entitlements-products-offering)
9. [Step 7 — Add the API key to the app](#step-7--add-the-api-key-to-the-app)
10. [Step 8 — Android manifest + permissions](#step-8--android-manifest--permissions)
11. [Step 9 — Test purchases](#step-9--test-purchases)
12. [Step 10 — Go live](#step-10--go-live)
13. [Adding a new theme later](#adding-a-new-theme-later)
14. [Troubleshooting](#troubleshooting)
15. [iOS / App Store (later)](#ios--app-store-later)

---

## 1. How the integration is structured

```
lib/
├── core/
│   ├── config/billing_config.dart       ← API keys + naming convention
│   └── services/billing_service.dart    ← RevenueCat wrapper + local mock
├── presentation/
│   ├── providers/theme_provider.dart    ← purchase / restore / ownership
│   ├── pages/theme_store_page.dart      ← UI: cards, restore, busy state
│   └── widgets/theme_pack_tile.dart     ← per-pack card with live price
└── theme/theme_catalog.dart             ← static list of packs (id + colors)
```

**Naming convention** — the app assumes a 1:1:1 mapping:

| Concept | Identifier | Example |
| --- | --- | --- |
| Theme pack id (in code) | as defined in `ThemePackId` | `midnight` |
| Play Store product id | `theme_<packId>` | `theme_midnight` |
| RevenueCat **package** identifier | same as pack id | `midnight` |
| RevenueCat **entitlement** id | same as pack id | `midnight` |

If you can't follow this convention (e.g. an existing product id), override
the relevant function in `lib/core/config/billing_config.dart`:

```dart
static String packageIdFor(String packId) => packId;
static String entitlementIdFor(String packId) => packId;
static String productIdFor(String packId) => 'theme_$packId';
```

**Local fallback** — while `BillingConfig.androidApiKey` is empty, the app
runs against an in-memory mock that persists "purchases" via
`SharedPreferences`. This means devs and CI keep working without RevenueCat.

---

## 2. Prerequisites

Before you start, confirm you have:

- [ ] A **Google Play Console** developer account ($25 one-time fee).
- [ ] A **RevenueCat** account (free up to $2.5k MTR).
- [ ] The Android `com.decodersfamily.calcu` app uploaded to Play Console
      at least once (required to see the "In-app products" section). A
      closed/internal testing track is enough.
- [ ] A signing keystore. The same APK fingerprint (`SHA-1`) must match
      both your dev test track and prod tracks for purchases to flow.

---

## Step 1 — Sign your release build

Play Console will only accept **signed AABs**. If you haven't done this yet:

1. Generate a keystore (one time, **back this up**):

   ```bash
   keytool -genkey -v -keystore ~/calcu-upload.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias calcu
   ```

2. Create `android/key.properties` (do **not** commit):

   ```properties
   storePassword=...
   keyPassword=...
   keyAlias=calcu
   storeFile=/absolute/path/to/calcu-upload.jks
   ```

3. Wire signing into `android/app/build.gradle.kts` (look for the
   `signingConfigs` block; copy the standard pattern from the Flutter docs
   if it isn't there).

4. Build:

   ```bash
   flutter build appbundle --release
   ```

   Output: `build/app/outputs/bundle/release/app-release.aab`

---

## Step 2 — Upload a build to Google Play

1. Open [Play Console](https://play.google.com/console) → your app.
2. Go to **Testing → Internal testing**.
3. Create a release, upload `app-release.aab`, save and roll out.
4. Add yourself to the **Testers** list (use the email tied to a real
   Google account on a real Android device).

> ⚠️ You **must** roll out a build (even just to internal testing) before
> Play Console enables the "Monetize → Products → In-app products" page.

---

## Step 3 — Create products in Play Console

1. Go to **Monetize → Products → In-app products → Create product**.
2. For each premium theme, create one product:

   | Product ID | Name | Description | Default price |
   | --- | --- | --- | --- |
   | `theme_midnight` | Midnight theme | Deep purples and electric violet | $0.20 |
   | `theme_sunset` | Sunset theme | Warm amber and coral | $0.25 |
   | `theme_forest` | Forest theme | Calm greens | $0.25 |
   | `theme_ocean` | Ocean theme | Cool teals and crisp cyan | $0.30 |
   | `theme_monochrome` | Monochrome theme | Pure grayscale | $0.30 |

   > ⚠️ **Minimum price check:** Google Play has per-country minimums.
   > In most regions the floor is currently **$0.10 USD-equivalent**, but
   > a few markets still hold $0.99 minimums. When you create the product
   > in Play Console, the *Pricing template* will reject any region whose
   > floor is above your set price — let it auto-skip those countries
   > rather than blocking the whole product.

3. Type: **Managed product** (one-time, non-consumable).
4. Status: **Active**.
5. Save each.

> If you change a product ID later you also have to change `productIdFor`
> in `BillingConfig`. Keep them aligned.

---

## Step 4 — Create a RevenueCat project

1. Sign in at <https://app.revenuecat.com>.
2. **Project → New project** → name it `Calcu`.
3. Inside the project: **Apps → + New** → choose **Google Play Store**.
4. Fill in:
   - **App name:** `Calcu Android`
   - **Bundle ID:** `com.decodersfamily.calcu`
   - Leave the service account field for now — we'll do it next.
5. Save. RevenueCat now shows a **public Android SDK key**
   (`goog_xxxxxxxxxxxxxxxxxxxx`). Keep this tab open.

---

## Step 5 — Connect Google Play to RevenueCat

RevenueCat needs server-to-server access to verify purchases. You give it
that via a Google Cloud service account.

1. In RevenueCat (still in the Android app config) click
   **"Connect to Google Play"** — it links to the official guide and
   shows the JSON-credentials uploader.

2. Follow these condensed steps:

   - Go to <https://console.cloud.google.com/iam-admin/serviceaccounts>.
   - Pick the project that's linked to your Play Console (Play creates
     one automatically; if unsure, in Play Console go to **Setup → API
     access**).
   - **Create service account** → name `revenuecat`, role
     **Pub/Sub Admin** (for real-time notifications) and
     **Service Account User**.
   - On the new account → **Keys → Add key → JSON** → download the file.

3. In Play Console → **Setup → API access** → grant the new service
   account access:
   - **Permissions:** *View financial data, orders, and cancellation
     survey responses* + *Manage orders and subscriptions*.
   - Apply to your app (`com.decodersfamily.calcu`).

4. Back in RevenueCat → upload the JSON key from step 2.

5. *(Optional but recommended)* Real-time developer notifications — in
   RevenueCat copy the **Pub/Sub topic** it shows you, then in Play
   Console → **Monetize → Monetization setup** paste it under
   "Real-time developer notifications".

You should see RevenueCat report **"Service credentials valid"** within a
minute.

---

## Step 6 — Create entitlements, products, offering

Inside your RevenueCat project:

### 6a. Import products

1. **Product catalog → Products → + New**.
2. For each of the 5 Play products you created:
   - **Identifier:** the Play product ID (e.g. `theme_midnight`)
   - **Store:** Google Play Store
   - Save.

### 6b. Create entitlements

1. **Entitlements → + New** → repeat for each pack.
2. **Identifier** must match the pack id exactly:
   `midnight`, `sunset`, `forest`, `ocean`, `monochrome`.
3. Click into each entitlement → **Attach products** → attach the
   matching Play product (`midnight` ← `theme_midnight`, etc.).

### 6c. Create offering

1. **Offerings → + New** → identifier `default` → **Make current**.
2. Add packages — one per theme. For each:
   - **Identifier:** the pack id (`midnight`, `sunset`, …). Use
     **Custom**, not the predefined "Lifetime/Monthly" tiers.
   - **Product:** the matching Play product.
3. Save.

> Why three layers? Products are what's billed, entitlements are what
> unlock features, and offerings group packages for display. Keeping pack
> id == package id == entitlement id collapses all three to the same
> string and removes a class of bugs. This is also what
> `BillingConfig.packageIdFor` / `entitlementIdFor` assume.

---

## Step 7 — Add the API key to the app

Open `lib/core/config/billing_config.dart` and paste the public Android
SDK key from Step 4:

```dart
class BillingConfig {
  static const String androidApiKey = 'goog_xxxxxxxxxxxxxxxxxxxx';
  static const String iosApiKey = '';
  // ...
}
```

> **Public ≠ secret.** RevenueCat SDK keys are designed to ship in client
> apps. Don't confuse them with the **secret** API key on the same
> dashboard page — that one is for server-side use only and must never
> appear in your APK.

After this change, the app stops using the local mock and routes through
the real Play Billing flow. You can confirm in the theme store: a
**Restore purchases** button appears at the bottom only when
`isStoreConfigured` is true.

---

## Step 8 — Android manifest + permissions

The `purchases_flutter` plugin **already declares** the
`com.android.vending.BILLING` permission via its own AndroidManifest, so
you don't need to add it manually. Just verify after a clean build:

```bash
flutter build appbundle --release
unzip -p build/app/outputs/bundle/release/app-release.aab \
  base/manifest/AndroidManifest.xml | grep BILLING
```

Other manifest checks:

- `INTERNET` permission — already present in
  `android/app/src/main/AndroidManifest.xml` ✅.
- `minSdk` — Play Billing requires API 21+, and `purchases_flutter` 10.x
  bumps this to 24+. Confirm in `android/app/build.gradle.kts`:

  ```kotlin
  defaultConfig {
      minSdk = 24
      // ...
  }
  ```

  If `flutter.minSdkVersion` resolves to less than 24, set it explicitly.

---

## Step 9 — Test purchases

You **cannot** test billing on the emulator's default Play Services. You
need a real device signed in with a Google account that's on the
Play Console **License testers** list.

### 9a. Add yourself as a license tester

1. Play Console → **Settings → License testing** (top-level account
   setting, not per-app).
2. Add the Gmail address you use on your test device.
3. Set **License response** to `RESPOND_NORMALLY`.

### 9b. Install via the Internal testing link

1. Play Console → **Internal testing → Testers → Copy opt-in URL**.
2. Open it on your test device, accept the invite, install Calcu via
   the Play Store link.

### 9c. Test flows to run

| Flow | Steps | Expected |
| --- | --- | --- |
| Purchase | open theme store → tap **Buy** on a premium pack → confirm | Google sheet shows test card. Complete → snackbar "X unlocked & applied" |
| Already-owned | tap **Buy** on the same pack again | Goes through purchase but Play short-circuits and re-grants entitlement |
| Restore | clear app data → open theme store → **Restore purchases** | Snackbar "Restored N themes", premium tiles flip to **Apply** |
| Cancel | tap **Buy** → close the Google sheet | App stays on store; snackbar "Purchase cancelled" |
| Cross-device | buy on device A → install + sign in on device B → tap **Restore** | Same entitlements appear on B |

Test purchases incur **no real charge**. They show up in the Play
Console with a yellow "test" badge. Cancel a test purchase via
<https://play.google.com/store/account/orderhistory> if you want to
re-test the buy flow.

### 9d. Useful logs

`Purchases.setLogLevel(LogLevel.warn)` is set in `BillingService.initialize`.
For deep debugging temporarily change it to `LogLevel.verbose` and run:

```bash
flutter run --release   # billing requires release mode for real flows
```

Errors surface as `BillingException` and are shown via snackbar in the
store page (`theme_store_page.dart` → `_purchasePack`).

---

## Step 10 — Go live

1. RevenueCat → **Project settings → Apps → Android** → confirm
   "Service credentials valid".
2. Play Console → promote the build from internal → closed → open →
   production tracks.
3. Each product in **Monetize → In-app products** must be **Active**
   on production tracks (not just internal).
4. RevenueCat → **Charts → Active subscribers / one-time purchases** —
   real revenue should start showing within minutes of the first sale.

---

## Adding a new theme later

This is the whole flow once everything's wired up:

1. **In code:**
   - Add the id to `ThemePackId` in `lib/theme/theme_catalog.dart`.
   - Add a new `ThemePack` in `ThemeCatalog.packs` (light + dark
     palettes + preview color + `isPremium: true`).
2. **Play Console:** create product `theme_<newId>`. Activate.
3. **RevenueCat:** add Product → add Entitlement (id = newId) → add
   Package to the current Offering (identifier = newId). Attach product
   to entitlement.
4. **Ship a new app version** (the catalog is shipped in code, so old
   clients don't see the new theme until they update).

No `BillingConfig` change needed — the convention handles it.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `BillingException: No offerings configured in RevenueCat` | Offering not marked **Current**, or app polled before products were active | RevenueCat → Offerings → "Make current" on `default`. Wait 5–10 min for Play to propagate after creating products. |
| `BillingException: Package "midnight" missing from offering` | Offering exists but no package with that identifier | Add a Package whose identifier equals the pack id. |
| Buy button does nothing on emulator | Emulator without Play Services / not signed in | Use a real device with a tester Google account, or use a Play-images emulator (`Google Play` flavor). |
| `Service credentials invalid` in RevenueCat | Service account missing IAM roles, or Play API access not granted to the service account | Re-do Step 5. Order matters: Cloud IAM → Play Console API access → upload JSON. |
| `INSTALL_FAILED_VERSION_DOWNGRADE` when installing test build | Play Store has a higher version than your sideload | Bump `version:` in `pubspec.yaml`, rebuild. |
| Restore returns 0 themes for an account that bought before | Account isn't a license tester for that app | Step 9a — add the Gmail to **License testers**. |
| `BILLING` permission missing in built APK | Stripped by ProGuard/R8 manifest merger | Ensure you're not using a custom `<application>` block that drops merger rules. |
| RevenueCat dashboard shows purchases but app doesn't unlock | Entitlement id mismatch | Each entitlement id **must** equal the pack id. Re-check Step 6b. |
| Long delay between purchase and unlock on first install | Real-time notifications not configured | Step 5 #5 — Pub/Sub topic. Otherwise RevenueCat falls back to Play receipts; usually still <30s. |

---

## iOS / App Store (later)

When you ship iOS:

1. App Store Connect → create the same products with ids
   `theme_midnight`, `theme_sunset`, …
2. RevenueCat → Apps → + iOS → bundle id, upload App Store Connect
   shared secret + p8 key.
3. RevenueCat re-uses the same Entitlements and Offering — attach the
   iOS products to the same entitlements (Step 6b).
4. In `BillingConfig.iosApiKey` paste the iOS public SDK key.

The Dart code doesn't change. `BillingService` already detects the
platform via `Platform.isIOS` and selects the right key.

---

## Reference

- RevenueCat Flutter docs: <https://www.revenuecat.com/docs/flutter>
- Play Console — In-app products:
  <https://support.google.com/googleplay/android-developer/answer/1153481>
- Test purchases:
  <https://developer.android.com/google/play/billing/test>
- Pub package: <https://pub.dev/packages/purchases_flutter>
