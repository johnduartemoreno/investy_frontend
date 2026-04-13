---
name: flutter-ux
description: Apply Investy Flutter UX standards — Material 3 with iOS polish, DM Sans typography, colorScheme tokens, shared widgets, and Riverpod patterns. Use this skill when building or reviewing any Flutter screen, widget, or form in this project.
---

Before writing any Flutter UI, think about the design intent:
- **Role of this screen**: Is it a data display (dashboard, portfolio), a form (create goal, top-up), or a navigation hub (settings)?
- **Primary action**: What is the ONE thing the user must do? Make it unmissable.
- **Hierarchy**: Big numbers → section titles → supporting text. Weight and size carry meaning.

Then implement following these rules strictly.

## Typography — DM Sans only

All text uses `theme.textTheme.*` — NEVER set `fontFamily` or `GoogleFonts.*` per widget.

| Role | Style | Use for |
|------|-------|---------|
| Big numbers / hero values | `headlineMedium` (28sp w600) | Balance amounts, goal targets |
| Screen / section titles | `titleLarge` (22sp w600) | "Recent Activity", "My Goals" |
| Card titles | `titleMedium` (16sp w600) | Asset names, goal names |
| Body copy | `bodyLarge` / `bodyMedium` | Descriptions, activity items |
| Secondary / dates | `bodySmall` (12sp w400) | Timestamps, deadlines, hints |
| Chips / buttons / labels | `labelLarge` (14sp w600) | Action labels, category chips |

## Colors — always use colorScheme tokens

```dart
// CORRECT
color: theme.colorScheme.primary
color: theme.colorScheme.onSurfaceVariant
color: theme.colorScheme.surfaceContainerLow  // filled input backgrounds

// WRONG — never hardcode
color: Colors.grey[200]
color: Color(0xFF6750A4)
color: Colors.grey
```

## Shared widgets — always use, never inline

| Widget | Import | Use for |
|--------|--------|---------|
| `PrimaryButton` | `core/presentation/widgets/primary_button.dart` | ALL confirm/submit actions |
| `CustomTextField` | `core/presentation/widgets/custom_text_field.dart` | Standard text inputs |
| `CustomCard` | `core/presentation/widgets/custom_card.dart` | ALL card containers |
| `ThousandsSeparatorInputFormatter` | `core/utils/thousands_separator_input_formatter.dart` | ALL money/amount inputs |
| `CurrencyFormatter.format(value)` | `core/utils/currency_formatter.dart` | ALL money display strings |

## Money inputs — required pattern

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

- Convert to cents before sending to backend: `(amount * 100).round()`
- NEVER use `FilteringTextInputFormatter` alone for money fields
- NEVER use `.toInt()` — always `.round()`

## Money display — required pattern

```dart
// CORRECT
Text(CurrencyFormatter.format(goal.targetAmount))   // → $12,000.00
Text(CurrencyFormatter.format(wallet.availableCash)) // → $1,500.00

// WRONG
Text('\$${value.toStringAsFixed(0)}')
Text('\$${value}')
```

## Forms & inputs

- `hintText` always — NEVER `labelText` (floating labels look unprofessional)
- `filled: true`, `borderSide: BorderSide.none` when unfocused
- Border radius: 12px for inner fields, 16px for cards
- Spacing: 8 (S), 12 (M), 16 (L), 24 (XL) — use `AppDimens` constants

## Buttons

- Primary action → `PrimaryButton` (handles loading state + full width automatically)
- NEVER use `ElevatedButton` directly
- Destructive → outlined with red border

## Progress indicators

```dart
// CORRECT
CircularProgressIndicator.adaptive()

// WRONG
CircularProgressIndicator()
```

## Bottom sheets — required structure

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,  // keyboard pushes content up
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (_) => SingleChildScrollView(
    padding: EdgeInsets.only(
      left: 24, right: 24, top: 24,
      bottom: MediaQuery.of(context).viewInsets.bottom + 32,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // full-width buttons
      children: [...],
    ),
  ),
);
```

## AppBar

- Always `centerTitle: true` (already set in AppTheme — do not override)

## State management — Riverpod patterns

- Read data: `FutureProvider.autoDispose` → `ref.watch(provider)`
- Forms: `StateNotifierProvider.autoDispose`
- After write success: `ref.invalidate(restXxxProvider)` to refresh
- Never call `ref.watch` inside callbacks — use `ref.read`

## Form validation pattern

Validate **all fields simultaneously** — never short-circuit before checking every condition:

```dart
Future<void> _submit() async {
  final formValid = _formKey.currentState!.validate(); // validates all TextFormFields
  final dateValid = _selectedDate != null;
  if (!dateValid) setState(() => _dateError = true);   // show inline error on non-form field
  if (!formValid || !dateValid) return;                // exit only after all errors are shown
  // proceed with submission
}
```

- Non-`TextFormField` fields (chips, date pickers, toggles): use a `bool _xError` flag + inline red text
- Button `onPressed`: **always enabled** — disable only during `_isLoading`. Never hide the button based on partial state; let submit show what's missing.

```dart
// Inline error widget for non-form fields
if (_dateError)
  Padding(
    padding: const EdgeInsets.only(left: 4, top: 6),
    child: Text('Select a target date',
        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.error)),
  ),
```

## Time-horizon chips pattern

For goals / planning screens where the user picks a duration (not an exact date):

```dart
// Preset chips: 6M / 1Y / 2Y / 3Y / 5Y + Custom
static const _presets = [
  (label: '6M', months: 6), (label: '1Y', months: 12),
  (label: '2Y', months: 24), (label: '3Y', months: 36), (label: '5Y', months: 60),
];

AnimatedContainer(
  duration: const Duration(milliseconds: 150),
  decoration: BoxDecoration(
    color: isActive ? colorScheme.primaryContainer : colorScheme.surfaceContainerLow,
    borderRadius: BorderRadius.circular(20),
    border: isActive ? Border.all(color: colorScheme.primary, width: 1.5) : null,
  ),
)
```
- Custom button opens `showDatePicker` as escape hatch
- Show resolved date below chips with a `Icons.check_circle_outline` in `colorScheme.primary`
- Prefer this over `showDatePicker` for any investment/planning horizon

## iOS polish checklist

Before finishing any screen:
- [ ] `CircularProgressIndicator.adaptive()` — not `.()` directly
- [ ] `centerTitle: true` on AppBar
- [ ] No hardcoded colors — all `colorScheme.*`
- [ ] All amounts display via `CurrencyFormatter.format()`
- [ ] All money inputs use `ThousandsSeparatorInputFormatter`
- [ ] Bottom sheet has `isScrollControlled: true` + `SingleChildScrollView`
- [ ] Buttons are `PrimaryButton` or `FilledButton` — never `ElevatedButton`
- [ ] Text inputs use `hintText` — never `labelText`
- [ ] Form submit validates ALL fields simultaneously before returning
- [ ] Button is enabled unless `_isLoading` — never disabled based on partial state
