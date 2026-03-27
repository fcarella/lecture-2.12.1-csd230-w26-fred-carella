import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthProvider with ChangeNotifier {
  String? _token;

  String? get token => _token;
  bool get isAuthenticated => _token != null && !JwtDecoder.isExpired(_token!);
  
  bool get isAdmin {
    if (_token == null) return false;
    try {
      Map<String, dynamic> payload = JwtDecoder.decode(_token!);
      List<dynamic> roles = payload['roles'] ?? [];
      return roles.contains('ROLE_ADMIN');
    } catch (e) {
      return false;
    }
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    if (_token != null && JwtDecoder.isExpired(_token!)) {
      _token = null;
      prefs.remove('jwt_token');
    }
    notifyListeners();
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    _token = token;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _token = null;
    notifyListeners();
  }
}
