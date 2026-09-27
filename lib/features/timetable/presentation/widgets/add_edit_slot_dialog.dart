import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:college_pulse/core/constants/app_colors.dart';
import 'package:college_pulse/core/constants/app_constants.dart';
import 'package:college_pulse/core/localization/app_localizations.dart';
import 'package:college_pulse/core/utils/date_time_utils.dart';
import 'package:college_pulse/features/timetable/models/course_slot.dart';
import 'package:college_pulse/features/timetable/models/slot_type.dart';

class AddEditSlotDialog extends StatefulWidget {
  final CourseSlot? slotToEdit;
  final int initialDay;
  final List<String> existingCourses;
  final void Function(CourseSlot slot) onSave;

  const AddEditSlotDialog({
    super.key,
    this.slotToEdit,
    required this.initialDay,
    this.existingCourses = const [],
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    CourseSlot? slotToEdit,
    required int initialDay,
    List<String> existingCourses = const [],
    required void Function(CourseSlot slot) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddEditSlotDialog(
          slotToEdit: slotToEdit,
          initialDay: initialDay,
          existingCourses: existingCourses,
          onSave: onSave,
        ),
      ),
    );
  }

  @override
  State<AddEditSlotDialog> createState() => _AddEditSlotDialogState();
}

class _AddEditSlotDialogState extends State<AddEditSlotDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _courseNameController;
  late TextEditingController _instructorController;
  late TextEditingController _roomController;

  late int _selectedDay;
  late int _startTimeMinutes;
  late int _endTimeMinutes;
  late SlotType _selectedSlotType;
  late int _selectedColorHex;

  @override
  void initState() {
    super.initState();
    final slot = widget.slotToEdit;

    _courseNameController = TextEditingController(text: slot?.courseName ?? '');
    _instructorController = TextEditingController(text: slot?.instructorName ?? '');
    _roomController = TextEditingController(text: slot?.room ?? '');

    _selectedDay = slot?.dayOfWeek ?? widget.initialDay;
    _startTimeMinutes = slot?.startTimeMinutes ?? (9 * 60); // 09:00 AM
    _endTimeMinutes = slot?.endTimeMinutes ?? (10 * 60 + 30); // 10:30 AM
    _selectedSlotType = slot?.slotType ?? SlotType.lecture;
    _selectedColorHex = slot?.colorHex ?? AppColors.coursePalette[0].value;
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _instructorController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _pickStartTime() async {
    final initial = DateTimeUtils.minutesToTimeOfDay(_startTimeMinutes);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      final minutes = DateTimeUtils.timeOfDayToMinutes(picked);
      setState(() {
        _startTimeMinutes = minutes;
        if (_endTimeMinutes <= _startTimeMinutes) {
          _endTimeMinutes = _startTimeMinutes + 90; // Default 1.5h duration
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final initial = DateTimeUtils.minutesToTimeOfDay(_endTimeMinutes);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      final minutes = DateTimeUtils.timeOfDayToMinutes(picked);
      if (minutes > _startTimeMinutes) {
        setState(() {
          _endTimeMinutes = minutes;
        });
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.slotToEdit?.id ?? const Uuid().v4();
    final slot = CourseSlot(
      id: id,
      courseName: _courseNameController.text.trim(),
      instructorName: _instructorController.text.trim().isEmpty
          ? null
          : _instructorController.text.trim(),
      room: _roomController.text.trim().isEmpty ? null : _roomController.text.trim(),
      dayOfWeek: _selectedDay,
      startTimeMinutes: _startTimeMinutes,
      endTimeMinutes: _endTimeMinutes,
      slotType: _selectedSlotType,
      colorHex: _selectedColorHex,
    );

    widget.onSave(slot);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final theme = Theme.of(context);
    final isEditing = widget.slotToEdit != null;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? l10n.editSlot : l10n.addSlot,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Course Name
              Text(
                l10n.courseNameLabel,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _courseNameController,
                decoration: InputDecoration(
                  hintText: isArabic ? 'مثال: هياكل بيانات' : 'e.g. Data Structures',
                  prefixIcon: const Icon(Icons.menu_book_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return isArabic ? 'اسم المادة مطلوب' : 'Course name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Slot Type Selector Chips (Lecture, Section, Lab)
              Text(
                isArabic ? 'نوع الحصة' : 'Slot Type',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: SlotType.values.map((type) {
                  final isSelected = _selectedSlotType == type;
                  final color = type.color;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        avatar: Icon(
                          type.icon,
                          size: 16,
                          color: isSelected ? Colors.white : color,
                        ),
                        label: Text(type.localizedName(context)),
                        selected: isSelected,
                        selectedColor: color,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedSlotType = type);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Day of Week
              Text(
                l10n.selectDayLabel,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AppConstants.standardWeekDays.map((day) {
                    final isSelected = _selectedDay == day;
                    return Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: FilterChip(
                        label: Text(l10n.dayName(day)),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedDay = day);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),

              // Start & End Time Pickers
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.startTimeLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickStartTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: theme.inputDecorationTheme.fillColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  DateTimeUtils.formatMinutesOfDay(_startTimeMinutes, isArabic: isArabic),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.endTimeLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickEndTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: theme.inputDecorationTheme.fillColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_filled_rounded, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  DateTimeUtils.formatMinutesOfDay(_endTimeMinutes, isArabic: isArabic),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Room & Instructor
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.roomLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _roomController,
                          decoration: InputDecoration(
                            hintText: isArabic ? 'مدرج 204' : 'Hall 204',
                            prefixIcon: const Icon(Icons.place_outlined, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.instructorNameLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _instructorController,
                          decoration: InputDecoration(
                            hintText: isArabic ? 'د. أحمد' : 'Dr. Ahmed',
                            prefixIcon: const Icon(Icons.person_outline, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Color Palette selector
              Text(
                isArabic ? 'لون التمييز' : 'Color Tag',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: AppColors.coursePalette.map((color) {
                  final isSelected = _selectedColorHex == color.value;
                  return InkWell(
                    onTap: () => setState(() => _selectedColorHex = color.value),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.6),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(l10n.saveSlot),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}


