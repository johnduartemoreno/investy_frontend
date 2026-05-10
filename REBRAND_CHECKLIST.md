# S15.5 UI Rebrand — Checklist

> Generado: 2026-05-09 | Estado: análisis inicial, sin ediciones

Leyenda: ✅ OK | ⚠️ Parcial | ❌ Problema | N/A No aplica

---

## Prioridad por cantidad de problemas

| # | Pantalla | Problemas (❌+⚠️) | Feature |
|---|----------|-------------------|---------|
| 1 | TopUpScreen | 7 | Transacciones |
| 2 | LoginScreen | 6 | Auth |
| 3 | SignUpScreen | 6 | Auth |
| 4 | GoalsScreen | 6 | Goals |
| 5 | RiskResultScreen | 5 | Risk Profile |
| 6 | SettingsScreen | 5 | Settings |
| 7 | WithdrawBottomSheet | 5 | Transacciones |
| 8 | VerifyEmailScreen | 4 | Auth |
| 9 | ForgotPasswordScreen | 4 | Auth |
| 10 | SecurityScreen | 4 | Settings |
| 11 | SellAssetScreen | 3 | Transacciones |
| 12 | AboutScreen | 3 | Settings |
| 13 | PortfolioScreen | 2 | Portfolio |
| 14 | BuyAssetScreen | 2 | Transacciones |
| 15 | RiskQuestionnaireScreen | 2 | Risk Profile |
| 16 | AppearanceScreen | 1 | Settings |
| 17 | HelpScreen | 1 | Settings |
| 18 | NotificationsScreen | 1 | Settings |

---

## Análisis por pantalla

---

### [6 problemas] LoginScreen (`lib/features/auth/presentation/login_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | ❌ | Usa `FilledButton` directamente en línea 349 en lugar del widget `PrimaryButton` |
| ✦ Sparkle en CTA | ❌ | Sin `Icons.auto_awesome_rounded` en el botón "Sign In" (línea 349) |
| Border radius 14-24 | ⚠️ | `BorderRadius.circular(32)` en el header (línea 159) — fuera del rango 14-24; `BorderRadius.circular(12)` en botones es OK |
| Sin colores hardcodeados | ⚠️ | `Colors.white` en el logo circular (línea 174) — debería usar `colorScheme.surface` o token equivalente |
| Tipografía theme.textTheme | ✅ | Usa `textTheme.*` correctamente en todos los textos |
| Dark theme surface tokens | ✅ | Usa `colorScheme.surface`, `colorScheme.primaryContainer` — sin hexes hardcodeados |
| AppBar centerTitle | N/A | Sin AppBar — pantalla sin barra de navegación |
| Loader adaptive() | ❌ | `CircularProgressIndicator()` sin `.adaptive()` en línea 360 — falta `.adaptive()` |

**Acciones requeridas:**
- [ ] Reemplazar `FilledButton` (línea 349) con `PrimaryButton` del widget compartido
- [ ] Agregar `Icons.auto_awesome_rounded` como sufijo/icono en el CTA de login
- [ ] Cambiar `Colors.white` (línea 174) por `colorScheme.surface` o `colorScheme.onPrimary`
- [ ] Cambiar `CircularProgressIndicator()` (línea 360) por `CircularProgressIndicator.adaptive()`
- [ ] Evaluar reducir `Radius.circular(32)` del header a 24 para consistencia

---

### [6 problemas] SignUpScreen (`lib/features/auth/presentation/signup_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | ❌ | Usa `FilledButton` directamente en línea 414 en lugar del widget `PrimaryButton` |
| ✦ Sparkle en CTA | ❌ | Sin `Icons.auto_awesome_rounded` en el botón "Sign Up" (línea 414) |
| Border radius 14-24 | ⚠️ | `BorderRadius.circular(32)` en el header (línea 180) — fuera del rango 14-24 |
| Sin colores hardcodeados | ⚠️ | `Colors.white` en el logo circular (línea 205) — debería usar token de tema |
| Tipografía theme.textTheme | ✅ | Usa `textTheme.*` correctamente |
| Dark theme surface tokens | ✅ | Usa `colorScheme.surface`, `colorScheme.primaryContainer` — sin hexes |
| AppBar centerTitle | N/A | Sin AppBar formal — usa Stack con botón back manual |
| Loader adaptive() | ❌ | `CircularProgressIndicator()` sin `.adaptive()` en línea 428 |

