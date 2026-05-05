import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API endpoint
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access_token'];
        // Store token securely (using shared_preferences or flutter_secure_storage)
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid credentials';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _token = null;
    // Clear stored token
    notifyListeners();
  }

  String? get token => _token;
}