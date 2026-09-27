import 'package:flutter/material.dart';
import 'package:college_pulse/core/constants/app_colors.dart';
import 'package:college_pulse/core/localization/app_localizations.dart';
import 'package:college_pulse/core/utils/date_time_utils.dart';
import 'package:college_pulse/features/timetable/models/course_slot.dart';
import 'package:college_pulse/features/timetable/models/slot_type.dart';

class CourseSlotCard extends StatefulWidget {
  final CourseSlot slot;
  final bool isOngoing;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onQuickAddTask;

  const CourseSlotCard({
    super.key,
    required this.slot,
    this.isOngoing = false,
    this.onEdit,
    this.onDelete,
    this.onQuickAddTask,
  });

  @override
  State<CourseSlotCard> createState() => _CourseSlotCardState();
}

class _CourseSlotCardState extends State<CourseSlotCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isOngoing) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CourseSlotCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOngoing && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isOngoing && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final typeColor = widget.slot.slotType.color;
    final slotColor = Color(widget.slot.colorHex);

    final cardContent = Card(
      elevation: widget.isOngoing ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.isOngoing
              ? AppColors.livePulse
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          width: widget.isOngoing ? 2.2 : 1,
        ),
      ),
      color: widget.isOngoing
          ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4))
          : theme.cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Type chip & Ongoing Badge & Menu
            Row(
              children: [
                // Type Badge (Lecture / Section / Lab)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: typeColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.slot.slotType.icon, size: 14, color: typeColor),
                      const SizedBox(width: 5),
                      Text(
                        widget.slot.slotType.localizedName(context),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Pulsing Live Badge if currently ongoing
                if (widget.isOngoing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.livePulse,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.radio_button_checked, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          l10n.happeningNow,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                // Action Menu (Edit / Delete)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (val) {
                    if (val == 'edit') widget.onEdit?.call();
                    if (val == 'delete') widget.onDelete?.call();
                    if (val == 'task') widget.onQuickAddTask?.call();
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'task',
                      child: Row(
                        children: [
                          const Icon(Icons.add_task, size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(l10n.quickAddForThisClass),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 18),
                          const SizedBox(width: 10),
                          Text(l10n.editSlot),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, size: 18, color: AppColors.urgent),
                          const SizedBox(width: 10),
                          Text(l10n.delete, style: const TextStyle(color: AppColors.urgent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Course Name
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: slotColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.slot.courseName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Metadata: Time range, Room, Instructor
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                // Time
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: widget.isOngoing ? AppColors.livePulse : theme.hintColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateTimeUtils.formatTimeRange(
                        widget.slot.startTimeMinutes,
                        widget.slot.endTimeMinutes,
                        isArabic: isArabic,
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: widget.isOngoing ? FontWeight.bold : FontWeight.w500,
                        color: widget.isOngoing
                            ? (isDark ? Colors.white : const Color(0xFF0F5132))
                            : null,
                      ),
                    ),
                  ],
                ),

                // Room / Hall
                if (widget.slot.room != null && widget.slot.room!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.place_outlined, size: 16, color: theme.hintColor),
                      const SizedBox(width: 6),
                      Text(
                        widget.slot.room!,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                // Instructor
                if (widget.slot.instructorName != null &&
                    widget.slot.instructorName!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline_rounded, size: 16, color: theme.hintColor),
                      const SizedBox(width: 6),
                      Text(
                        widget.slot.instructorName!,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
              ],
            ),

            // If ongoing: show quick log task shortcut button
            if (widget.isOngoing) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onQuickAddTask,
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: Text(l10n.quickAddForThisClass),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.livePulse,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (widget.isOngoing) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: cardContent,
      );
    }

    return cardContent;
  }
}