**Acciones requeridas:**
- [ ] Reemplazar `FilledButton` (línea 414) con `PrimaryButton`
- [ ] Agregar `Icons.auto_awesome_rounded` en el CTA de Sign Up
- [ ] Cambiar `Colors.white` (línea 205) por `colorScheme.surface`
- [ ] Cambiar `CircularProgressIndicator()` (línea 428) por `CircularProgressIndicator.adaptive()`

---

### [4 problemas] ForgotPasswordScreen (`lib/features/auth/presentation/forgot_password_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | ❌ | Usa `FilledButton` directamente en líneas 129 y 163 — dos instancias sin `PrimaryButton` |
| ✦ Sparkle en CTA | ❌ | Sin `Icons.auto_awesome_rounded` en el botón "Send Reset Link" |
| Border radius 14-24 | ✅ | `BorderRadius.circular(12)` en botones — dentro del rango |
| Sin colores hardcodeados | ✅ | Sin colores hardcodeados — usa `colorScheme.*` |
| Tipografía theme.textTheme | ✅ | Usa `textTheme.*` correctamente |
| Dark theme surface tokens | ✅ | Sin hardcoding de fondos |
| AppBar centerTitle | ❌ | AppBar en línea 65 sin `centerTitle: true` — `backgroundColor: Colors.transparent` OK pero falta centrado |
| Loader adaptive() | ❌ | `CircularProgressIndicator()` sin `.adaptive()` en línea 140 |

**Acciones requeridas:**
- [ ] Reemplazar `FilledButton` (líneas 129, 163) con `PrimaryButton`
- [ ] Agregar `centerTitle: true` en `AppBar` (línea 65)
- [ ] Cambiar `CircularProgressIndicator()` (línea 140) por `CircularProgressIndicator.adaptive()`
- [ ] Agregar sparkle icon en CTA principal

---

### [4 problemas] VerifyEmailScreen (`lib/features/auth/presentation/verify_email_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | ❌ | Usa `FilledButton.icon` directamente en línea 120 — debería unificarse o usar `PrimaryButton` |
| ✦ Sparkle en CTA | ❌ | Sin `Icons.auto_awesome_rounded` en el botón "Confirm" |
| Border radius 14-24 | N/A | Botones usan `FilledButton` sin `style` personalizado — hereda del tema |
| Sin colores hardcodeados | ❌ | `Colors.orange` en línea 36 (SnackBar "not verified") y `Colors.green` en línea 52 (SnackBar "sent") — deben usar `colorScheme.error` / `colorScheme.tertiary` |
| Tipografía theme.textTheme | ✅ | Usa `Theme.of(context).textTheme.*` correctamente |
| Dark theme surface tokens | ✅ | Sin fondos hardcodeados |
| AppBar centerTitle | ⚠️ | AppBar en línea 73 sin `centerTitle: true` explícito (puede heredar del tema global, pero no es explícito) |
| Loader adaptive() | ❌ | `CircularProgressIndicator()` sin `.adaptive()` en línea 126 (dentro del botón de refresh); el de línea 143 (`OutlinedButton`) tampoco tiene `.adaptive()` |

**Acciones requeridas:**
- [ ] Cambiar `Colors.orange` (línea 36) por `colorScheme.tertiary` o `colorScheme.error`
- [ ] Cambiar `Colors.green` (línea 52) por `colorScheme.tertiary`
- [ ] Cambiar `CircularProgressIndicator()` (líneas 126, 143) por `CircularProgressIndicator.adaptive()`
- [ ] Agregar `centerTitle: true` explícito en AppBar

---

