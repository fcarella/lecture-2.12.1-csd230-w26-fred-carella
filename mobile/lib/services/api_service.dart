import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';

class ApiService {
  final AuthProvider authProvider;
  
  // 10.0.2.2 maps to localhost for Android Emulators. Use 127.0.0.1 for iOS.
  static String get baseUrl {
    if (Platform.isAndroid) return 'http://192.168.0.199:8080/api/rest';
    return 'http://192.168.0.199:8080/api/rest';
  }

  ApiService(this.authProvider);

  Future<Map<String, String>> _getHeaders() async {
    return {
      'Content-Type': 'application/json',
      if (authProvider.token != null) 'Authorization': 'Bearer ${authProvider.token}',
    };
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      authProvider.logout(); // Auto-logout if token is expired/invalid
      throw Exception('Session expired. Please login again.');
    }
    if (response.statusCode >= 400) {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: await _getHeaders());
    _checkResponse(response);
    return jsonDecode(response.body);
  }

  Future<dynamic> post(String endpoint, [Map<String, dynamic>? body]) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );
    _checkResponse(response);
    if (response.body.isNotEmpty) return jsonDecode(response.body);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    _checkResponse(response);
    return jsonDecode(response.body);
  }

  Future<void> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint'), headers: await _getHeaders());
    _checkResponse(response);
  }
}
