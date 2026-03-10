import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_todo_app/data/models/auth_model.dart';
import 'package:flutter_todo_app/core/constants/app_config.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  Future<AuthModel> signUp({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(AppConfig.signUpUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    _throwIfError(body);
    return AuthModel.fromJson(body);
  }

  Future<AuthModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(AppConfig.signInUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    _throwIfError(body);
    return AuthModel.fromJson(body);
  }

  Future<AuthModel> refreshToken(AuthModel current) async {
    final response = await http.post(
      Uri.parse(AppConfig.refreshTokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'grant_type=refresh_token&refresh_token=${current.refreshToken}',
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body.containsKey('error')) {
      throw const AuthException('Session expired. Please log in again.');
    }
    final expiresIn =
        int.tryParse(body['expires_in']?.toString() ?? '3600') ?? 3600;
    return current.copyWith(
      idToken: body['id_token'] as String,
      expiresAt: DateTime.now()
          .add(Duration(seconds: expiresIn))
          .millisecondsSinceEpoch,
    );
  }

  void _throwIfError(Map<String, dynamic> body) {
    if (!body.containsKey('error')) return;
    final code = (body['error'] as Map)['message'] as String? ?? 'UNKNOWN';
    throw AuthException(_mapErrorCode(code));
  }

  String _mapErrorCode(String code) {
    switch (code) {
      case 'EMAIL_EXISTS':
        return 'An account with this email already exists.';
      case 'EMAIL_NOT_FOUND':
        return 'No account found with this email.';
      case 'INVALID_PASSWORD':
        return 'Incorrect password. Please try again.';
      case 'USER_DISABLED':
        return 'This account has been disabled.';
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'Too many failed attempts. Please try later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}