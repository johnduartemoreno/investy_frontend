import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage "Remember email" functionality
class EmailStorageService {
  static const String _emailKey = 'remembered_email';

  /// Save email to local storage
  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  /// Get remembered email from local storage
  Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Clear remembered email from local storage
  Future<void> clearEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
  }
}
