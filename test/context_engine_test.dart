import 'package:flutter_test/flutter_test.dart';
import 'package:college_pulse/features/context_engine/context_engine.dart';
import 'package:college_pulse/features/timetable/models/course_slot.dart';
import 'package:college_pulse/features/timetable/models/slot_type.dart';

void main() {
  group('ContextDetectionEngine Tests', () {
    final mondaySlots = [
      const CourseSlot(
        id: 'slot_1',
        courseName: 'Algorithms',
        instructorName: 'Dr. Tarek',
        room: 'Hall 302',
        dayOfWeek: 1, // Monday
        startTimeMinutes: 600, // 10:00 AM
        endTimeMinutes: 690, // 11:30 AM
        slotType: SlotType.lecture,
        colorHex: 0xFF2563EB,
      ),
      const CourseSlot(
        id: 'slot_2',
        courseName: 'Database Lab',
        instructorName: 'Eng. Sarah',
        room: 'Lab 4',
        dayOfWeek: 1, // Monday
        startTimeMinutes: 720, // 12:00 PM
        endTimeMinutes: 810, // 01:30 PM
        slotType: SlotType.lab,
        colorHex: 0xFF0D9488,
      ),
    ];

    test('Detects ongoing lecture accurately when inside time window', () {
      // 10:45 AM on Monday (weekday 1)
      final testTime = DateTime(2026, 9, 28, 10, 45); // Sept 28 2026 is Monday
      expect(testTime.weekday, 1);

      final contextResult = ContextDetectionEngine.evaluateContext(
        allSlots: mondaySlots,
        currentTime: testTime,
      );

      expect(contextResult.hasActiveCourse, isTrue);
      expect(contextResult.activeSlot?.courseName, 'Algorithms');
      expect(contextResult.minutesRemainingInActive, 45); // ends at 11:30 (690 - 645 = 45)
      expect(contextResult.activeProgress, closeTo(0.5, 0.01)); // half of 90 mins
      expect(contextResult.hasNextCourseToday, isTrue);
      expect(contextResult.nextSlotToday?.courseName, 'Database Lab');
      expect(contextResult.minutesUntilNext, 75); // 12:00 - 10:45 = 75 mins
    });

    test('Detects free time when outside scheduled slot hours', () {
      // 11:40 AM on Monday (between slot 1 and slot 2)
      final testTime = DateTime(2026, 9, 28, 11, 40);

      final contextResult = ContextDetectionEngine.evaluateContext(
        allSlots: mondaySlots,
        currentTime: testTime,
      );

      expect(contextResult.hasActiveCourse, isFalse);
      expect(contextResult.activeSlot, isNull);
      expect(contextResult.hasNextCourseToday, isTrue);
      expect(contextResult.nextSlotToday?.courseName, 'Database Lab');
      expect(contextResult.minutesUntilNext, 20); // 12:00 - 11:40 = 20 mins
    });

    test('Reports no active or upcoming courses after all slots end for the day', () {
      // 03:00 PM on Monday
      final testTime = DateTime(2026, 9, 28, 15, 0);

      final contextResult = ContextDetectionEngine.evaluateContext(
        allSlots: mondaySlots,
        currentTime: testTime,
      );

      expect(contextResult.hasActiveCourse, isFalse);
      expect(contextResult.hasNextCourseToday, isFalse);
      expect(contextResult.nextSlotToday, isNull);
    });
  });
}
