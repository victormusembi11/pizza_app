import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _role;

  bool get isAuthenticated => _isAuthenticated;
  String? get role => _role;

  void login(String role) {
    _isAuthenticated = true;
    _role = role;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _role = null;
    notifyListeners();
  }
}
