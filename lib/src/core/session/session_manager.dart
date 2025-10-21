import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/models/auth_user_model.dart';
import '../../features/auth/domain/entities/auth_user.dart';

class SessionManager extends ChangeNotifier {
  SessionManager({required SharedPreferences prefs}) : _prefs = prefs;

  static const _storageKey = 'session_manager.current_user';

  final SharedPreferences _prefs;

  AuthUser? _currentUser;
  bool _isInitialized = false;

  AuthUser? get currentUser => _currentUser;

  String? get token => _currentUser?.token;

  bool get isAuthenticated => _currentUser?.token != null;

  bool get isInitialized => _isInitialized;

  Future<void> restore() async {
    final raw = _prefs.getString(_storageKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final user = AuthUserModel.fromJson(decoded).toEntity();
        _currentUser = user;
      } catch (_) {
        await _prefs.remove(_storageKey);
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> updateUser(AuthUser? user) async {
    _currentUser = user;

    if (user == null) {
      await _prefs.remove(_storageKey);
    } else {
      final model = AuthUserModel.fromEntity(user);
      await _prefs.setString(_storageKey, jsonEncode(model.toJson()));
    }

    notifyListeners();
  }

  Future<void> clear() => updateUser(null);
}
