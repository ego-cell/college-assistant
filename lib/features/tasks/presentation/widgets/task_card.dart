import 'package:flutter/material.dart';
import 'package:college_pulse/core/constants/app_colors.dart';
import 'package:college_pulse/core/localization/app_localizations.dart';
import 'package:college_pulse/features/tasks/models/task_category.dart';
import 'package:college_pulse/features/tasks/models/task_item.dart';

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final ValueChanged<bool?>? onToggleCompleted;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onToggleCompleted,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = l10n.isArabic;

    final catColor = task.category.color;
    final isUrgent = task.isUrgent;
    final isOverdue = task.isOverdue;
    final isCompleted = task.isCompleted;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isUrgent
              ? AppColors.urgent.withOpacity(0.6)
              : isOverdue
                  ? AppColors.urgent.withOpacity(0.3)
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: isUrgent ? 1.8 : 1,
        ),
      ),
      color: isCompleted
          ? (isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFF8FAFC))
          : theme.cardTheme.color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Category chip, Course name, Urgent/Overdue badge, and Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: catColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(task.category.icon, size: 14, color: catColor),
                        const SizedBox(width: 4),
                        Text(
                          task.category.localizedName(context),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: catColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Course Name Tag
                  if (task.courseName != null && task.courseName!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.courseName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Completion Checkbox
                  Transform.scale(
                    scale: 1.15,
                    child: Checkbox(
                      value: isCompleted,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      activeColor: AppColors.success,
                      onChanged: onToggleCompleted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                task.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color: isCompleted
                      ? theme.hintColor
                      : theme.textTheme.titleMedium?.color,
                ),
              ),

              // Description if available
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isCompleted ? theme.hintColor.withOpacity(0.6) : theme.hintColor,
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // Footer: Countdown Badge / Smart Date & Status
              Row(
                children: [
                  // Countdown chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? AppColors.urgent.withOpacity(0.12)
                          : isOverdue
                              ? const Color(0xFF94A3B8).withOpacity(0.15)
                              : isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUrgent
                              ? Icons.alarm_rounded
                              : isOverdue
                                  ? Icons.history_rounded
                                  : Icons.event_rounded,
                          size: 14,
                          color: isUrgent
                              ? AppColors.urgent
                              : isOverdue
                                  ? theme.hintColor
                                  : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          task.formattedCountdown(isArabic: isArabic),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isUrgent ? FontWeight.bold : FontWeight.w500,
                            color: isUrgent
                                ? AppColors.urgent
                                : isOverdue
                                    ? theme.hintColor
                                    : (isDark ? Colors.white70 : const Color(0xFF334155)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Delete action
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    color: theme.hintColor,
                    tooltip: l10n.deleteTask,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


