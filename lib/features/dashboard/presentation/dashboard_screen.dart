import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:college_pulse/core/constants/app_colors.dart';
import 'package:college_pulse/core/localization/app_localizations.dart';
import 'package:college_pulse/core/services/storage_service.dart';
import 'package:college_pulse/features/context_engine/context_provider.dart';
import 'package:college_pulse/features/tasks/presentation/widgets/quick_add_task_sheet.dart';
import 'package:college_pulse/features/tasks/providers/task_provider.dart';
import 'package:college_pulse/features/timetable/providers/timetable_provider.dart';
import 'widgets/happening_now_card.dart';
import 'widgets/today_schedule_preview.dart';
import 'widgets/urgent_deadlines_section.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToTimetable;
  final VoidCallback onNavigateToTasks;

  const DashboardScreen({
    super.key,
    required this.onNavigateToTimetable,
    required this.onNavigateToTasks,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isArabic = l10n.isArabic;

    final contextProvider = context.watch<ContextProvider>();
    final timetableProvider = context.watch<TimetableProvider>();
    final taskProvider = context.watch<TaskProvider>();

    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM', isArabic ? 'ar' : 'en').format(now);

    final todaySlots = timetableProvider.todaySlots;
    final urgentTasks = taskProvider.urgentTasks;
    final isSlotsEmpty = timetableProvider.allSlots.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 12,
                color: theme.hintColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.quickAddTitle,
            icon: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 26),
            onPressed: () => _openQuickAdd(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await timetableProvider.loadSlots();
          await taskProvider.loadTasks();
          contextProvider.evaluateNow();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome / Demo seed banner if app is brand new
              if (isSlotsEmpty) ...[
                _buildDemoSeedBanner(context),
                const SizedBox(height: 16),
              ],

              // 1. Dynamic Context: Happening Now Card
              HappeningNowCard(
                contextProvider: contextProvider,
                onQuickAdd: () => _openQuickAdd(context),
              ),
              const SizedBox(height: 24),

              // 2. Today's Schedule Timeline Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.todaysSchedule,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: onNavigateToTimetable,
                    child: Text(
                      l10n.allFilter,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TodaySchedulePreview(
                slots: todaySlots,
                activeSlotId: contextProvider.activeSlot?.id,
                onSlotTap: (slot) {
                  onNavigateToTimetable();
                },
              ),
              const SizedBox(height: 24),

              // 3. Urgent Deadlines (< 48 Hours)
              UrgentDeadlinesSection(
                urgentTasks: urgentTasks,
                onToggleComplete: (task) => taskProvider.toggleTaskCompleted(task),
                onDelete: (task) => taskProvider.deleteTask(task.id),
                onViewAll: onNavigateToTasks,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openQuickAdd(context),
        icon: const Icon(Icons.bolt_rounded),
        label: Text(
          contextProvider.hasActiveCourse
              ? l10n.quickAddForThisClass
              : l10n.quickAddTitle,
        ),
      ),
    );
  }

  Widget _buildDemoSeedBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.loadDemoData,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.loadDemoDataDesc,
            style: TextStyle(fontSize: 12, color: theme.hintColor),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _seedDemoData(context),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(l10n.loadDemoData),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
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

  void _openQuickAdd(BuildContext context) {
    final contextProvider = context.read<ContextProvider>();
    final timetableProvider = context.read<TimetableProvider>();
    final taskProvider = context.read<TaskProvider>();

    QuickAddTaskSheet.show(
      context,
      presetSlot: contextProvider.activeSlot,
      availableSlots: timetableProvider.allSlots,
      onTaskCreated: (task) => taskProvider.addTask(task),
    );
  }
}