### [2 problemas] BuyAssetScreen (`lib/features/dashboard/presentation/screens/buy_asset_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | ✅ | Usa `PrimaryButton` correctamente en línea 319 |
| ✦ Sparkle en CTA | ❌ | Sin `Icons.auto_awesome_rounded` en el `PrimaryButton` de confirmación de compra |
| Border radius 14-24 | ✅ | Usa `BorderRadius.circular(12)` — dentro del rango aceptado |
| Sin colores hardcodeados | ✅ | Sin colores hardcodeados — usa `colorScheme.*` |
| Tipografía theme.textTheme | ✅ | Usa `theme.textTheme.*` correctamente |
| Dark theme surface tokens | ✅ | Usa `cs.surfaceContainerLow`, `cs.primaryContainer` — tokens correctos |
| AppBar centerTitle | ⚠️ | AppBar en línea 121 sin `centerTitle: true` explícito |
| Loader adaptive() | ✅ | Usa `CircularProgressIndicator.adaptive()` en línea 175 (búsqueda) |

**Acciones requeridas:**
- [ ] Agregar `Icons.auto_awesome_rounded` en el `PrimaryButton` de "Confirmar compra"
- [ ] Agregar `centerTitle: true` en el AppBar (línea 121)

---

### [3 problemas] SellAssetScreen (`lib/features/dashboard/presentation/screens/sell_asset_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | ✅ | Usa `PrimaryButton` correctamente en línea 541 |
| ✦ Sparkle en CTA | ❌ | Sin `Icons.auto_awesome_rounded` en el `PrimaryButton` de confirmación de venta |
| Border radius 14-24 | ✅ | `BorderRadius.circular(24)` en el sheet (línea 133), `BorderRadius.circular(14)` en tiles (línea 171) — dentro del rango |
| Sin colores hardcodeados | ✅ | Sin colores hardcodeados — usa `colorScheme.*` |
| Tipografía theme.textTheme | ✅ | Usa `theme.textTheme.*` + `TextStyle` solo para chips (línea 457) — aceptable para override de chip |
| Dark theme surface tokens | ✅ | Usa `colors.surfaceContainerLow` — token correcto |
| AppBar centerTitle | ⚠️ | AppBar en línea 30 sin `centerTitle: true` explícito |
| Loader adaptive() | ✅ | Usa `CircularProgressIndicator.adaptive()` en línea 39 |

**Acciones requeridas:**
- [ ] Agregar `Icons.auto_awesome_rounded` en el `PrimaryButton` de "Confirmar venta"
- [ ] Agregar `centerTitle: true` en el AppBar (línea 30)

---

### [7 problemas] TopUpScreen (`lib/features/transactions/presentation/screens/top_up_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | ❌ | Usa `FilledButton` directamente en línea 305 — sin `PrimaryButton` |
| ✦ Sparkle en CTA | ❌ | Sin `Icons.auto_awesome_rounded` en el botón de confirmación |
| Border radius 14-24 | ⚠️ | `BorderRadius.circular(20)` en chips (línea 361) — fuera del rango 14-24 especificado |
| Sin colores hardcodeados | ❌ | `Colors.green` en línea 138 (SnackBar de éxito) y `Colors.grey` en línea 297 (`Icon(Icons.chevron_right, color: Colors.grey)`) — deben usar tokens del tema |
| Tipografía theme.textTheme | ❌ | `TextStyle(fontSize: 16, fontWeight: FontWeight.w600)` hardcodeado en línea 327-328 — debe ser `theme.textTheme.titleMedium` |
| Dark theme surface tokens | ✅ | Usa `colorScheme.surfaceContainerLow` — token correcto |
| AppBar centerTitle | ✅ | AppBar tiene `centerTitle: true` en línea 165 |
| Loader adaptive() | ❌ | `CircularProgressIndicator()` sin `.adaptive()` en línea 319 |

