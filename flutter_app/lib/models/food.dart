class Food {
  final String id;
  final String name;
  final double weight;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String mealType;
  final DateTime date;
  final DateTime createdAt;

  Food({
    required this.id,
    required this.name,
    required this.weight,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    required this.mealType,
    required this.date,
    required this.createdAt,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      mealType: json['meal_type'] ?? '早餐',
      date: DateTime.parse(json['date'] ?? DateTime.now().toString()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'meal_type': mealType,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}