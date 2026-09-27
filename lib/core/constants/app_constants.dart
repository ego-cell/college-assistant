class AppConstants {
  static const String appName = 'College Pulse';
  static const String appNameAr = 'رفيق الكلية الذكي';

  // Storage Keys
  static const String keyTimetableSlots = 'cp_timetable_slots';
  static const String keyTasks = 'cp_task_items';
  static const String keyLocale = 'cp_app_locale';
  static const String keyThemeMode = 'cp_theme_mode';
  static const String keyHasSampleData = 'cp_has_sample_data';

  // Days of week (1 = Monday, ..., 7 = Sunday)
  // In typical Middle-Eastern / Egyptian universities, week starts Saturday (6) or Sunday (7).
  static const List<int> standardWeekDays = [
    6, // Saturday
    7, // Sunday
    1, // Monday
    2, // Tuesday
    3, // Wednesday
    4, // Thursday
    5, // Friday
  ];

  // Default Reminder Offsets in Minutes:
  // 48 hours = 2880 mins
  // 24 hours = 1440 mins
  // 2 hours = 120 mins
  // Morning of deadline = handled dynamically (08:00 AM)
  static const int reminder48h = 2880;
  static const int reminder24h = 1440;
  static const int reminder2h = 120;

  // Urgent threshold: 48 hours
  static const Duration urgentThreshold = Duration(hours: 48);

  // Notification Channel
  static const String notificationChannelId = 'college_pulse_deadlines_channel';
  static const String notificationChannelName = 'College Deadlines & Quizzes';
  static const String notificationChannelDescription =
      'Notifications for upcoming university sheets, quizzes, and project deadlines';
}
