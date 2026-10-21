import 'package:flutter/material.dart';

import 'package:bsmart/core/enums/expenditure_type.dart';
import 'package:bsmart/core/theme/app_colors.dart';

/// Icon per expense type (list rows and the form's type tiles).
IconData expenditureIcon(ExpenditureType type) => switch (type) {
  ExpenditureType.electricity => Icons.bolt_rounded,
  ExpenditureType.gas => Icons.local_fire_department_rounded,
  ExpenditureType.water => Icons.water_drop_rounded,
  ExpenditureType.taxes => Icons.account_balance_rounded,
  ExpenditureType.renting => Icons.home_work_rounded,
  ExpenditureType.other => Icons.more_horiz_rounded,
};

/// Tint per expense type.
Color expenditureColor(ExpenditureType type) => switch (type) {
  ExpenditureType.electricity => const Color(0xFFD9822B),
  ExpenditureType.gas => const Color(0xFFD64545),
  ExpenditureType.water => const Color(0xFF3D6FD6),
  ExpenditureType.taxes => const Color(0xFF7A5AC8),
  ExpenditureType.renting => AppColors.success,
  ExpenditureType.other => const Color(0xFF6B7280),
};
