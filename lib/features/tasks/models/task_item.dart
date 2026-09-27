import 'package:flutter/material.dart';
import 'package:college_pulse/core/constants/app_constants.dart';
import 'package:college_pulse/core/utils/date_time_utils.dart';
import 'package:college_pulse/features/timetable/models/slot_type.dart';
import 'task_category.dart';

class TaskItem {
  final String id;
  final String? courseId;
  final String? courseName;
  final SlotType? slotType; // lecture, section, or lab
  final String title;
  final String? description;
  final TaskCategory category;
  final DateTime createdAt;
  final DateTime dueDate;
  final List<int> reminderOffsetsInMinutes; // e.g., [2880, 1440, 120]
  final bool isCompleted;
  final bool isArchived;

  const TaskItem({
    required this.id,
    this.courseId,
    this.courseName,
    this.slotType,
    required this.title,
    this.description,
    required this.category,
    required this.createdAt,
    required this.dueDate,
    this.reminderOffsetsInMinutes = const [
      AppConstants.reminder24h,
      AppConstants.reminder2h,
    ],
    this.isCompleted = false,
    this.isArchived = false,
  });

  bool get isPersonal => category == TaskCategory.personal || courseId == null;

  bool get isOverdue {
    if (isCompleted) return false;
    return DateTime.now().isAfter(dueDate);
  }

  bool get isUrgent {
    if (isCompleted || isOverdue) return false;
    final diff = dueDate.difference(DateTime.now());
    return diff.inMilliseconds <= AppConstants.urgentThreshold.inMilliseconds && !diff.isNegative;
  }

  /// Whether task should appear in active upcoming lists
  bool get isActive {
    return !isCompleted && !isArchived && !isOverdue;
  }

  String formattedCountdown({bool isArabic = true}) {
    return DateTimeUtils.formatCountdown(dueDate, isArabic: isArabic);
  }

  String formattedDueDate({bool isArabic = true}) {
    return DateTimeUtils.formatSmartDate(dueDate, isArabic: isArabic);
  }

  String? fullCourseLabel(BuildContext context) {
    if (courseName == null || courseName!.isEmpty) return null;
    if (slotType != null) {
      return '$courseName • ${slotType!.localizedName(context)}';
    }
    return courseName;
  }

  TaskItem copyWith({
    String? id,
    String? courseId,
    String? courseName,
    SlotType? slotType,
    String? title,
    String? description,
    TaskCategory? category,
    DateTime? createdAt,
    DateTime? dueDate,
    List<int>? reminderOffsetsInMinutes,
    bool? isCompleted,
    bool? isArchived,
  }) {
    return TaskItem(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      slotType: slotType ?? this.slotType,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      reminderOffsetsInMinutes:
          reminderOffsetsInMinutes ?? this.reminderOffsetsInMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'slotType': slotType?.name,
      'title': title,
      'description': description,
      'category': category.name,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'reminderOffsetsInMinutes': reminderOffsetsInMinutes,
      'isCompleted': isCompleted,
      'isArchived': isArchived,
    };
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    SlotType? parsedSlotType;
    if (json['slotType'] != null) {
      try {
        parsedSlotType = SlotType.values.firstWhere(
          (e) => e.name == json['slotType'],
        );
      } catch (_) {
        parsedSlotType = null;
      }
    }

    return TaskItem(
      id: json['id'] as String,
      courseId: json['courseId'] as String?,
      courseName: json['courseName'] as String?,
      slotType: parsedSlotType,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: TaskCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TaskCategory.assignment,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      reminderOffsetsInMinutes: (json['reminderOffsetsInMinutes'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [AppConstants.reminder24h, AppConstants.reminder2h],
      isCompleted: json['isCompleted'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
    );
  }
}
