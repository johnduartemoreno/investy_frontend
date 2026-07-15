// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityItemModel _$ActivityItemModelFromJson(Map<String, dynamic> json) =>
    ActivityItemModel(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num).toInt(),
      type: json['type'] as String? ?? 'UNKNOWN',
      timestamp: json['timestamp'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      quantityUnits: (json['quantityUnits'] as num?)?.toInt() ?? 0,
      priceCents: (json['priceCents'] as num?)?.toInt() ?? 0,
      totalBeforeFeesCents:
          (json['totalBeforeFeesCents'] as num?)?.toInt() ?? 0,
      feeCents: (json['feeCents'] as num?)?.toInt() ?? 0,
      realizedPnlCents: (json['realizedPnlCents'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ActivityItemModelToJson(ActivityItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'totalBeforeFeesCents': instance.totalBeforeFeesCents,
      'feeCents': instance.feeCents,
      'type': instance.type,
      'timestamp': instance.timestamp,
      'symbol': instance.symbol,
      'quantityUnits': instance.quantityUnits,
      'priceCents': instance.priceCents,
      'realizedPnlCents': instance.realizedPnlCents,
    };
