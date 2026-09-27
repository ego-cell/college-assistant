import 'package:flutter/material.dart';
import 'package:college_pulse/core/utils/date_time_utils.dart';
import 'slot_type.dart';

class CourseSlot {
  final String id;
  final String courseName;
  final String? instructorName;
  final String? room;
  final int dayOfWeek; // 1 = Monday ... 7 = Sunday
  final int startTimeMinutes; // minutes from 00:00 (e.g., 600 = 10:00 AM)
  final int endTimeMinutes; // minutes from 00:00 (e.g., 690 = 11:30 AM)
  final SlotType slotType;
  final int colorHex;

  const CourseSlot({
    required this.id,
    required this.courseName,
    this.instructorName,
    this.room,
    required this.dayOfWeek,
    required this.startTimeMinutes,
    required this.endTimeMinutes,
    required this.slotType,
    required this.colorHex,
  });

  TimeOfDay get startTime => DateTimeUtils.minutesToTimeOfDay(startTimeMinutes);
  TimeOfDay get endTime => DateTimeUtils.minutesToTimeOfDay(endTimeMinutes);
  Color get color => Color(colorHex);
  String get formattedTimeRange =>
      DateTimeUtils.formatTimeRange(startTimeMinutes, endTimeMinutes);

  /// Checks if this slot is currently taking place based on current DateTime
  bool isOngoingAt(DateTime now) {
    if (now.weekday != dayOfWeek) return false;
    final currentMinutes = now.hour * 60 + now.minute;
    return currentMinutes >= startTimeMinutes && currentMinutes < endTimeMinutes;
  }

  /// Calculates percentage progress of the slot (0.0 to 1.0)
  double getProgress(DateTime now) {
    if (!isOngoingAt(now)) return 0.0;
    final currentMinutes = now.hour * 60 + now.minute;
    final totalDuration = endTimeMinutes - startTimeMinutes;
    if (totalDuration <= 0) return 1.0;
    final elapsed = currentMinutes - startTimeMinutes;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  /// Calculates remaining minutes in this slot
  int getRemainingMinutes(DateTime now) {
    if (!isOngoingAt(now)) return 0;
    final currentMinutes = now.hour * 60 + now.minute;
    return (endTimeMinutes - currentMinutes).clamp(0, 1440);
  }

  CourseSlot copyWith({
    String? id,
    String? courseName,
    String? instructorName,
    String? room,
    int? dayOfWeek,
    int? startTimeMinutes,
    int? endTimeMinutes,
    SlotType? slotType,
    int? colorHex,
  }) {
    return CourseSlot(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      instructorName: instructorName ?? this.instructorName,
      room: room ?? this.room,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTimeMinutes: startTimeMinutes ?? this.startTimeMinutes,
      endTimeMinutes: endTimeMinutes ?? this.endTimeMinutes,
      slotType: slotType ?? this.slotType,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseName': courseName,
      'instructorName': instructorName,
      'room': room,
      'dayOfWeek': dayOfWeek,
      'startTimeMinutes': startTimeMinutes,
      'endTimeMinutes': endTimeMinutes,
      'slotType': slotType.name,
      'colorHex': colorHex,
    };
  }

  factory CourseSlot.fromJson(Map<String, dynamic> json) {
    return CourseSlot(
      id: json['id'] as String,
      courseName: json['courseName'] as String,
      instructorName: json['instructorName'] as String?,
      room: json['room'] as String?,
      dayOfWeek: json['dayOfWeek'] as int,
      startTimeMinutes: json['startTimeMinutes'] as int,
      endTimeMinutes: json['endTimeMinutes'] as int,
      slotType: SlotType.values.firstWhere(
        (e) => e.name == json['slotType'],
        orElse: () => SlotType.lecture,
      ),
      colorHex: json['colorHex'] as int? ?? 0xFF2563EB,
    );
  }
}

