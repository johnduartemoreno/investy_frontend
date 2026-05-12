# Design Audit — Investy S15.5

> Screenshots: 2026-05-09 · 21 screens × 2 modes = 42 screenshots
> Auditor: Claude (visual comparison, no code touched)

---

## 1. Dark mode vs Light mode — inconsistencias (no-color)

| Pantalla | Diferencia estructural |
|----------|------------------------|
| **02 Owl AI** | Badge "Strong buy": light = outlined borde verde, dark = filled verde sólido con texto blanco — estilos distintos del mismo componente |
| **04 Buy Asset** | Warning banner: light = rosa/pink, dark = verde — color semántico opuesto (no es adaptación de modo, es error de color) |
| **05 Sell Asset** | Mismo problema que 04 — warning banner rosa (light) vs verde (dark) |
| **05b Sell Bottomsheet** | Chips 25%/50%/MAX: light = outlined border, dark = filled dark card — estilos de componente distintos |
| **08 Goals** | Progress bar track: light = gris claro (vacío), dark = blanco sólido full-width (parece 100% lleno) — bug visual severo |
| **08 Goals** | Badge "0.0%": light = pill lavender legible, dark = texto bajo contraste sobre fondo oscuro |
| **09 New Goal** | Date chips (6M/1Y/2Y/3Y/5Y): light = texto plano sin fondo visible, dark = chips dark rellenas redondeadas |
| **10 Portfolio** | Color de returns: light = positivos en rosa/rojo, dark = positivos en verde — semántica invertida |
| **11/13 Settings** | Iconos de lista: light = púrpura vibrante (alto contraste), dark = casi invisibles por bajo contraste sobre fondo oscuro |
| **13 Settings banner** | Banner "Brokerage not set up": light = fondo gris oscuro con texto blanco, dark = fondo blanco con texto oscuro — invertido e incorrecto en ambos modos |
| **15 Notifications** | Texto de bullets: dark mode tiene el texto pegado al borde izquierdo sin padding — layout clipping |

---

## 2. Problemas críticos por pantalla

| Pantalla | Archivo | Problema | Prioridad |
|----------|---------|----------|-----------|
| Goals | `08_goals` | Progress bar track es BLANCO en dark → parece lleno al 100% cuando está en 0% | 🔴 P0 |
| Settings banner | `13_settings_banner` | Banner con color hardcodeado: gris oscuro en light, blanco en dark — ambos incorrectos para sus modos | 🔴 P0 |
| Portfolio | `10_portfolio` | Returns positivos en color rosa/rojo en light mode — debería ser verde en ambos modos | 🔴 P0 |
| Buy Asset | `04_buy_asset` | Warning banner: rosa en light, verde en dark — mismo banner, semantics opuestas | 🔴 P1 |
| Sell Asset | `05_sell_asset` | Mismo warning banner inconsistente (rosa vs verde) | 🔴 P1 |
| Notifications | `15_notifications` | Texto de bullets sin left padding en dark mode — cortado al borde | 🔴 P1 |
| Buy Asset | `04_buy_asset` | "Confirm Purchase" siempre gris — no usa `PrimaryButton`, sin ✦ sparkle | 🟠 P2 |
| Sell Asset | `05_sell_asset` | "Confirm Sale" siempre gris — no usa `PrimaryButton`, sin ✦ sparkle | 🟠 P2 |
| Top Up | `06_top_up` | "Confirm Deposit" siempre gris — no usa `PrimaryButton`, sin ✦ sparkle | 🟠 P2 |
| Settings | `11_settings` | Iconos de menú casi invisibles en dark mode — color no adapta al tema | 🟠 P2 |
| Sell Bottomsheet | `05b_sell_asset_bottomsheet` | Chips 25%/50%/MAX: outlined en light, filled en dark — componente inconsistente | 🟡 P3 |
| Owl AI | `02_owl_ai` | Badge signal "Strong buy": outlined en light, solid en dark — estilos distintos | 🟡 P3 |
| New Goal | `09_new_goal` | Date chips sin fondo visible en light mode — no comunican que son seleccionables | 🟡 P3 |
| Goals | `08_goals` | Badge "0.0%" bajo contraste en dark mode | 🟡 P3 |
| Home | `01_home` | Username "Johnduartemoreno" todo en minúsculas — debería ser capitalizado | 🟡 P3 |
| Recent Activity | `03_recent_activity` | Íconos de transacción sin tipo diferenciado — todas las transacciones muestran el mismo ícono de flechas | 🟡 P3 |
| Portfolio | `10_portfolio` | Avatar del activo usa letra inicial genérica "A" o "B" para todos — no diferencia el tipo de activo | 🟡 P3 |
| About Investy | `18/19_about_investy` | Ícono del piggy bank en círculo blanco hardcodeado — funciona visualmente pero no usa token de tema | 🟢 P4 |

