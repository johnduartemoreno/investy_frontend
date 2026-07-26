import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;

  /// True only right after a Google Sign-In that created a brand-new account,
  /// so the UI can collect the display currency before the user lands on Home
  /// (F5). Transient, client-only — never persisted or serialized.
  final bool isNewUser;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.isNewUser = false,
  });

  @override
  List<Object?> get props => [id, email, name, isNewUser];
}
