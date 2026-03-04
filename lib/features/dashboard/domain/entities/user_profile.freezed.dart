// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  /// Document ID — injected from Firestore doc.id, not a stored field.
  String get uid => throw _privateConstructorUsedError;

  /// User's email address.
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name')
  String get displayName => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_url')
  String? get photoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_number')
  String? get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'base_currency')
  String get baseCurrency => throw _privateConstructorUsedError;
  @JsonKey(name: 'onboarding_completed')
  bool get onboardingCompleted => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  @JsonKey(name: 'track_mode')
  String? get trackMode => throw _privateConstructorUsedError;
  String? get timezone => throw _privateConstructorUsedError;
  @JsonKey(name: 'preferred_language')
  String? get preferredLanguage => throw _privateConstructorUsedError;

  /// Audit fields
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Calculated field on client, not stored in DB.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double get totalNetWorth => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {String uid,
      String email,
      @JsonKey(name: 'display_name') String displayName,
      @JsonKey(name: 'photo_url') String? photoUrl,
      @JsonKey(name: 'phone_number') String? phoneNumber,
      @JsonKey(name: 'base_currency') String baseCurrency,
      @JsonKey(name: 'onboarding_completed') bool onboardingCompleted,
      String? country,
      @JsonKey(name: 'track_mode') String? trackMode,
      String? timezone,
      @JsonKey(name: 'preferred_language') String? preferredLanguage,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(includeFromJson: false, includeToJson: false)
      double totalNetWorth});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = null,
    Object? photoUrl = freezed,
    Object? phoneNumber = freezed,
    Object? baseCurrency = null,
    Object? onboardingCompleted = null,
    Object? country = freezed,
    Object? trackMode = freezed,
    Object? timezone = freezed,
    Object? preferredLanguage = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? totalNetWorth = null,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      baseCurrency: null == baseCurrency
          ? _value.baseCurrency
          : baseCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      onboardingCompleted: null == onboardingCompleted
          ? _value.onboardingCompleted
          : onboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      trackMode: freezed == trackMode
          ? _value.trackMode
          : trackMode // ignore: cast_nullable_to_non_nullable
              as String?,
      timezone: freezed == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredLanguage: freezed == preferredLanguage
          ? _value.preferredLanguage
          : preferredLanguage // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalNetWorth: null == totalNetWorth
          ? _value.totalNetWorth
          : totalNetWorth // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String email,
      @JsonKey(name: 'display_name') String displayName,
      @JsonKey(name: 'photo_url') String? photoUrl,
      @JsonKey(name: 'phone_number') String? phoneNumber,
      @JsonKey(name: 'base_currency') String baseCurrency,
      @JsonKey(name: 'onboarding_completed') bool onboardingCompleted,
      String? country,
      @JsonKey(name: 'track_mode') String? trackMode,
      String? timezone,
      @JsonKey(name: 'preferred_language') String? preferredLanguage,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(includeFromJson: false, includeToJson: false)
      double totalNetWorth});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = null,
    Object? photoUrl = freezed,
    Object? phoneNumber = freezed,
    Object? baseCurrency = null,
    Object? onboardingCompleted = null,
    Object? country = freezed,
    Object? trackMode = freezed,
    Object? timezone = freezed,
    Object? preferredLanguage = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? totalNetWorth = null,
  }) {
    return _then(_$UserProfileImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      baseCurrency: null == baseCurrency
          ? _value.baseCurrency
          : baseCurrency // ignore: cast_nullable_to_non_nullable
              as String,
      onboardingCompleted: null == onboardingCompleted
          ? _value.onboardingCompleted
          : onboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      trackMode: freezed == trackMode
          ? _value.trackMode
          : trackMode // ignore: cast_nullable_to_non_nullable
              as String?,
      timezone: freezed == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredLanguage: freezed == preferredLanguage
          ? _value.preferredLanguage
          : preferredLanguage // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalNetWorth: null == totalNetWorth
          ? _value.totalNetWorth
          : totalNetWorth // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.uid,
      required this.email,
      @JsonKey(name: 'display_name') required this.displayName,
      @JsonKey(name: 'photo_url') this.photoUrl,
      @JsonKey(name: 'phone_number') this.phoneNumber,
      @JsonKey(name: 'base_currency') this.baseCurrency = 'USD',
      @JsonKey(name: 'onboarding_completed') this.onboardingCompleted = false,
      this.country,
      @JsonKey(name: 'track_mode') this.trackMode,
      this.timezone,
      @JsonKey(name: 'preferred_language') this.preferredLanguage,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(includeFromJson: false, includeToJson: false)
      this.totalNetWorth = 0.0});

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  /// Document ID — injected from Firestore doc.id, not a stored field.
  @override
  final String uid;

  /// User's email address.
  @override
  final String email;
  @override
  @JsonKey(name: 'display_name')
  final String displayName;
  @override
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  @override
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @override
  @JsonKey(name: 'base_currency')
  final String baseCurrency;
  @override
  @JsonKey(name: 'onboarding_completed')
  final bool onboardingCompleted;
  @override
  final String? country;
  @override
  @JsonKey(name: 'track_mode')
  final String? trackMode;
  @override
  final String? timezone;
  @override
  @JsonKey(name: 'preferred_language')
  final String? preferredLanguage;

  /// Audit fields
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Calculated field on client, not stored in DB.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final double totalNetWorth;

  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, baseCurrency: $baseCurrency, onboardingCompleted: $onboardingCompleted, country: $country, trackMode: $trackMode, timezone: $timezone, preferredLanguage: $preferredLanguage, createdAt: $createdAt, updatedAt: $updatedAt, totalNetWorth: $totalNetWorth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.baseCurrency, baseCurrency) ||
                other.baseCurrency == baseCurrency) &&
            (identical(other.onboardingCompleted, onboardingCompleted) ||
                other.onboardingCompleted == onboardingCompleted) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.trackMode, trackMode) ||
                other.trackMode == trackMode) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.preferredLanguage, preferredLanguage) ||
                other.preferredLanguage == preferredLanguage) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.totalNetWorth, totalNetWorth) ||
                other.totalNetWorth == totalNetWorth));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      email,
      displayName,
      photoUrl,
      phoneNumber,
      baseCurrency,
      onboardingCompleted,
      country,
      trackMode,
      timezone,
      preferredLanguage,
      createdAt,
      updatedAt,
      totalNetWorth);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {required final String uid,
      required final String email,
      @JsonKey(name: 'display_name') required final String displayName,
      @JsonKey(name: 'photo_url') final String? photoUrl,
      @JsonKey(name: 'phone_number') final String? phoneNumber,
      @JsonKey(name: 'base_currency') final String baseCurrency,
      @JsonKey(name: 'onboarding_completed') final bool onboardingCompleted,
      final String? country,
      @JsonKey(name: 'track_mode') final String? trackMode,
      final String? timezone,
      @JsonKey(name: 'preferred_language') final String? preferredLanguage,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final double totalNetWorth}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override

  /// Document ID — injected from Firestore doc.id, not a stored field.
  String get uid;
  @override

  /// User's email address.
  String get email;
  @override
  @JsonKey(name: 'display_name')
  String get displayName;
  @override
  @JsonKey(name: 'photo_url')
  String? get photoUrl;
  @override
  @JsonKey(name: 'phone_number')
  String? get phoneNumber;
  @override
  @JsonKey(name: 'base_currency')
  String get baseCurrency;
  @override
  @JsonKey(name: 'onboarding_completed')
  bool get onboardingCompleted;
  @override
  String? get country;
  @override
  @JsonKey(name: 'track_mode')
  String? get trackMode;
  @override
  String? get timezone;
  @override
  @JsonKey(name: 'preferred_language')
  String? get preferredLanguage;
  @override

  /// Audit fields
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override

  /// Calculated field on client, not stored in DB.
  @JsonKey(includeFromJson: false, includeToJson: false)
  double get totalNetWorth;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
