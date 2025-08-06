import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _email;

  String? get token => _token;
  String? get email => _email;

  void login(String email, String token) {
    _email = email;
    _token = token;
    notifyListeners();
  }

  void logout() {
    _email = null;
    _token = null;
    notifyListeners();
  }

  bool get isAuthenticated => _token != null;
}