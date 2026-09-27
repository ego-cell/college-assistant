import 'package:flutter/material.dart';
import '../data/timetable_repository.dart';
import '../models/course_slot.dart';

class TimetableProvider extends ChangeNotifier {
  final TimetableRepository _repository;
  List<CourseSlot> _slots = [];
  int _selectedDay = DateTime.now().weekday;
  bool _isLoading = true;

  // Callback to inform ContextProvider
  void Function(List<CourseSlot>)? onSlotsUpdated;

  TimetableProvider({
    TimetableRepository? repository,
    this.onSlotsUpdated,
  }) : _repository = repository ?? TimetableRepository() {
    loadSlots();
  }

  List<CourseSlot> get allSlots => _slots;
  int get selectedDay => _selectedDay;
  bool get isLoading => _isLoading;

  List<CourseSlot> get slotsForSelectedDay {
    final list = _slots.where((s) => s.dayOfWeek == _selectedDay).toList()
      ..sort((a, b) => a.startTimeMinutes.compareTo(b.startTimeMinutes));
    return list;
  }

  List<CourseSlot> get todaySlots {
    final today = DateTime.now().weekday;
    final list = _slots.where((s) => s.dayOfWeek == today).toList()
      ..sort((a, b) => a.startTimeMinutes.compareTo(b.startTimeMinutes));
    return list;
  }

  List<String> get uniqueCourseNames {
    final names = _slots.map((s) => s.courseName).toSet().toList();
    names.sort();
    return names;
  }

  void setSelectedDay(int day) {
    if (_selectedDay != day) {
      _selectedDay = day;
      notifyListeners();
    }
  }

  Future<void> loadSlots() async {
    _isLoading = true;
    notifyListeners();

    _slots = await _repository.getAllSlots();
    _isLoading = false;
    notifyListeners();

    onSlotsUpdated?.call(_slots);
  }

  Future<void> addSlot(CourseSlot slot) async {
    await _repository.saveSlot(slot);
    await loadSlots();
  }

  Future<void> updateSlot(CourseSlot slot) async {
    await _repository.saveSlot(slot);
    await loadSlots();
  }

  Future<void> deleteSlot(String slotId) async {
    await _repository.deleteSlot(slotId);
    await loadSlots();
  }

  Future<void> setSlotsDirectly(List<CourseSlot> newSlots) async {
    _slots = newSlots;
    notifyListeners();
    onSlotsUpdated?.call(_slots);
  }
}
