import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_provider.g.dart';

/// Signals that the current session was forcibly terminated (second 401).
/// Login screen listens to this and shows a snackbar before the user sees
/// the login form.
@riverpod
class SessionTerminated extends _$SessionTerminated {
  @override
  bool build() => false;

  void terminate() => state = true;
  void reset() => state = false;
}
