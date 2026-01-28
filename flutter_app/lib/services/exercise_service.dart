import 'package:calsum_flutter/services/api_service.dart';
import '../models/exercise.dart';

class ExerciseService {
  final ApiService _apiService = ApiService();

  Future<List<Exercise>> getExercises() async {
    return await _apiService.getExercises();
  }

  Future<Exercise> addExercise(Exercise exercise) async {
    return await _apiService.addExercise(exercise);
  }

  Future<void> updateExercise(String id, Exercise exercise) async {
    await _apiService.updateExercise(id, exercise);
  }

  Future<void> deleteExercise(String id) async {
    await _apiService.deleteExercise(id);
  }
}