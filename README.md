# Investy — Flutter Mobile App

**Mobile-only (Android/iOS). Web and macOS are out of scope.**

Flutter application using Clean Architecture, Riverpod, GoRouter, and Material 3. Connects to the Investy Go backend via REST. Firebase is used exclusively for authentication (JWT) — no Firestore.

## Architecture

Clean Architecture (domain → data → presentation):

```
lib/
├── core/
│   ├── config/app_config.dart          # Base URL — env-aware (local/staging/prod)
│   ├── network/dio_client.dart         # Firebase JWT interceptor + 401 retry
│   ├── providers/
│   │   ├── locale_provider.dart        # EN/ES/PT — persisted to SharedPreferences
│   │   ├── session_provider.dart       # Auth state + session termination
│   │   └── theme_provider.dart         # System/Light/Dark toggle
│   ├── router/app_router.dart          # GoRouter — all routes
│   ├── theme/
│   │   ├── app_theme.dart              # Material 3 dark/light theme, brand tokens
│   │   └── app_dimens.dart             # Spacing constants
│   └── widgets/
│       └── owl_ai_widget.dart          # Animated Owl mascot (CustomPainter, 5 controllers)
├── features/
│   ├── auth/                           # Login, signup, forgot password, Google Sign-In
│   ├── dashboard/                      # Home screen, Owl AI sheet, buy/sell/deposit/withdraw
│   ├── portfolio/                      # Holdings with market values
│   ├── goals/                          # Financial goals + create goal sheet
│   ├── risk_profile/                   # 5-question questionnaire → Conservative/Moderate/Aggressive
│   ├── kyc/                            # Sumsub WebSDK onboarding
│   ├── transactions/                   # Top-up screen
│   ├── alerts/                         # Price alerts (above/below) + create sheet (B12)
│   └── settings/                       # Profile, appearance, security, language, about
└── l10n/                               # ARB strings — EN / ES / PT
    ├── app_en.arb
    ├── app_es.arb
    └── app_pt.arb
```

## Key Libraries

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` + `riverpod_annotation` | State management — FutureProvider, Notifier |
| `go_router` | Declarative navigation with redirect guards |
| `dio` | HTTP client with Firebase JWT interceptor |
| `firebase_auth` | JWT identity only — no Firestore |
| `google_sign_in` | OAuth — unified login+signup |
| `google_fonts` | DM Sans — applied globally via `AppTheme` |
| `shared_preferences` | Language + theme persistence |
| `intl` | ARB-based i18n (EN/ES/PT) |

## REST Backend Integration

Base URL selected automatically:

| Environment | URL |
|-------------|-----|
| Android emulator | `http://10.0.2.2:8080` |
| iOS device / debug | `http://192.168.1.8:8080` (Mac LAN IP — update in `app_config.dart`) |
| Staging | `http://investy-backend-stg.eba-wqzwp2yc.us-east-1.elasticbeanstalk.com` |
| Production | `https://api.investy.com` |

Use `--dart-define=USE_STAGING=true` to force staging URL in debug builds.
Add `--dart-define=GIT_SHA=$(git rev-parse --short HEAD)` to stamp the build SHA in the on-screen environment badge (B53); without it the badge shows the environment only.

### Provider → Endpoint map

| Provider | Endpoint | Description |
|----------|----------|-------------|
| `restDashboardProvider` | `GET /dashboard` | Balance, invested value, activity |
| `restPortfolioProvider` | `GET /portfolio` | Holdings + asset metadata |
| `portfolioHistoryProvider` | `GET /portfolio/history` | Portfolio value curve, range-reactive (B43) |
| `todaysChangeProvider` | _(derived)_ | Today's +/− €/% from portfolio history (B43) |
| `assetHistoryProvider` | `GET /assets/{symbol}/history` | Price history for asset detail screen (B43) |
| `restGoalsProvider` | `GET /goals` | Goals with progress |
| `riskProfileProvider` | `GET /risk-profile` | Conservative / Moderate / Aggressive |
| `recommendationsProvider` | `GET /recommendations` | AI picks (Claude API, cache 24h) |
| `owlHistoryProvider` | `GET /recommendations/history` | Persisted Owl AI sessions (B29) |
| `alertsProvider` | `GET /price-alerts` | User's price alerts list (B12) |
| `AlertFormController` | `POST` / `DELETE /price-alerts` | Create / delete a price alert (B12) |
| `FitScoreController` | `GET /assets/{symbol}/fit` | Fit Score of a purchase (S19) — imperative, debounced |
| `BuyAssetController` | `POST /transactions` | BUY order |
| `SellAssetController` | `POST /transactions` | SELL order |

## Fit Score card (S19)

`FitScoreCard` (`lib/features/dashboard/presentation/widgets/fit_score_card.dart`)
shows how well a purchase suits **this** user. It appears on the buy screen —
below the goal selector, above the confirm button — and on asset detail, where it
assesses the position already held (`amountCents: 0`).

**The card computes nothing.** Every score, threshold and caveat arrives decided
from the backend; the widget maps `reason` keys to translated sentences. A key the
app does not know yet renders as nothing, never as the raw key.

