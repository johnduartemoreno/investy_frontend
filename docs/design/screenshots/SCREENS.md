# Investy — Screen Registry

> **Agent rule:** Before marking any UI task done, look up the modified `.dart` file(s) in the **Source file** column below.  
> If a matching row exists → stop and ask the user:  
> *"¿Actualizamos el screenshot de [Screen name]? (`light_mode/XX.png` + `dark_mode/XX.png`)"*  
> Do NOT commit the screenshot yourself — wait for the user to provide new images.

---

## Auth

| ID | Screen | Route | Source file(s) | Light | Dark |
|----|--------|-------|----------------|-------|------|
| 00 | Login | `/login` | `auth/presentation/login_screen.dart` | `light_mode/00_login.png` | `dark_mode/00_login.png` |
| 00b | Reset Password | `/login` → forgot link | `auth/presentation/forgot_password_screen.dart` | `light_mode/00b_reset_password.png` | `dark_mode/00b_reset_password.png` |
| 00c | Google OAuth iOS dialog | (iOS system dialog shown on login) | `auth/presentation/login_screen.dart` | — | `dark_mode/00c_google_oauth_ios.png` |
| — | Sign Up | `/signup` | `auth/presentation/signup_screen.dart` | — | — |
| — | Verify Email | `/verify-email` | `auth/presentation/verify_email_screen.dart` | — | — |

---

## Dashboard (Home)

| ID | Screen | Route | Source file(s) | Light | Dark |
|----|--------|-------|----------------|-------|------|
| 01 | Home / Dashboard | `/home` | `dashboard/presentation/screens/dashboard_screen.dart` | `light_mode/01_home.png` | `dark_mode/01_home.png` |
| 02 | Owl AI Sheet | `/home` → Owl AI button | `dashboard/presentation/screens/dashboard_screen.dart` (`_OwlAdvisorSheet`) | `light_mode/02_owl_ai.png` | `dark_mode/02_owl_ai.png` |
| 02b | Owl History (list) | `/home/owl-history` | `dashboard/presentation/screens/owl_history_screen.dart` | `light_mode/02b_owl_history.png` | `dark_mode/02b_owl_history.png` |
| 02c | Owl History detail (sheet) | `/home/owl-history` → tap session | `dashboard/presentation/screens/owl_history_screen.dart` (`_OwlHistoryDetailSheet`) | `light_mode/02c_owl_history_detail.png` | `dark_mode/02c_owl_history_detail.png` |
| 03 | Recent Activity | `/home/activity` | `dashboard/presentation/screens/dashboard_screen.dart` (activity list) | `light_mode/03_recent_activity.png` | `dark_mode/03_recent_activity.png` |
| 04 | Buy Asset | `/home/buy-asset` | `dashboard/presentation/screens/buy_asset_screen.dart` | `light_mode/04_buy_asset.png` | `dark_mode/04_buy_asset.png` |
| 05 | Sell Asset (list) | `/home/sell-asset` | `dashboard/presentation/screens/sell_asset_screen.dart` | `light_mode/05_sell_asset.png` | `dark_mode/05_sell_asset.png` |
| 05b | Sell Asset (bottom sheet) | `/home/sell-asset` → tap holding | `dashboard/presentation/screens/sell_asset_screen.dart` (`_SellSheet`) | `light_mode/05b_sell_asset_bottomsheet.png` | `dark_mode/05b_sell_asset_bottomsheet.png` |
| 06 | Top Up / Deposit | `/home/top-up` | `transactions/presentation/screens/top_up_screen.dart` | `light_mode/06_top_up.png` | `dark_mode/06_top_up.png` |
| 07 | Withdraw (bottom sheet) | `/home` → Retirar | `dashboard/presentation/widgets/withdraw_bottom_sheet.dart` | `light_mode/07_withdraw.png` | `dark_mode/07_withdraw.png` |

---

## Goals / Metas

| ID | Screen | Route | Source file(s) | Light | Dark |
|----|--------|-------|----------------|-------|------|
| 08 | Goals list | `/goals` | `goals/presentation/goals_screen.dart` | `light_mode/08_goals.png` | `dark_mode/08_goals.png` |
| 09 | New Goal (sheet) | `/goals` → + button | `goals/presentation/widgets/create_goal_sheet.dart` | `light_mode/09_new_goal.png` | `dark_mode/09_new_goal.png` |
| 08b | Goal Detail | `/goals/:goalId` | `goals/presentation/goal_detail_screen.dart` | `light_mode/08b_goal_detail.png` | `dark_mode/08b_goal_detail.png` |
| 08c | Goals — empty state (first use) | `/goals` with no goals | `goals/presentation/goals_screen.dart` | `light_mode/08c_goals_empty.png` | `dark_mode/08c_goals_empty.png` |

