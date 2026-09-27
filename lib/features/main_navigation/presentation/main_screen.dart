import 'package:flutter/material.dart';
import 'package:college_pulse/core/constants/app_colors.dart';
import 'package:college_pulse/core/localization/app_localizations.dart';
import 'package:college_pulse/features/dashboard/presentation/dashboard_screen.dart';
import 'package:college_pulse/features/settings/presentation/settings_screen.dart';
import 'package:college_pulse/features/tasks/presentation/tasks_screen.dart';
import 'package:college_pulse/features/timetable/presentation/timetable_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _navigateToIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final screens = [
      DashboardScreen(
        onNavigateToTimetable: () => _navigateToIndex(1),
        onNavigateToTasks: () => _navigateToIndex(2),
      ),
      const TimetableScreen(),
      const TasksScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToIndex,
        indicatorColor: AppColors.primary.withOpacity(0.18),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard_rounded, color: AppColors.primary),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            label: l10n.navTimetable,
          ),
          NavigationDestination(
            icon: const Icon(Icons.assignment_outlined),
            selectedIcon: const Icon(Icons.assignment_rounded, color: AppColors.primary),
            label: l10n.navTasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded, color: AppColors.primary),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}


