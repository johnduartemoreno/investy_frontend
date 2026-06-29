// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$alertFormControllerHash() =>
    r'abed2b3542be445ee54cd4be7be75bd30777fb78';

/// Pattern D — mutation controller for creating a price alert (B12).
/// Idle state is AsyncData(null). Invalidates [alertsProvider] only on success.
/// Deletion is done inline in the list tile (a fire-and-forget datasource call +
/// invalidate) — routing it through this autoDispose notifier from a `ref.read`
/// context disposes it mid-await and throws "Future already completed".
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