**Two reason keys are emitted by more than one component, and each needs its own
wording.** `_reasonText` therefore takes the `FitComponentKind` and picks:

| key | emitted by | why one sentence cannot serve both |
|-----|-----------|-----------------------------------|
| `class_not_in_plan` | profile + diversification | "does it belong?" and "how far does it push you off?" are different questions. `entity.go:142-147` says G1 states it "in its own words" — that only became true once the key was split. |
| `no_portfolio` | diversification + concentration | "no mix to compare against" is right under *effect on your mix* and **wrong** under *weight in your portfolio*, which does not measure the mix. |

`no_profile` is also shared (profile + diversification) and is deliberately **not**
split: it names what is missing without misdescribing either component.

Both splits came out of the S19 UAT, one after the other — the second was found
only because the first had already been fixed. **When splitting a shared reason
key, sweep the whole family rather than the instance you happened to see.**

Three rules it exists to enforce, each with a widget test:

- **Colour and sentences in front, the number behind "ver por qué"** (decision of
  2026-08-11). A score presiding over the screen claims a precision five
  components over a few weeks of data do not have, and reads as advice.
- **A component with no data reads "sin medir", never `0`.** A zero says the fit
  is bad. This is the last layer where that distinction can be lost.
- **The disclaimer is visible without expanding anything**, on both branches of
  the card — including the one where a verdict sits above a buy button.

Below the confidence threshold the backend does not send a score at all, and the
card shows what is missing instead: the user's gaps under *"Qué ayudaría"* and
ours under *"De nuestro lado"*, never run together.

## Owl AI Advisor

The Owl AI mascot (`lib/core/widgets/owl_ai_widget.dart`) is a pure Flutter `CustomPainter` with 5 `AnimationController`s:

| Controller | Behavior |
|-----------|---------|
| `_breathCtrl` | Subtle body scale 2s loop |
| `_blinkCtrl` | Eye blink every 3–5s |
| `_tieCtrl` | Tie swing 1.8s loop |
| `_thinkCtrl` | Fast pulse while loading |
| `_celebrateCtrl` | ElasticOut bounce on recommendations loaded |

States: `idle` / `thinking` (while API loads) / `celebrating` (on data received).

The Owl AI sheet (`_OwlAdvisorSheet` in `dashboard_screen.dart`):
- Reads `riskProfileProvider` + `restAvailableCashProvider` for context pills
- Calls `recommendationsProvider` — reasons arrive pre-localized from Claude in the user's language
- Refresh button (🔄) invalidates cache and calls `?refresh=true`
- Error state shows friendly message + retry button
- BUY button uses `context.push` (not `go`) so sheet stays in stack when navigating
- Goal chips in the header show active goals — tap navigates to goal detail (S18)
- History button (🕐 icon) pushes `/home/owl-history` — list of persisted sessions
  with date, ticker chips and context snapshot; tap opens a read-only detail sheet
  (`owl_history_screen.dart`, B29). Old sessions keep their original language.

## i18n

Three locales supported: **EN** (default), **ES**, **PT**.

- All UI strings use ARB keys — never hardcoded English
- Language persisted to `SharedPreferences` + synced to backend (`PUT /language`)
- Claude API recommendation reasons returned in the user's current language
- KYC rejection reasons are Sumsub `rejectLabels` — machine codes mapped to ARB
  keys by `KycRejectLabels`, with a generic line for codes we do not know. The
  raw code never reaches the user. The label set is Sumsub's and grows without
  notice, so an unknown one must still say something (B77).
- The Sumsub KYC WebSDK is initialized with the app's active locale (fallback
  `en`) and the app's active theme — both used to be hardcoded (English, white
  background). The SDK card renders with **its own** theme, so setting only our
  page background left a white card on a dark page; `withConf` gets `lang` and
  `theme` together (B61). Both are frozen for the WebView's lifetime on purpose:
  applying a new one means re-initializing the SDK, which restarts the
  verification.
- Push notification text is rendered by the **backend** from
  `users.preferred_language`; it arrives already translated and the app cannot
  change it (B60). The app therefore pushes its language to the backend **on
  sign-in**, not only when the user changes it in Settings — otherwise a user
  reading the app in Spanish keeps the `en` default the backend row is created
  with, and every notification arrives in English. On sign-in the device wins:
  it is the language the user is reading right now.
- Add new keys to all three `.arb` files, then run `flutter gen-l10n`

## Android permissions

Declared in `android/app/src/main/AndroidManifest.xml`:

| Permission | Why |
|---|---|
| `INTERNET` | REST backend |
| `CAMERA` | Sumsub KYC liveness check. Requested at runtime via `permission_handler` before launching the SDK, and granted to the WebView through `AndroidWebViewController.setOnPlatformPermissionRequest` — without that callback Android denies every web permission request by default (B61) |

`RECORD_AUDIO` is deliberately **not** declared: Sumsub's liveness check is
facial. The microphone only appears in the SDK's generic instructions text, not
as a requirement — and an unnecessary permission is store-review risk.

