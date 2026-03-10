// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoalResponseModel _$GoalResponseModelFromJson(Map<String, dynamic> json) =>
    GoalResponseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmountCents: (json['targetAmountCents'] as num).toInt(),
      currentAmountCents: (json['currentAmountCents'] as num).toInt(),
      deadline: json['deadline'] as String,
      category: json['category'] as String,
    );

Map<String, dynamic> _$GoalResponseModelToJson(GoalResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'targetAmountCents': instance.targetAmountCents,
      'currentAmountCents': instance.currentAmountCents,
      'deadline': instance.deadline,
      'category': instance.category,
    };
