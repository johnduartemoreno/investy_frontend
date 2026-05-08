// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recommendationsHash() => r'9f4700ae3f637ecc9a53337c122485448c9e9c18';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Fetches AI recommendations for the current user.
/// Pass [forceRefresh] = true to bypass the server-side 24h cache.
///
/// Copied from [recommendations].
@ProviderFor(recommendations)
const recommendationsProvider = RecommendationsFamily();

/// Fetches AI recommendations for the current user.
/// Pass [forceRefresh] = true to bypass the server-side 24h cache.
///
/// Copied from [recommendations].
class RecommendationsFamily
    extends Family<AsyncValue<List<RecommendationModel>>> {
  /// Fetches AI recommendations for the current user.
  /// Pass [forceRefresh] = true to bypass the server-side 24h cache.
  ///
  /// Copied from [recommendations].
  const RecommendationsFamily();

  /// Fetches AI recommendations for the current user.
  /// Pass [forceRefresh] = true to bypass the server-side 24h cache.
  ///
  /// Copied from [recommendations].
  RecommendationsProvider call({
    bool forceRefresh = false,
  }) {
    return RecommendationsProvider(
      forceRefresh: forceRefresh,
    );
  }

  @override
  RecommendationsProvider getProviderOverride(
    covariant RecommendationsProvider provider,
  ) {
    return call(
      forceRefresh: provider.forceRefresh,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recommendationsProvider';
}

/// Fetches AI recommendations for the current user.
/// Pass [forceRefresh] = true to bypass the server-side 24h cache.
///
/// Copied from [recommendations].
class RecommendationsProvider
    extends AutoDisposeFutureProvider<List<RecommendationModel>> {
  /// Fetches AI recommendations for the current user.
  /// Pass [forceRefresh] = true to bypass the server-side 24h cache.
  ///
  /// Copied from [recommendations].
  RecommendationsProvider({
    bool forceRefresh = false,
  }) : this._internal(
          (ref) => recommendations(
            ref as RecommendationsRef,
            forceRefresh: forceRefresh,
          ),
          from: recommendationsProvider,
          name: r'recommendationsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$recommendationsHash,
          dependencies: RecommendationsFamily._dependencies,
          allTransitiveDependencies:
              RecommendationsFamily._allTransitiveDependencies,
          forceRefresh: forceRefresh,
        );

  RecommendationsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.forceRefresh,
  }) : super.internal();

  final bool forceRefresh;

  @override
  Override overrideWith(
    FutureOr<List<RecommendationModel>> Function(RecommendationsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecommendationsProvider._internal(
        (ref) => create(ref as RecommendationsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        forceRefresh: forceRefresh,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RecommendationModel>> createElement() {
    return _RecommendationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecommendationsProvider &&
        other.forceRefresh == forceRefresh;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, forceRefresh.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RecommendationsRef
    on AutoDisposeFutureProviderRef<List<RecommendationModel>> {
  /// The parameter `forceRefresh` of this provider.
  bool get forceRefresh;
}

class _RecommendationsProviderElement
    extends AutoDisposeFutureProviderElement<List<RecommendationModel>>
    with RecommendationsRef {
  _RecommendationsProviderElement(super.provider);

  @override
  bool get forceRefresh => (origin as RecommendationsProvider).forceRefresh;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
