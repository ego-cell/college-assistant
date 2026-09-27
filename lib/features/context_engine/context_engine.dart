import 'package:college_pulse/features/timetable/models/course_slot.dart';

class CurrentClassContext {
  final CourseSlot? activeSlot;
  final CourseSlot? nextSlotToday;
  final int minutesRemainingInActive;
  final double activeProgress; // 0.0 to 1.0
  final int minutesUntilNext;
  final DateTime evaluatedAt;

  const CurrentClassContext({
    this.activeSlot,
    this.nextSlotToday,
    this.minutesRemainingInActive = 0,
    this.activeProgress = 0.0,
    this.minutesUntilNext = 0,
    required this.evaluatedAt,
  });

  bool get hasActiveCourse => activeSlot != null;
  bool get hasNextCourseToday => nextSlotToday != null;

  static CurrentClassContext empty(DateTime now) {
    return CurrentClassContext(evaluatedAt: now);
  }
}

class ContextDetectionEngine {
  /// Evaluates current timetable slots against current DateTime
  static CurrentClassContext evaluateContext({
    required List<CourseSlot> allSlots,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final currentDay = now.weekday; // 1 = Mon ... 7 = Sun
    final currentMinutes = now.hour * 60 + now.minute;

    // Filter slots for today
    final todaySlots = allSlots.where((s) => s.dayOfWeek == currentDay).toList()
      ..sort((a, b) => a.startTimeMinutes.compareTo(b.startTimeMinutes));

    CourseSlot? activeSlot;
    CourseSlot? nextSlot;
    int minutesRemaining = 0;
    double progress = 0.0;
    int minutesUntilNext = 0;

    for (final slot in todaySlots) {
      if (currentMinutes >= slot.startTimeMinutes && currentMinutes < slot.endTimeMinutes) {
        // We found the active slot!
        activeSlot = slot;
        final totalDuration = slot.endTimeMinutes - slot.startTimeMinutes;
        final elapsed = currentMinutes - slot.startTimeMinutes;
        progress = totalDuration > 0 ? (elapsed / totalDuration).clamp(0.0, 1.0) : 0.0;
        minutesRemaining = (slot.endTimeMinutes - currentMinutes).clamp(0, 1440);
        break;
      }
    }

    // Look for the next upcoming slot today
    for (final slot in todaySlots) {
      if (slot.startTimeMinutes > currentMinutes) {
        nextSlot = slot;
        minutesUntilNext = (slot.startTimeMinutes - currentMinutes).clamp(0, 1440);
        break;
      }
    }

    return CurrentClassContext(
      activeSlot: activeSlot,
      nextSlotToday: nextSlot,
      minutesRemainingInActive: minutesRemaining,
      activeProgress: progress,
      minutesUntilNext: minutesUntilNext,
      evaluatedAt: now,
    );
  }
}

