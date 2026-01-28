import 'package:flutter/material.dart';
import '../services/exercise_service.dart';
import '../models/exercise.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final ExerciseService _exerciseService = ExerciseService();
  List<Exercise> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await _exerciseService.getExercises();
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('加载运动记录失败: $e');
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
          : _exercises.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无运动记录',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '点击下方+按钮添加运动记录',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return _buildExerciseItem(exercise);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExerciseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExerciseItem(Exercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.fitness_center,
            color: Colors.orange,
          ),
        ),
        title: Text(exercise.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${exercise.sets}组 • ${exercise.completed ? '已完成' : '未完成'}'),
            Text('${exercise.caloriesBurned} kcal'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _showEditExerciseDialog(exercise),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: () => _deleteExercise(exercise.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExerciseDialog() {
    showDialog(
      context: context,
      builder: (context) => ExerciseFormDialog(
        onSave: (exercise) async {
          try {
            await _exerciseService.addExercise(exercise);
            _loadExercises();
            Navigator.pop(context);
          } catch (e) {
            _showErrorSnackBar('添加运动失败: $e');
          }
        },
      ),
    );
  }

  void _showEditExerciseDialog(Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => ExerciseFormDialog(
        exercise: exercise,
        onSave: (updatedExercise) async {
          try {
            await _exerciseService.updateExercise(exercise.id, updatedExercise);
            _loadExercises();
            Navigator.pop(context);
          } catch (e) {
            _showErrorSnackBar('更新运动失败: $e');
          }
        },
      ),
    );
  }

  Future<void> _deleteExercise(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条运动记录吗？'),
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
        await _exerciseService.deleteExercise(id);
        _loadExercises();
      } catch (e) {
        _showErrorSnackBar('删除运动失败: $e');
      }
    }
  }
}

class ExerciseFormDialog extends StatefulWidget {
  final Exercise? exercise;
  final Function(Exercise) onSave;

  const ExerciseFormDialog({
    super.key,
    this.exercise,
    required this.onSave,
  });

  @override
  State<ExerciseFormDialog> createState() => _ExerciseFormDialogState();
}

class _ExerciseFormDialogState extends State<ExerciseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _setsController = TextEditingController();
  final _caloriesController = TextEditingController();
  bool _completed = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _nameController.text = widget.exercise!.name;
      _setsController.text = widget.exercise!.sets.toString();
      _caloriesController.text = widget.exercise!.caloriesBurned.toString();
      _completed = widget.exercise!.completed;
      _selectedDate = widget.exercise!.date;
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
                widget.exercise == null ? '添加运动' : '编辑运动',
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
                        labelText: '运动项目',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入运动项目';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _setsController,
                      decoration: InputDecoration(
                        labelText: '组数',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入组数';
                        }
                        if (int.tryParse(value) == null) {
                          return '请输入有效的数字';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _caloriesController,
                      decoration: InputDecoration(
                        labelText: '消耗热量 (kcal)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入消耗热量';
                        }
                        if (double.tryParse(value) == null) {
                          return '请输入有效的数字';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('是否完成:', style: Theme.of(context).textTheme.bodyMedium),
                          Row(
                            children: [
                              Text(_completed ? '是' : '否'),
                              const SizedBox(width: 8),
                              Switch(
                                value: _completed,
                                onChanged: (value) {
                                  setState(() {
                                    _completed = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
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
                    onPressed: _saveExercise,
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

  void _saveExercise() {
    if (_formKey.currentState!.validate()) {
      final exercise = Exercise(
        id: widget.exercise?.id ?? '',
        name: _nameController.text,
        sets: int.parse(_setsController.text),
        completed: _completed,
        caloriesBurned: double.parse(_caloriesController.text),
        date: _selectedDate,
        createdAt: widget.exercise?.createdAt ?? DateTime.now(),
      );
      widget.onSave(exercise);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }
}