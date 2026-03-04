import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Entity representing a user profile.
/// Maps to Firestore: users/{uid}
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    /// Document ID — injected from Firestore doc.id, not a stored field.
    required String uid,

    /// User's email address.
    required String email,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'base_currency') @Default('USD') String baseCurrency,
    @JsonKey(name: 'onboarding_completed')
    @Default(false)
    bool onboardingCompleted,
    String? country,
    @JsonKey(name: 'track_mode') String? trackMode,
    String? timezone,
    @JsonKey(name: 'preferred_language') String? preferredLanguage,

    /// Audit fields
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,

    /// Calculated field on client, not stored in DB.
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(0.0)
    double totalNetWorth,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
