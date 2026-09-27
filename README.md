# 🎓 College Pulse | رفيق الكلية الذكي
> **Smart Context-Aware University Student Assistant (Flutter Android App)**  
> تطبيق إنتاجية ذكي للطلاب الجامعيين مدرك لسياق المحاضرات تلقائياً ومبني بتقنية Flutter (يعمل بالكامل بدون إنترنت 100% Offline-First).

---

## 🌟 The Core Superpower: Dynamic Context Awareness (محرك الاستشعار الزمني)
University students often need to jot down tasks, quizzes, or assignment sheet numbers during lectures. Instead of forcing manual course selection every time:
1. **Dynamic Context Engine**: Evaluates `DateTime.now()` in real time against the student's weekly timetable.
2. **Auto-Preselection**: If opened during a lecture or lab (e.g., Sunday 10:00 AM – 11:30 AM), the Quick-Add modal **automatically pre-selects the ongoing subject and type** (Lecture vs. Lab/Section).
3. **Live "Happening Now" Pulse**: Highlights the ongoing class on the dashboard with a pulsating live badge, remaining minutes countdown, and class completion progress bar.
4. **Free-Time Fallback**: Outside schedule hours, defaults seamlessly to manual course selection or personal tasks.

---

## 📱 Features & Highlights

### 1. Bilingual Support & RTL Localization (ثنائي اللغة - عربي / إنجليزي)
- Full Arabic (`ar`) layout with native **RTL (Right-to-Left)** support.
- English (`en`) layout with **LTR (Left-to-Right)** support.
- Instant runtime switching from Settings without restarting the app.

### 2. Timetable Management (الجدول الدراسي)
- Day tabs (Saturday through Friday) accommodating Arab and international academic weeks.
- Slot details: Course Name, Instructor / TA, Hall / Room, Start & End Times, Slot Type (`Lecture`, `Section`, `Lab`).
- Interactive CRUD: Add, edit, delete slots with custom color tags.

### 3. Quick-Add Action & Smart Task Classifier (الإضافة السريعة وتصنيف المهام)
- One-tap bottom sheet pre-populated with active class context.
- Category chips:
  - `[Quiz / كويز]` (Red)
  - `[Assignment / Sheet / شيت]` (Blue)
  - `[Search / Report / بحث أو تقرير]` (Purple)
  - `[Project / مشروع]` (Emerald)
  - `[Personal Task / مهمة خاصة]` (Orange)
- One-tap deadline presets:
  - *"Next Week at Same Class Time / الأسبوع القادم بنفس الميعاد"* (automatically computes exact date and time)
  - *"Tomorrow / غداً"*
  - *"In 3 Days / خلال 3 أيام"*
  - *Custom Date & Time Picker*
- Smart reminder offsets: 48h before, 24h before, 2h before, Morning of deadline.

### 4. Personal Tasks & Multi-Scope Filtering
- Independent personal to-dos unrelated to academic courses.
- Filter tabs: `All / الكل` | `College / الكلية` | `Personal / شخصي`.
- Status tabs: `Upcoming / القادمة` | `Archived & Expired / الأرشيف والمنتهية` | `Completed / المكتملة`.

### 5. Auto-Cleanup & Expiry Logic (إدارة المهام المنتهية)
- Expired deadlines are cleanly separated from the active dashboard to prevent cognitive overload.
- Main dashboard highlights **Urgent Deadlines (< 48 hours)** with remaining hours badges.

### 6. Native Offline Notification Engine
- Uses `flutter_local_notifications` + `timezone`.
- Configured for Android 14+ (`SCHEDULE_EXACT_ALARM`, `POST_NOTIFICATIONS`, `USE_EXACT_ALARM`).
- Reliable exact alarms trigger before submissions and exams.

---

## 🏗️ Architecture & Folder Structure

```
d:/pro/
├── android/                        # Android Native Project Config (Permissions & Gradle 34+)
│   └── app/src/main/AndroidManifest.xml
├── lib/
│   ├── main.dart                   # MultiProvider, App Entry, Demo Data Seeder
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart     # Palette for slots, categories, themes
│   │   │   └── app_constants.dart  # Channels, keys, week day constants
│   │   ├── localization/
│   │   │   ├── app_localizations.dart   # Full Arabic & English dictionary
│   │   │   └── app_locale_provider.dart # Persistent locale notifier
│   │   ├── services/
│   │   │   ├── storage_service.dart     # Fast JSON/SharedPreferences persistence
│   │   │   └── notification_service.dart# Exact alarms and Android channels
│   │   ├── theme/
│   │   │   └── app_theme.dart      # Material 3 Light/Dark themes
│   │   └── utils/
│   │       └── date_time_utils.dart# Context math, countdown & smart date formatting
│   └── features/
│       ├── context_engine/         # Dynamic Context Detection Engine & Ticker
│       │   ├── context_engine.dart
│       │   └── context_provider.dart
│       ├── dashboard/              # Home Screen, Happening Now Card, Urgent Deadlines
│       │   └── presentation/
│       ├── main_navigation/        # Bottom navigation scaffold
│       ├── settings/               # Language, Theme, Demo Seeder, Clear Data
│       ├── tasks/                  # Task Models, Repository, Provider, Quick Add Sheet
│       │   ├── models/
│       │   ├── data/
│       │   ├── providers/
│       │   └── presentation/
│       └── timetable/              # Course Slots, Day Tabs, Slot Cards, Dialogs
│           ├── models/
│           ├── data/
│           ├── providers/
│           └── presentation/
├── test/
│   ├── context_engine_test.dart    # Unit tests for time windows and slot detection
│   └── task_item_test.dart         # Unit tests for urgency, overdue, JSON serialization
└── pubspec.yaml                    # Dependencies & Flutter SDK settings
```

---

## 🚀 Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Unit Tests
```bash
flutter test
```

### 3. Run on Android Device / Emulator
```bash
flutter run
```

### 4. Build Release APK (Android SDK 34+)
```bash
flutter build apk --release
```

---

## ⚡ Instant Demo Data
The application includes a built-in realistic demo data generator. On first launch, or by tapping **"تحميل جدول ومهام تجريبية للجامعة"** in Settings, it immediately seeds:
- A lecture taking place **right now** relative to your current system time (so you can observe the "Happening Now" pulse and auto-prefill immediately!).
- An upcoming lab later today.
- Scheduled classes across other weekdays.
- Urgent quizzes and assignment sheets with countdown timers.
