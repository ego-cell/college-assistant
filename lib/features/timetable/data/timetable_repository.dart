import 'package:college_pulse/core/services/storage_service.dart';
import '../models/course_slot.dart';

class TimetableRepository {
  final StorageService _storageService;

  TimetableRepository({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  Future<List<CourseSlot>> getAllSlots() async {
    return await _storageService.loadSlots();
  }

  Future<List<CourseSlot>> getSlotsForDay(int dayOfWeek) async {
    final all = await getAllSlots();
    final daySlots = all.where((s) => s.dayOfWeek == dayOfWeek).toList()
      ..sort((a, b) => a.startTimeMinutes.compareTo(b.startTimeMinutes));
    return daySlots;
  }

  Future<void> saveSlot(CourseSlot slot) async {
    final all = await getAllSlots();
    final index = all.indexWhere((s) => s.id == slot.id);
    if (index >= 0) {
      all[index] = slot;
    } else {
      all.add(slot);
    }
    await _storageService.saveSlots(all);
  }

  Future<void> deleteSlot(String slotId) async {
    final all = await getAllSlots();
    all.removeWhere((s) => s.id == slotId);
    await _storageService.saveSlots(all);
  }

  Future<void> saveAllSlots(List<CourseSlot> slots) async {
    await _storageService.saveSlots(slots);
  }
}

