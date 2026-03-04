// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contribution.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Contribution _$ContributionFromJson(Map<String, dynamic> json) {
  return _Contribution.fromJson(json);
}

/// @nodoc
mixin _$Contribution {
  String get id => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;

  /// Type of contribution: "deposit" or "withdrawal"
  String get type => throw _privateConstructorUsedError;

  /// Audit: immutable creation time.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Optional human-readable description (e.g., "Buy AAPL").
  String? get description => throw _privateConstructorUsedError;

  /// Links to the transaction that created this contribution (e.g., a buy).
  /// Null for standalone deposits/withdrawals.
  @JsonKey(name: 'transaction_id')
  String? get transactionId => throw _privateConstructorUsedError;

  /// Wallet balance after this transaction.
  @JsonKey(name: 'running_balance')
  double? get runningBalance => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ContributionCopyWith<Contribution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContributionCopyWith<$Res> {
  factory $ContributionCopyWith(
          Contribution value, $Res Function(Contribution) then) =
      _$ContributionCopyWithImpl<$Res, Contribution>;
  @useResult
  $Res call(
      {String id,
      double amount,
      String type,
      @JsonKey(name: 'created_at') DateTime createdAt,
      String? description,
      @JsonKey(name: 'transaction_id') String? transactionId,
      @JsonKey(name: 'running_balance') double? runningBalance});
}

/// @nodoc
class _$ContributionCopyWithImpl<$Res, $Val extends Contribution>
    implements $ContributionCopyWith<$Res> {
  _$ContributionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? type = null,
    Object? createdAt = null,
    Object? description = freezed,
    Object? transactionId = freezed,
    Object? runningBalance = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      runningBalance: freezed == runningBalance
          ? _value.runningBalance
          : runningBalance // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContributionImplCopyWith<$Res>
    implements $ContributionCopyWith<$Res> {
  factory _$$ContributionImplCopyWith(
          _$ContributionImpl value, $Res Function(_$ContributionImpl) then) =
      __$$ContributionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      double amount,
      String type,
      @JsonKey(name: 'created_at') DateTime createdAt,
      String? description,
      @JsonKey(name: 'transaction_id') String? transactionId,
      @JsonKey(name: 'running_balance') double? runningBalance});
}

/// @nodoc
class __$$ContributionImplCopyWithImpl<$Res>
    extends _$ContributionCopyWithImpl<$Res, _$ContributionImpl>
    implements _$$ContributionImplCopyWith<$Res> {
  __$$ContributionImplCopyWithImpl(
      _$ContributionImpl _value, $Res Function(_$ContributionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? type = null,
    Object? createdAt = null,
    Object? description = freezed,
    Object? transactionId = freezed,
    Object? runningBalance = freezed,
  }) {
    return _then(_$ContributionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      runningBalance: freezed == runningBalance
          ? _value.runningBalance
          : runningBalance // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ContributionImpl implements _Contribution {
  const _$ContributionImpl(
      {required this.id,
      required this.amount,
      required this.type,
      @JsonKey(name: 'created_at') required this.createdAt,
      this.description,
      @JsonKey(name: 'transaction_id') this.transactionId,
      @JsonKey(name: 'running_balance') this.runningBalance});

  factory _$ContributionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContributionImplFromJson(json);

  @override
  final String id;
  @override
  final double amount;

  /// Type of contribution: "deposit" or "withdrawal"
  @override
  final String type;

  /// Audit: immutable creation time.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Optional human-readable description (e.g., "Buy AAPL").
  @override
  final String? description;

  /// Links to the transaction that created this contribution (e.g., a buy).
  /// Null for standalone deposits/withdrawals.
  @override
  @JsonKey(name: 'transaction_id')
  final String? transactionId;

  /// Wallet balance after this transaction.
  @override
  @JsonKey(name: 'running_balance')
  final double? runningBalance;

  @override
  String toString() {
    return 'Contribution(id: $id, amount: $amount, type: $type, createdAt: $createdAt, description: $description, transactionId: $transactionId, runningBalance: $runningBalance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContributionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.runningBalance, runningBalance) ||
                other.runningBalance == runningBalance));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, amount, type, createdAt,
      description, transactionId, runningBalance);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ContributionImplCopyWith<_$ContributionImpl> get copyWith =>
      __$$ContributionImplCopyWithImpl<_$ContributionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContributionImplToJson(
      this,
    );
  }
}

abstract class _Contribution implements Contribution {
  const factory _Contribution(
          {required final String id,
          required final double amount,
          required final String type,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          final String? description,
          @JsonKey(name: 'transaction_id') final String? transactionId,
          @JsonKey(name: 'running_balance') final double? runningBalance}) =
      _$ContributionImpl;

  factory _Contribution.fromJson(Map<String, dynamic> json) =
      _$ContributionImpl.fromJson;

  @override
  String get id;
  @override
  double get amount;
  @override

  /// Type of contribution: "deposit" or "withdrawal"
  String get type;
  @override

  /// Audit: immutable creation time.
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override

  /// Optional human-readable description (e.g., "Buy AAPL").
  String? get description;
  @override

  /// Links to the transaction that created this contribution (e.g., a buy).
  /// Null for standalone deposits/withdrawals.
  @JsonKey(name: 'transaction_id')
  String? get transactionId;
  @override

  /// Wallet balance after this transaction.
  @JsonKey(name: 'running_balance')
  double? get runningBalance;
  @override
  @JsonKey(ignore: true)
  _$$ContributionImplCopyWith<_$ContributionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
