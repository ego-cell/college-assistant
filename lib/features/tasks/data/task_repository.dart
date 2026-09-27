import 'package:college_pulse/core/services/storage_service.dart';
import '../models/task_item.dart';

class TaskRepository {
  final StorageService _storageService;

  TaskRepository({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  Future<List<TaskItem>> getAllTasks() async {
    return await _storageService.loadTasks();
  }

  Future<void> saveTask(TaskItem task) async {
    final all = await getAllTasks();
    final index = all.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      all[index] = task;
    } else {
      all.add(task);
    }
    await _storageService.saveTasks(all);
  }

  Future<void> deleteTask(String taskId) async {
    final all = await getAllTasks();
    all.removeWhere((t) => t.id == taskId);
    await _storageService.saveTasks(all);
  }

  Future<void> toggleTaskComplete(String taskId) async {
    final all = await getAllTasks();
    final index = all.indexWhere((t) => t.id == taskId);
    if (index >= 0) {
      final item = all[index];
      all[index] = item.copyWith(isCompleted: !item.isCompleted);
      await _storageService.saveTasks(all);
    }
  }

  Future<void> saveAllTasks(List<TaskItem> tasks) async {
    await _storageService.saveTasks(tasks);
  }
}

