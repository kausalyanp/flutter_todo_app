import 'package:flutter/foundation.dart';

import '../data/models/task_model.dart';
import '../data/services/task_service.dart';
import 'auth_provider.dart';

enum TaskStatus { idle, loading, success, error }
enum TaskFilter { all, active, completed }

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;
  final AuthProvider _authProvider;

  TaskProvider(this._taskService, this._authProvider);

  List<TaskModel> _tasks = [];
  TaskStatus _status = TaskStatus.idle;
  String? _errorMessage;
  TaskFilter _filter = TaskFilter.all;

  TaskStatus get status => _status;
  String? get errorMessage => _errorMessage;
  TaskFilter get filter => _filter;
  bool get isLoading => _status == TaskStatus.loading;

  List<TaskModel> get tasks {
    switch (_filter) {
      case TaskFilter.active:
        return _tasks.where((t) => !t.completed).toList();
      case TaskFilter.completed:
        return _tasks.where((t) => t.completed).toList();
      case TaskFilter.all:
        return List.unmodifiable(_tasks);
    }
  }

  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.completed).length;
  int get activeCount => _tasks.where((t) => !t.completed).length;

  Future<void> fetchTasks() async {
    final (userId, idToken) = await _getCredentials();
    if (userId == null || idToken == null) return;

    _setStatus(TaskStatus.loading);
    try {
      final fetched = await _taskService.fetchTasks(
        userId: userId,
        idToken: idToken,
      );
      _tasks = fetched;
      _setStatus(TaskStatus.success);
    } on TaskException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Failed to load tasks. Check your connection.');
    }
  }

  Future<bool> addTask(String title) async {
    if (title.trim().isEmpty) return false;
    final (userId, idToken) = await _getCredentials();
    if (userId == null || idToken == null) return false;

    try {
      final created = await _taskService.addTask(
        userId: userId,
        idToken: idToken,
        title: title,
      );
      _tasks.insert(0, created);
      notifyListeners();
      return true;
    } on TaskException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Failed to add task.');
      return false;
    }
  }

  Future<bool> updateTaskTitle(TaskModel task, String newTitle) async {
    if (newTitle.trim().isEmpty || newTitle.trim() == task.title) return false;
    final (userId, idToken) = await _getCredentials();
    if (userId == null || idToken == null) return false;

    try {
      final updated = await _taskService.updateTaskTitle(
        userId: userId,
        idToken: idToken,
        task: task,
        newTitle: newTitle,
      );
      _replaceTask(updated);
      return true;
    } on TaskException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('Failed to update task.');
      return false;
    }
  }

  Future<void> toggleCompletion(TaskModel task) async {
    final (userId, idToken) = await _getCredentials();
    if (userId == null || idToken == null) return;

    _replaceTask(task.copyWith(completed: !task.completed));
    try {
      final updated = await _taskService.toggleCompletion(
        userId: userId,
        idToken: idToken,
        task: task,
      );
      _replaceTask(updated);
    } on TaskException catch (e) {
      _replaceTask(task);
      _setError(e.message);
    } catch (_) {
      _replaceTask(task);
      _setError('Failed to update task status.');
    }
  }

  Future<bool> deleteTask(String taskId) async {
    final (userId, idToken) = await _getCredentials();
    if (userId == null || idToken == null) return false;

    final original = List<TaskModel>.from(_tasks);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();

    try {
      await _taskService.deleteTask(
        userId: userId,
        idToken: idToken,
        taskId: taskId,
      );
      return true;
    } on TaskException catch (e) {
      _tasks = original;
      _setError(e.message);
      notifyListeners();
      return false;
    } catch (_) {
      _tasks = original;
      _setError('Failed to delete task.');
      notifyListeners();
      return false;
    }
  }

  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void reset() {
    _tasks = [];
    _status = TaskStatus.idle;
    _errorMessage = null;
    _filter = TaskFilter.all;
    notifyListeners();
  }

  Future<(String?, String?)> _getCredentials() async {
    final userId = _authProvider.userId;
    final idToken = await _authProvider.getFreshToken();
    return (userId, idToken);
  }

  void _replaceTask(TaskModel updated) {
    final idx = _tasks.indexWhere((t) => t.id == updated.id);
    if (idx != -1) {
      _tasks[idx] = updated;
      notifyListeners();
    }
  }

  void _setStatus(TaskStatus s) {
    _status = s;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    _status = TaskStatus.error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}