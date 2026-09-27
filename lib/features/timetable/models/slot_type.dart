import 'package:flutter/material.dart';
import 'package:college_pulse/core/constants/app_colors.dart';
import 'package:college_pulse/core/localization/app_localizations.dart';

enum SlotType {
  lecture,
  section,
  lab,
}

extension SlotTypeExtension on SlotType {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case SlotType.lecture:
        return l10n.slotTypeLecture;
      case SlotType.section:
        return l10n.slotTypeSection;
      case SlotType.lab:
        return l10n.slotTypeLab;
    }
  }

  Color get color {
    switch (this) {
      case SlotType.lecture:
        return AppColors.typeLecture;
      case SlotType.section:
        return AppColors.typeSection;
      case SlotType.lab:
        return AppColors.typeLab;
    }
  }

  IconData get icon {
    switch (this) {
      case SlotType.lecture:
        return Icons.school_rounded;
      case SlotType.section:
        return Icons.group_work_rounded;
      case SlotType.lab:
        return Icons.computer_rounded;
    }
  }
}

