import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_constants.dart';
import 'package:college_pulse/features/tasks/models/task_item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String keyNotificationSound = 'pref_notification_sound';

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Create primary notification channel
      await _setupNotificationChannels();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  Future<void> _setupNotificationChannels() async {
    final sound = await getSelectedSound();
    final playSound = sound != 'silent';

    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDescription,
      importance: sound == 'silent' ? Importance.low : Importance.max,
      enableVibration: true,
      playSound: playSound,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<String> getSelectedSound() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyNotificationSound) ?? 'default';
  }

  Future<void> setSelectedSound(String soundKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyNotificationSound, soundKey);
    await _setupNotificationChannels();
  }

  Future<void> requestPermissions() async {
    try {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  /// Schedules notifications for a task according to its reminder offsets
  Future<void> scheduleTaskReminders(TaskItem task) async {
    if (!_isInitialized) await init();

    // Cancel existing notifications for this task first
    await cancelTaskNotifications(task.id);

    if (task.isCompleted || task.isArchived || task.isOverdue) return;

    final now = DateTime.now();
    final sound = await getSelectedSound();
    final playSound = sound != 'silent';

    for (int offsetMinutes in task.reminderOffsetsInMinutes) {
      final triggerTime = task.dueDate.subtract(Duration(minutes: offsetMinutes));
      if (triggerTime.isAfter(now)) {
        final notifId = _generateNotificationId(task.id, offsetMinutes);
        final hoursBefore = offsetMinutes ~/ 60;
        final title = '🔔 تذكير بموعد التسليم: ${task.title}';
        final body = hoursBefore > 0
            ? 'باقي $hoursBefore ساعة على موعد التسليم النهائي!'
            : 'باقي $offsetMinutes دقيقة على الموعد!';

        try {
          await _notificationsPlugin.zonedSchedule(
            notifId,
            title,
            body,
            tz.TZDateTime.from(triggerTime, tz.local),
            NotificationDetails(
              android: AndroidNotificationDetails(
                AppConstants.notificationChannelId,
                AppConstants.notificationChannelName,
                channelDescription: AppConstants.notificationChannelDescription,
                importance: sound == 'silent' ? Importance.low : Importance.max,
                priority: sound == 'silent' ? Priority.low : Priority.high,
                playSound: playSound,
                enableVibration: true,
                showWhen: true,
                styleInformation: const BigTextStyleInformation(''),
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: task.id,
          );
        } catch (e) {
          debugPrint('Failed to schedule exact alarm: $e');
        }
      }
    }
  }

  /// Cancels all scheduled notifications for a task
  Future<void> cancelTaskNotifications(String taskId) async {
    if (!_isInitialized) return;
    try {
      const offsets = [
        AppConstants.reminder48h,
        AppConstants.reminder24h,
        AppConstants.reminder2h,
      ];
      for (final offset in offsets) {
        await _notificationsPlugin.cancel(_generateNotificationId(taskId, offset));
      }
    } catch (e) {
      debugPrint('Error canceling notifications: $e');
    }
  }

  /// Shows an immediate test notification with the chosen sound configuration
  Future<void> showTestNotification({bool isArabic = true, String? soundOverride}) async {
    if (!_isInitialized) await init();

    try {
      final sound = soundOverride ?? await getSelectedSound();
      final playSound = sound != 'silent';

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: sound == 'silent' ? Importance.low : Importance.max,
        priority: sound == 'silent' ? Priority.low : Priority.high,
        playSound: playSound,
        enableVibration: true,
        ticker: 'College Pulse Test',
      );

      final NotificationDetails details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        99999,
        isArabic ? '🎓 رفيق الكلية: تجربة الصوت' : '🎓 College Pulse: Sound Test',
        isArabic
            ? 'تم تطبيق نغمة التنبيه بنجاح. ستصلك التذكيرات بهذا الصوت!'
            : 'Alert sound applied successfully. You will receive notifications with this tone!',
        details,
      );
    } catch (e) {
      debugPrint('Error showing test notification: $e');
    }
  }

  int _generateNotificationId(String taskId, int offset) {
    return (taskId.hashCode ^ offset).abs() % 2147483647;
  }
}
