// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'holding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Holding _$HoldingFromJson(Map<String, dynamic> json) {
  return _Holding.fromJson(json);
}

/// @nodoc
mixin _$Holding {
  String get id => throw _privateConstructorUsedError;
  String get symbol => throw _privateConstructorUsedError;
  double get quantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'avg_cost')
  double get avgCost => throw _privateConstructorUsedError;
  @JsonKey(name: 'asset_class')
  String get assetClass => throw _privateConstructorUsedError;

  /// Current price fetched from external API.
  /// Nullable until price is fetched. Not persisted to Firestore.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double? get currentPrice => throw _privateConstructorUsedError;

  /// Audit: last update timestamp.
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HoldingCopyWith<Holding> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HoldingCopyWith<$Res> {
  factory $HoldingCopyWith(Holding value, $Res Function(Holding) then) =
      _$HoldingCopyWithImpl<$Res, Holding>;
  @useResult
  $Res call(
      {String id,
      String symbol,
      double quantity,
      @JsonKey(name: 'avg_cost') double avgCost,
      @JsonKey(name: 'asset_class') String assetClass,
      @JsonKey(includeFromJson: false, includeToJson: false)
      double? currentPrice,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$HoldingCopyWithImpl<$Res, $Val extends Holding>
    implements $HoldingCopyWith<$Res> {
  _$HoldingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? symbol = null,
    Object? quantity = null,
    Object? avgCost = null,
    Object? assetClass = null,
    Object? currentPrice = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      avgCost: null == avgCost
          ? _value.avgCost
          : avgCost // ignore: cast_nullable_to_non_nullable
              as double,
      assetClass: null == assetClass
          ? _value.assetClass
          : assetClass // ignore: cast_nullable_to_non_nullable
              as String,
      currentPrice: freezed == currentPrice
          ? _value.currentPrice
          : currentPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HoldingImplCopyWith<$Res> implements $HoldingCopyWith<$Res> {
  factory _$$HoldingImplCopyWith(
          _$HoldingImpl value, $Res Function(_$HoldingImpl) then) =
      __$$HoldingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String symbol,
      double quantity,
      @JsonKey(name: 'avg_cost') double avgCost,
      @JsonKey(name: 'asset_class') String assetClass,
      @JsonKey(includeFromJson: false, includeToJson: false)
      double? currentPrice,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$HoldingImplCopyWithImpl<$Res>
    extends _$HoldingCopyWithImpl<$Res, _$HoldingImpl>
    implements _$$HoldingImplCopyWith<$Res> {
  __$$HoldingImplCopyWithImpl(
      _$HoldingImpl _value, $Res Function(_$HoldingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? symbol = null,
    Object? quantity = null,
    Object? avgCost = null,
    Object? assetClass = null,
    Object? currentPrice = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$HoldingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as double,
      avgCost: null == avgCost
          ? _value.avgCost
          : avgCost // ignore: cast_nullable_to_non_nullable
              as double,
      assetClass: null == assetClass
          ? _value.assetClass
          : assetClass // ignore: cast_nullable_to_non_nullable
              as String,
      currentPrice: freezed == currentPrice
          ? _value.currentPrice
          : currentPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HoldingImpl extends _Holding {
  const _$HoldingImpl(
      {required this.id,
      required this.symbol,
      required this.quantity,
      @JsonKey(name: 'avg_cost') required this.avgCost,
      @JsonKey(name: 'asset_class') required this.assetClass,
      @JsonKey(includeFromJson: false, includeToJson: false) this.currentPrice,
      @JsonKey(name: 'updated_at') this.updatedAt})
      : super._();

  factory _$HoldingImpl.fromJson(Map<String, dynamic> json) =>
      _$$HoldingImplFromJson(json);

  @override
  final String id;
  @override
  final String symbol;
  @override
  final double quantity;
  @override
  @JsonKey(name: 'avg_cost')
  final double avgCost;
  @override
  @JsonKey(name: 'asset_class')
  final String assetClass;

  /// Current price fetched from external API.
  /// Nullable until price is fetched. Not persisted to Firestore.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final double? currentPrice;

  /// Audit: last update timestamp.
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Holding(id: $id, symbol: $symbol, quantity: $quantity, avgCost: $avgCost, assetClass: $assetClass, currentPrice: $currentPrice, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HoldingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.avgCost, avgCost) || other.avgCost == avgCost) &&
            (identical(other.assetClass, assetClass) ||
                other.assetClass == assetClass) &&
            (identical(other.currentPrice, currentPrice) ||
                other.currentPrice == currentPrice) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, symbol, quantity, avgCost,
      assetClass, currentPrice, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HoldingImplCopyWith<_$HoldingImpl> get copyWith =>
      __$$HoldingImplCopyWithImpl<_$HoldingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HoldingImplToJson(
      this,
    );
  }
}

abstract class _Holding extends Holding {
  const factory _Holding(
      {required final String id,
      required final String symbol,
      required final double quantity,
      @JsonKey(name: 'avg_cost') required final double avgCost,
      @JsonKey(name: 'asset_class') required final String assetClass,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final double? currentPrice,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt}) = _$HoldingImpl;
  const _Holding._() : super._();

  factory _Holding.fromJson(Map<String, dynamic> json) = _$HoldingImpl.fromJson;

  @override
  String get id;
  @override
  String get symbol;
  @override
  double get quantity;
  @override
  @JsonKey(name: 'avg_cost')
  double get avgCost;
  @override
  @JsonKey(name: 'asset_class')
  String get assetClass;
  @override

  /// Current price fetched from external API.
  /// Nullable until price is fetched. Not persisted to Firestore.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double? get currentPrice;
  @override

  /// Audit: last update timestamp.
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$HoldingImplCopyWith<_$HoldingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
