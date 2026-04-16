// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionTerminatedHash() => r'a4b250c977a1e059d9d8c75722955c8e240cc86a';

/// Signals that the current session was forcibly terminated (second 401).
/// Login screen listens to this and shows a snackbar before the user sees
/// the login form.
///
/// Copied from [SessionTerminated].
@ProviderFor(SessionTerminated)
final sessionTerminatedProvider =
    AutoDisposeNotifierProvider<SessionTerminated, bool>.internal(
  SessionTerminated.new,
  name: r'sessionTerminatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionTerminatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionTerminated = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
