// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$assetHistoryHash() => r'1d0912761fa9561b62308c5723e008deecd3bb46';

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

/// Asset daily price series, keyed by (symbol, range). The detail screen owns
/// its own range in local state and re-watches with the new value.
///
/// Copied from [assetHistory].
@ProviderFor(assetHistory)
const assetHistoryProvider = AssetHistoryFamily();

/// Asset daily price series, keyed by (symbol, range). The detail screen owns
/// its own range in local state and re-watches with the new value.
///
/// Copied from [assetHistory].
class AssetHistoryFamily extends Family<AsyncValue<AssetHistoryModel>> {
  /// Asset daily price series, keyed by (symbol, range). The detail screen owns
  /// its own range in local state and re-watches with the new value.
  ///
  /// Copied from [assetHistory].
  const AssetHistoryFamily();

  /// Asset daily price series, keyed by (symbol, range). The detail screen owns
  /// its own range in local state and re-watches with the new value.
  ///
  /// Copied from [assetHistory].
  AssetHistoryProvider call(
    String symbol,
    String range,
  ) {
    return AssetHistoryProvider(
      symbol,
      range,
    );
  }

  @override
  AssetHistoryProvider getProviderOverride(
    covariant AssetHistoryProvider provider,
  ) {
    return call(
      provider.symbol,
      provider.range,
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
  String? get name => r'assetHistoryProvider';
}

/// Asset daily price series, keyed by (symbol, range). The detail screen owns
/// its own range in local state and re-watches with the new value.
///
/// Copied from [assetHistory].
class AssetHistoryProvider
    extends AutoDisposeFutureProvider<AssetHistoryModel> {
  /// Asset daily price series, keyed by (symbol, range). The detail screen owns
  /// its own range in local state and re-watches with the new value.
  ///
  /// Copied from [assetHistory].
  AssetHistoryProvider(
    String symbol,
    String range,
  ) : this._internal(
          (ref) => assetHistory(
            ref as AssetHistoryRef,
            symbol,
            range,
          ),
          from: assetHistoryProvider,
          name: r'assetHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$assetHistoryHash,
          dependencies: AssetHistoryFamily._dependencies,
          allTransitiveDependencies:
              AssetHistoryFamily._allTransitiveDependencies,
          symbol: symbol,
          range: range,
        );

  AssetHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.symbol,
    required this.range,
  }) : super.internal();

  final String symbol;
  final String range;

  @override
  Override overrideWith(
    FutureOr<AssetHistoryModel> Function(AssetHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AssetHistoryProvider._internal(
        (ref) => create(ref as AssetHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        symbol: symbol,
        range: range,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AssetHistoryModel> createElement() {
    return _AssetHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AssetHistoryProvider &&
        other.symbol == symbol &&
        other.range == range;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, symbol.hashCode);
    hash = _SystemHash.combine(hash, range.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AssetHistoryRef on AutoDisposeFutureProviderRef<AssetHistoryModel> {
  /// The parameter `symbol` of this provider.
  String get symbol;

  /// The parameter `range` of this provider.
  String get range;
}

class _AssetHistoryProviderElement
    extends AutoDisposeFutureProviderElement<AssetHistoryModel>
    with AssetHistoryRef {
  _AssetHistoryProviderElement(super.provider);

  @override
  String get symbol => (origin as AssetHistoryProvider).symbol;
  @override
  String get range => (origin as AssetHistoryProvider).range;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
