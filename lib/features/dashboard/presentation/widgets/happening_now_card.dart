import 'package:flutter/material.dart';
import 'package:college_pulse/core/constants/app_colors.dart';
import 'package:college_pulse/core/localization/app_localizations.dart';
import 'package:college_pulse/core/utils/date_time_utils.dart';
import 'package:college_pulse/features/context_engine/context_provider.dart';
import 'package:college_pulse/features/timetable/models/course_slot.dart';
import 'package:college_pulse/features/timetable/models/slot_type.dart';

class HappeningNowCard extends StatefulWidget {
  final ContextProvider contextProvider;
  final VoidCallback onQuickAdd;

  const HappeningNowCard({
    super.key,
    required this.contextProvider,
    required this.onQuickAdd,
  });

  @override
  State<HappeningNowCard> createState() => _HappeningNowCardState();
}

class _HappeningNowCardState extends State<HappeningNowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = l10n.isArabic;

    final hasActive = widget.contextProvider.hasActiveCourse;
    final activeSlot = widget.contextProvider.activeSlot;
    final nextSlot = widget.contextProvider.nextSlot;
    final progress = widget.contextProvider.activeProgress;
    final remainingMinutes = widget.contextProvider.minutesRemaining;

    if (hasActive && activeSlot != null) {
      // Active Lecture Taking Place Right Now!
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (ctx, child) => Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E3A8A), const Color(0xFF0F172A)]
                  : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background accent circles for modern visual flair
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar: "Happening Now" pulse badge & slot type
                    Row(
                      children: [
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
                              const SizedBox(width: 5),
                              Text(
                                l10n.happeningNow,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            activeSlot.slotType.localizedName(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$remainingMinutes ${isArabic ? 'دقيقة متبقية' : 'mins left'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Course Name
                    Text(
                      activeSlot.courseName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Hall / Room & Instructor
                    Row(
                      children: [
                        if (activeSlot.room != null) ...[
                          const Icon(Icons.place_rounded, size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            activeSlot.room!,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(width: 14),
                        ],
                        if (activeSlot.instructorName != null) ...[
                          const Icon(Icons.person_rounded, size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              activeSlot.instructorName!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Class Duration Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.livePulse),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick-Add CTA Button for this Active Class
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: widget.onQuickAdd,
                        icon: const Icon(Icons.bolt_rounded, size: 20, color: AppColors.primary),
                        label: Text(
                          l10n.quickAddForThisClass,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // No Active Lecture: Free Time or Next Class Preview
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.wb_sunny_rounded, color: AppColors.secondary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.freeTime,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.noActiveLecture,
                        style: TextStyle(fontSize: 12, color: theme.hintColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (nextSlot != null) ...[
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${l10n.nextClassIn} ${widget.contextProvider.minutesUntilNext} ${isArabic ? 'دقيقة' : 'mins'}:',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nextSlot.courseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                l10n.enjoyFreeTime,
                style: TextStyle(fontSize: 12, color: theme.hintColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