**Acciones requeridas:**
- [ ] Reemplazar `FilledButton` (línea 305) con `PrimaryButton`
- [ ] Agregar `Icons.auto_awesome_rounded` en el CTA de depósito
- [ ] Cambiar `Colors.green` (línea 138) por `colorScheme.tertiary`
- [ ] Cambiar `Colors.grey` (línea 297) por `colorScheme.onSurfaceVariant`
- [ ] Cambiar `TextStyle(fontSize: 16, ...)` (línea 327) por `theme.textTheme.titleMedium?.copyWith(...)`
- [ ] Cambiar `CircularProgressIndicator()` (línea 319) por `CircularProgressIndicator.adaptive()`
- [ ] Evaluar `BorderRadius.circular(20)` en chips → reducir a 16-20 o alinear con constante de tema

---

### [5 problemas] WithdrawBottomSheet (`lib/features/dashboard/presentation/widgets/withdraw_bottom_sheet.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | ❌ | Usa `FilledButton` directamente en línea 216 — sin `PrimaryButton` |
| ✦ Sparkle en CTA | ❌ | Sin `Icons.auto_awesome_rounded` en el botón de confirmación de retiro |
| Border radius 14-24 | ⚠️ | `BorderRadius.circular(20)` en chips (línea 257) — limítrofe; `BorderRadius.circular(24)` en el sheet (línea 97) — OK |
| Sin colores hardcodeados | ✅ | Sin colores hardcodeados — usa `colorScheme.*` |
| Tipografía theme.textTheme | ✅ | Usa `theme.textTheme.*` correctamente |
| Dark theme surface tokens | ✅ | Usa `theme.scaffoldBackgroundColor` — aceptable aunque `colorScheme.surface` sería más correcto |
| AppBar centerTitle | N/A | Es un bottom sheet, sin AppBar |
| Loader adaptive() | ❌ | `CircularProgressIndicator()` sin `.adaptive()` en línea 138 |

**Acciones requeridas:**
- [ ] Reemplazar `FilledButton` (línea 216) con `PrimaryButton`
- [ ] Agregar `Icons.auto_awesome_rounded` en el CTA de retiro
- [ ] Cambiar `CircularProgressIndicator()` (línea 138) por `CircularProgressIndicator.adaptive()`
- [ ] Evaluar cambiar `theme.scaffoldBackgroundColor` (línea 96) por `colorScheme.surface`

---

### [6 problemas] GoalsScreen (`lib/features/goals/presentation/goals_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | N/A | Sin CTA de confirmación de formulario en esta pantalla — usa FAB para crear |
| ✦ Sparkle en CTA | ❌ | FAB `FloatingActionButton.extended` (línea 44) sin `Icons.auto_awesome_rounded` — solo usa `Icons.add` |
| Border radius 14-24 | ✅ | `BorderRadius.circular(20)` en badge de progreso (línea 128), `BorderRadius.circular(4)` en progress bar (línea 147) — aceptables |
| Sin colores hardcodeados | ❌ | `Colors.grey[200]` en línea 144 (`LinearProgressIndicator backgroundColor`) — debe usar `colorScheme.surfaceContainerHighest` o similar; `Colors.grey` en línea 160 (fecha de deadline) — debe ser `colorScheme.onSurfaceVariant` |
| Tipografía theme.textTheme | ❌ | `TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)` en línea 133 — debe usar `theme.textTheme.labelMedium?.copyWith(...)` |
| Dark theme surface tokens | ❌ | `theme.primaryColor.withValues(alpha: 0.1)` en línea 128 — `theme.primaryColor` es legacy, debe usar `colorScheme.primary` |
| AppBar centerTitle | ⚠️ | AppBar en línea 24 sin `centerTitle: true` explícito |
| Loader adaptive() | ✅ | Usa `CircularProgressIndicator.adaptive()` en línea 41 |

**Acciones requeridas:**
- [ ] Cambiar `Colors.grey[200]` (línea 144) por `colorScheme.surfaceContainerHighest`
- [ ] Cambiar `Colors.grey` (línea 160) por `colorScheme.onSurfaceVariant`
- [ ] Cambiar `TextStyle(...)` (línea 133) por `theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)`
- [ ] Cambiar `theme.primaryColor` (línea 128) por `colorScheme.primary`
- [ ] Agregar `centerTitle: true` en AppBar
- [ ] Considerar añadir sparkle o icon diferenciador en el FAB de metas

