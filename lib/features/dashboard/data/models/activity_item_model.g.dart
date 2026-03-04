// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityItemModel _$ActivityItemModelFromJson(Map<String, dynamic> json) =>
    ActivityItemModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toInt(),
      type: json['type'] as String,
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$ActivityItemModelToJson(ActivityItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'type': instance.type,
      'timestamp': instance.timestamp,
    };
