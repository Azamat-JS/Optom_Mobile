import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/network/api_exception.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/crm/domain/crm_due.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// "11.12.2026" for a stored calendar day (kept in UTC, never shifted).
final crmDayFormat = DateFormat('dd.MM.yyyy');

/// "125 400" — km, grouped like the app's money.
final crmKmFormat = NumberFormat.decimalPattern('uz');

/// "4", "1,5" — quantities without trailing zeros.
final crmQtyFormat = NumberFormat('#,##0.###', 'uz');

/// A failed CRM request as text: a 403 means SUPER_ADMIN hasn't switched CRM on (or switched it
/// off while the menu was still open).
String crmErrorText(BuildContext context, Object error) {
  final l10n = context.l10n;
  if (error is ForbiddenApiException) return l10n.crmNotEnabled;
  return l10n.commonErrorWith(error is ApiException ? error.message : '$error');
}

/// A plate drawn like the physical one: bordered and monospaced.
class PlateBadge extends StatelessWidget {
  const PlateBadge({required this.plate, this.large = false, super.key});

  /// As stored ("01A123BC"); formatted here.
  final String plate;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 10 : 7, vertical: large ? 5 : 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.textSecondary.withValues(alpha: 0.6), width: 1.2),
      ),
      child: Text(
        formatPlate(plate),
        style: TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w800,
          fontSize: large ? 15 : 12.5,
          letterSpacing: 0.6,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

/// The driver's photo, or their initial on the yellow circle.
class DriverPhoto extends StatelessWidget {
  const DriverPhoto({required this.name, this.url, this.active = true, this.size = 48, super.key});

  final String name;
  final String? url;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url == null) return DashAvatar(name: name, active: active, size: size);
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => DashAvatar(name: name, active: active, size: size),
      ),
    );
  }
}

/// "11.12.2026 · 3 kun qoldi": red when overdue, amber within 3 days (when alerts go out).
class DueText extends StatelessWidget {
  const DueText({required this.dueDate, this.fontSize = 13, this.bold = false, super.key});

  final DateTime dueDate;
  final double fontSize;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final days = daysUntil(dueDate);
    final relative = days == 0
        ? l10n.crmDueToday
        : days > 0
            ? l10n.crmDueIn(days)
            : l10n.crmOverdueBy(-days);
    final color = switch (dueStage(days)) {
      DueStage.overdue => Theme.of(context).colorScheme.error,
      DueStage.soon => const Color(0xFFB86E00),
      DueStage.later => BrandColors.of(context).textSecondary,
    };
    return Text(
      '${crmDayFormat.format(dueDate)} · $relative',
      style: TextStyle(color: color, fontSize: fontSize, fontWeight: bold ? FontWeight.w800 : FontWeight.w600),
    );
  }
}
