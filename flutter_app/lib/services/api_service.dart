import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/food.dart';
import '../models/exercise.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _authHeaders {
    final headers = Map<String, String>.from(ApiService.headers);
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // 用户认证相关API
  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: headers,
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('登录失败: ${response.statusCode}');
    }
  }

  Future<String> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('注册失败: ${response.statusCode}');
    }
  }

  // 食物记录相关API
  Future<List<Food>> getFoods() async {
    final response = await http.get(
      Uri.parse('$baseUrl/foods'),
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((item) => Food.fromJson(item)).toList();
    } else {
      throw Exception('获取食物记录失败');
    }
  }

  Future<Food> addFood(Food food) async {
    final response = await http.post(
      Uri.parse('$baseUrl/foods'),
      headers: _authHeaders,
      body: jsonEncode(food.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Food.fromJson(data);
    } else {
      throw Exception('添加食物记录失败');
    }
  }

  Future<void> updateFood(String id, Food food) async {
    final response = await http.put(
      Uri.parse('$baseUrl/foods/$id'),
      headers: _authHeaders,
      body: jsonEncode(food.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('更新食物记录失败');
    }
  }

  Future<void> deleteFood(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/foods/$id'),
      headers: _authHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('删除食物记录失败');
    }
  }

  // 运动记录相关API
  Future<List<Exercise>> getExercises() async {
    final response = await http.get(
      Uri.parse('$baseUrl/exercises'),
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((item) => Exercise.fromJson(item)).toList();
    } else {
      throw Exception('获取运动记录失败');
    }
  }

  Future<Exercise> addExercise(Exercise exercise) async {
    final response = await http.post(
      Uri.parse('$baseUrl/exercises'),
      headers: _authHeaders,
      body: jsonEncode(exercise.toJson()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Exercise.fromJson(data);
    } else {
      throw Exception('添加运动记录失败');
    }
  }

  Future<void> updateExercise(String id, Exercise exercise) async {
    final response = await http.put(
      Uri.parse('$baseUrl/exercises/$id'),
      headers: _authHeaders,
      body: jsonEncode(exercise.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('更新运动记录失败');
    }
  }

  Future<void> deleteExercise(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/exercises/$id'),
      headers: _authHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('删除运动记录失败');
    }
  }
}