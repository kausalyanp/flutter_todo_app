import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_todo_app/data/models/auth_model.dart';
import 'package:flutter_todo_app/data/services/auth_service.dart';
import 'package:flutter_todo_app/data/services/user_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService = UserService();

  AuthProvider(this._authService) {
    _tryAutoLogin();
  }

  AuthModel? _user;
  AuthStatus _status = AuthStatus.uninitialized;
  String? _errorMessage;

  AuthModel? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get userId => _user?.localId;
  String? get idToken => _user?.idToken;
  String? get userEmail => _user?.email;

  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('auth_data');
    if (stored == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      final json = jsonDecode(stored) as Map<String, dynamic>;
      var auth = AuthModel.fromStoredJson(json);
      if (auth.isExpired) {
        auth = await _authService.refreshToken(auth);
        await _persistAuth(auth);
      }
      _user = auth;
      _status = AuthStatus.authenticated;
    } catch (_) {
      await _clearPersistedAuth();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final auth =
          await _authService.signUp(email: email, password: password);
      await _setAuthenticated(auth);

      // ── Save login status to database ──────────────────────────
      await _userService.setLoginStatus(
        userId: auth.localId,
        idToken: auth.idToken,
        email: auth.email,
        isLoggedIn: true,
      );

      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final auth =
          await _authService.signIn(email: email, password: password);
      await _setAuthenticated(auth);

      // ── Save login status to database ──────────────────────────
      await _userService.setLoginStatus(
        userId: auth.localId,
        idToken: auth.idToken,
        email: auth.email,
        isLoggedIn: true,
      );

      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  Future<void> signOut() async {
    // ── Set isLoggedIn to false before clearing session ───────────
    if (_user != null) {
      await _userService.setLoginStatus(
        userId: _user!.localId,
        idToken: _user!.idToken,
        email: _user!.email,
        isLoggedIn: false,
      );
    }

    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    await _clearPersistedAuth();
    notifyListeners();
  }

  Future<String?> getFreshToken() async {
    if (_user == null) return null;
    if (!_user!.isExpired) return _user!.idToken;
    try {
      final refreshed = await _authService.refreshToken(_user!);
      _user = refreshed;
      await _persistAuth(refreshed);
      notifyListeners();
      return refreshed.idToken;
    } catch (_) {
      await signOut();
      return null;
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _setAuthenticated(AuthModel auth) async {
    _user = auth;
    _status = AuthStatus.authenticated;
    _errorMessage = null;
    await _persistAuth(auth);
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _persistAuth(AuthModel auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_data', jsonEncode(auth.toJson()));
  }

  Future<void> _clearPersistedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_data');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}