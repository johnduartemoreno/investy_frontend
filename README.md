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

### Provider → Endpoint map

| Provider | Endpoint | Description |
|----------|----------|-------------|
| `restDashboardProvider` | `GET /dashboard` | Balance, invested value, activity |
| `restPortfolioProvider` | `GET /portfolio` | Holdings + asset metadata |
| `restGoalsProvider` | `GET /goals` | Goals with progress |
| `riskProfileProvider` | `GET /risk-profile` | Conservative / Moderate / Aggressive |
| `recommendationsProvider` | `GET /recommendations` | AI picks (Claude API, cache 24h) |
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

## i18n

Three locales supported: **EN** (default), **ES**, **PT**.

- All UI strings use ARB keys — never hardcoded English
- Language persisted to `SharedPreferences` + synced to backend (`PUT /language`)
- Claude API recommendation reasons returned in the user's current language
- Add new keys to all three `.arb` files, then run `flutter gen-l10n`

## Theme

Material 3 with full custom dark surface tokens:

| Token | Color | Used for |
|-------|-------|---------|
| `darkBase` | `#0F0F13` | Scaffold background |
| `darkSurface` | `#1A1A20` | Cards, containers |
| `darkElevated` | `#1E1C2A` | Bottom sheets |
| `brandPurple` | `#6C63FF` | Primary actions, gradients |
| `brandPurpleLight` | `#a78bfa` | Accents, subtitles |

Rule: **never use raw hex colors in widgets** — always `Theme.of(context).colorScheme.*` tokens.

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
