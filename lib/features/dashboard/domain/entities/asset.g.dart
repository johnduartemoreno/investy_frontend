// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AssetImpl _$$AssetImplFromJson(Map<String, dynamic> json) => _$AssetImpl(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      currentPrice: (json['current_price'] as num).toDouble(),
    );

Map<String, dynamic> _$$AssetImplToJson(_$AssetImpl instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'logo_url': instance.logoUrl,
      'current_price': instance.currentPrice,
    };