## Core Shared Widgets

Always use these — never inline equivalents:

| Widget | File | Use for |
|--------|------|---------|
| `PrimaryButton` | `core/presentation/widgets/primary_button.dart` | All confirm/submit buttons — gradient fill + glow |
| `CustomTextField` | `core/presentation/widgets/custom_text_field.dart` | Standard text inputs |
| `CustomCard` | `core/presentation/widgets/custom_card.dart` | All card containers — purple border + glow |
| `GradientIconBox` | `core/presentation/widgets/gradient_icon_box.dart` | Asset/feature icons in cards and sheets |
| `SignalBadge` | `core/presentation/widgets/signal_badge.dart` | Trading signal chips — Strong Buy / Moderate / Sell |
| `LeftAccentBox` | `core/presentation/widgets/left_accent_box.dart` | Highlighted insights with left purple bar |
| `GradientPillButton` | `core/presentation/widgets/gradient_pill_button.dart` | Compact pill actions in sheets |
| `ThousandsSeparatorInputFormatter` | `core/utils/thousands_separator_input_formatter.dart` | ALL amount/money inputs |
| `CurrencyFormatter` | `core/utils/currency_formatter.dart` | All money display strings |

## Theme

Material 3 with explicit light + dark `ColorScheme` — both built without `ColorScheme.fromSeed`:

| Token | Light | Dark | Used for |
|-------|-------|------|---------|
| `brandPurple` | `#6C63FF` | `#6C63FF` | Primary actions, gradients |
| `brandPurpleLight` | `#a78bfa` | `#a78bfa` | Accents, subtitles, gradient end |
| `signalGreen` | `#4ade80` | `#4ade80` | Strong Buy badge |
| `signalAmber` | `#D97706` | `#D97706` | Moderate badge |
| `lightSurface` / `darkBase` | `#F8F8FC` | `#0F0F13` | Scaffold background |
| `lightCard` / `darkSurface` | `#EEEDF8` | `#1A1A20` | Cards, containers |
| — / `darkElevated` | — | `#1E1C2A` | Bottom sheets |

Rule: **never use raw hex colors in widgets** — always `Theme.of(context).colorScheme.*` tokens.

## Screenshots

Screen registry: `docs/design/screenshots/SCREENS.md` — maps each screen ID to its source `.dart` file and screenshot paths (`light_mode/XX.png` + `dark_mode/XX.png`).

After modifying any screen in `lib/features/`, check `SCREENS.md` and ask the user for an updated screenshot before marking the task done.

## Local Development

```bash
# Install dependencies
flutter pub get

# Generate Riverpod + Freezed code
dart run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze    # must be 0 errors before any merge
```

### Running for UAT (physical device)

UAT runs on a physical device, never the simulator. Two flags below are not
optional extras:

- **`-d <device-id>`** — with four devices paired, a bare `flutter run` opens a
  picker and waits there forever.
- **`GIT_SHA`** — without it the badge shows the environment but not *which*
  build is running, and a stale build pointing at staging already cost a full
  round of UAT confusion (2026-07-26, B53).

```bash
# Against the LOCAL backend. `localhost` is unreachable from a physical iPhone —
# it is the phone itself — so the Mac's LAN IP is passed in. Read it at run time:
# it changes between sessions, and a stale IP fails against a host that does not
# exist.
flutter run --profile -d <device-id> \
  --dart-define=LOCAL_IP=$(ipconfig getifaddr en0) \
  --dart-define=GIT_SHA=$(git rev-parse --short HEAD)

# Against STAGING.
flutter run --profile -d <device-id> \
  --dart-define=USE_STAGING=true \
  --dart-define=GIT_SHA=$(git rev-parse --short HEAD)
```

**`--profile` is not optional on a physical iPhone.** A debug build is JIT, and
iOS kills a JIT process that has no debugger attached — so a debug build dies
within seconds of being opened from the home screen, and survives only for as
long as `flutter run` stays connected. That connection is exactly what the VPN
breaks (see the mDNS note below), so in debug the two failures compound and look
like one: the console hangs at "Installing and launching", and the app on the
phone crashes on open. Both disappear in profile mode, which is self-contained.

`flutter devices` lists the ids. The profile build takes ~100s at
"Installing and launching" — it is not stuck. **Keep the phone
unlocked** or the launch never completes and you get a white screen.

An `OS Error: Address already in use, errno = 48` in `MDnsClient.start` after
"Installing and launching" is **not an app failure**: the app is already
installed and running with its `--dart-define`s compiled in. What broke is VM
service discovery over mDNS, usually because a VPN puts the default route on a
`utun` interface. You lose hot reload, DevTools and device logs — nothing of the
app's behaviour.

## Settings Screens

| Route | Screen |
|-------|--------|
| `/settings` | Profile photo, display name, language |
| `/settings/appearance` | System / Light / Dark theme |
| `/settings/security` | Change password, delete account |
| `/settings/about` | Version, Privacy Policy, Terms |
| `/settings/help` | FAQ + support email |
