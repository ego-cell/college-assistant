import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import 'package:college_pulse/features/timetable/models/course_slot.dart';
import 'package:college_pulse/features/timetable/models/slot_type.dart';
import 'package:college_pulse/features/tasks/models/task_item.dart';
import 'package:college_pulse/features/tasks/models/task_category.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const _uuid = Uuid();

  // --- Course Slots ---

  Future<List<CourseSlot>> loadSlots() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(AppConstants.keyTimetableSlots);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => CourseSlot.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveSlots(List<CourseSlot> slots) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(slots.map((s) => s.toJson()).toList());
    await prefs.setString(AppConstants.keyTimetableSlots, jsonString);
  }

  // --- Task Items ---

  Future<List<TaskItem>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(AppConstants.keyTasks);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((item) => TaskItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTasks(List<TaskItem> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(AppConstants.keyTasks, jsonString);
  }

  // --- Clear All ---
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyTimetableSlots);
    await prefs.remove(AppConstants.keyTasks);
  }

  // --- Realistic Demo Data Generation ---
  /// Seeds timetable slots and realistic student tasks tailored to the current day and time
  /// so that the Dynamic Context Detection Engine triggers immediately!
  Future<Map<String, dynamic>> seedRealisticDemoData() async {
    final now = DateTime.now();
    final currentDay = now.weekday; // 1 = Monday ... 7 = Sunday
    final currentMinute = now.hour * 60 + now.minute;

    // Slot 1: Taking place RIGHT NOW (starts 25 mins ago, ends 50 mins from now)
    final ongoingStart = (currentMinute - 25).clamp(480, 1380); // clamp within typical hours
    final ongoingEnd = (ongoingStart + 75).clamp(ongoingStart + 30, 1430);

    // Slot 2: Later today (starts 30 mins after ongoing ends)
    final nextStart = (ongoingEnd + 30).clamp(ongoingEnd + 15, 1380);
    final nextEnd = (nextStart + 90).clamp(nextStart + 45, 1435);

    final demoSlots = <CourseSlot>[
      // Live Slot right now
      CourseSlot(
        id: _uuid.v4(),
        courseName: 'Algorithms & Data Structures | خوارزميات وهياكل بيانات',
        instructorName: 'د. طارق محمود',
        room: 'مدرج 302 - مبنى جنيدي',
        dayOfWeek: currentDay,
        startTimeMinutes: ongoingStart,
        endTimeMinutes: ongoingEnd,
        slotType: SlotType.lecture,
        colorHex: AppColors.coursePalette[0].value,
      ),
      // Next Slot today
      CourseSlot(
        id: _uuid.v4(),
        courseName: 'Database Systems Lab | معمل قواعد بيانات',
        instructorName: 'م. سارة إبراهيم',
        room: 'معمل حاسب 4',
        dayOfWeek: currentDay,
        startTimeMinutes: nextStart,
        endTimeMinutes: nextEnd,
        slotType: SlotType.lab,
        colorHex: AppColors.coursePalette[1].value,
      ),
      // Schedule for other days
      CourseSlot(
        id: _uuid.v4(),
        courseName: 'Operating Systems | نظم تشغيل',
        instructorName: 'د. شريف عبد الوهاب',
        room: 'مدرج 101',
        dayOfWeek: (currentDay % 7) + 1,
        startTimeMinutes: 9 * 60, // 09:00 AM
        endTimeMinutes: 10 * 60 + 30, // 10:30 AM
        slotType: SlotType.lecture,
        colorHex: AppColors.coursePalette[2].value,
      ),
      CourseSlot(
        id: _uuid.v4(),
        courseName: 'Computer Networks Section | سكشن شبكات',
        instructorName: 'م. كريم عصام',
        room: 'قاعة السكاشن 12',
        dayOfWeek: (currentDay % 7) + 1,
        startTimeMinutes: 11 * 60, // 11:00 AM
        endTimeMinutes: 12 * 60 + 30, // 12:30 PM
        slotType: SlotType.section,
        colorHex: AppColors.coursePalette[3].value,
      ),
      CourseSlot(
        id: _uuid.v4(),
        courseName: 'Software Engineering | هندسة برمجيات',
        instructorName: 'د. نهى سليم',
        room: 'مدرج 405',
        dayOfWeek: ((currentDay + 1) % 7) + 1,
        startTimeMinutes: 10 * 60, // 10:00 AM
        endTimeMinutes: 11 * 60 + 30, // 11:30 AM
        slotType: SlotType.lecture,
        colorHex: AppColors.coursePalette[4].value,
      ),
    ];

    // Seed realistic student tasks
    final demoTasks = <TaskItem>[
      // Urgent Quiz tomorrow
      TaskItem(
        id: _uuid.v4(),
        courseId: demoSlots[0].id,
        courseName: 'Algorithms & Data Structures',
        title: 'كويز على الأشجار الثنائية والـ AVL Trees',
        description: 'يشمل مراجعة خواص التوازن وخطوات الـ Rotation من المحاضرة 4 إلى 6',
        category: TaskCategory.quiz,
        createdAt: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(hours: 18)), // Urgent (< 24h)
        reminderOffsetsInMinutes: [AppConstants.reminder24h, AppConstants.reminder2h],
      ),
      // Assignment sheet due in 3 days
      TaskItem(
        id: _uuid.v4(),
        courseId: demoSlots[1].id,
        courseName: 'Database Systems Lab',
        title: 'تسليم شيت 4: استعلامات SQL المعقدة و Join',
        description: 'حل المسائل من 1 إلى 8 ورفع ملف الـ .sql على منصة الجامعة',
        category: TaskCategory.assignment,
        createdAt: now,
        dueDate: now.add(const Duration(days: 3, hours: 2)),
        reminderOffsetsInMinutes: [AppConstants.reminder48h, AppConstants.reminder24h],
      ),
      // Project due next week
      TaskItem(
        id: _uuid.v4(),
        courseId: demoSlots[2].id,
        courseName: 'Operating Systems',
        title: 'المقترح المبدئي لمشروع نظام إدارة العمليات (Process Scheduling Simulator)',
        description: 'تسليم تقرير يشمل الـ Class Diagram وخطة التنفيذ بلغة C++ أو Flutter',
        category: TaskCategory.project,
        createdAt: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(days: 6, hours: 14)),
        reminderOffsetsInMinutes: [AppConstants.reminder48h, AppConstants.reminder24h],
      ),
      // Personal Non-academic Task
      TaskItem(
        id: _uuid.v4(),
        courseId: null,
        courseName: null,
        title: 'شراء كشكول محاضرات سلك وآلة حاسبة علمية fx-991',
        description: 'من مكتبة الكلية قبل سكشن الشبكات',
        category: TaskCategory.personal,
        createdAt: now,
        dueDate: now.add(const Duration(days: 1, hours: 4)),
        reminderOffsetsInMinutes: [AppConstants.reminder24h],
      ),
      // Completed Task
      TaskItem(
        id: _uuid.v4(),
        courseId: demoSlots[3].id,
        courseName: 'Software Engineering',
        title: 'مراجعة متطلبات SRS للمشروع الفصلي',
        description: 'تم الانتهاء والمراجعة مع معيد السكشن',
        category: TaskCategory.report,
        createdAt: now.subtract(const Duration(days: 4)),
        dueDate: now.subtract(const Duration(days: 1)),
        isCompleted: true,
      ),
    ];

    await saveSlots(demoSlots);
    await saveTasks(demoTasks);

    return {
      'slots': demoSlots,
      'tasks': demoTasks,
    };
  }
}

