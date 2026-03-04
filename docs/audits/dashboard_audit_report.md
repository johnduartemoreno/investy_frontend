# Dashboard Code Audit Report
## Reality Check: Real vs. Mock Data Inventory

**Date:** February 9, 2026  
**Auditor:** Senior Code Auditor  
**Project:** Investy  
**Scope:** Dashboard Screen & Action Buttons

---

## Executive Summary

The Dashboard has been significantly upgraded from a UI shell to **mostly real implementation**. However, **3 critical UI elements remain non-functional** (empty handlers). One component (chart/graph) **does not exist at all**.

---

## Detailed Findings

### ✅ **REAL** Components (Properly Implemented)

#### 1. **Total Portfolio Value** - ✅ REAL
**File:** [dashboard_screen.dart:L30-L39](file:///Users/aduarte/investy/lib/features/dashboard/presentation/screens/dashboard_screen.dart#L30-L39)

```dart
final netWorthProvider = Provider.autoDispose<AsyncValue<double>>((ref) {
  final holdingsAsync = ref.watch(holdingsStreamProvider);
  return holdingsAsync.whenData((holdings) {
    return holdings.fold<double>(
      0.0,
      (sum, holding) => sum + (holding.quantity * holding.avgCost),
    );
  });
});
```

**Status:** ✅ **100% REAL**
- **Calculation:** Live calculation from Firestore `holdings` collection
- **Formula:** `Σ(quantity × avgCost)` for all holdings
- **Data Source:** Real-time Firestore stream via [dashboard_repository_impl.dart:L53-L80](file:///Users/aduarte/investy/lib/features/dashboard/data/repositories/dashboard_repository_impl.dart#L53-L80)
- **No hardcoded values**

---

#### 2. **Recent Activity List** - ✅ REAL
**File:** [dashboard_screen.dart:L42-L46](file:///Users/aduarte/investy/lib/features/dashboard/presentation/screens/dashboard_screen.dart#L42-L46)

```dart
final recentActivityStreamProvider =
    StreamProvider.autoDispose<List<Contribution>>((ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.watchContributions();
});
```

**Status:** ✅ **100% REAL**
- **Data Source:** Firestore `contributions` collection (ordered by date descending)
- **Implementation:** Real-time stream from [dashboard_repository_impl.dart:L83-L114](file:///Users/aduarte/investy/lib/features/dashboard/data/repositories/dashboard_repository_impl.dart#L83-L114)
- **No mock items injected**
- **Note:** Displays "Withdrawal" entries created during asset purchases (see lines 204-214 in repository) - this is **intentional** per the cash flow tracking design

---

#### 3. **Buy Button** - ✅ REAL
**File:** [dashboard_screen.dart:L284-L286](file:///Users/aduarte/investy/lib/features/dashboard/presentation/screens/dashboard_screen.dart#L284-L286)

```dart
(
  icon: Icons.trending_up,
  label: 'Buy',
  onTap: () => context.go('/home/buy-asset'),
),
```

**Status:** ✅ **FULLY FUNCTIONAL**
- **Navigation:** Routes to `/home/buy-asset`
- **Backend Logic:** Calls `buyAsset()` method with Firestore transaction (verified in repository)

---

### ❌ **MOCK / NON-FUNCTIONAL** Components

#### 4. **Top-up Button** - ⚠️ PARTIALLY REAL
**File:** [dashboard_screen.dart:L289-L291](file:///Users/aduarte/investy/lib/features/dashboard/presentation/screens/dashboard_screen.dart#L289-L291)

```dart
(
  icon: Icons.add_card,
  label: 'Top-up',
  onTap: () => context.go('/home/top-up'),
),
```

**Status:** ⚠️ **NAVIGATION WIRED, UNKNOWN DESTINATION**
- **Navigation:** Routes to `/home/top-up`
- **Verdict:** Button **does navigate**, but the actual Top-Up screen logic was not audited
- **Repository Support:** ✅ Has `addContribution()` method ready to use

---

#### 5. **Withdraw Button** - ❌ [MOCK]
**File:** [dashboard_screen.dart:L294-L296](file:///Users/aduarte/investy/lib/features/dashboard/presentation/screens/dashboard_screen.dart#L294-L296)

```dart
(
  icon: Icons.file_download_outlined,
  label: 'Withdraw',
  onTap: () {},  // ← EMPTY HANDLER
),
```

**Status:** ❌ **UI SHELL ONLY**
- **Handler:** `onTap: () {}`
- **No navigation, no logic**
- **100% FAKE**

---

#### 6. **More Button** - ❌ [MOCK]
**File:** [dashboard_screen.dart:L299-L301](file:///Users/aduarte/investy/lib/features/dashboard/presentation/screens/dashboard_screen.dart#L299-L301)

```dart
(
  icon: Icons.grid_view,
  label: 'More',
  onTap: () {},  // ← EMPTY HANDLER
),
```

**Status:** ❌ **UI SHELL ONLY**
- **Handler:** `onTap: () {}`
- **No navigation, no logic**
- **100% FAKE**

---

#### 7. **Portfolio Chart/Graph** - ❌ [DOES NOT EXIST]
**Status:** ❌ **COMPONENT NOT FOUND**
- **Search Results:** No chart/graph component exists in the dashboard
- **No static data, no real data** - the component was never implemented
- **100% FAKE (doesn't exist)**

---

#### 8. **Notification Button (Header)** - ❌ [MOCK]
**File:** [dashboard_screen.dart:L205-L208](file:///Users/aduarte/investy/lib/features/dashboard/presentation/screens/dashboard_screen.dart#L205-L208)

```dart
IconButton.filledTonal(
  onPressed: () {},  // ← EMPTY HANDLER
  icon: const Icon(Icons.notifications_outlined),
),
```

**Status:** ❌ **UI SHELL ONLY**
- **Handler:** `onPressed: () {}`
- **100% FAKE**

---

#### 9. **"See All" Button (Recent Activity)** - ❌ [MOCK]
**File:** [dashboard_screen.dart:L348-L350](file:///Users/aduarte/investy/lib/features/dashboard/presentation/screens/dashboard_screen.dart#L348-L350)

```dart
TextButton(
  onPressed: () {},  // ← EMPTY HANDLER
  child: const Text('See All'),
),
```

**Status:** ❌ **UI SHELL ONLY**
- **Handler:** `onPressed: () {}`
- **100% FAKE**

---

#### 10. **Transaction Item Tap** - ❌ [MOCK]
**File:** [dashboard_screen.dart:L426](file:///Users/aduarte/investy/lib/features/dashboard/presentation/screens/dashboard_screen.dart#L426)

```dart
onTap: () {},  // ← Each transaction card does nothing when tapped
```

**Status:** ❌ **UI SHELL ONLY**
- **Handler:** `onTap: () {}`
- **100% FAKE**

---

## Summary Table

| Component | Status | Data Source | Notes |
|-----------|--------|-------------|-------|
| **Total Portfolio Value** | ✅ REAL | Firestore `holdings` (live calc) | Fully functional |
| **Recent Activity List** | ✅ REAL | Firestore `contributions` (stream) | No mock items |
| **Buy Button** | ✅ REAL | Navigation + Firestore transaction | Fully wired |
| **Top-up Button** | ⚠️ PARTIAL | Navigation (destination unknown) | Routes to `/home/top-up` |
| **Withdraw Button** | ❌ [MOCK] | None | Empty `onTap: () {}` |
| **More Button** | ❌ [MOCK] | None | Empty `onTap: () {}` |
| **Portfolio Chart/Graph** | ❌ [MOCK] | N/A - Does not exist | Never implemented |
| **Notification Button** | ❌ [MOCK] | None | Empty `onPressed: () {}` |
| **"See All" Button** | ❌ [MOCK] | None | Empty `onPressed: () {}` |
| **Transaction Tap** | ❌ [MOCK] | None | Empty `onTap: () {}` |

---

## Risk Assessment

### 🟢 Low Risk (Functional)
- Total Portfolio Value calculation
- Recent Activity list rendering
- Buy button workflow

### 🟡 Medium Risk (Unclear Status)
- Top-up button (navigates but destination not verified)

### 🔴 High Risk (User-Facing Fakes)
- **Withdraw button** - Users might expect this to work
- **More button** - Could be confusing if tapped
- **Portfolio Chart** - Missing entirely (might be expected)
- **Notification button** - Visible but non-functional
- **"See All" button** - Suggests more content that doesn't exist
- **Transaction tap** - Users might expect detail views

---

## Recommendations

1. **Immediate Action Required:**
   - Implement or remove the **Withdraw** button
   - Implement or remove the **More** button
   - Add visual indicators (e.g., "Coming Soon") for non-functional buttons

2. **High Priority:**
   - Implement the **Portfolio Chart** or remove the placeholder space
   - Wire up the **"See All"** button to a full activity history view

3. **Low Priority:**
   - Add detail views for tapping transactions
   - Implement notifications system or hide the bell icon

---

## Code Quality Notes

✅ **Strengths:**
- Clean separation of concerns (providers, repository, UI)
- Proper use of async streams
- Error handling in place
- Real-time Firestore integration

⚠️ **Concerns:**
- Multiple empty handlers create "clickable but broken" user experience
- No visual differentiation between functional/non-functional buttons

---

**End of Audit Report**
