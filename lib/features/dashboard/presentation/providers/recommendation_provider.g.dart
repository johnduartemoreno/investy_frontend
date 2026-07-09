// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recommendationsHash() => r'827e5548067e807153b5a7361de23167374ff166';

/// Fetches AI recommendations for the current user.
/// Reasons are returned in the user's current app language (en/es/pt).
/// To force refresh: call datasource with forceRefresh=true then ref.invalidate(recommendationsProvider).
///
/// Copied from [recommendations].
@ProviderFor(recommendations)
final recommendationsProvider =
    AutoDisposeFutureProvider<List<RecommendationModel>>.internal(
  recommendations,
  name: r'recommendationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recommendationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecommendationsRef
    = AutoDisposeFutureProviderRef<List<RecommendationModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
