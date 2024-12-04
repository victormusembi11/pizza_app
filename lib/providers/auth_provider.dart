import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _role;
  String? _userId;
  String? _email;
  String? _name;

  bool get isAuthenticated => _isAuthenticated;
  String? get role => _role;
  String? get userId => _userId;
  String? get email => _email;
  String? get name => _name;

  void login(String id, String email, String name, String role) {
    _isAuthenticated = true;
    _userId = id;
    _email = email;
    _name = name;
    _role = role;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _userId = null;
    _email = null;
    _name = null;
    _role = null;
    notifyListeners();
  }
}
