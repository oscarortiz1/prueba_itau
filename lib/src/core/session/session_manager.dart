import 'package:flutter/foundation.dart';

import '../../features/auth/domain/entities/auth_user.dart';

class SessionManager extends ChangeNotifier {
  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;

  String? get token => _currentUser?.token;

  bool get isAuthenticated => _currentUser?.token != null;

  void updateUser(AuthUser? user) {
    _currentUser = user;
    notifyListeners();
  }

  void clear() {
    updateUser(null);
  }
}
