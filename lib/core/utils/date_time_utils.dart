import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeUtils {
  /// Converts TimeOfDay to total minutes of day (0..1439)
  static int timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  /// Converts total minutes of day back to TimeOfDay
  static TimeOfDay minutesToTimeOfDay(int totalMinutes) {
    final hour = (totalMinutes ~/ 60) % 24;
    final minute = totalMinutes % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Formats TimeOfDay in localized 12-hour format (e.g. "10:30 ص" or "10:30 AM")
  static String formatTimeOfDay(TimeOfDay time, {bool isArabic = true}) {
    final period = time.period == DayPeriod.am
        ? (isArabic ? 'ص' : 'AM')
        : (isArabic ? 'م' : 'PM');
    final hourOfPeriod = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minuteStr = time.minute.toString().padLeft(2, '0');
    return '$hourOfPeriod:$minuteStr $period';
  }

  /// Formats minutes into localized 12-hour format
  static String formatMinutesOfDay(int minutes, {bool isArabic = true}) {
    return formatTimeOfDay(minutesToTimeOfDay(minutes), isArabic: isArabic);
  }

  /// Formats a time range (e.g., "10:00 ص - 11:30 ص")
  static String formatTimeRange(int startMinutes, int endMinutes, {bool isArabic = true}) {
    final start = formatMinutesOfDay(startMinutes, isArabic: isArabic);
    final end = formatMinutesOfDay(endMinutes, isArabic: isArabic);
    return isArabic ? '$start - $end' : '$start - $end';
  }

  /// Formats a DateTime with contextual day label: "اليوم", "غداً", or "الأحد، 28 سبتمبر"
  static String formatSmartDate(DateTime date, {bool isArabic = true}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final differenceDays = target.difference(today).inDays;

    final timeStr = DateFormat('h:mm', isArabic ? 'ar' : 'en').format(date);
    final period = DateFormat('a', isArabic ? 'ar' : 'en').format(date);

    if (differenceDays == 0) {
      return isArabic ? 'اليوم في $timeStr $period' : 'Today at $timeStr $period';
    } else if (differenceDays == 1) {
      return isArabic ? 'غداً في $timeStr $period' : 'Tomorrow at $timeStr $period';
    } else if (differenceDays == -1) {
      return isArabic ? 'أمس' : 'Yesterday';
    } else {
      final formatter = DateFormat('EEEE, d MMM', isArabic ? 'ar' : 'en');
      return '${formatter.format(date)} ($timeStr $period)';
    }
  }

  /// Returns remaining time countdown string (e.g. "باقي يومان و3 ساعات", "باقي 45 دقيقة", "2d 3h left")
  static String formatCountdown(DateTime targetDate, {bool isArabic = true}) {
    final now = DateTime.now();
    final diff = targetDate.difference(now);

    if (diff.isNegative) {
      final past = now.difference(targetDate);
      if (past.inDays > 0) {
        return isArabic ? 'فات موعدها منذ ${past.inDays} يوم' : 'Overdue by ${past.inDays}d';
      } else if (past.inHours > 0) {
        return isArabic ? 'فات موعدها منذ ${past.inHours} ساعة' : 'Overdue by ${past.inHours}h';
      } else {
        return isArabic ? 'فات موعدها للتو' : 'Just expired';
      }
    }

    if (diff.inDays >= 2) {
      final days = diff.inDays;
      final hours = diff.inHours % 24;
      if (hours > 0) {
        return isArabic ? 'باقي $days يوم و $hours ساعة' : '$days days, $hours hrs left';
      }
      return isArabic ? 'باقي $days أيام' : '$days days left';
    } else if (diff.inDays == 1) {
      final hours = diff.inHours % 24;
      return isArabic ? 'باقي يوم و $hours ساعة' : '1 day, $hours hrs left';
    } else if (diff.inHours >= 1) {
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      if (minutes > 0) {
        return isArabic ? 'باقي $hours ساعة و $minutes دقيقة' : '$hours hrs, $minutes mins left';
      }
      return isArabic ? 'باقي $hours ساعات' : '$hours hrs left';
    } else if (diff.inMinutes > 0) {
      return isArabic ? 'باقي ${diff.inMinutes} دقيقة' : '${diff.inMinutes} mins left';
    } else {
      return isArabic ? 'أقل من دقيقة' : 'Less than a minute';
    }
  }

  /// Calculates a deadline for "Next Week at Same Class Time"
  static DateTime calculateNextWeekClassTime(int dayOfWeek, int startMinutes) {
    final now = DateTime.now();
    // In Dart weekday: 1 = Monday, 7 = Sunday
    // Days until next occurrence of dayOfWeek:
    int daysUntil = (dayOfWeek - now.weekday) % 7;
    if (daysUntil <= 0) {
      daysUntil += 7; // Next week's occurrence
    }
    final nextDate = now.add(Duration(days: daysUntil));
    final time = minutesToTimeOfDay(startMinutes);
    return DateTime(nextDate.year, nextDate.month, nextDate.day, time.hour, time.minute);
  }
}
