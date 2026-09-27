import 'package:flutter/material.dart';
import 'package:college_pulse/core/constants/app_colors.dart';
import 'package:college_pulse/core/localization/app_localizations.dart';
import 'package:college_pulse/core/utils/date_time_utils.dart';
import 'package:college_pulse/features/timetable/models/course_slot.dart';
import 'package:college_pulse/features/timetable/models/slot_type.dart';

class TodaySchedulePreview extends StatelessWidget {
  final List<CourseSlot> slots;
  final String? activeSlotId;
  final ValueChanged<CourseSlot>? onSlotTap;

  const TodaySchedulePreview({
    super.key,
    required this.slots,
    this.activeSlotId,
    this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = l10n.isArabic;

    if (slots.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.weekend_rounded, color: theme.hintColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.noClassesToday,
                  style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 125,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: slots.length,
        itemBuilder: (ctx, index) {
          final slot = slots[index];
          final isOngoing = slot.id == activeSlotId;
          final typeColor = slot.slotType.color;

          return Container(
            width: 200,
            margin: EdgeInsets.only(
              left: isArabic ? 0 : (index == 0 ? 0 : 10),
              right: isArabic ? (index == 0 ? 0 : 10) : 0,
            ),
            child: Card(
              elevation: isOngoing ? 3 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isOngoing
                      ? AppColors.livePulse
                      : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  width: isOngoing ? 2 : 1,
                ),
              ),
              color: isOngoing
                  ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4))
                  : theme.cardTheme.color,
              child: InkWell(
                onTap: () => onSlotTap?.call(slot),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Type & Live badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              slot.slotType.localizedName(context),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                              ),
                            ),
                          ),
                          if (isOngoing)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.livePulse,
                              ),
                            ),
                        ],
                      ),

                      // Course Name
                      Text(
                        slot.courseName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),

                      // Time
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 12, color: theme.hintColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              DateTimeUtils.formatTimeRange(
                                slot.startTimeMinutes,
                                slot.endTimeMinutes,
                                isArabic: isArabic,
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.hintColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