---

### [2 problemas] PortfolioScreen (`lib/features/portfolio/presentation/portfolio_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | N/A | Sin botones de submit — pantalla de lectura |
| ✦ Sparkle en CTA | N/A | Sin CTAs primarias de acción |
| Border radius 14-24 | ✅ | `BorderRadius.circular(4)` en shimmer — aceptable para placeholders |
| Sin colores hardcodeados | ✅ | Sin colores hardcodeados — usa `colorScheme.*` correctamente |
| Tipografía theme.textTheme | ✅ | Usa `theme.textTheme.*` correctamente |
| Dark theme surface tokens | ✅ | Usa `colorScheme.surfaceContainerHighest` para shimmer — correcto |
| AppBar centerTitle | ⚠️ | AppBar en línea 25 sin `centerTitle: true` explícito |
| Loader adaptive() | ❌ | `_buildLoadingState` en línea 92 usa shimmer (OK), pero no hay indicador de carga explícito con loader — sin problema crítico; sin embargo, si se agrega un loader de fallback debe ser `.adaptive()` |

**Acciones requeridas:**
- [ ] Agregar `centerTitle: true` en el AppBar (línea 25)

---

### [2 problemas] RiskQuestionnaireScreen (`lib/features/risk_profile/presentation/screens/risk_questionnaire_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | ✅ | Usa `PrimaryButton` correctamente en línea 177 |
| ✦ Sparkle en CTA | ❌ | Sin `Icons.auto_awesome_rounded` en el `PrimaryButton` de submit del cuestionario |
| Border radius 14-24 | ✅ | Usa `AppDimens.radius` — consistente con el tema |
| Sin colores hardcodeados | ⚠️ | `Colors.transparent` en línea 228 (border de opción no seleccionada) — funcional pero podría ser más explícito con `colorScheme.outline.withValues(alpha: 0)` |
| Tipografía theme.textTheme | ✅ | Usa `theme.textTheme.*` correctamente |
| Dark theme surface tokens | ✅ | Usa `cs.primaryContainer`, `cs.surfaceContainerLow` — tokens correctos |
| AppBar centerTitle | ✅ | `centerTitle: true` en línea 119 |
| Loader adaptive() | N/A | Sin loader — `isLoading` se pasa a `PrimaryButton` que lo maneja internamente |

**Acciones requeridas:**
- [ ] Agregar `Icons.auto_awesome_rounded` en el `PrimaryButton` de "Enviar cuestionario"

---

### [5 problemas] RiskResultScreen (`lib/features/risk_profile/presentation/screens/risk_result_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | ✅ | Usa `PrimaryButton` correctamente en línea 108 |
| ✦ Sparkle en CTA | ❌ | Sin `Icons.auto_awesome_rounded` en el `PrimaryButton` de "Done" |
| Border radius 14-24 | ✅ | `BorderRadius.circular(20)` en `_ScoreChip` (línea 137) — limítrofe, aceptable |
| Sin colores hardcodeados | ❌ | `Colors.orange` (línea 56), `Colors.green` (línea 63), `Colors.blue` (línea 69) hardcodeados para los perfiles de riesgo — deben derivar del `colorScheme` (ej. `colorScheme.tertiary`, `colorScheme.secondary`, `colorScheme.primary`) |
| Tipografía theme.textTheme | ✅ | Usa `theme.textTheme.*` correctamente |
| Dark theme surface tokens | ✅ | Sin fondos hardcodeados; los colores de icono salen de las variables locales |
| AppBar centerTitle | ✅ | `centerTitle: true` en línea 23 |
| Loader adaptive() | ✅ | Usa `CircularProgressIndicator.adaptive()` en línea 27 |

