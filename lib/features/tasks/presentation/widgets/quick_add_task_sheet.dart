import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:college_pulse/core/constants/app_colors.dart';
import 'package:college_pulse/core/constants/app_constants.dart';
import 'package:college_pulse/core/localization/app_localizations.dart';
import 'package:college_pulse/core/utils/date_time_utils.dart';
import 'package:college_pulse/features/timetable/models/course_slot.dart';
import 'package:college_pulse/features/timetable/models/slot_type.dart';
import 'package:college_pulse/features/tasks/models/task_category.dart';
import 'package:college_pulse/features/tasks/models/task_item.dart';

enum DeadlinePreset {
  nextWeekClassTime,
  tomorrow,
  in3Days,
  custom,
}

class QuickAddTaskSheet extends StatefulWidget {
  final CourseSlot? presetSlot;
  final List<CourseSlot> availableSlots;
  final void Function(TaskItem task) onTaskCreated;

  const QuickAddTaskSheet({
    super.key,
    this.presetSlot,
    required this.availableSlots,
    required this.onTaskCreated,
  });

  static Future<void> show(
    BuildContext context, {
    CourseSlot? presetSlot,
    required List<CourseSlot> availableSlots,
    required void Function(TaskItem task) onTaskCreated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: QuickAddTaskSheet(
          presetSlot: presetSlot,
          availableSlots: availableSlots,
          onTaskCreated: onTaskCreated,
        ),
      ),
    );
  }

  @override
  State<QuickAddTaskSheet> createState() => _QuickAddTaskSheetState();
}

