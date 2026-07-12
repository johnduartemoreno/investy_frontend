// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$alertFormControllerHash() =>
    r'60e3a9c8037812e0a2f21d6ebc3877b418540766';

/// Pattern D — mutation controller for creating a price alert (B12).
/// Idle state is AsyncData(null).
///
/// The list refresh ([alertsProvider] invalidation) is NOT done here: the
/// sheet's success listener pops the modal, which disposes this autoDispose
/// notifier mid-flight — an `ref.invalidate` issued from this method right
/// after the await is dropped, so the new alert never shows in the list. The
/// sheet invalidates instead, from a ref that is still alive when it fires.
/// Same reason deletion is done inline in the list tile.
///
/// Copied from [AlertFormController].
@ProviderFor(AlertFormController)
final alertFormControllerProvider =
    AutoDisposeAsyncNotifierProvider<AlertFormController, void>.internal(
  AlertFormController.new,
  name: r'alertFormControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$alertFormControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AlertFormController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
