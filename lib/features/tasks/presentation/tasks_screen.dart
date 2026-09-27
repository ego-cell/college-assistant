import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:college_pulse/core/constants/app_colors.dart';
import 'package:college_pulse/core/localization/app_localizations.dart';
import 'package:college_pulse/features/context_engine/context_provider.dart';
import 'package:college_pulse/features/timetable/providers/timetable_provider.dart';
import '../models/task_item.dart';
import '../providers/task_provider.dart';
import 'widgets/quick_add_task_sheet.dart';
import 'widgets/task_card.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();
    final timetableProvider = context.watch<TimetableProvider>();
    final contextProvider = context.watch<ContextProvider>();

    final tasks = taskProvider.filteredTasks;
    final activeCount = taskProvider.activeTasks.length;
    final archivedCount = taskProvider.archivedOrExpiredTasks.length;
    final completedCount = taskProvider.completedTasks.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.navTasks,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: l10n.quickAddTitle,
            icon: const Icon(Icons.add_task_rounded),
            onPressed: () => _openQuickAdd(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Scope Filter (All / College / Personal)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
            ),
            child: Row(
              children: [
                _buildScopeChip(
                  context,
                  title: l10n.allFilter,
                  filter: TaskScopeFilter.all,
                  selected: taskProvider.scopeFilter == TaskScopeFilter.all,
                ),
                const SizedBox(width: 8),
                _buildScopeChip(
                  context,
                  title: l10n.collegeFilter,
                  filter: TaskScopeFilter.college,
                  selected: taskProvider.scopeFilter == TaskScopeFilter.college,
                ),
                const SizedBox(width: 8),
                _buildScopeChip(
                  context,
                  title: l10n.personalFilter,
                  filter: TaskScopeFilter.personal,
                  selected: taskProvider.scopeFilter == TaskScopeFilter.personal,
                ),
              ],
            ),
          ),

          // Status Segment Tabs (Upcoming, Archived/Expired, Completed)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildStatusTab(
                  context,
                  title: l10n.tabUpcoming,
                  count: activeCount,
                  status: TaskStatusFilter.upcoming,
                  selected: taskProvider.statusFilter == TaskStatusFilter.upcoming,
                ),
                _buildStatusTab(
                  context,
                  title: l10n.tabArchived,
                  count: archivedCount,
                  status: TaskStatusFilter.archived,
                  selected: taskProvider.statusFilter == TaskStatusFilter.archived,
                ),
                _buildStatusTab(
                  context,
                  title: l10n.tabCompleted,
                  count: completedCount,
                  status: TaskStatusFilter.completed,
                  selected: taskProvider.statusFilter == TaskStatusFilter.completed,
                ),
              ],
            ),
          ),

          // Task List or Empty State
          Expanded(
            child: tasks.isEmpty
                ? _buildEmptyState(context, taskProvider.statusFilter)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    itemCount: tasks.length,
                    itemBuilder: (ctx, index) {
                      final task = tasks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TaskCard(
                          task: task,
                          onToggleCompleted: (_) => taskProvider.toggleTaskCompleted(task),
                          onDelete: () => _confirmDelete(context, task),
                        ),
                      );
                    },
                  ),
          ),
        ],
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

  Widget _buildScopeChip(
    BuildContext context, {
    required String title,
    required TaskScopeFilter filter,
    required bool selected,
  }) {
    return ChoiceChip(
      label: Text(title),
      selected: selected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      onSelected: (_) => context.read<TaskProvider>().setScopeFilter(filter),
    );
  }

  Widget _buildStatusTab(
    BuildContext context, {
    required String title,
    required int count,
    required TaskStatusFilter status,
    required bool selected,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<TaskProvider>().setStatusFilter(status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? theme.cardTheme.color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected ? AppColors.primary : theme.hintColor,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withOpacity(0.15)
                        : theme.dividerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: selected ? AppColors.primary : theme.hintColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, TaskStatusFilter filter) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    IconData icon;
    String message;

    switch (filter) {
      case TaskStatusFilter.upcoming:
        icon = Icons.done_all_rounded;
        message = l10n.isArabic
            ? 'رائع! لا توجد تسليمات معلقة، كل أمورك تحت السيطرة'
            : 'Great job! No pending deadlines, everything is under control.';
        break;
      case TaskStatusFilter.archived:
        icon = Icons.inventory_2_outlined;
        message = l10n.isArabic
            ? 'الأرشيف فارغ، لا توجد مهام منتهية الصلاحية'
            : 'Archive is empty, no expired or archived tasks.';
        break;
      case TaskStatusFilter.completed:
        icon = Icons.checklist_rounded;
        message = l10n.isArabic
            ? 'لم تكمل أي مهمة بعد، أنجز أول مهمة واحتفل بإنجازك!'
            : 'No completed tasks yet. Finish a task and check it off!';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
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

  void _confirmDelete(BuildContext context, TaskItem task) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteTask),
        content: Text('${l10n.deleteTaskConfirm}\n"${task.title}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(task.id);
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.delete, style: const TextStyle(color: AppColors.urgent)),
          ),
        ],
      ),
    );
  }
}


