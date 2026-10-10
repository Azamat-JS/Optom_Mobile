import 'package:flutter/widgets.dart';

import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/l10n/app_localizations.dart';

export 'package:bsmart/l10n/app_localizations.dart';

extension L10nX on BuildContext {
  /// `context.l10n.someKey` — the generated strings for the active locale.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension UserRoleL10n on UserRole {
  /// Localized display name (the ARB `roleLabel` select is keyed by enum name).
  String localizedLabel(AppLocalizations l10n) => l10n.roleLabel(name);
}
