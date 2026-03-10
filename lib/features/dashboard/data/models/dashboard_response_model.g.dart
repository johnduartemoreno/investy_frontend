// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardResponseModel _$DashboardResponseModelFromJson(
        Map<String, dynamic> json) =>
    DashboardResponseModel(
      userName: json['userName'] as String? ?? 'Investor',
      totalBalance: (json['totalBalance'] as num?)?.toInt() ?? 0,
      investedValue: (json['investedValue'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      recentActivity: (json['recentActivity'] as List<dynamic>)
          .map((e) => ActivityItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DashboardResponseModelToJson(
        DashboardResponseModel instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'totalBalance': instance.totalBalance,
      'investedValue': instance.investedValue,
      'currency': instance.currency,
      'recentActivity': instance.recentActivity.map((e) => e.toJson()).toList(),
    };
