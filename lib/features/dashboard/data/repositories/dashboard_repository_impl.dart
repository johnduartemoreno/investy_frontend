import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_fs
    show Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/insufficient_funds_exception.dart';
import '../../domain/entities/contribution.dart';
import '../../domain/entities/holding.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/asset.dart';
import '../../domain/repositories/dashboard_repository.dart';

part 'dashboard_repository_impl.g.dart';

/// Implementation of [DashboardRepository] using Firebase Firestore.
///
/// 🛑 GOVERNANCE: All Firestore writes use entity `.toJson()`.
/// Raw maps are FORBIDDEN per DATA_DICTIONARY.md.
///
/// 🛑 PRECISION ENGINE:
/// - Fiat (cash): stored as `int` (cents, ×100).
/// - Asset quantities: stored as `int` (sats, ×10⁸).
/// - Prices / avg_cost: stored as `int` (cents, ×100).
/// - Entities expose `double`. This repository is the SOLE conversion boundary.
class DashboardRepositoryImpl implements DashboardRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DashboardRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  /// Returns the current authenticated user's UID.
  /// Throws if no user is authenticated.
  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  // ─────────────────────────────────────────────
  // Helpers: Firestore Timestamp → DateTime
  // ─────────────────────────────────────────────

  /// Safely converts a Firestore value to an ISO 8601 string for fromJson.
  /// Handles Timestamp, String, and null.
  String? _toIsoString(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    } else if (value is String) {
      return value;
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // PRECISION ENGINE: int ↔ double Helpers
  // ─────────────────────────────────────────────

  /// Fiat scale: 2 decimal places (cents).
  static const int _fiatScale = 100;

  /// Asset scale: 8 decimal places (satoshis).
  static const int _assetScale = 100000000; // 10^8

  /// Converts a human-readable dollar amount to integer cents.
  /// e.g. $123.45 → 12345
  int _toCents(double dollars) => (dollars * _fiatScale).round();

  /// Converts integer cents to a human-readable dollar amount.
  /// e.g. 12345 → $123.45
  double _fromCents(int cents) => cents / _fiatScale;

  /// Converts a human-readable asset quantity to integer satoshi units.
  /// e.g. 0.005 → 500000
  int _toAssetUnits(double value) => (value * _assetScale).round();

  /// Converts integer satoshi units to a human-readable asset quantity.
  /// e.g. 500000 → 0.005
  double _fromAssetUnits(int units) => units / _assetScale;

  // ─────────────────────────────────────────────
  // TRANSACTION HELPER: Read wallet balance
  // ─────────────────────────────────────────────

  /// Reads the current wallet balance in integer cents within a transaction.
  /// Returns 0 if the wallet document does not exist (cold start).
  Future<int> _readWalletCents(
    cloud_fs.Transaction tx,
    DocumentReference walletRef,
  ) async {
    final snapshot = await tx.get(walletRef);
    if (!snapshot.exists) return 0;
    final data = snapshot.data() as Map<String, dynamic>;
    return (data['available_cash'] as num).toInt();
  }

  // ─────────────────────────────────────────────
  // STREAM WATCHERS (Firestore int → Entity double)
  // ─────────────────────────────────────────────

  @override
  Stream<UserProfile> watchUserProfile() {
    return _firestore.collection('users').doc(_uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        throw Exception('User profile not found');
      }
      return UserProfile.fromJson({
        'uid': snapshot.id,
        ...data,
        // Convert Firestore Timestamps to ISO strings for fromJson
        if (data['created_at'] != null)
          'created_at': _toIsoString(data['created_at']),
        if (data['updated_at'] != null)
          'updated_at': _toIsoString(data['updated_at']),
      });
    });
  }

  @override
  Stream<Wallet> watchWallet() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('wallet')
        .doc('main')
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        // Return a default empty wallet if document doesn't exist yet
        return const Wallet();
      }
      // Convert cents (int) → dollars (double) before passing to entity
      final int cashCents = (data['available_cash'] as num?)?.toInt() ?? 0;
      return Wallet.fromJson({
        ...data,
        'available_cash': _fromCents(cashCents),
        if (data['updated_at'] != null)
          'updated_at': _toIsoString(data['updated_at']),
      });
    });
  }

  @override
  Stream<List<Holding>> watchHoldings() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('holdings')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Convert sats (int) → double for quantity; cents (int) → double for avg_cost
        final int quantitySats = (data['quantity'] as num?)?.toInt() ?? 0;
        final int avgCostCents = (data['avg_cost'] as num?)?.toInt() ?? 0;
        return Holding.fromJson({
          'id': doc.id,
          ...data,
          'quantity': _fromAssetUnits(quantitySats),
          'avg_cost': _fromCents(avgCostCents),
          if (data['updated_at'] != null)
            'updated_at': _toIsoString(data['updated_at']),
        });
      }).toList();
    }).handleError((e) {
      debugPrint('🔥 Error watching holdings: $e');
      throw e;
    });
  }

  @override
  Stream<List<Contribution>> watchContributions() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('contributions')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Convert cents (int) → dollars (double)
        final int amountCents = (data['amount'] as num?)?.toInt() ?? 0;
        final int runningBalanceCents =
            (data['running_balance'] as num?)?.toInt() ?? 0;
        return Contribution.fromJson({
          'id': doc.id,
          ...data,
          'amount': _fromCents(amountCents),
          'running_balance': _fromCents(runningBalanceCents),
          'created_at': _toIsoString(data['created_at']) ??
              DateTime.now().toIso8601String(),
        });
      }).toList();
    }).handleError((e) {
      debugPrint('🔥 Error watching contributions: $e');
      throw e;
    });
  }

  @override
  Stream<List<Transaction>> watchTransactions() {
    return _firestore
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Convert: quantity → sats→double, price/total → cents→double
        final int quantitySats = (data['quantity'] as num?)?.toInt() ?? 0;
        final int priceCents = (data['price'] as num?)?.toInt() ?? 0;
        final int totalCents =
            (data['total_before_fees'] as num?)?.toInt() ?? 0;
        return Transaction.fromJson({
          'id': doc.id,
          ...data,
          'quantity': _fromAssetUnits(quantitySats),
          'price': _fromCents(priceCents),
          'total_before_fees': _fromCents(totalCents),
          'created_at': _toIsoString(data['created_at']) ??
              DateTime.now().toIso8601String(),
        });
      }).toList();
    }).handleError((e) {
      debugPrint('🔥 Error watching transactions: $e');
      throw e;
    });
  }

  // ─────────────────────────────────────────────
  // WRITE OPERATIONS (Integer Precision Engine)
  // ─────────────────────────────────────────────

  @override
  Future<String> addContribution({
    required double amount,
    required String type,
    required DateTime date,
    String? description,
  }) async {
    final uid = _uid;

    final walletRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('wallet')
        .doc('main');

    final contributionRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('contributions')
        .doc();

    await _firestore.runTransaction((tx) async {
      // 1. READ wallet balance in cents
      final currentCents = await _readWalletCents(tx, walletRef);

      // 2. CONVERT amount to cents
      final amountCents = _toCents(amount);

      // 3. MATH: deposit adds, withdrawal subtracts
      final int newCents;
      if (type == 'deposit') {
        newCents = currentCents + amountCents;
      } else if (type == 'withdrawal') {
        newCents = currentCents - amountCents;
      } else {
        throw Exception('Invalid contribution type: $type');
      }

      // 4. VALIDATE: prevent overdraft on withdrawal
      if (type == 'withdrawal' && newCents < 0) {
        throw InsufficientFundsException(
          available: _fromCents(currentCents),
          requested: amount,
          action: 'withdrawal',
        );
      }

      // 5. WRITE contribution — integer cents
      final contribution = Contribution(
        id: contributionRef.id,
        amount: amount,
        type: type,
        createdAt: DateTime.now(), // placeholder, overridden by serverTimestamp
        description: description,
        runningBalance: _fromCents(newCents),
      );
      final contributionJson = contribution.toJson();
      contributionJson.remove('id');
      // Override with integer cents for Firestore storage
      contributionJson['amount'] = amountCents;
      contributionJson['running_balance'] = newCents;
      contributionJson['created_at'] = FieldValue.serverTimestamp();
      tx.set(contributionRef, contributionJson);

      // 6. WRITE wallet — integer cents
      tx.set(
        walletRef,
        {
          'available_cash': newCents,
          'updated_at': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });

    return contributionRef.id;
  }

  @override
  Future<void> buyAsset({
    required String symbol,
    required double price,
    required double quantity,
  }) async {
    final uid = _uid;
    final upperSymbol = symbol.toUpperCase();

    final holdingRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('holdings')
        .doc(upperSymbol);

    final contributionRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('contributions')
        .doc();

    final transactionRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc();

    final walletRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('wallet')
        .doc('main');

    return _firestore.runTransaction((tx) async {
      // 1. READ wallet balance in cents
      final currentCents = await _readWalletCents(tx, walletRef);

      // 2. READ current holding (if any)
      final holdingSnapshot = await tx.get(holdingRef);

      // 3. CONVERT to integer units
      final priceCents = _toCents(price);
      final quantitySats = _toAssetUnits(quantity);
      final purchaseCents = _toCents(price * quantity);

      // 4. VALIDATE: prevent overdraft
      if (currentCents < purchaseCents) {
        throw InsufficientFundsException(
          available: _fromCents(currentCents),
          requested: _fromCents(purchaseCents),
          action: 'buy',
        );
      }

      // 5. MATH: wallet debit + holding weighted average
      final newCents = currentCents - purchaseCents;

      int newQtySats;
      int newAvgCents;

      if (holdingSnapshot.exists) {
        final data = holdingSnapshot.data() as Map<String, dynamic>;
        final oldQtySats = (data['quantity'] as num).toInt();
        final oldAvgCents = (data['avg_cost'] as num).toInt();
        newQtySats = oldQtySats + quantitySats;
        // Integer division for weighted average cost
        newAvgCents =
            ((oldQtySats * oldAvgCents) + (quantitySats * priceCents)) ~/
                newQtySats;
      } else {
        newQtySats = quantitySats;
        newAvgCents = priceCents;
      }

      // 6. WRITE Holding — integer sats for quantity, cents for avg_cost
      final holdingEntity = Holding(
        id: upperSymbol,
        symbol: upperSymbol,
        quantity: _fromAssetUnits(newQtySats),
        avgCost: _fromCents(newAvgCents),
        assetClass: 'Equity',
        updatedAt: DateTime.now(),
      );
      final holdingJson = holdingEntity.toJson();
      holdingJson.remove('id');
      // Override with integer values for Firestore storage
      holdingJson['quantity'] = newQtySats;
      holdingJson['avg_cost'] = newAvgCents;
      holdingJson['updated_at'] = FieldValue.serverTimestamp();
      tx.set(holdingRef, holdingJson, SetOptions(merge: true));

      // 7. WRITE Transaction — integer units
      final transactionEntity = Transaction(
        id: transactionRef.id,
        symbol: upperSymbol,
        type: 'buy',
        quantity: quantity,
        price: price,
        totalBeforeFees: _fromCents(purchaseCents),
        createdAt: DateTime.now(),
      );
      final transactionJson = transactionEntity.toJson();
      transactionJson.remove('id');
      // Override with integer values for Firestore storage
      transactionJson['quantity'] = quantitySats;
      transactionJson['price'] = priceCents;
      transactionJson['total_before_fees'] = purchaseCents;
      transactionJson['created_at'] = FieldValue.serverTimestamp();
      tx.set(transactionRef, transactionJson);

      // 8. WRITE Contribution (withdrawal for cash used) — integer cents
      final contributionEntity = Contribution(
        id: contributionRef.id,
        amount: _fromCents(purchaseCents),
        type: 'withdrawal',
        description: 'Buy $upperSymbol',
        createdAt: DateTime.now(),
        transactionId: transactionRef.id,
        runningBalance: _fromCents(newCents),
      );
      final contributionJson = contributionEntity.toJson();
      contributionJson.remove('id');
      // Override with integer cents for Firestore storage
      contributionJson['amount'] = purchaseCents;
      contributionJson['running_balance'] = newCents;
      contributionJson['created_at'] = FieldValue.serverTimestamp();
      tx.set(contributionRef, contributionJson);

      // 9. WRITE Wallet — integer cents
      tx.set(
        walletRef,
        {
          'available_cash': newCents,
          'updated_at': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  @override
  Future<void> sellAsset(
      String symbol, double currentPrice, double quantity) async {
    final uid = _uid;
    final upperSymbol = symbol.toUpperCase();

    final holdingRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('holdings')
        .doc(upperSymbol);

    final transactionRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc();

    final contributionRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('contributions')
        .doc();

    final walletRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('wallet')
        .doc('main');

    return _firestore.runTransaction((tx) async {
      // 1. READ wallet balance in cents
      final currentCents = await _readWalletCents(tx, walletRef);

      // 2. READ current holding
      final holdingSnapshot = await tx.get(holdingRef);

      // 3. VALIDATE: holding must exist
      if (!holdingSnapshot.exists) {
        throw InsufficientFundsException(
          available: 0,
          requested: quantity,
          action: 'sell',
        );
      }

      final holdingData = holdingSnapshot.data() as Map<String, dynamic>;
      final oldQtySats = (holdingData['quantity'] as num).toInt();
      final sellQtySats = _toAssetUnits(quantity);

      // VALIDATE: sufficient shares
      if (oldQtySats < sellQtySats) {
        throw InsufficientFundsException(
          available: _fromAssetUnits(oldQtySats),
          requested: quantity,
          action: 'sell',
        );
      }

      // 4. CONVERT price to cents
      final priceCents = _toCents(currentPrice);
      final saleCents = _toCents(currentPrice * quantity);

      // 5. MATH
      final newCents = currentCents + saleCents;
      final newQtySats = oldQtySats - sellQtySats;

      // 6. WRITE Holding — delete if zero, else update quantity only
      if (newQtySats == 0) {
        tx.delete(holdingRef);
      } else {
        // Keep avg_cost unchanged on sale
        final existingAvgCost = (holdingData['avg_cost'] as num).toInt();
        final holdingEntity = Holding(
          id: upperSymbol,
          symbol: upperSymbol,
          quantity: _fromAssetUnits(newQtySats),
          avgCost: _fromCents(existingAvgCost),
          assetClass: holdingData['asset_class'] as String? ?? 'Equity',
          updatedAt: DateTime.now(),
        );
        final holdingJson = holdingEntity.toJson();
        holdingJson.remove('id');
        // Override with integer values for Firestore storage
        holdingJson['quantity'] = newQtySats;
        holdingJson['avg_cost'] = existingAvgCost;
        holdingJson['updated_at'] = FieldValue.serverTimestamp();
        tx.set(holdingRef, holdingJson, SetOptions(merge: true));
      }

      // 7. WRITE Transaction — integer units
      final transactionEntity = Transaction(
        id: transactionRef.id,
        symbol: upperSymbol,
        type: 'sell',
        quantity: quantity,
        price: currentPrice,
        totalBeforeFees: _fromCents(saleCents),
        createdAt: DateTime.now(),
      );
      final transactionJson = transactionEntity.toJson();
      transactionJson.remove('id');
      // Override with integer values for Firestore storage
      transactionJson['quantity'] = sellQtySats;
      transactionJson['price'] = priceCents;
      transactionJson['total_before_fees'] = saleCents;
      transactionJson['created_at'] = FieldValue.serverTimestamp();
      tx.set(transactionRef, transactionJson);

      // 8. WRITE Contribution (deposit for cash received) — integer cents
      final contributionEntity = Contribution(
        id: contributionRef.id,
        amount: _fromCents(saleCents),
        type: 'deposit',
        description: 'Sold $upperSymbol',
        createdAt: DateTime.now(),
        transactionId: transactionRef.id,
        runningBalance: _fromCents(newCents),
      );
      final contributionJson = contributionEntity.toJson();
      contributionJson.remove('id');
      // Override with integer cents for Firestore storage
      contributionJson['amount'] = saleCents;
      contributionJson['running_balance'] = newCents;
      contributionJson['created_at'] = FieldValue.serverTimestamp();
      tx.set(contributionRef, contributionJson);

      // 9. WRITE Wallet — integer cents
      tx.set(
        walletRef,
        {
          'available_cash': newCents,
          'updated_at': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  @override
  Future<List<Asset>> searchAssets(String query) async {
    if (query.isEmpty) return [];

    // Simple startAt/endAt search
    final snapshot = await _firestore
        .collection('assets')
        .where('symbol', isGreaterThanOrEqualTo: query.toUpperCase())
        .where('symbol', isLessThan: '${query.toUpperCase()}z')
        .limit(10)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Convert current_price from cents (int) → dollars (double)
      final int priceCents = (data['current_price'] as num?)?.toInt() ?? 0;
      return Asset.fromJson({
        ...data,
        'current_price': _fromCents(priceCents),
      });
    }).toList();
  }
}

/// Riverpod provider for [DashboardRepository].
@riverpod
DashboardRepository dashboardRepository(Ref ref) {
  return DashboardRepositoryImpl(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
}
