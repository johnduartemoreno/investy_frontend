# Investy Frontend — Agent Instructions

## 🎨 UX & Design Standard

**Framework:** Flutter with Material 3 (`useMaterial3: true`).
**Feel:** Material 3 with iOS-like polish — centered titles, filled inputs, adaptive indicators, smooth rounded corners.

### Color Palette
- **Seed color:** `Color(0xFF6750A4)` (purple) — do NOT hardcode colors. Always use `Theme.of(context).colorScheme.*`.
- Primary surfaces: `colorScheme.surfaceContainerLow` for input backgrounds
- Never use `Colors.grey[200]` or raw hex colors in widgets — use theme tokens.

### Core Shared Widgets — ALWAYS use these, never inline equivalents
| Widget | File | Use for |
|--------|------|---------|
| `PrimaryButton` | `core/presentation/widgets/primary_button.dart` | All confirm/submit buttons |
| `CustomTextField` | `core/presentation/widgets/custom_text_field.dart` | Standard text inputs |
| `CustomCard` | `core/presentation/widgets/custom_card.dart` | All card containers |
| `ThousandsSeparatorInputFormatter` | `core/utils/thousands_separator_input_formatter.dart` | ALL amount/money inputs |
| `CurrencyFormatter` | `core/utils/currency_formatter.dart` | All money display strings |

### Amount / Money Input Standard
Every form field that accepts a monetary value MUST follow this pattern:
```dart
TextFormField(
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
  textAlign: TextAlign.center,
  decoration: InputDecoration(
    prefixText: '\$ ',
    border: InputBorder.none,
    hintText: '0',
  ),
  inputFormatters: [ThousandsSeparatorInputFormatter()],
)
```
- **Never** use `FilteringTextInputFormatter` alone for money fields
- **Never** use `ElevatedButton` — use `PrimaryButton` or `FilledButton`
- Convert to cents before sending to backend: `(amount * 100).round()`

### Forms & Inputs
- Border radius: `AppDimens.radius` (16px) or 12px for inner fields
- Inputs: `filled: true`, `borderSide: BorderSide.none` — no visible border when unfocused
- Focus border: uses `colorScheme.primary` (auto via theme)
- Spacing: use `AppDimens` constants (S=8, M=12, L=16, XL=24)

### Buttons
- Primary action: `PrimaryButton` (wraps `FilledButton` + `CircularProgressIndicator.adaptive()`)
- Destructive: outlined red border (see Log Out in settings)
- Quick-select chips: outlined `borderRadius: 20`, label bold + `colorScheme.primary`

### Progress Indicators
- Always `CircularProgressIndicator.adaptive()` — renders native on iOS, Material on Android
- Never `CircularProgressIndicator()` directly in app UI

### AppBar
- Always `centerTitle: true` (already set in `AppTheme`)

### Bottom Sheets
- `showModalBottomSheet(isScrollControlled: true)` — allows keyboard to push content up
- `RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)))`
- Padding: `EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 32)`
- Content MUST be wrapped in `SingleChildScrollView` — keyboard pushes content up correctly
- Column inside sheet MUST use `crossAxisAlignment: CrossAxisAlignment.stretch` — ensures buttons are full-width

### Form Fields
- Always use `hintText` — NEVER `labelText`. Floating labels overlap inputs and look unprofessional.
- `CustomTextField` already uses this pattern — follow it for any inline `TextFormField` too

### Displaying Money in UI
- Always `CurrencyFormatter.format(doubleValue)` — never `.toStringAsFixed(0)` or string interpolation with `\$`
- Example: `CurrencyFormatter.format(goal.targetAmount)` → `$12,000,000.00`

---

## 🏗️ Architecture Rules

- **State management:** Riverpod (`flutter_riverpod` + `riverpod_annotation`)
- **Navigation:** GoRouter
- **Pattern:** Clean Architecture — `domain/` → `data/` → `presentation/`
- **Providers:** `FutureProvider.autoDispose` for REST reads; `StateNotifierProvider.autoDispose` for forms

## 💰 Money Rules (mirrors backend)
- Wire format: `int` cents (`targetAmountCents`, `totalBalance`, etc.)
- Display: `double` dollars via `CurrencyFormatter.format(value)` or `/ 100.0`
- Conversion outbound: `(uiDouble * 100).round()` — never `toInt()`
- Never use `@JsonKey(defaultValue: ...)` on domain-critical monetary fields — raise the issue instead

## 🌐 i18n
- All UI strings use `.arb` keys (not hardcoded English) for user-facing text
- Error codes from backend map to `.arb` keys — never display raw error codes to users

## 🔒 Data Governance
- If backend returns `null` for a required field, STOP and report — do not silently default
- See root `CLAUDE.md` §Data Governance for full rule

## 📁 Key Files
- Theme: `lib/core/theme/app_theme.dart`
- Dimensions: `lib/core/theme/app_dimens.dart`
- Router: `lib/core/router/app_router.dart`
- Dio client: `lib/core/network/dio_client.dart` (Firebase JWT interceptor)
- API base URL: `lib/core/config/app_config.dart` (platform-aware: Android/iOS/prod)
