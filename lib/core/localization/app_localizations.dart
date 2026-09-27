import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('ar'));
  }

  bool get isArabic => locale.languageCode == 'ar';
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;

  // General App
  String get appTitle => isArabic ? 'رفيق الكلية الذكي' : 'College Pulse';
  String get appSubtitle => isArabic
      ? 'مساعدك الذكي المدرك لمحاضراتك ومهامك الجامعية'
      : 'Smart Context-Aware University Assistant';

  // Navigation & Tabs
  String get navDashboard => isArabic ? 'الرئيسية' : 'Dashboard';
  String get navTimetable => isArabic ? 'الجدول' : 'Timetable';
  String get navTasks => isArabic ? 'المهام' : 'Tasks';
  String get navSettings => isArabic ? 'الإعدادات' : 'Settings';

  // Context Engine & Dashboard
  String get happeningNow => isArabic ? 'جاري الآن' : 'Happening Now';
  String get freeTime => isArabic ? 'وقت استراحة' : 'Free Time';
  String get noActiveLecture => isArabic ? 'لا توجد محاضرة جارية حالياً' : 'No active class right now';
  String get enjoyFreeTime => isArabic
      ? 'استغل وقتك في مراجعة المهام أو الاستراحة'
      : 'Review your pending tasks or take a break';
  String get nextClassIn => isArabic ? 'المحاضرة التالية بعد' : 'Next class in';
  String get startsAt => isArabic ? 'تبدأ في' : 'Starts at';
  String get endsIn => isArabic ? 'تنتهي بعد' : 'Ends in';
  String get classInProgress => isArabic ? 'محاضرة قيد الانعقاد' : 'Class in progress';
  String get quickAddForThisClass =>
      isArabic ? 'إضافة مهمة لهذه المحاضرة' : 'Quick Add for this Class';
  String get todaysSchedule => isArabic ? 'جدول اليوم' : "Today's Schedule";
  String get noClassesToday => isArabic ? 'لا توجد محاضرات مجدولة اليوم' : 'No classes scheduled today';
  String get urgentDeadlines => isArabic ? 'تسليمات عاجلة (< 48 ساعة)' : 'Urgent Deadlines (< 48h)';
  String get noUrgentDeadlines => isArabic ? 'لا توجد تسليمات عاجلة حالياً 👍' : 'No urgent deadlines right now 👍';
  String get upcomingDeadlines => isArabic ? 'المهام والتسليمات القادمة' : 'Upcoming Deliverables';

  // Task Categories
  String get categoryQuiz => isArabic ? 'كويز' : 'Quiz';
  String get categoryAssignment => isArabic ? 'شيت / تكليف' : 'Assignment / Sheet';
  String get categoryReport => isArabic ? 'تقرير / بحث' : 'Report / Search';
  String get categoryProject => isArabic ? 'مشروع' : 'Project';
  String get categoryPersonal => isArabic ? 'مهمة خاصة' : 'Personal Task';

  // Course Slot Types
  String get slotTypeLecture => isArabic ? 'محاضرة' : 'Lecture';
  String get slotTypeSection => isArabic ? 'سكشن' : 'Section';
  String get slotTypeLab => isArabic ? 'معمل' : 'Lab';

  // Timetable Days
  String get saturday => isArabic ? 'السبت' : 'Saturday';
  String get sunday => isArabic ? 'الأحد' : 'Sunday';
  String get monday => isArabic ? 'الاثنين' : 'Monday';
  String get tuesday => isArabic ? 'الثلاثاء' : 'Tuesday';
  String get wednesday => isArabic ? 'الأربعاء' : 'Wednesday';
  String get thursday => isArabic ? 'الخميس' : 'Thursday';
  String get friday => isArabic ? 'الجمعة' : 'Friday';

  String dayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 6:
        return saturday;
      case 7:
        return sunday;
      case 1:
        return monday;
      case 2:
        return tuesday;
      case 3:
        return wednesday;
      case 4:
        return thursday;
      case 5:
        return friday;
      default:
        return isArabic ? 'يوم' : 'Day';
    }
  }

  // Quick Add Modal & Task Form
  String get quickAddTitle => isArabic ? 'إضافة سريعة للمطلوب' : 'Quick Add Task';
  String get autoDetectedBanner =>
      isArabic ? '✨ تم استشعار المحاضرة الحالية تلقائياً' : '✨ Current class auto-detected';
  String get manualCourseSelect => isArabic ? 'اختر المادة' : 'Select Course';
  String get targetCourse => isArabic ? 'المادة الدراسية' : 'Target Course';
  String get taskTitleLabel => isArabic ? 'عنوان المطلوب (مثال: شيت 3 مسائل 1-5)' : 'Task Title (e.g. Sheet 3)';
  String get taskTitleHint => isArabic ? 'اكتب المطلوب باختصار...' : 'Brief task title...';
  String get taskDescriptionLabel => isArabic ? 'ملاحظات وتفاصيل إضافية' : 'Notes & Details';
  String get taskDescriptionHint => isArabic ? 'رقم الأسئلة، تعليمات الدكتور، شروط التسليم...' : 'Question numbers, instructor notes...';
  String get taskCategory => isArabic ? 'تصنيف المطلوب' : 'Category';
  String get deadlinePresets => isArabic ? 'موعد التسليم المقترح' : 'Suggested Deadline';
  String get presetNextWeekClassTime =>
      isArabic ? 'الأسبوع القادم بنفس الميعاد' : 'Next week at same class time';
  String get presetTomorrow => isArabic ? 'غداً' : 'Tomorrow';
  String get presetIn3Days => isArabic ? 'خلال 3 أيام' : 'In 3 days';
  String get presetCustom => isArabic ? 'تاريخ ووقت مخصص' : 'Custom Date & Time';
  String get remindersLabel => isArabic ? 'تنبيهي قبل الموعد بـ:' : 'Remind me before:';
  String get reminder48hLabel => isArabic ? 'يومين قبل' : '2 days before';
  String get reminder24hLabel => isArabic ? '24 ساعة قبل' : '24h before';
  String get reminder2hLabel => isArabic ? 'ساعتين قبل' : '2 hours before';
  String get reminderMorningLabel => isArabic ? 'صباح يوم التسليم' : 'Morning of deadline';
  String get customReminderLabel => isArabic ? 'تحديد موعد تنبيه مخصص' : 'Set Custom Alert Time';
  String get customReminderSet => isArabic ? 'موعد التنبيه المخصص:' : 'Custom Alert Set:';
  String get pickReminderDateTime => isArabic ? 'اختر تاريخ ووقت التنبيه' : 'Choose alert date & time';
  String get saveTask => isArabic ? 'حفظ المهمة' : 'Save Task';
  String get taskSavedSuccess => isArabic ? 'تم حفظ المهمة وجدولة التنبيه بنجاح' : 'Task saved & reminder scheduled!';
  String get fillRequiredFields => isArabic ? 'يرجى كتابة عنوان المطلوب' : 'Please enter task title';

  // Task Filters & Screen
  String get allFilter => isArabic ? 'الكل' : 'All';
  String get collegeFilter => isArabic ? 'الكلية' : 'College';
  String get personalFilter => isArabic ? 'شخصي' : 'Personal';
  String get tabUpcoming => isArabic ? 'القادمة' : 'Upcoming';
  String get tabArchived => isArabic ? 'المنتهية والأرشيف' : 'Archived & Expired';
  String get tabCompleted => isArabic ? 'المكتملة' : 'Completed';
  String get overdue => isArabic ? 'فات موعدها' : 'Overdue';
  String get urgent => isArabic ? 'عاجل' : 'Urgent';
  String get markCompleted => isArabic ? 'اكتملت' : 'Done';
  String get markPending => isArabic ? 'إعادة للتنشيط' : 'Mark Incomplete';
  String get deleteTask => isArabic ? 'حذف المهمة' : 'Delete Task';
  String get deleteTaskConfirm => isArabic ? 'هل تريد بالتأكيد حذف هذه المهمة؟' : 'Are you sure you want to delete this task?';
  String get noTasksInTab => isArabic ? 'لا توجد مهام في هذا القسم' : 'No tasks in this section';

  // Timetable Screen
  String get addSlot => isArabic ? 'إضافة حصة / محاضرة' : 'Add Class Slot';
  String get editSlot => isArabic ? 'تعديل بيانات الحصة' : 'Edit Class Slot';
  String get deleteSlotConfirm => isArabic ? 'هل تريد حذف هذه المحاضرة من الجدول؟' : 'Delete this slot from timetable?';
  String get courseNameLabel => isArabic ? 'اسم المادة' : 'Course Name';
  String get instructorNameLabel => isArabic ? 'اسم الدكتور / المعيد' : 'Instructor / TA Name';
  String get roomLabel => isArabic ? 'المدرج / القاعة / المعمل' : 'Hall / Room / Lab';
  String get startTimeLabel => isArabic ? 'وقت البدء' : 'Start Time';
  String get endTimeLabel => isArabic ? 'وقت الانتهاء' : 'End Time';
  String get selectDayLabel => isArabic ? 'اليوم' : 'Day of Week';
  String get saveSlot => isArabic ? 'حفظ الحصة' : 'Save Slot';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get delete => isArabic ? 'حذف' : 'Delete';
  String get noSlotsForDay => isArabic ? 'لا توجد محاضرات مضافة لهذا اليوم' : 'No classes added for this day';
  String get addFirstSlot => isArabic ? 'اضغط + لإضافة أول محاضرة' : 'Tap + to add your first lecture';

  // Settings Screen
  String get settingsTitle => isArabic ? 'الإعدادات' : 'Settings';
  String get languageSection => isArabic ? 'اللغة / Language' : 'Language / اللغة';
  String get arabicOption => 'العربية (Arabic)';
  String get englishOption => 'English (الإنجليزية)';
  String get appearanceSection => isArabic ? 'المظهر' : 'Appearance';
  String get themeMode => isArabic ? 'وضع الثيم' : 'Theme Mode';
  String get themeSystem => isArabic ? 'تلقائي (حسب النظام)' : 'System Default';
  String get themeLight => isArabic ? 'فاتح' : 'Light Mode';
  String get themeDark => isArabic ? 'داكن' : 'Dark Mode';
  String get notificationsSection => isArabic ? 'التنبيهات' : 'Notifications';
  String get notificationSound => isArabic ? 'نغمة وصوت التنبيه' : 'Alert Sound';
  String get soundDefault => isArabic ? 'نغمة النظام الافتراضية' : 'Default System Tone';
  String get soundUrgent => isArabic ? 'نغمة عاجلة (كويزات وتسليمات)' : 'Urgent Alert (Quizzes & Deadlines)';
  String get soundChime => isArabic ? 'رنين هادئ للتذكير' : 'Gentle Chime';
  String get soundSilent => isArabic ? 'اهتزاز فقط (صامت)' : 'Vibrate Only (Silent)';
  String get playPreview => isArabic ? 'تجربة النغمة' : 'Test Tone';
  String get testNotification => isArabic ? 'إرسال تنبيه تجريبي' : 'Send Test Notification';
  String get testNotificationSent => isArabic ? 'تم إرسال التنبيه التجريبي!' : 'Test notification sent!';
  String get dataManagementSection => isArabic ? 'إدارة البيانات' : 'Data Management';
  String get loadDemoData => isArabic ? 'تحميل جدول ومهام تجريبية للجامعة' : 'Load University Demo Schedule & Tasks';
  String get loadDemoDataDesc => isArabic
      ? 'يضيف جدول دراسي متكامل مطابق لوقتك الحالي لتجربة الاستشعار الفوري'
      : 'Adds realistic college schedule tailored to current time to test live context';
  String get demoDataLoaded => isArabic ? 'تم تحميل البيانات التجريبية بنجاح!' : 'Demo data loaded successfully!';
  String get clearAllData => isArabic ? 'مسح كافة البيانات' : 'Clear All Data';
  String get clearAllConfirm => isArabic
      ? 'هل أنت متأكد من مسح جميع المحاضرات والمهام المحفوظة؟'
      : 'Are you sure you want to clear all slots and tasks?';
  String get dataCleared => isArabic ? 'تم مسح البيانات بنجاح' : 'All data cleared';
  String get aboutApp => isArabic ? 'عن التطبيق' : 'About App';
  String get offlineFirstBadge => isArabic ? 'يعمل بالكامل بدون إنترنت 100%' : '100% Offline-First';
  String get contextAwareBadge => isArabic ? 'مدرك للسياق الزمني' : 'Time & Context Aware';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
