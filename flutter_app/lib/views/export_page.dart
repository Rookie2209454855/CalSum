import 'package:flutter/material.dart';
import '../services/food_service.dart';
import '../services/exercise_service.dart';
import '../services/export_service.dart';
import '../models/food.dart';
import '../models/exercise.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final FoodService _foodService = FoodService();
  final ExerciseService _exerciseService = ExerciseService();
  final ExportService _exportService = ExportService();
  List<Food> _foods = [];
  List<Exercise> _exercises = [];
  bool _isLoading = true;
  bool _exporting = false;

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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _exportToCsv() async {
    setState(() {
      _exporting = true;
    });

    try {
      final csvContent = await _exportService.exportToCsv(_foods, _exercises);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'calsum_data_$timestamp.csv';
      
      await _exportService.saveToFile(csvContent, filename);
      
      _showSuccessSnackBar('数据已导出到文件: $filename');
    } catch (e) {
      _showErrorSnackBar('导出失败: $e');
    } finally {
      setState(() {
        _exporting = false;
      });
    }
  }

  Future<void> _exportToJson() async {
    setState(() {
      _exporting = true;
    });

    try {
      final jsonContent = await _exportService.exportToJson(_foods, _exercises);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'calsum_data_$timestamp.json';
      
      await _exportService.saveToFile(jsonContent, filename);
      
      _showSuccessSnackBar('数据已导出到文件: $filename');
    } catch (e) {
      _showErrorSnackBar('导出失败: $e');
    } finally {
      setState(() {
        _exporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据导出'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 数据统计卡片
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '数据概览',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem('食物记录', _foods.length, Icons.restaurant, Colors.green),
                              _buildStatItem('运动记录', _exercises.length, Icons.fitness_center, Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 导出选项
                  Text(
                    '导出格式',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildExportOption(
                    'CSV格式',
                    '适合电子表格软件导入',
                    Icons.table_chart,
                    Colors.blue,
                    _exportToCsv,
                  ),
                  const SizedBox(height: 12),
                  _buildExportOption(
                    'JSON格式',
                    '适合程序处理和备份',
                    Icons.code,
                    Colors.purple,
                    _exportToJson,
                  ),
                  const SizedBox(height: 24),
                  // 导出说明
                  Card(
                    color: Colors.grey[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '导出说明',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '导出的数据文件将保存在设备的下载目录中，包含所有食物和运动记录。',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String title, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }

  Widget _buildExportOption(
      String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: _exporting ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
              if (_exporting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}