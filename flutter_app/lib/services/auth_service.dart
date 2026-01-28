import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  AuthService() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token != null) {
      _apiService.setToken(token);
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<void> login(String username, String password) async {
    try {
      final token = await _apiService.login(username, password);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      
      _apiService.setToken(token);
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      final token = await _apiService.register(username, email, password);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      
      _apiService.setToken(token);
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    
    _apiService.setToken(null);
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}