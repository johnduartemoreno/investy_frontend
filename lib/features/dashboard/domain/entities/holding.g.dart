// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HoldingImpl _$$HoldingImplFromJson(Map<String, dynamic> json) =>
    _$HoldingImpl(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      avgCost: (json['avg_cost'] as num).toDouble(),
      assetClass: json['asset_class'] as String,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$HoldingImplToJson(_$HoldingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbol': instance.symbol,
      'quantity': instance.quantity,
      'avg_cost': instance.avgCost,
      'asset_class': instance.assetClass,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
