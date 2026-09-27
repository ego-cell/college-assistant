import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:college_pulse/core/constants/app_colors.dart';
import 'package:college_pulse/core/constants/app_constants.dart';
import 'package:college_pulse/core/localization/app_localizations.dart';
import 'package:college_pulse/features/context_engine/context_provider.dart';
import 'package:college_pulse/features/tasks/presentation/widgets/quick_add_task_sheet.dart';
import 'package:college_pulse/features/tasks/providers/task_provider.dart';
import '../models/course_slot.dart';
import '../providers/timetable_provider.dart';
import 'widgets/add_edit_slot_dialog.dart';
import 'widgets/course_slot_card.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final timetableProvider = context.watch<TimetableProvider>();
    final contextProvider = context.watch<ContextProvider>();

    final selectedDay = timetableProvider.selectedDay;
    final today = DateTime.now().weekday;
    final slots = timetableProvider.slotsForSelectedDay;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.navTimetable,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: l10n.addSlot,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _openAddSlot(context, selectedDay),
          ),
        ],
      ),
      body: Column(
        children: [
          // Weekday Selector Tabs
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: AppConstants.standardWeekDays.length,
              itemBuilder: (ctx, index) {
                final day = AppConstants.standardWeekDays[index];
                final isSelected = day == selectedDay;
                final isToday = day == today;
                final daySlotCount =
                    timetableProvider.allSlots.where((s) => s.dayOfWeek == day).length;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.dayName(day),
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isToday ? AppColors.primary : null),
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? Colors.white : AppColors.livePulse,
                            ),
                          ),
                        ],
                        if (daySlotCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.25)
                                  : theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$daySlotCount',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : theme.hintColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    onSelected: (_) => timetableProvider.setSelectedDay(day),
                  ),
                );
              },
            ),
          ),

          // Slots List or Empty state
          Expanded(
            child: slots.isEmpty
                ? _buildEmptyState(context, selectedDay)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: slots.length,
                    itemBuilder: (ctx, index) {
                      final slot = slots[index];
                      final isOngoing = contextProvider.activeSlot?.id == slot.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CourseSlotCard(
                          slot: slot,
                          isOngoing: isOngoing,
                          onEdit: () => _openEditSlot(context, slot),
                          onDelete: () => _confirmDelete(context, slot),
                          onQuickAddTask: () => _openQuickAddForSlot(context, slot),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSlot(context, selectedDay),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addSlot),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, int selectedDay) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

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
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noSlotsForDay,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addFirstSlot,
              style: TextStyle(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _openAddSlot(context, selectedDay),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addSlot),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddSlot(BuildContext context, int currentDay) {
    final timetable = context.read<TimetableProvider>();
    AddEditSlotDialog.show(
      context,
      initialDay: currentDay,
      existingCourses: timetable.uniqueCourseNames,
      onSave: (newSlot) => timetable.addSlot(newSlot),
    );
  }

  void _openEditSlot(BuildContext context, CourseSlot slot) {
    final timetable = context.read<TimetableProvider>();
    AddEditSlotDialog.show(
      context,
      slotToEdit: slot,
      initialDay: slot.dayOfWeek,
      existingCourses: timetable.uniqueCourseNames,
      onSave: (updatedSlot) => timetable.updateSlot(updatedSlot),
    );
  }

  void _confirmDelete(BuildContext context, CourseSlot slot) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.delete),
        content: Text('${l10n.deleteSlotConfirm}\n"${slot.courseName}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<TimetableProvider>().deleteSlot(slot.id);
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.delete, style: const TextStyle(color: AppColors.urgent)),
          ),
        ],
      ),
    );
  }

  void _openQuickAddForSlot(BuildContext context, CourseSlot slot) {
    final timetable = context.read<TimetableProvider>();
    final taskProvider = context.read<TaskProvider>();

    QuickAddTaskSheet.show(
      context,
      presetSlot: slot,
      availableSlots: timetable.allSlots,
      onTaskCreated: (task) => taskProvider.addTask(task),
    );
  }
}


