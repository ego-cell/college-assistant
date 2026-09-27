import 'dart:async';
import 'package:flutter/material.dart';
import 'package:college_pulse/features/timetable/models/course_slot.dart';
import 'context_engine.dart';

class ContextProvider extends ChangeNotifier {
  List<CourseSlot> _slots = [];
  CurrentClassContext _currentContext = CurrentClassContext.empty(DateTime.now());
  Timer? _tickerTimer;

  ContextProvider() {
    _startTicker();
  }

  CurrentClassContext get currentContext => _currentContext;
  CourseSlot? get activeSlot => _currentContext.activeSlot;
  CourseSlot? get nextSlot => _currentContext.nextSlotToday;
  bool get hasActiveCourse => _currentContext.hasActiveCourse;
  double get activeProgress => _currentContext.activeProgress;
  int get minutesRemaining => _currentContext.minutesRemainingInActive;
  int get minutesUntilNext => _currentContext.minutesUntilNext;

  void updateSlots(List<CourseSlot> newSlots) {
    _slots = newSlots;
    evaluateNow();
  }

  void evaluateNow() {
    _currentContext = ContextDetectionEngine.evaluateContext(
      allSlots: _slots,
      currentTime: DateTime.now(),
    );
    notifyListeners();
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    // Re-evaluate every 15 seconds for responsive real-time feedback
    _tickerTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      evaluateNow();
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}

