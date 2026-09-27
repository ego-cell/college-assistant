import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:college_pulse/core/constants/app_colors.dart';
import 'package:college_pulse/core/localization/app_locale_provider.dart';
import 'package:college_pulse/core/localization/app_localizations.dart';
import 'package:college_pulse/core/services/notification_service.dart';
import 'package:college_pulse/core/services/storage_service.dart';
import 'package:college_pulse/core/theme/app_theme.dart';
import 'package:college_pulse/features/context_engine/context_provider.dart';
import 'package:college_pulse/features/tasks/providers/task_provider.dart';
import 'package:college_pulse/features/timetable/providers/timetable_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedSound = 'default';

  @override
  void initState() {
    super.initState();
    _loadSelectedSound();
  }

  Future<void> _loadSelectedSound() async {
    final sound = await NotificationService().getSelectedSound();
    if (mounted) {
      setState(() => _selectedSound = sound);
    }
  }

  Future<void> _changeSound(String soundKey) async {
    await NotificationService().setSelectedSound(soundKey);
    setState(() => _selectedSound = soundKey);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeProvider = context.watch<AppLocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Language Section
          _buildSectionHeader(context, l10n.languageSection, Icons.language_rounded),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('العربية (Arabic)'),
                  subtitle: const Text('واجهة من اليمين إلى اليسار (RTL)'),
                  value: 'ar',
                  groupValue: localeProvider.locale.languageCode,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) localeProvider.setLocale(Locale(val));
                  },
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: const Text('English (الإنجليزية)'),
                  subtitle: const Text('Left-to-right interface (LTR)'),
                  value: 'en',
                  groupValue: localeProvider.locale.languageCode,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) localeProvider.setLocale(Locale(val));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Appearance Section
          _buildSectionHeader(context, l10n.appearanceSection, Icons.palette_outlined),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(l10n.themeSystem),
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  activeColor: AppColors.primary,
                  onChanged: (mode) {
                    if (mode != null) themeProvider.setThemeMode(mode);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.themeLight),
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  activeColor: AppColors.primary,
                  onChanged: (mode) {
                    if (mode != null) themeProvider.setThemeMode(mode);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.themeDark),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  activeColor: AppColors.primary,
                  onChanged: (mode) {
                    if (mode != null) themeProvider.setThemeMode(mode);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Notifications & Sound Selection Section
          _buildSectionHeader(context, l10n.notificationsSection, Icons.notifications_active_outlined),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Row(
                    children: [
                      const Icon(Icons.music_note_rounded, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.notificationSound,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                RadioListTile<String>(
                  title: Text(l10n.soundDefault),
                  subtitle: Text(l10n.isArabic ? 'صوت النظام القياسي للإشعارات' : 'Standard system alert sound'),
                  value: 'default',
                  groupValue: _selectedSound,
                  activeColor: AppColors.primary,
                  secondary: IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
                    tooltip: l10n.playPreview,
                    onPressed: () async {
                      await NotificationService().showTestNotification(
                        isArabic: l10n.isArabic,
                        soundOverride: 'default',
                      );
                    },
                  ),
                  onChanged: (val) {
                    if (val != null) _changeSound(val);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: Text(l10n.soundUrgent),
                  subtitle: Text(l10n.isArabic ? 'صوت قوي مع اهتزاز مستمر' : 'High priority tone with vibration'),
                  value: 'urgent',
                  groupValue: _selectedSound,
                  activeColor: AppColors.urgent,
                  secondary: IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.urgent),
                    tooltip: l10n.playPreview,
                    onPressed: () async {
                      await NotificationService().showTestNotification(
                        isArabic: l10n.isArabic,
                        soundOverride: 'urgent',
                      );
                    },
                  ),
                  onChanged: (val) {
                    if (val != null) _changeSound(val);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: Text(l10n.soundChime),
                  subtitle: Text(l10n.isArabic ? 'نغمة جرس هادئة' : 'Soft bell chime'),
                  value: 'chime',
                  groupValue: _selectedSound,
                  activeColor: AppColors.secondary,
                  secondary: IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.secondary),
                    tooltip: l10n.playPreview,
                    onPressed: () async {
                      await NotificationService().showTestNotification(
                        isArabic: l10n.isArabic,
                        soundOverride: 'chime',
                      );
                    },
                  ),
                  onChanged: (val) {
                    if (val != null) _changeSound(val);
                  },
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: Text(l10n.soundSilent),
                  subtitle: Text(l10n.isArabic ? 'اهتزاز لطيف بدون صوت مسموع' : 'Gentle vibration without audible sound'),
                  value: 'silent',
                  groupValue: _selectedSound,
                  activeColor: Colors.grey,
                  secondary: const Icon(Icons.vibration_rounded, color: Colors.grey),
                  onChanged: (val) {
                    if (val != null) _changeSound(val);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.alarm_on_rounded, color: AppColors.primary),
                  title: Text(l10n.testNotification),
                  subtitle: Text(
                    l10n.isArabic
                        ? 'إرسال إشعار تجريبي بالصوت المختار'
                        : 'Trigger sample notification with selected sound',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    await NotificationService().requestPermissions();
                    await NotificationService().showTestNotification(isArabic: l10n.isArabic);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.testNotificationSent),
                          backgroundColor: AppColors.info,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. Data Management & Demo Seeder
          _buildSectionHeader(context, l10n.dataManagementSection, Icons.storage_rounded),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.school_rounded, color: AppColors.primary),
                  title: Text(l10n.loadDemoData),
                  subtitle: Text(
                    l10n.loadDemoDataDesc,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.download_rounded),
                  onTap: () => _seedDemoData(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_sweep_rounded, color: AppColors.urgent),
                  title: Text(
                    l10n.clearAllData,
                    style: const TextStyle(color: AppColors.urgent),
                  ),
                  subtitle: Text(
                    l10n.isArabic
                        ? 'حذف جميع المحاضرات والمهام المحفوظة'
                        : 'Wipe all timetable slots and student tasks',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () => _confirmClearData(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. About App & Badges
          _buildSectionHeader(context, l10n.aboutApp, Icons.info_outline_rounded),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.appTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.appSubtitle,
                              style: TextStyle(fontSize: 12, color: theme.hintColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.offline_bolt_rounded, size: 16, color: AppColors.success),
                        label: Text(l10n.offlineFirstBadge, style: const TextStyle(fontSize: 11)),
                      ),
                      Chip(
                        avatar: const Icon(Icons.sensors_rounded, size: 16, color: AppColors.primary),
                        label: Text(l10n.contextAwareBadge, style: const TextStyle(fontSize: 11)),
                      ),
                      const Chip(
                        avatar: Icon(Icons.security_rounded, size: 16, color: AppColors.secondary),
                        label: Text('Privacy-First (No Cloud/Tracking)', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.hintColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seedDemoData(BuildContext context) async {
    final storage = StorageService();
    final data = await storage.seedRealisticDemoData();

    if (context.mounted) {
      context.read<TimetableProvider>().setSlotsDirectly(data['slots']);
      context.read<TaskProvider>().setTasksDirectly(data['tasks']);
      context.read<ContextProvider>().updateSlots(data['slots']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).demoDataLoaded),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmClearData(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearAllData),
        content: Text(l10n.clearAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await StorageService().clearAll();
              if (context.mounted) {
                context.read<TimetableProvider>().setSlotsDirectly([]);
                context.read<TaskProvider>().setTasksDirectly([]);
                context.read<ContextProvider>().updateSlots([]);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.dataCleared),
                    backgroundColor: AppColors.urgent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: AppColors.urgent)),
          ),
        ],
      ),
    );
  }
}
