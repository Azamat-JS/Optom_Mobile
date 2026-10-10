import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';

/// AppBar gear that opens Settings (language, logout) — shared by every
/// role's home shell.
class SettingsActionButton extends StatelessWidget {
  const SettingsActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      tooltip: context.l10n.commonSettings,
      onPressed: () => context.push(RouteNames.settings),
    );
  }
}
