import 'package:flutter/material.dart';
import 'package:college_pulse/core/constants/app_colors.dart';
import 'package:college_pulse/core/localization/app_localizations.dart';
import 'package:college_pulse/features/tasks/models/task_item.dart';
import 'package:college_pulse/features/tasks/presentation/widgets/task_card.dart';

class UrgentDeadlinesSection extends StatelessWidget {
  final List<TaskItem> urgentTasks;
  final ValueChanged<TaskItem> onToggleComplete;
  final ValueChanged<TaskItem> onDelete;
  final VoidCallback onViewAll;

  const UrgentDeadlinesSection({
    super.key,
    required this.urgentTasks,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.urgent),
                const SizedBox(width: 8),
                Text(
                  l10n.urgentDeadlines,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (urgentTasks.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.urgent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${urgentTasks.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                l10n.allFilter,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (urgentTasks.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.noUrgentDeadlines,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: urgentTasks.map((task) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TaskCard(
                  task: task,
                  onToggleCompleted: (_) => onToggleComplete(task),
                  onDelete: () => onDelete(task),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}