**Acciones requeridas:**
- [ ] Reemplazar `Colors.orange` (línea 56), `Colors.green` (línea 63), `Colors.blue` (línea 69) con tokens del `colorScheme` o constantes de `AppTheme`
- [ ] Agregar `Icons.auto_awesome_rounded` en el `PrimaryButton` "Done"

---

### [5 problemas] SettingsScreen (`lib/features/settings/presentation/settings_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | N/A | Sin CTA de confirmación — pantalla de navegación |
| ✦ Sparkle en CTA | N/A | Sin CTAs primarias |
| Border radius 14-24 | ✅ | Usa `AppDimens.radius` via `OutlinedButton` — consistente |
| Sin colores hardcodeados | ❌ | `Colors.red` x3: líneas 251 (icono logout), 254 (texto logout), 259 (border del botón) — debe usar `colorScheme.error` |
| Tipografía theme.textTheme | ❌ | `const TextStyle(fontWeight: FontWeight.w500)` en línea 228 (`_buildListTile` title) — sin color theme; `TextStyle(fontSize: 13)` en línea 234 — fontSize hardcodeado |
| Dark theme surface tokens | ✅ | Usa `colorScheme.primary`, `colorScheme.onSurfaceVariant` — correcto |
| AppBar centerTitle | ⚠️ | AppBar en línea 26 sin `centerTitle: true` explícito |
| Loader adaptive() | ✅ | `CircularProgressIndicator.adaptive()` en línea 71 (avatar upload) |

**Acciones requeridas:**
- [ ] Cambiar `Colors.red` (líneas 251, 254, 259) por `colorScheme.error`
- [ ] Cambiar `const TextStyle(fontWeight: FontWeight.w500)` (línea 228) por `theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)`
- [ ] Cambiar `TextStyle(fontSize: 13)` (línea 234) por `theme.textTheme.labelSmall`
- [ ] Agregar `centerTitle: true` en AppBar

---

### [4 problemas] SecurityScreen (`lib/features/settings/presentation/security_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | ✅ | Usa `PrimaryButton` en línea 296 (`_ChangePasswordSheet`) |
| ✦ Sparkle en CTA | ❌ | Sin `Icons.auto_awesome_rounded` en el `PrimaryButton` de cambio de contraseña |
| Border radius 14-24 | ✅ | Usa `AppDimens.radius` — consistente |
| Sin colores hardcodeados | ❌ | `Colors.blue` x2 en líneas 507 y 514 — `focusedBorder` del `_PasswordField` usa `Colors.blue` hardcodeado en lugar de `colorScheme.primary` |
| Tipografía theme.textTheme | ✅ | Usa `theme.textTheme.*` correctamente |
| Dark theme surface tokens | ✅ | Sin fondos hardcodeados |
| AppBar centerTitle | ⚠️ | AppBar en línea 27 sin `centerTitle: true` explícito |
| Loader adaptive() | ✅ | `CircularProgressIndicator.adaptive(strokeWidth: 2)` en línea 452 |

**Acciones requeridas:**
- [ ] Cambiar `Colors.blue` (líneas 507, 514 en `_PasswordField`) por `colorScheme.primary`
- [ ] Agregar `centerTitle: true` en el AppBar (línea 27)
- [ ] Agregar sparkle icon en el `PrimaryButton` de cambio de contraseña

---

### [1 problema] AppearanceScreen (`lib/features/settings/presentation/appearance_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | N/A | Sin CTA de confirmación — pantalla de opciones |
| ✦ Sparkle en CTA | N/A | Sin CTAs primarias |
| Border radius 14-24 | N/A | Sin border radius customizado — usa `Card` del tema |
| Sin colores hardcodeados | ✅ | Sin colores hardcodeados |
| Tipografía theme.textTheme | ✅ | Usa `textTheme.*` correctamente |
| Dark theme surface tokens | ✅ | Sin fondos hardcodeados |
| AppBar centerTitle | ⚠️ | AppBar en línea 31 sin `centerTitle: true` explícito |
| Loader adaptive() | N/A | Sin loader |

**Acciones requeridas:**
- [ ] Agregar `centerTitle: true` en el AppBar (línea 31)

