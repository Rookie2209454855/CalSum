import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/food_service.dart';
import '../models/food.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final FoodService _foodService = FoodService();
  List<Food> _foods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    try {
      final foods = await _foodService.getFoods();
      setState(() {
        _foods = foods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('加载食物记录失败: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _foods.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无食物记录',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击下方+按钮添加食物记录',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _foods.length,
                  itemBuilder: (context, index) {
                    final food = _foods[index];
                    return _buildFoodItem(food);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFoodDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFoodItem(Food food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.restaurant,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(food.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${food.weight}g • ${food.mealType}'),
            Text('${food.calories} kcal'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditFoodDialog(food),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _deleteFood(food.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFoodDialog() {
    showDialog(
      context: context,
      builder: (context) => FoodFormDialog(
        onSave: (food) async {
          try {
            await _foodService.addFood(food);
            _loadFoods();
            Navigator.pop(context);
          } catch (e) {
            _showErrorSnackBar('添加食物失败: $e');
          }
        },
      ),
    );
  }

  void _showEditFoodDialog(Food food) {
    showDialog(
      context: context,
      builder: (context) => FoodFormDialog(
        food: food,
        onSave: (updatedFood) async {
          try {
            await _foodService.updateFood(food.id, updatedFood);
            _loadFoods();
            Navigator.pop(context);
          } catch (e) {
            _showErrorSnackBar('更新食物失败: $e');
          }
        },
      ),
    );
  }

  Future<void> _deleteFood(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条食物记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _foodService.deleteFood(id);
        _loadFoods();
      } catch (e) {
        _showErrorSnackBar('删除食物失败: $e');
      }
    }
  }
}

class FoodFormDialog extends StatefulWidget {
  final Food? food;
  final Function(Food) onSave;

  const FoodFormDialog({
    super.key,
    this.food,
    required this.onSave,
  });

  @override
  State<FoodFormDialog> createState() => _FoodFormDialogState();
}

class _FoodFormDialogState extends State<FoodFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _caloriesController = TextEditingController();
  String _mealType = '早餐';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.food != null) {
      _nameController.text = widget.food!.name;
      _weightController.text = widget.food!.weight.toString();
      _caloriesController.text = widget.food!.calories.toString();
      _mealType = widget.food!.mealType;
      _selectedDate = widget.food!.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 500 : 400,
          maxHeight: isDesktop ? 700 : 600,
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.food == null ? '添加食物' : '编辑食物',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '食物名称',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入食物名称';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: '重量 (g)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入重量';
                        }
                        if (double.tryParse(value) == null) {
                          return '请输入有效的数字';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _caloriesController,
                      decoration: InputDecoration(
                        labelText: '热量 (kcal)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入热量';
                        }
                        if (double.tryParse(value) == null) {
                          return '请输入有效的数字';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _mealType,
                      decoration: InputDecoration(
                        labelText: '餐别',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: ['早餐', '午餐', '晚餐', '加餐']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _mealType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
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
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: '日期',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedDate.toString().split(' ')[0]),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _saveFood,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveFood() {
    if (_formKey.currentState!.validate()) {
      final food = Food(
        id: widget.food?.id ?? '',
        name: _nameController.text,
        weight: double.parse(_weightController.text),
        calories: double.parse(_caloriesController.text),
        mealType: _mealType,
        date: _selectedDate,
        createdAt: widget.food?.createdAt ?? DateTime.now(),
      );
      widget.onSave(food);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }
}