import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_todo_app/core/constants/app_config.dart';

class UserService {

  // ── Save login status and email when user logs in ─────────────────
  Future<void> setLoginStatus({
    required String userId,
    required String idToken,
    required String email,
    required bool isLoggedIn,
  }) async {
    final url = AppConfig.userStatusUrl(userId, idToken);

    await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'isLoggedIn': isLoggedIn,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

  // ── Fetch user status from database ──────────────────────────────
  Future<Map<String, dynamic>?> getUserStatus({
    required String userId,
    required String idToken,
  }) async {
    final url = AppConfig.userStatusUrl(userId, idToken);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) {
        return data as Map<String, dynamic>;
      }
    }
    return null;
  }
}