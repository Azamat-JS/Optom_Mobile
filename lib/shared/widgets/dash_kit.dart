import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';

/// Building blocks of the redesigned operator screens (Phase 9 U4: home,
/// reports, POS): a grey page with white rounded cards, bold section titles,
/// pill toggles, stat tiles and shortcut tiles. Colours come from
/// [BrandColors], so light and dark mode follow automatically.
abstract final class DashColors {
  /// Page background behind the cards.
  static Color page(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? BrandColors.of(context).sheet : const Color(0xFFF2F3F6);

  /// Card surface.
  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? BrandColors.of(context).field : Colors.white;

  /// Recessed fill inside a card (photo placeholders, secondary buttons).
  /// In dark mode the card *is* the field colour, so this uses the page.
  static Color inset(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? BrandColors.of(context).sheet : BrandColors.of(context).field;
}

/// White rounded card (raised grey in dark mode).
class DashCard extends StatelessWidget {
  const DashCard({required this.child, this.padding = const EdgeInsets.all(16), this.onTap, super.key});

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DashColors.card(context),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// "Savdo dinamikasi" + optional trailing action.
class DashSectionTitle extends StatelessWidget {
  const DashSectionTitle(this.text, {this.trailing, this.padding = const EdgeInsets.fromLTRB(4, 22, 4, 10), super.key});

  final String text;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Rounded pill segmented toggle (the references' "1W 4W 1Y" chips). The
/// selected pill is yellow; [onDark] renders it for the dark hero card.
class PillToggle<T> extends StatelessWidget {
  const PillToggle({
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
    this.onDark = false,
    this.expand = false,
    super.key,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;
  final bool onDark;

  /// Stretch the pills to the full width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final track = onDark ? Colors.white.withValues(alpha: 0.1) : DashColors.card(context);
    Widget pill(T value) {
      final isSelected = value == selected;
      final child = Semantics(
        selected: isSelected,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: AppMotion.standard,
            curve: AppMotion.emphasized,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.brandYellow : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label(value),
              maxLines: 1,
              style: TextStyle(
                fontFamily: BrandTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? AppColors.onBrand
                    : onDark
                    ? Colors.white.withValues(alpha: 0.75)
                    : colors.textSecondary,
              ),
            ),
          ),
        ),
      );
      return expand ? Expanded(child: child) : child;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: track, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [for (final v in values) pill(v)],
      ),
    );
  }
}

/// Plum-style tile: tinted icon, label, value, optional sub-line. Tappable.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.tint,
    this.onTap,
    this.index = 0,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  /// Icon colour; defaults to gold. Pass the error colour for debts.
  final Color? tint;
  final VoidCallback? onTap;

  /// Position in its grid, for a staggered entrance.
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final color = tint ?? colors.accentText;
    return DashCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 19, color: color),
              ),
              const Spacer(),
              if (onTap != null) Icon(Icons.chevron_right_rounded, size: 20, color: colors.textMuted),
            ],
          ),
          const Spacer(),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textSecondary, fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Always one sub-line, so neighbouring tiles' values line up.
          Text(
            subtitle ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (50 * index).ms, duration: AppMotion.standard).slideY(begin: 0.08, end: 0);
  }
}

/// Icon-on-tile shortcut ("Mahsulotlar", "Mijozlar" …) for the home grid.
class ShortcutTile extends StatelessWidget {
  const ShortcutTile({required this.icon, required this.label, required this.onTap, this.highlight = false, super.key});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Yellow tile for the primary action (Kassa).
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: highlight ? AppColors.brandYellow : DashColors.card(context),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: highlight
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Icon(icon, color: highlight ? AppColors.onBrand : colors.textPrimary, size: 26),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round header button (back, settings, actions) on the grey page.
class DashRoundButton extends StatelessWidget {
  const DashRoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.highlight = false,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Material(
      color: highlight ? AppColors.brandYellow : DashColors.card(context),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: highlight ? AppColors.onBrand : colors.textPrimary, size: 23),
          ),
        ),
      ),
    );
  }
}

/// "Label ........ value" row of a bill card.
class BillRow extends StatelessWidget {
  const BillRow({required this.label, required this.value, this.strong = false, this.muted = false, super.key});

  final String label;
  final String value;
  final bool strong;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final style = TextStyle(
      color: muted ? colors.textSecondary : colors.textPrimary,
      fontSize: strong ? 17 : 15.5,
      fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
    );
    // Label takes the free space; the value hugs the right edge and wraps
    // inside at most 60% of the row.
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: style)),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.6),
            child: Text(value, textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }
}

/// Dashed hairline between bill sections.
class DashedDivider extends StatelessWidget {
  const DashedDivider({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 9).floor();
        return Row(
          children: [
            for (var i = 0; i < count; i++)
              Container(width: 5, height: 1.2, margin: const EdgeInsets.only(right: 4), color: color),
          ],
        );
      },
    );
  }
}

/// Compact "− 2 +" quantity stepper (yellow, like the storefront's ADD).
class DashStepper extends StatelessWidget {
  const DashStepper({required this.value, required this.onMinus, required this.onPlus, this.expand = false, super.key});

  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  /// Stretch to the full width, value centred between the buttons.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, VoidCallback onTap, String tooltip) => InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Tooltip(
        message: tooltip,
        child: SizedBox(width: 34, height: 34, child: Icon(icon, size: 18, color: AppColors.onBrand)),
      ),
    );
    return Material(
      color: AppColors.brandYellow,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          button(Icons.remove_rounded, onMinus, '−'),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 22),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: BrandTheme.fontFamily,
                color: AppColors.onBrand,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          button(Icons.add_rounded, onPlus, '+'),
        ],
      ),
    );
  }
}
