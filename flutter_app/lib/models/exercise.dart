class Exercise {
  final String id;
  final String name;
  final int sets;
  final bool completed;
  final double caloriesBurned;
  final DateTime date;
  final DateTime createdAt;

  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.completed,
    required this.caloriesBurned,
    required this.date,
    required this.createdAt,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sets: json['sets'] ?? 0,
      completed: json['completed'] ?? false,
      caloriesBurned: (json['calories_burned'] ?? 0).toDouble(),
      date: DateTime.parse(json['date'] ?? DateTime.now().toString()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'completed': completed,
      'calories_burned': caloriesBurned,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}