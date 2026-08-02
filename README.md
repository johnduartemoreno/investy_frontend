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
| `BuyAssetController` | `POST /transactions` | BUY order |
| `SellAssetController` | `POST /transactions` | SELL order |

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

# Run on device (debug mode → local backend)
flutter run

# Run on device pointing to staging
flutter run --dart-define=USE_STAGING=true

# Analyze
flutter analyze    # must be 0 errors before any merge
```

## Settings Screens

| Route | Screen |
|-------|--------|
| `/settings` | Profile photo, display name, language |
| `/settings/appearance` | System / Light / Dark theme |
| `/settings/security` | Change password, delete account |
| `/settings/about` | Version, Privacy Policy, Terms |
| `/settings/help` | FAQ + support email |
