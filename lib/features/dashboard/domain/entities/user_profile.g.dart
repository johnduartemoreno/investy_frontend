// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      photoUrl: json['photo_url'] as String?,
      phoneNumber: json['phone_number'] as String?,
      baseCurrency: json['base_currency'] as String? ?? 'USD',
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      country: json['country'] as String?,
      trackMode: json['track_mode'] as String?,
      timezone: json['timezone'] as String?,
      preferredLanguage: json['preferred_language'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'display_name': instance.displayName,
      'photo_url': instance.photoUrl,
      'phone_number': instance.phoneNumber,
      'base_currency': instance.baseCurrency,
      'onboarding_completed': instance.onboardingCompleted,
      'country': instance.country,
      'track_mode': instance.trackMode,
      'timezone': instance.timezone,
      'preferred_language': instance.preferredLanguage,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
