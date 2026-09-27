import 'package:flutter/material.dart';
import 'package:college_pulse/core/constants/app_constants.dart';
import 'package:college_pulse/core/services/notification_service.dart';
import '../data/task_repository.dart';
import '../models/task_category.dart';
import '../models/task_item.dart';

enum TaskScopeFilter {
  all,
  college,
  personal,
}

enum TaskStatusFilter {
  upcoming,
  archived,
  completed,
}

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;
  final NotificationService _notificationService;

  List<TaskItem> _tasks = [];
  bool _isLoading = true;

  TaskScopeFilter _scopeFilter = TaskScopeFilter.all;
  TaskStatusFilter _statusFilter = TaskStatusFilter.upcoming;

  TaskProvider({
    TaskRepository? repository,
    NotificationService? notificationService,
  })  : _repository = repository ?? TaskRepository(),
        _notificationService = notificationService ?? NotificationService() {
    loadTasks();
  }

  List<TaskItem> get allTasks => _tasks;
  bool get isLoading => _isLoading;
  TaskScopeFilter get scopeFilter => _scopeFilter;
  TaskStatusFilter get statusFilter => _statusFilter;

  // Active / Impending deliverables (due date in future, not completed, not archived)
  List<TaskItem> get activeTasks {
    return _tasks.where((t) => t.isActive).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Urgent tasks due in next 48 hours for Dashboard
  List<TaskItem> get urgentTasks {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (t.isCompleted || t.isArchived) return false;
      final diff = t.dueDate.difference(now);
      return !diff.isNegative && diff.inMilliseconds <= AppConstants.urgentThreshold.inMilliseconds;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  // Expired or explicitly archived tasks
  List<TaskItem> get archivedOrExpiredTasks {
    return _tasks.where((t) => !t.isCompleted && (t.isArchived || t.isOverdue)).toList()
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
  }

  // Completed tasks
  List<TaskItem> get completedTasks {
    return _tasks.where((t) => t.isCompleted).toList()
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));
  }

  // Filtered tasks for the Tasks screen based on current scope & status filter
  List<TaskItem> get filteredTasks {
    List<TaskItem> baseList;
    switch (_statusFilter) {
      case TaskStatusFilter.upcoming:
        baseList = activeTasks;
        break;
      case TaskStatusFilter.archived:
        baseList = archivedOrExpiredTasks;
        break;
      case TaskStatusFilter.completed:
        baseList = completedTasks;
        break;
    }

    switch (_scopeFilter) {
      case TaskScopeFilter.all:
        return baseList;
      case TaskScopeFilter.college:
        return baseList.where((t) => t.category != TaskCategory.personal).toList();
      case TaskScopeFilter.personal:
        return baseList.where((t) => t.category == TaskCategory.personal).toList();
    }
  }

  void setScopeFilter(TaskScopeFilter filter) {
    if (_scopeFilter != filter) {
      _scopeFilter = filter;
      notifyListeners();
    }
  }

  void setStatusFilter(TaskStatusFilter filter) {
    if (_statusFilter != filter) {
      _statusFilter = filter;
      notifyListeners();
    }
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _repository.getAllTasks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(TaskItem task) async {
    await _repository.saveTask(task);
    await _notificationService.scheduleTaskReminders(task);
    await loadTasks();
  }

  Future<void> updateTask(TaskItem task) async {
    await _repository.saveTask(task);
    if (task.isCompleted) {
      await _notificationService.cancelTaskNotifications(task.id);
    } else {
      await _notificationService.scheduleTaskReminders(task);
    }
    await loadTasks();
  }

  Future<void> toggleTaskCompleted(TaskItem task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updated);
  }

  Future<void> deleteTask(String taskId) async {
    await _notificationService.cancelTaskNotifications(taskId);
    await _repository.deleteTask(taskId);
    await loadTasks();
  }

  Future<void> setTasksDirectly(List<TaskItem> newTasks) async {
    _tasks = newTasks;
    notifyListeners();
  }
}

