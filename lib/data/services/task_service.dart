import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_todo_app/data/models/task_model.dart';
import 'package:flutter_todo_app/core/constants/app_config.dart';

class TaskException implements Exception {
  final String message;
  const TaskException(this.message);
  @override
  String toString() => message;
}

class TaskService {
  Future<List<TaskModel>> fetchTasks({
    required String userId,
    required String idToken,
  }) async {
    final url = AppConfig.tasksUrl(userId, idToken);
    final response = await http.get(Uri.parse(url));
    _handleHttpError(response);

    final data = jsonDecode(response.body);
    if (data == null) return [];

    final tasksMap = data as Map<String, dynamic>;
    final tasks = tasksMap.entries
        .map((e) =>
            TaskModel.fromJson(e.key, e.value as Map<String, dynamic>))
        .toList();

    tasks.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    return tasks;
  }

  Future<TaskModel> addTask({
    required String userId,
    required String idToken,
    required String title,
  }) async {
    final url = AppConfig.tasksUrl(userId, idToken);
    final task = TaskModel(
      id: '',
      title: title.trim(),
      completed: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );
    _handleHttpError(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final generatedId = body['name'] as String;
    return task.copyWith(id: generatedId);
  }

  Future<TaskModel> updateTaskTitle({
    required String userId,
    required String idToken,
    required TaskModel task,
    required String newTitle,
  }) async {
    final url = AppConfig.taskUrl(userId, task.id, idToken);
    final updated = task.copyWith(title: newTitle.trim());

    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': updated.title}),
    );
    _handleHttpError(response);
    return updated;
  }

  Future<TaskModel> toggleCompletion({
    required String userId,
    required String idToken,
    required TaskModel task,
  }) async {
    final url = AppConfig.taskUrl(userId, task.id, idToken);
    final updated = task.copyWith(completed: !task.completed);

    final response = await http.patch(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'completed': updated.completed}),
    );
    _handleHttpError(response);
    return updated;
  }

  Future<void> deleteTask({
    required String userId,
    required String idToken,
    required String taskId,
  }) async {
    final url = AppConfig.taskUrl(userId, taskId, idToken);
    final response = await http.delete(Uri.parse(url));
    _handleHttpError(response);
  }

  void _handleHttpError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    switch (response.statusCode) {
      case 401:
        throw const TaskException('Unauthorized. Please log in again.');
      case 403:
        throw const TaskException('Permission denied.');
      case 404:
        throw const TaskException('Task not found.');
      default:
        throw TaskException(
            'Network error (${response.statusCode}). Please try again.');
    }
  }
}