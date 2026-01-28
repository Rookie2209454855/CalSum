import 'package:calsum_flutter/services/api_service.dart';
import '../models/food.dart';

class FoodService {
  final ApiService _apiService = ApiService();

  Future<List<Food>> getFoods() async {
    return await _apiService.getFoods();
  }

  Future<Food> addFood(Food food) async {
    return await _apiService.addFood(food);
  }

  Future<void> updateFood(String id, Food food) async {
    await _apiService.updateFood(id, food);
  }

  Future<void> deleteFood(String id) async {
    await _apiService.deleteFood(id);
  }
}