---

## Portfolio

| ID | Screen | Route | Source file(s) | Light | Dark |
|----|--------|-------|----------------|-------|------|
| 10 | Portfolio | `/portfolio` | `portfolio/presentation/portfolio_screen.dart` | `light_mode/10_portfolio.png` | `dark_mode/10_portfolio.png` |
| 10c | Portfolio — empty state (first use) | `/portfolio` with no holdings | `portfolio/presentation/portfolio_screen.dart` | `light_mode/10c_portfolio_empty.png` | `dark_mode/10c_portfolio_empty.png` |

---

## Settings / Ajustes

| ID | Screen | Route | Source file(s) | Light | Dark |
|----|--------|-------|----------------|-------|------|
| 11 | Settings main | `/settings` | `settings/presentation/settings_screen.dart` | `light_mode/11_settings.png` | `dark_mode/11_settings.png` |
| 12 | Identity Verification (KYC) | `/settings/kyc` | `kyc/presentation/screens/kyc_screen.dart` | `light_mode/12_identity_verification.png` | `dark_mode/12_identity_verification.png` |
| 12b | Identity Verification — Recoverable rejection (`retry`) | `/settings/kyc` | `kyc/presentation/screens/kyc_screen.dart` | `light_mode/12b_identity_verification_retry.png` | `dark_mode/12b_identity_verification_retry.png` |
| 12c | Identity Verification — Final rejection | `/settings/kyc` | `kyc/presentation/screens/kyc_screen.dart` | `light_mode/12c_identity_verification_rejected.png` | `dark_mode/12c_identity_verification_rejected.png` |
| 13 | Settings + broker banner | `/settings` (with SnackBar) | `settings/presentation/settings_screen.dart` | `light_mode/13_settings_banner.png` | `dark_mode/13_settings_banner.png` |
| 14 | Risk Profile questionnaire | `/settings/risk-profile` | `risk_profile/presentation/screens/risk_questionnaire_screen.dart` | `light_mode/14_risk_profile.png` | `dark_mode/14_risk_profile.png` |
| 15 | Notifications | `/settings/notifications` | `settings/presentation/notifications_screen.dart` | `light_mode/15_notifications.png` | `dark_mode/15_notifications.png` |
| 16 | Privacy & Security | `/settings/security` | `settings/presentation/security_screen.dart` | `light_mode/16_privacy_security.png` | `dark_mode/16_privacy_security.png` |
| 16b | Change Password (sheet) | `/settings/security` → Cambiar | `settings/presentation/security_screen.dart` | `light_mode/16b_delete_account_dialog.png`¹ | `dark_mode/16b_change_password_sheet.png` |
| 16c | Delete Account (dialog) | `/settings/security` → Eliminar | `settings/presentation/security_screen.dart` | — | `dark_mode/16c_delete_account_dialog.png` |
| 17 | Appearance | `/settings/appearance` | `settings/presentation/appearance_screen.dart` | `light_mode/17_appearance.png` | `dark_mode/17_appearance.png` |
| 18 | About Investy | `/settings/about` | `settings/presentation/about_screen.dart` | `light_mode/18_about_investy.png` | `dark_mode/18_about_investy.png` |
| 20 | Help & Support | `/settings/help` | `settings/presentation/help_screen.dart` | `light_mode/20_help_support.png` | `dark_mode/20_help_support.png` |

---

¹ *El archivo `light_mode/16b_delete_account_dialog.png` contiene el dialog de confirmación, no el sheet de cambiar contraseña — pendiente alinear nombre en próximo sprint.*

---

## Screens without screenshots yet

| Screen | Route | Source file |
|--------|-------|-------------|
| Sign Up | `/signup` | `auth/presentation/signup_screen.dart` |
| Verify Email | `/verify-email` | `auth/presentation/verify_email_screen.dart` |
| Risk Result | `/settings/risk-profile` (result) | `risk_profile/presentation/screens/risk_result_screen.dart` |
