import 'package:flutter/material.dart';
import 'package:college_pulse/core/constants/app_colors.dart';
import 'package:college_pulse/core/localization/app_localizations.dart';

enum TaskCategory {
  quiz,
  assignment,
  report,
  project,
  personal,
}

extension TaskCategoryExtension on TaskCategory {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case TaskCategory.quiz:
        return l10n.categoryQuiz;
      case TaskCategory.assignment:
        return l10n.categoryAssignment;
      case TaskCategory.report:
        return l10n.categoryReport;
      case TaskCategory.project:
        return l10n.categoryProject;
      case TaskCategory.personal:
        return l10n.categoryPersonal;
    }
  }

  Color get color {
    switch (this) {
      case TaskCategory.quiz:
        return AppColors.categoryQuiz;
      case TaskCategory.assignment:
        return AppColors.categoryAssignment;
      case TaskCategory.report:
        return AppColors.categoryReport;
      case TaskCategory.project:
        return AppColors.categoryProject;
      case TaskCategory.personal:
        return AppColors.categoryPersonal;
    }
  }

  IconData get icon {
    switch (this) {
      case TaskCategory.quiz:
        return Icons.quiz_rounded;
      case TaskCategory.assignment:
        return Icons.assignment_rounded;
      case TaskCategory.report:
        return Icons.menu_book_rounded;
      case TaskCategory.project:
        return Icons.rocket_launch_rounded;
      case TaskCategory.personal:
        return Icons.person_rounded;
    }
  }

  bool get isAcademic => this != TaskCategory.personal;
}

