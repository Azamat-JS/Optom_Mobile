import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';

/// Round floating map button (back, fit-to-bounds, my location …) on the
/// full-screen maps (Phase 9: delivery tracking, courier delivery, fleet).
class MapRoundButton extends StatelessWidget {
  const MapRoundButton({required this.icon, required this.tooltip, required this.onTap, this.busy = false, super.key});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  /// Shows a small spinner instead of the icon (and ignores taps).
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: busy ? null : onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 48,
            height: 48,
            child: busy
                ? const Padding(padding: EdgeInsets.all(15), child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(icon, color: scheme.onSurface),
          ),
        ),
      ),
    );
  }
}

/// Top row over a full-screen map: round back button, a title pill and
/// round [actions]. Place it at the top of a `Stack`; it brings its own
/// status-bar inset, and keeps the status-bar icons dark because the map
/// stays light in dark mode too.
class MapTopBar extends StatelessWidget {
  const MapTopBar({required this.title, this.actions = const [], super.key});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              MapRoundButton(
                icon: Icons.arrow_back_rounded,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 10)],
                  ),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              for (final action in actions) ...[const SizedBox(width: 10), action],
            ],
          ),
        ),
      ),
    );
  }
}

/// Round call button for map panels/sheets: ink with a yellow icon, yellow
/// with an ink icon in dark mode (ink would vanish on a dark panel).
class MapCallButton extends StatelessWidget {
  const MapCallButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IconButton.filled(
      tooltip: context.l10n.commonCall,
      style: IconButton.styleFrom(
        backgroundColor: dark ? AppColors.brandYellow : AppColors.ink,
        foregroundColor: dark ? AppColors.onBrand : AppColors.brandYellow,
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.call_rounded),
    );
  }
}
