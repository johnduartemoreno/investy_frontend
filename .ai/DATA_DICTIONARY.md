# Investy - Data Dictionary & Governance Rules

## 🛑 STRICT AI DIRECTIVE
ANY code generated for this project MUST strictly adhere to this Data Dictionary. Do not invent new fields, change casing, or write raw JSON maps to Firestore.

## 1. Global Data Governance Rules
* **Database Casing:** Firestore strictly uses `snake_case` for ALL collections, documents, and fields.
* **App Memory Casing:** Dart code strictly uses `camelCase` for all variables and properties.
* **Translation Layer:** ALL database reads/writes must pass through the entity's `.fromJson()` and `.toJson()` methods (using `freezed` and `@JsonKey` to handle the translation).
* **Audit Fields:** All entities must use `created_at` (immutable creation time) and `updated_at` (mutation time). Never use `date` or `timestamp`.
* **No Raw Maps:** Repositories are strictly forbidden from writing raw maps (`{'field': value}`) to Firestore. Only use `.toJson()` or `.copyWith().toJson()`.

## 2. Firestore Schema

### Collection: `users/{uid}`
* `uid` (String)
* `email` (String)
* `display_name` (String)
* `base_currency` (String)
* `country` (String)
* `timezone` (String)
* `preferred_language` (String)
* `track_mode` (String)
* `onboarding_completed` (Boolean)
* `created_at` (Timestamp)
* `updated_at` (Timestamp)

### Sub-collection: `users/{uid}/wallet` (Document: `main`)
* `available_cash`: `int` (Cents, e.g., 1050 = $10.50)
* `updated_at` (Timestamp)

### Sub-collection: `users/{uid}/contributions` (Immutable Ledger)
* `id` (String)
* `amount`: `int` (Cents)
* `type` (String: 'deposit' | 'withdrawal')
* `description` (String)
* `transaction_id` (String, Optional)
* `running_balance`: `int` (Cents)
* `created_at` (Timestamp)

### Sub-collection: `users/{uid}/holdings` (Live Portfolio)
* `id` (String: Ticker Symbol, e.g., 'AAPL')
* `symbol` (String)
* `asset_class` (String: e.g., 'Equity', 'Crypto')
* `quantity`: `int` (Precision 10^8)
* `avg_cost`: `int` (Precision 10^8)
* `updated_at` (Timestamp)

### Sub-collection: `users/{uid}/transactions` (Immutable Receipts)
* `id` (String)
* `symbol` (String)
* `type` (String: 'buy' | 'sell')
* `quantity`: `int` (Precision 10^8)
* `price`: `int` (Precision 10^8)
* `total_before_fees` (Number: double)
* `created_at` (Timestamp)

### Global Collection: `assets` (Market Data)
* `id` (String: Ticker Symbol, e.g., 'AAPL')
* `symbol` (String)
* `name` (String)
* `current_price`: `int` (Precision 10^8)
* `logo_url` (String, Optional)
