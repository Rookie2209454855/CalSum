import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/food.dart';
import '../models/exercise.dart';

class ExportService {
  Future<String> exportToCsv(List<Food> foods, List<Exercise> exercises) async {
    final csvContent = StringBuffer();
    
    // 添加CSV头部
    csvContent.writeln('类型,名称,重量,热量,组数,完成状态,日期');
    
    // 添加食物记录
    for (final food in foods) {
      csvContent.writeln('食物,${food.name},${food.weight},${food.calories},,,${food.date.toString().split(' ')[0]}');
    }
    
    // 添加运动记录
    for (final exercise in exercises) {
      csvContent.writeln('运动,${exercise.name},,${exercise.caloriesBurned},${exercise.sets},${exercise.completed},${exercise.date.toString().split(' ')[0]}');
    }
    
    return csvContent.toString();
  }

  Future<String> exportToJson(List<Food> foods, List<Exercise> exercises) async {
    final data = {
      'foods': foods.map((food) => food.toJson()).toList(),
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'exported_at': DateTime.now().toIso8601String(),
    };
    
    return jsonEncode(data);
  }

  Future<void> saveToFile(String content, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content);
    
    // 复制到公共下载目录
    final downloadsDirectory = await getDownloadsDirectory();
    if (downloadsDirectory != null) {
      final publicFile = File('${downloadsDirectory.path}/$filename');
      await publicFile.writeAsString(content);
    }
  }

  Future<void> shareFile(String content, String filename) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content);
    
    // 使用分享功能
    await Clipboard.setData(ClipboardData(text: content));
  }
}