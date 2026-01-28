import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/food_service.dart';
import '../services/exercise_service.dart';
import '../models/food.dart';
import '../models/exercise.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final FoodService _foodService = FoodService();
  final ExerciseService _exerciseService = ExerciseService();
  List<Food> _foods = [];
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final foods = await _foodService.getFoods();
      final exercises = await _exerciseService.getExercises();
      setState(() {
        _foods = foods;
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('加载数据失败: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  double get _totalCaloriesIntake {
    return _foods
        .where((food) => _isSameDay(food.date, _selectedDate))
        .fold(0.0, (sum, food) => sum + food.calories);
  }

  double get _totalCaloriesBurned {
    return _exercises
        .where((exercise) => _isSameDay(exercise.date, _selectedDate))
        .fold(0.0, (sum, exercise) => sum + exercise.caloriesBurned);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 日期选择器
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '数据统计',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() {
                                  _selectedDate = date;
                                });
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  _selectedDate.toString().split(' ')[0],
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.calendar_today),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 热量概览卡片
                  Row(
                    children: [
                      Expanded(
                        child: _buildCalorieCard(
                          '摄入热量',
                          _totalCaloriesIntake,
                          'kcal',
                          Colors.green,
                          Icons.restaurant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCalorieCard(
                          '消耗热量',
                          _totalCaloriesBurned,
                          'kcal',
                          Colors.orange,
                          Icons.fitness_center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 净热量卡片
                  Card(
                    color: _totalCaloriesIntake - _totalCaloriesBurned > 0
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '净热量',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                _totalCaloriesIntake - _totalCaloriesBurned > 0
                                    ? '摄入 > 消耗'
                                    : '消耗 > 摄入',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          Text(
                            '${(_totalCaloriesIntake - _totalCaloriesBurned).toStringAsFixed(0)} kcal',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: _totalCaloriesIntake - _totalCaloriesBurned > 0
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 食物记录列表
                  Text(
                    '今日食物记录',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildFoodList(),
                  const SizedBox(height: 16),
                  // 运动记录列表
                  Text(
                    '今日运动记录',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildExerciseList(),
                ],
              ),
            ),
    );
  }

  Widget _buildCalorieCard(
      String title, double value, String unit, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                      Text(
                        '${value.toStringAsFixed(0)} $unit',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodList() {
    final todayFoods = _foods
        .where((food) => _isSameDay(food.date, _selectedDate))
        .toList();

    if (todayFoods.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('暂无今日食物记录'),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: todayFoods
            .map((food) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant, color: Colors.green),
                  ),
                  title: Text(food.name),
                  subtitle: Text('${food.weight}g • ${food.mealType}'),
                  trailing: Text('${food.calories} kcal'),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildExerciseList() {
    final todayExercises = _exercises
        .where((exercise) => _isSameDay(exercise.date, _selectedDate))
        .toList();

    if (todayExercises.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('暂无今日运动记录'),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: todayExercises
            .map((exercise) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fitness_center, color: Colors.orange),
                  ),
                  title: Text(exercise.name),
                  subtitle: Text('${exercise.sets}组 • ${exercise.completed ? '已完成' : '未完成'}'),
                  trailing: Text('${exercise.caloriesBurned} kcal'),
                ))
            .toList(),
      ),
    );
  }
}