class _QuickAddTaskSheetState extends State<QuickAddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  CourseSlot? _selectedSlot;
  bool _isAutoDetected = false;
  TaskCategory _selectedCategory = TaskCategory.assignment;

  DeadlinePreset _selectedPreset = DeadlinePreset.nextWeekClassTime;
  late DateTime _selectedDueDate;

  // Selected reminder offsets in minutes
  final Set<int> _selectedReminderOffsets = {
    AppConstants.reminder24h,
    AppConstants.reminder2h,
  };

  @override
  void initState() {
    super.initState();
    _selectedSlot = widget.presetSlot;
    _isAutoDetected = widget.presetSlot != null;

    // Default category based on slot type if available
    if (widget.presetSlot != null) {
      if (widget.presetSlot!.slotType == SlotType.lab) {
        _selectedCategory = TaskCategory.assignment; // Lab sheet
      } else if (widget.presetSlot!.slotType == SlotType.lecture) {
        _selectedCategory = TaskCategory.assignment;
      }
    }

    _computeInitialDueDate();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _computeInitialDueDate() {
    final now = DateTime.now();
    if (_selectedSlot != null) {
      _selectedDueDate = DateTimeUtils.calculateNextWeekClassTime(
        _selectedSlot!.dayOfWeek,
        _selectedSlot!.startTimeMinutes,
      );
      _selectedPreset = DeadlinePreset.nextWeekClassTime;
    } else {
      // Default to tomorrow 23:59
      _selectedDueDate = DateTime(now.year, now.month, now.day + 1, 23, 59);
      _selectedPreset = DeadlinePreset.tomorrow;
    }
  }

  void _onPresetSelected(DeadlinePreset preset) async {
    final now = DateTime.now();
    setState(() => _selectedPreset = preset);

    switch (preset) {
      case DeadlinePreset.nextWeekClassTime:
        if (_selectedSlot != null) {
          setState(() {
            _selectedDueDate = DateTimeUtils.calculateNextWeekClassTime(
              _selectedSlot!.dayOfWeek,
              _selectedSlot!.startTimeMinutes,
            );
          });
        } else {
          setState(() {
            _selectedDueDate = now.add(const Duration(days: 7));
          });
        }
        break;
      case DeadlinePreset.tomorrow:
        setState(() {
          _selectedDueDate = DateTime(now.year, now.month, now.day + 1, 23, 59);
        });
        break;
      case DeadlinePreset.in3Days:
        setState(() {
          _selectedDueDate = DateTime(now.year, now.month, now.day + 3, 23, 59);
        });
        break;
      case DeadlinePreset.custom:
        await _pickCustomDateTime();
        break;
    }
  }

  Future<void> _pickCustomDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDueDate),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _selectedPreset = DeadlinePreset.custom;
        });
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final isPersonal = _selectedCategory == TaskCategory.personal;
    final task = TaskItem(
      id: const Uuid().v4(),
      courseId: isPersonal ? null : _selectedSlot?.id,
      courseName: isPersonal ? null : _selectedSlot?.courseName,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _selectedCategory,
      createdAt: DateTime.now(),
      dueDate: _selectedDueDate,
      reminderOffsetsInMinutes: _selectedReminderOffsets.toList(),
    );

    widget.onTaskCreated(task);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).taskSavedSuccess),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isArabic = l10n.isArabic;
    final isDark = theme.brightness == Brightness.dark;

    // Unique courses from available slots
    final coursesMap = <String, CourseSlot>{};
    for (final s in widget.availableSlots) {
      if (!coursesMap.containsKey(s.courseName)) {
        coursesMap[s.courseName] = s;
      }
    }
    final courseSlotsList = coursesMap.values.toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.quickAddTitle,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Auto-detected Context Banner
              if (_isAutoDetected && _selectedSlot != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.livePulse.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.livePulse.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.livePulse, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.autoDetectedBanner,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.livePulse,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_selectedSlot!.courseName} (${_selectedSlot!.slotType.localizedName(context)})',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF0F5132),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Target Subject Selector (only if not Personal Task)
              if (_selectedCategory != TaskCategory.personal) ...[
                Text(
                  l10n.targetCourse,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedSlot?.courseName,
                      hint: Text(l10n.manualCourseSelect),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: courseSlotsList.map((slot) {
                        return DropdownMenuItem<String>(
                          value: slot.courseName,
                          child: Text(
                            slot.courseName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedSlot = coursesMap[val];
                            _isAutoDetected = false;
                            // Re-calculate deadline if preset is same class time
                            if (_selectedPreset == DeadlinePreset.nextWeekClassTime &&
                                _selectedSlot != null) {
                              _selectedDueDate = DateTimeUtils.calculateNextWeekClassTime(
                                _selectedSlot!.dayOfWeek,
                                _selectedSlot!.startTimeMinutes,
                              );
                            }
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Category / Type Chips
              Text(
                l10n.taskCategory,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TaskCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    final color = cat.color;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6, left: 6),
                      child: ChoiceChip(
                        avatar: Icon(
                          cat.icon,
                          size: 16,
                          color: isSelected ? Colors.white : color,
                        ),
                        label: Text(cat.localizedName(context)),
                        selected: isSelected,
                        selectedColor: color,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Task Title
              Text(
                l10n.taskTitleLabel,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: l10n.taskTitleHint,
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.fillRequiredFields;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Task Notes / Description
              Text(
                l10n.taskDescriptionLabel,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: l10n.taskDescriptionHint,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.notes_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Deadline Quick Presets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.deadlinePresets,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Text(
                    DateTimeUtils.formatSmartDate(_selectedDueDate, isArabic: isArabic),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Next week same class time (only if course slot is selected)
                  if (_selectedSlot != null)
                    ActionChip(
                      avatar: const Icon(Icons.update_rounded, size: 16),
                      label: Text(l10n.presetNextWeekClassTime),
                      backgroundColor: _selectedPreset == DeadlinePreset.nextWeekClassTime
                          ? AppColors.primary.withOpacity(0.15)
                          : null,
                      side: _selectedPreset == DeadlinePreset.nextWeekClassTime
                          ? const BorderSide(color: AppColors.primary, width: 1.5)
                          : null,
                      onPressed: () => _onPresetSelected(DeadlinePreset.nextWeekClassTime),
                    ),

                  // Tomorrow
                  ActionChip(
                    avatar: const Icon(Icons.today_rounded, size: 16),
                    label: Text(l10n.presetTomorrow),
                    backgroundColor: _selectedPreset == DeadlinePreset.tomorrow
                        ? AppColors.primary.withOpacity(0.15)
                        : null,
                    side: _selectedPreset == DeadlinePreset.tomorrow
                        ? const BorderSide(color: AppColors.primary, width: 1.5)
                        : null,
                    onPressed: () => _onPresetSelected(DeadlinePreset.tomorrow),
                  ),

                  // In 3 days
                  ActionChip(
                    avatar: const Icon(Icons.date_range_rounded, size: 16),
                    label: Text(l10n.presetIn3Days),
                    backgroundColor: _selectedPreset == DeadlinePreset.in3Days
                        ? AppColors.primary.withOpacity(0.15)
                        : null,
                    side: _selectedPreset == DeadlinePreset.in3Days
                        ? const BorderSide(color: AppColors.primary, width: 1.5)
                        : null,
                    onPressed: () => _onPresetSelected(DeadlinePreset.in3Days),
                  ),

                  // Custom Date Picker
                  ActionChip(
                    avatar: const Icon(Icons.more_time_rounded, size: 16),
                    label: Text(l10n.presetCustom),
                    backgroundColor: _selectedPreset == DeadlinePreset.custom
                        ? AppColors.primary.withOpacity(0.15)
                        : null,
                    side: _selectedPreset == DeadlinePreset.custom
                        ? const BorderSide(color: AppColors.primary, width: 1.5)
                        : null,
                    onPressed: () => _onPresetSelected(DeadlinePreset.custom),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reminder Triggers
              Text(
                l10n.remindersLabel,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: Text(l10n.reminder48hLabel),
                    selected: _selectedReminderOffsets.contains(AppConstants.reminder48h),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedReminderOffsets.add(AppConstants.reminder48h);
                        } else {
                          _selectedReminderOffsets.remove(AppConstants.reminder48h);
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.reminder24hLabel),
                    selected: _selectedReminderOffsets.contains(AppConstants.reminder24h),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedReminderOffsets.add(AppConstants.reminder24h);
                        } else {
                          _selectedReminderOffsets.remove(AppConstants.reminder24h);
                        }
                      });
                    },
                  ),
                  FilterChip(
                    label: Text(l10n.reminder2hLabel),
                    selected: _selectedReminderOffsets.contains(AppConstants.reminder2h),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedReminderOffsets.add(AppConstants.reminder2h);
                        } else {
                          _selectedReminderOffsets.remove(AppConstants.reminder2h);
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(l10n.saveTask),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}


