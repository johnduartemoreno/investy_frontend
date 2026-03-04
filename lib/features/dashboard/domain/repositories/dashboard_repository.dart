import '../entities/user_profile.dart';
import '../entities/holding.dart';
import '../entities/contribution.dart';
import '../entities/transaction.dart';
import '../entities/wallet.dart';
import '../entities/asset.dart';

/// Abstract repository contract for Dashboard data operations.
///
/// Provides real-time streams for user profile, wallet, holdings, contributions,
/// and transactions from Firestore.
///
/// 🛑 GOVERNANCE RULE: Implementations MUST use entity `.toJson()` or
/// `.copyWith().toJson()` for all Firestore writes. Raw maps are FORBIDDEN.
abstract class DashboardRepository {
  /// Watches the current user's profile for real-time updates.
  /// Maps to Firestore: users/{uid}
  Stream<UserProfile> watchUserProfile();

  /// Watches the current user's wallet for real-time updates.
  /// Maps to Firestore: users/{uid}/wallet/main
  Stream<Wallet> watchWallet();

  /// Watches the current user's holdings for real-time updates.
  /// Maps to Firestore: users/{uid}/holdings
  Stream<List<Holding>> watchHoldings();

  /// Watches the current user's contributions for real-time updates.
  /// Ordered by created_at descending (most recent first).
  /// Maps to Firestore: users/{uid}/contributions
  Stream<List<Contribution>> watchContributions();

  /// Watches the current user's transactions for real-time updates.
  /// Ordered by created_at descending (most recent first).
  /// Maps to Firestore: users/{uid}/transactions
  Stream<List<Transaction>> watchTransactions();

  /// Adds a new contribution (deposit or withdrawal).
  /// Returns the ID of the created document.
  Future<String> addContribution({
    required double amount,
    required String type,
    required DateTime date,
    String? description,
  });

  /// Buys an asset.
  /// - Updates/Creates the holding documents in users/{uid}/holdings/{symbol}.
  /// - Creates a withdrawal contribution in users/{uid}/contributions.
  Future<void> buyAsset({
    required String symbol,
    required double price,
    required double quantity,
  });

  /// Sells an asset from the user's portfolio.
  /// - Validates sufficient holdings exist for the given [symbol].
  /// - Subtracts [quantity] from holdings (deletes doc if quantity reaches 0).
  /// - Does NOT alter avgCost (weighted average cost is unchanged on sale).
  /// - Logs a 'sell' transaction and a 'deposit' contribution (cash returned).
  Future<void> sellAsset(String symbol, double currentPrice, double quantity);

  /// Searches for assets by symbol or name.
  Future<List<Asset>> searchAssets(String query);
}