---

### [3 problemas] AboutScreen (`lib/features/settings/presentation/about_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | N/A | Sin CTAs de confirmación |
| ✦ Sparkle en CTA | N/A | Sin CTAs primarias |
| Border radius 14-24 | N/A | Sin border radius customizado |
| Sin colores hardcodeados | ❌ | `Colors.white` en línea 23 — logo circular usa `color: Colors.white` como fondo del `Material` — debe ser `colorScheme.surface` |
| Tipografía theme.textTheme | ✅ | Usa `textTheme.*` correctamente |
| Dark theme surface tokens | ❌ | `Colors.white` (línea 23) como fondo del logo no es compatible con dark mode |
| AppBar centerTitle | ⚠️ | AppBar en línea 14 sin `centerTitle: true` explícito |
| Loader adaptive() | N/A | Sin loader |

**Acciones requeridas:**
- [ ] Cambiar `Colors.white` (línea 23) por `colorScheme.surface` para compatibilidad dark mode
- [ ] Agregar `centerTitle: true` en el AppBar (línea 14)

---

### [1 problema] HelpScreen (`lib/features/settings/presentation/help_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | N/A | Sin CTAs de confirmación |
| ✦ Sparkle en CTA | N/A | Sin CTAs primarias |
| Border radius 14-24 | ✅ | `BorderRadius.circular(12)` en tarjetas FAQ — dentro del rango |
| Sin colores hardcodeados | ✅ | Sin colores hardcodeados |
| Tipografía theme.textTheme | ✅ | Usa `textTheme.*` correctamente |
| Dark theme surface tokens | ✅ | Sin fondos hardcodeados |
| AppBar centerTitle | ⚠️ | AppBar en línea 22 sin `centerTitle: true` explícito |
| Loader adaptive() | N/A | Sin loader |

**Acciones requeridas:**
- [ ] Agregar `centerTitle: true` en el AppBar (línea 22)

---

### [1 problema] NotificationsScreen (`lib/features/settings/presentation/notifications_screen.dart`)

| Check | Estado | Detalle |
|-------|--------|---------|
| PrimaryButton | N/A | Sin CTAs de confirmación — usa `SwitchListTile` |
| ✦ Sparkle en CTA | N/A | Sin CTAs primarias |
| Border radius 14-24 | ✅ | `BorderRadius.circular(12)` en el Card — dentro del rango |
| Sin colores hardcodeados | ✅ | Sin colores hardcodeados |
| Tipografía theme.textTheme | ✅ | Usa `textTheme.*` correctamente |
| Dark theme surface tokens | ✅ | Sin fondos hardcodeados |
| AppBar centerTitle | ⚠️ | AppBar en línea 67 sin `centerTitle: true` explícito |
| Loader adaptive() | ✅ | Usa `CircularProgressIndicator.adaptive()` en línea 69 |

**Acciones requeridas:**
- [ ] Agregar `centerTitle: true` en el AppBar (línea 67)

---

## Resumen de patrones globales

### Problemas transversales (afectan múltiples pantallas)

| Problema | Pantallas afectadas |
|----------|---------------------|
| `CircularProgressIndicator()` sin `.adaptive()` | Login, SignUp, ForgotPassword, VerifyEmail, TopUp, Withdraw |
| `FilledButton` en lugar de `PrimaryButton` | Login, SignUp, ForgotPassword, TopUp, Withdraw |
| Sin `Icons.auto_awesome_rounded` en CTAs | Login, SignUp, ForgotPassword, BuyAsset, SellAsset, TopUp, Withdraw, Goals, RiskQuestionnaire, RiskResult, Security |
| AppBar sin `centerTitle: true` explícito | BuyAsset, SellAsset, Goals, Portfolio, Settings, Security, Appearance, About, Help, Notifications, VerifyEmail |
| Colores `Colors.*` hardcodeados | VerifyEmail, TopUp, Goals, RiskResult, Settings, Security, About |
| `Colors.white` incompatible con dark mode | Login, SignUp, About |