---

## 3. Inconsistencias globales

### A. Warning/info banner — color semántico incorrecto
- **Afecta:** `04_buy_asset`, `05_sell_asset`, `13_settings_banner`
- Light mode: fondo rosa (#F8D7DA o similar) — color de error/peligro
- Dark mode: fondo verde (#1B5E20 o similar) — color de éxito
- El mismo banner informativo ("Paper trading active") tiene colores semánticos opuestos según el modo. Debería ser un color neutro/warning (amber) en ambos.

### B. CTA principal siempre disabled
- **Afecta:** `04_buy_asset`, `05_sell_asset`, `06_top_up`
- Los botones "Confirm Purchase", "Confirm Sale", "Confirm Deposit" se muestran en gris desactivado al entrar a la pantalla.
- En `07_withdraw` y `09_new_goal` el CTA sí es `PrimaryButton` habilitado — inconsistencia de patrón.
- Ninguno de los 3 disabled buttons tiene ✦ sparkle para cuando se habiliten.

### C. Iconos de settings sin adaptación a dark mode
- **Afecta:** `11_settings`, `13_settings_banner`
- Los íconos del menú de settings (Currency, Identity, Brokerage, etc.) son púrpura en light (alto contraste) pero en dark mode pierden contraste severo al renderizarse sobre fondo oscuro.
- Causa probable: color hardcodeado en lugar de `colorScheme.primary` o `colorScheme.onSurface`.

### D. Chips de selección rápida — estilo inconsistente
- **Afecta:** `05b_sell_asset_bottomsheet`, `06_top_up`, `07_withdraw`, `09_new_goal`
- En algunos contextos los chips son outlined, en otros filled. En `07_withdraw` (light) los chips de 25%/50%/MAX son outlined correctamente. En `05b` (dark) son filled cards.
- El estilo correcto del CLAUDE.md: `outlined borderRadius: 20, label bold + colorScheme.primary`.

### E. Ausencia de ✦ sparkle en CTAs de transacción
- **Afecta:** `04_buy_asset`, `05_sell_asset`, `06_top_up`
- El botón Owl AI (`02_owl_ai`) sí tiene `✦ Refresh`. El botón de retiro (`07_withdraw`) es `PrimaryButton` plano sin sparkle. Ningún CTA de transacción tiene el ✦.
- Solo `02_owl_ai` lo implementa consistentemente.

### F. Color semántico de returns en Portfolio
- **Afecta:** `10_portfolio`
- Light mode: `+20.82%` aparece en rosa/rojo — mismo color que negativo.
- Dark mode: `+20.82%` aparece en verde — correcto.
- Causa probable: hardcoded color en lugar de condicional `value >= 0 ? Colors.green : Colors.red` usando tokens de tema.

---

## 4. Plan S15.5 — Orden de implementación

### Fase 1 — Quick wins (< 30 min c/u, sin riesgo de regresión)

| # | Fix | Archivo estimado | Tiempo |
|---|-----|-----------------|--------|
| F1.1 | Notifications: agregar leftPadding al texto de bullets en dark mode | `notifications_screen.dart` | 10 min |
| F1.2 | Portfolio: fix color semántico de returns (`>= 0 → green, < 0 → red`) | `portfolio_screen.dart` | 15 min |
| F1.3 | Home: capitalizar username display ("Johnduartemoreno" → "johnduartemoreno" con `.capitalize()` o `toUpperCase` del primer char) | `dashboard_screen.dart` | 10 min |
| F1.4 | Goals badge "0.0%": usar `colorScheme.onSurfaceVariant` para contraste en ambos modos | `goals_screen.dart` | 10 min |
| F1.5 | About Investy: cambiar piggy icon container a `colorScheme.surface` en vez de `Colors.white` hardcoded | `about_screen.dart` | 10 min |

### Fase 2 — Componentes (tocan widgets compartidos o shared state)

| # | Fix | Archivo estimado | Tiempo |
|---|-----|-----------------|--------|
| F2.1 | Warning banner: crear `InfoBanner` widget con color `colorScheme.tertiaryContainer` (amber/neutral) — aplicar en Buy, Sell, Settings | `core/widgets/info_banner.dart` + 3 screens | 45 min |
| F2.2 | Settings icons: cambiar a `color: colorScheme.primary` o `Theme.of(context).colorScheme.onSurface` en dark mode | `settings_screen.dart` | 20 min |
| F2.3 | Quick-select chips: estandarizar a outlined style en todos los bottomsheets (Sell, Withdraw, New Goal) | `sell_asset_screen.dart`, `withdraw_screen.dart`, `new_goal_screen.dart` | 30 min |
| F2.4 | Owl AI badge signal: estandarizar `SignalBadge` a un solo estilo (outlined con borde de color + texto de color) en ambos modos | `dashboard_screen.dart` o widget propio | 20 min |
| F2.5 | Date chips en New Goal: agregar `backgroundColor: colorScheme.surfaceContainerHighest` para que sean visibles en light mode | `new_goal_screen.dart` | 15 min |

### Fase 3 — Estructurales (layouts que cambian significativamente)

| # | Fix | Archivo estimado | Tiempo |
|---|-----|-----------------|--------|
| F3.1 | Goals progress bar: cambiar `backgroundColor` del `LinearProgressIndicator` a `colorScheme.surfaceContainerHighest` — fix del P0 más visible | `goals_screen.dart` | 20 min |
| F3.2 | Settings banner (13): reemplazar color hardcodeado por `colorScheme.errorContainer` o `colorScheme.tertiaryContainer` con texto `onErrorContainer` | `settings_screen.dart` | 25 min |
| F3.3 | Buy/Sell/TopUp CTAs: convertir a `PrimaryButton` activo cuando hay input válido; disabled solo si no hay asset/amount seleccionado — implica wiring con form state | `buy_asset_screen.dart`, `sell_asset_screen.dart`, `top_up_screen.dart` | 60 min |
| F3.4 | ✦ Sparkle: agregar ✦ prefix a CTAs de Buy, Sell, TopUp, Withdraw usando el mismo patrón que `✦ Refresh` en Owl AI | Los 4 screens | 20 min |

---

## 5. Checklist por pantalla

### 01 Home / Dashboard
- [x] AppBar: no tiene AppBar clásico — greeting custom ✅
- [ ] ✦ sparkle en CTA principal — N/A (acciones son los 4 botones redondos)
- [x] Sin colores hardcodeados — OK visual
- [x] CircularProgressIndicator.adaptive() — N/A
- [x] Dark mode consistente con light mode — ✅
- [ ] Username capitalizado — ❌ "Johnduartemoreno" todo minúsculas

### 02 Owl AI Sheet
- [x] ✦ sparkle en CTA "Refresh" — ✅
- [x] AppBar: no aplica (bottom sheet)
- [ ] Sin colores hardcodeados — ❌ badge "Strong buy" inconsistente entre modos
- [x] PrimaryButton — "BUY →" usa filled button ✅
- [ ] Dark mode consistente — ❌ badge style distinto (outlined vs filled)
- [x] Estado disabled — N/A

### 03 Recent Activity
- [x] AppBar: no aplica (scroll dentro de home)
- [ ] ✦ sparkle — N/A
- [x] Sin colores hardcodeados — OK
- [x] Dark mode consistente — ✅
- [ ] Tipo de transacción diferenciado — ❌ mismo ícono para todas

### 04 Buy Asset
- [x] AppBar centerTitle: true — ✅ "Buy Asset" centrado
- [ ] ✦ sparkle en CTA — ❌ "Confirm Purchase" sin sparkle
- [ ] Sin colores hardcodeados — ❌ warning banner color inconsistente entre modos
- [ ] PrimaryButton — ❌ botón es gris genérico disabled
- [x] CircularProgressIndicator.adaptive() — N/A
- [ ] Dark mode consistente — ❌ warning banner rosa vs verde
- [ ] Estado disabled visible — ❌ parece igual que enabled, no hay feedback claro

### 05 Sell Asset
- [x] AppBar centerTitle: true — ✅ "Sell Asset" centrado
- [ ] ✦ sparkle en CTA — ❌ (botón en bottomsheet)
- [ ] Sin colores hardcodeados — ❌ warning banner inconsistente
- [ ] PrimaryButton — ❌ "Confirm Sale" gris disabled
- [ ] Dark mode consistente — ❌ warning banner rosa vs verde
- [ ] Estado disabled visible — ❌

### 05b Sell Bottomsheet
- [x] AppBar: no aplica
- [ ] ✦ sparkle — ❌ "Confirm Sale" sin sparkle
- [ ] Sin colores hardcodeados — posible (chips inconsistentes)
- [ ] PrimaryButton — ❌ gris disabled
- [ ] Dark mode consistente — ❌ chips outlined vs filled
- [ ] Estado disabled — ❌ no hay feedback de por qué está disabled

### 06 Top Up
- [x] AppBar centerTitle: true — ✅ "Top Up" centrado
- [ ] ✦ sparkle — ❌ "Confirm Deposit" sin sparkle
- [x] Sin colores hardcodeados — OK
- [ ] PrimaryButton — ❌ gris disabled
- [x] Dark mode consistente — ✅ layout igual
- [ ] Estado disabled — ❌

### 07 Withdraw (Bottom Sheet)
- [x] AppBar: no aplica
- [ ] ✦ sparkle — ❌ "Confirm Withdrawal" sin sparkle
- [x] Sin colores hardcodeados — OK
- [x] PrimaryButton — ✅ botón es purple filled (único CTA habilitado)
- [x] Dark mode consistente — ✅
- [x] Estado enabled visible — ✅

### 08 Goals
- [x] AppBar centerTitle: true — ✅ "Goals" centrado
- [x] ✦ sparkle — N/A (FAB "Add Goal")
- [ ] Sin colores hardcodeados — ❌ progress bar track blanco hardcodeado
- [x] PrimaryButton — N/A
- [ ] Dark mode consistente — ❌ progress bar P0, badge contraste
- [ ] Estado — ❌ progress 0% parece 100% en dark mode

### 09 New Goal (Bottom Sheet)
- [x] AppBar: no aplica
- [ ] ✦ sparkle — ❌ "Create Goal" sin sparkle
- [ ] Sin colores hardcodeados — ❌ date chips sin bg en light
- [x] PrimaryButton — ✅ "Create Goal" es purple filled
- [ ] Dark mode consistente — ❌ date chips sin fondo en light, filled en dark
- [x] Estado enabled — ✅

### 10 Portfolio
- [x] AppBar centerTitle: true — ✅ "Portfolio" centrado
- [ ] ✦ sparkle — N/A
- [ ] Sin colores hardcodeados — ❌ return positivo en rosa (light) vs verde (dark)
- [x] PrimaryButton — N/A
- [ ] Dark mode consistente — ❌ color semántico de returns invertido
- [x] Layout — ✅

### 11 Settings
- [x] AppBar centerTitle: true — ✅ "Settings" centrado
- [ ] ✦ sparkle — N/A
- [ ] Sin colores hardcodeados — ❌ iconos no adaptan a dark mode
- [x] PrimaryButton — N/A
- [ ] Dark mode consistente — ❌ iconos bajo contraste en dark
- [x] Layout — ✅

### 12 Identity Verification
- [x] AppBar centerTitle: true — ✅
- [ ] ✦ sparkle — N/A (pantalla informativa)
- [x] Sin colores hardcodeados — ✅
- [x] PrimaryButton — N/A
- [x] Dark mode consistente — ✅
- [x] Layout — ✅

### 13 Settings Banner
- [x] AppBar centerTitle: true — ✅
- [ ] ✦ sparkle — N/A
- [ ] Sin colores hardcodeados — ❌ banner color completamente hardcodeado (P0)
- [x] PrimaryButton — N/A
- [ ] Dark mode consistente — ❌ banner invertido: oscuro en light, claro en dark
- [ ] Iconos dark mode — ❌ mismo problema que 11

### 14 Risk Profile
- [x] AppBar centerTitle: true — ✅ "Risk Profile" centrado
- [ ] ✦ sparkle — ❌ no hay "Next" button visible (sin selección)
- [x] Sin colores hardcodeados — ✅
- [ ] PrimaryButton — no visible en screenshot
- [x] Dark mode consistente — ✅
- [x] Layout — ✅

### 15 Notifications
- [x] AppBar centerTitle: true — ✅
- [ ] ✦ sparkle — N/A
- [x] Sin colores hardcodeados — ✅
- [x] PrimaryButton — N/A (toggle switch)
- [ ] Dark mode consistente — ❌ texto bullets sin left padding en dark
- [ ] Layout — ❌ clipping en dark mode

### 16 Privacy & Security
- [x] AppBar centerTitle: true — ✅
- [ ] ✦ sparkle — N/A
- [x] Sin colores hardcodeados — ✅ (rojo de "Delete" es semántico correcto)
- [x] PrimaryButton — N/A
- [x] Dark mode consistente — ✅
- [x] Layout — ✅

### 17 Appearance
- [x] AppBar centerTitle: true — ✅
- [ ] ✦ sparkle — N/A
- [x] Sin colores hardcodeados — ✅
- [x] PrimaryButton — N/A
- [x] Dark mode consistente — ✅
- [x] Layout — ✅

### 18 + 19 About Investy
- [x] AppBar centerTitle: true — ✅
- [ ] ✦ sparkle — N/A
- [ ] Sin colores hardcodeados — ❌ círculo del piggy bank es `Colors.white` hardcoded
- [x] PrimaryButton — N/A
- [x] Dark mode consistente — ✅ (el blanco hardcoded funciona visualmente en ambos)
- [x] Layout — ✅

### 20 Help & Support
- [x] AppBar centerTitle: true — ✅ "Help & Support" centrado
- [ ] ✦ sparkle — N/A
- [x] Sin colores hardcodeados — ✅
- [x] PrimaryButton — N/A
- [x] Dark mode consistente — ✅
- [x] Layout — ✅

---

## Resumen ejecutivo

| Categoría | Count |
|-----------|-------|
| 🔴 P0 — Blocker visual (bug severo) | 3 |
| 🔴 P1 — Crítico (inconsistencia funcional) | 3 |
| 🟠 P2 — Alto (afecta UX de transacciones) | 4 |
| 🟡 P3 — Medio (inconsistencia visual) | 6 |
| 🟢 P4 — Bajo (polish) | 1 |
| **Total issues** | **17** |

**Pantallas sin issues:** 12, 16, 17, 20 (4 de 21)
**Pantallas con P0:** 08 (goals progress bar), 10 (portfolio return color), 13 (settings banner)
