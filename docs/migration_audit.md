# Migration Audit Report

## Overview
This document outlines the analysis of providers in the `lib/features/dashboard` directory, identifying which ones are still using `StreamProvider` to Firestore versus `FutureProvider` to the Go Backend. It also lists any duplicated logic between the two.

## Providers Using `StreamProvider` to Firestore
1. **userProfileStreamProvider**
   - Fetches user profile data from Firestore.
   - Logic:
     ```dart
     final userProfileStreamProvider =
         StreamProvider.autoDispose<UserProfile>((ref) {
       final repository = ref.watch(dashboardRepositoryProvider);
       return repository.watchUserProfile();
     });
     ```

2. **holdingsStreamProvider**
   - Fetches holdings data from Firestore.
   - Logic:
     ```dart
     final holdingsStreamProvider = StreamProvider.autoDispose<List<Holding>>((ref) {
       final repository = ref.watch(dashboardRepositoryProvider);
       return repository.watchHoldings();
     });
     ```

3. **recentActivityStreamProvider**
   - Fetches recent activity data from Firestore.
   - Logic:
     ```dart
     final recentActivityStreamProvider =
         StreamProvider.autoDispose<List<ActivityItem>>((ref) {
       final repository = ref.watch(dashboardRepositoryProvider);

       return Rx.combineLatest2<List<Transaction>, List<Contribution>,
           List<ActivityItem>>(
         repository.watchTransactions(),
         repository.watchContributions(),
         (transactions, contributions) {
           final standaloneContributions =
               contributions.where((c) => c.transactionId == null).toList();
           final items = <ActivityItem>[
             ...transactions.map(ActivityItemTransaction.new),
             ...standaloneContributions.map(ActivityItemContribution.new),
           ];
           items.sort((a, b) => b.date.compareTo(a.date));
           return items;
         },
       );
     });
     ```

## Providers Using `FutureProvider` to Go Backend
1. **restDashboardProvider**
   - Fetches the full dashboard payload from the Go REST backend.
   - Logic:
     ```dart
     final restDashboardProvider =
         FutureProvider.autoDispose<DashboardResponseModel>((ref) async {
       final userId = FirebaseAuth.instance.currentUser?.uid;
       if (userId == null) throw Exception('User not authenticated');
       return ref.watch(dashboardRemoteDataSourceProvider).getDashboard(userId);
     });
     ```

2. **restAvailableCashProvider**
   - Fetches available cash from the Go REST backend.
   - Logic:
     ```dart
     final restAvailableCashProvider =
         Provider.autoDispose<AsyncValue<double>>((ref) {
       return ref
           .watch(restDashboardProvider)
           .whenData((dash) => dash.toDomainWallet().availableCash);
     });
     ```

3. **restInvestedValueProvider**
   - Fetches invested portfolio value from the Go REST backend.
   - Logic:
     ```dart
     final restInvestedValueProvider =
         Provider.autoDispose<AsyncValue<double>>((ref) {
       return ref
           .watch(restDashboardProvider)
           .whenData((dash) => dash.investedValue / 100.0);
     });
     ```

4. **restRecentActivityProvider**
   - Fetches recent activity from the Go REST backend.
   - Logic:
     ```dart
     final restRecentActivityProvider =
         Provider.autoDispose<AsyncValue<List<ActivityItem>>>((ref) {
       return ref.watch(restDashboardProvider).whenData(
             (dash) => dash.recentActivity
                 .map((m) => ActivityItemContribution(m.toDomain()))
                 .toList(),
           );
     });
     ```

## Duplicated Logic
1. **Fetching Data from Firestore:**
   - `userProfileStreamProvider`, `holdingsStreamProvider`, and `recentActivityStreamProvider` all fetch data from Firestore.
   - Logic:
     ```dart
     final repository = ref.watch(dashboardRepositoryProvider);
     return repository.watchUserProfile();
     ```

2. **Fetching Data from Go Backend:**
   - `restDashboardProvider`, `restAvailableCashProvider`, `restInvestedValueProvider`, and `restRecentActivityProvider` all fetch data from the Go REST backend.
   - Logic:
     ```dart
     final userId = FirebaseAuth.instance.currentUser?.uid;
     if (userId == null) throw Exception('User not authenticated');
     return ref.watch(dashboardRemoteDataSourceProvider).getDashboard(userId);
     ```

## Inconsistencies Found
1. **Data Source Inconsistency:**
   - Some providers fetch data from Firestore, while others fetch data from the Go Backend.
   - This inconsistency makes it difficult to maintain a Single Source of Truth.

2. **Duplicated Logic:**
   - The logic for fetching data from Firestore and the Go Backend is duplicated across multiple providers.
   - This duplication increases the risk of bugs and makes it harder to maintain the codebase.

## Migration Plan
1. **Identify Common Logic:**
   - Identify common logic between Firestore and Go Backend data fetching.
   - Create a new provider that abstracts the logic for fetching data from either source.

2. **Refactor Providers:**
   - Refactor `userProfileStreamProvider`, `holdingsStreamProvider`, and `recentActivityStreamProvider` to use the new provider.
   - Refactor `restDashboardProvider`, `restAvailableCashProvider`, `restInvestedValueProvider`, and `restRecentActivityProvider` to use the new provider.

3. **Update UI:**
   - Update the UI to use the new provider and ensure it works seamlessly with both Firestore and Go Backend data.

By following this plan, you can migrate to a Single Source of Truth in Postgres and simplify the codebase.
