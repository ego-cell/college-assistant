import 'package:flutter_test/flutter_test.dart';
import 'package:college_pulse/features/tasks/models/task_category.dart';
import 'package:college_pulse/features/tasks/models/task_item.dart';
import 'package:college_pulse/features/timetable/models/slot_type.dart';

void main() {
  group('TaskItem Model Tests', () {
    test('Correctly identifies urgent tasks (< 48 hours to due date)', () {
      final now = DateTime.now();
      final urgentTask = TaskItem(
        id: 't1',
        title: 'Quiz 1',
        category: TaskCategory.quiz,
        createdAt: now,
        dueDate: now.add(const Duration(hours: 24)),
      );

      final notUrgentTask = TaskItem(
        id: 't2',
        title: 'Final Project',
        category: TaskCategory.project,
        createdAt: now,
        dueDate: now.add(const Duration(days: 5)),
      );

      expect(urgentTask.isUrgent, isTrue);
      expect(notUrgentTask.isUrgent, isFalse);
    });

    test('Correctly identifies overdue expired tasks', () {
      final now = DateTime.now();
      final overdueTask = TaskItem(
        id: 't3',
        title: 'Late Sheet',
        category: TaskCategory.assignment,
        createdAt: now.subtract(const Duration(days: 3)),
        dueDate: now.subtract(const Duration(hours: 2)),
      );

      expect(overdueTask.isOverdue, isTrue);
      expect(overdueTask.isActive, isFalse);
    });

    test('Serialization to and from JSON preserves all fields including slotType', () {
      final now = DateTime.now();
      final original = TaskItem(
        id: 't4',
        courseId: 'c_101',
        courseName: 'Algorithms',
        slotType: SlotType.section,
        title: 'Sheet 3 Questions',
        description: 'Solve problems 1 through 5',
        category: TaskCategory.assignment,
        createdAt: now,
        dueDate: now.add(const Duration(days: 2)),
        reminderOffsetsInMinutes: [1440, 120],
        isCompleted: false,
        isArchived: false,
      );

      final json = original.toJson();
      final restored = TaskItem.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.courseName, original.courseName);
      expect(restored.slotType, original.slotType);
      expect(restored.title, original.title);
      expect(restored.category, original.category);
      expect(restored.reminderOffsetsInMinutes, original.reminderOffsetsInMinutes);
    });
  });
}
