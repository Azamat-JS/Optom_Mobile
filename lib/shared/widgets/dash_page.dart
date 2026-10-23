import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// Page frame of the redesigned operator screens (Phase 9 U4c): grey page,
/// no AppBar; a header row with a round back button, a large title and
/// round [actions]; an optional [header] under it (search, filters); then
/// [body], which fills the rest and brings its own scrolling.
class DashPage extends StatelessWidget {
  const DashPage({
    required this.title,
    required this.body,
    this.actions = const [],
    this.header,
    this.bottomBar,
    this.floatingActionButton,
    this.showBack = true,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final Widget? header;
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: DashColors.page(context),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomBar,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    if (showBack) ...[
                      DashRoundButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    for (final (i, action) in actions.indexed) ...[if (i > 0) const SizedBox(width: 8), action],
                  ],
                ),
              ),
              if (header != null) Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 0), child: header),
              const SizedBox(height: 10),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

/// White rounded search field with a clear button.
class DashSearchField extends StatefulWidget {
  const DashSearchField({required this.controller, required this.hint, required this.onChanged, super.key});

  final TextEditingController controller;
  final String hint;

  /// Also called with '' when the clear button empties the field.
  final ValueChanged<String> onChanged;

  @override
  State<DashSearchField> createState() => _DashSearchFieldState();
}

class _DashSearchFieldState extends State<DashSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Container(
      height: 52,
      decoration: BoxDecoration(color: DashColors.card(context), borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, color: colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(color: colors.textMuted, fontWeight: FontWeight.w500),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isCollapsed: true,
              ),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            IconButton(
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              icon: Icon(Icons.close_rounded, color: colors.textSecondary),
              onPressed: () {
                widget.controller.clear();
                widget.onChanged('');
              },
            )
          else
            const SizedBox(width: 14),
        ],
      ),
    );
  }
}

/// Square photo (or icon) in a recessed rounded box.
class DashThumb extends StatelessWidget {
  const DashThumb({this.url, this.icon = Icons.inventory_2_rounded, this.size = 48, this.radius, super.key});

  final String? url;
  final IconData icon;
  final double size;

  /// Corner radius; defaults to a share of [size] (fine for small thumbs,
  /// too round for big tiles, which pass a fixed one).
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final placeholder = Icon(icon, color: colors.textMuted, size: size * 0.46);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? size * 0.27),
      child: Container(
        width: size,
        height: size,
        color: DashColors.inset(context),
        child: url == null
            ? placeholder
            : CachedNetworkImage(imageUrl: url!, fit: BoxFit.cover, errorWidget: (_, _, _) => placeholder),
      ),
    );
  }
}

/// One row of a list as its own white card: leading, title, subtitle,
/// trailing. [dimmed] greys out an inactive entry.
class DashListCard extends StatelessWidget {
  const DashListCard({
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.dimmed = false,
    super.key,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: DashCard(
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w700),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 10), trailing!],
          ],
        ),
      ),
    );
  }
}

/// Icon + message (+ optional action) for an empty or failed list. Scrolls,
/// so pull-to-refresh still works around it.
class DashEmptyState extends StatelessWidget {
  const DashEmptyState({required this.icon, required this.text, this.action, super.key});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      children: [
        const SizedBox(height: 90),
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(color: DashColors.card(context), shape: BoxShape.circle),
            child: Icon(icon, size: 36, color: colors.textMuted),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.textSecondary, fontSize: 15, fontWeight: FontWeight.w600),
        ),
        if (action != null) ...[const SizedBox(height: 14), Center(child: action)],
      ],
    );
  }
}

/// Small tinted label ("Faol emas", "Asosiy" …).
class DashTag extends StatelessWidget {
  const DashTag({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// "Label ……… value" row of an info card.
class DashInfoRow extends StatelessWidget {
  const DashInfoRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.textSecondary, fontSize: 14.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: colors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// Restyles every text field / dropdown under it as a white rounded filled
/// field whose label stays inside the box (forms on the grey page). Fields
/// must not pass their own `border:` for this to apply.
class DashFormTheme extends StatelessWidget {
  const DashFormTheme({required this.child, this.onSheet = false, super.key});

  final Widget child;

  /// Inside a bottom sheet or dialog: use the field fill (grey on the white
  /// sheet in light mode, raised grey on the dark sheet; the recessed
  /// [DashColors.inset] would equal the dark sheet and hide the fields).
  final bool onSheet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = BrandColors.of(context);
    final dark = theme.brightness == Brightness.dark;
    // Underline-type borders keep the floating label inside the filled box;
    // only the bottom edge shows focus / error.
    UnderlineInputBorder border([Color? color, double width = 2]) => UnderlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: color == null ? BorderSide.none : BorderSide(color: color, width: width),
    );
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: onSheet ? colors.field : DashColors.card(context),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: border(),
          enabledBorder: border(),
          disabledBorder: border(),
          focusedBorder: border(dark ? AppColors.brandYellow : AppColors.brandAmber),
          errorBorder: border(theme.colorScheme.error),
          focusedErrorBorder: border(theme.colorScheme.error),
          labelStyle: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
        ),
      ),
      child: child,
    );
  }
}

/// Horizontal row of filter pills (selected = yellow), e.g. order statuses.
class DashChoiceChips<T> extends StatelessWidget {
  const DashChoiceChips({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
    super.key,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final value = values[i];
          final isSelected = value == selected;
          return Semantics(
            selected: isSelected,
            button: true,
            child: Material(
              color: isSelected ? AppColors.brandYellow : DashColors.card(context),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => onSelected(value),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      label(value),
                      style: TextStyle(
                        color: isSelected ? AppColors.onBrand : colors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Sticky full-width yellow button for a page's `bottomBar` (save, place
/// order …). [child] replaces the label, e.g. with a spinner.
class DashBottomButton extends StatelessWidget {
  const DashBottomButton({required this.label, required this.onPressed, this.icon, this.busy = false, super.key});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
    final Widget content = busy
        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
        : Text(label);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: icon == null || busy
            ? FilledButton(onPressed: busy ? null : onPressed, style: style, child: content)
            : FilledButton.icon(onPressed: onPressed, style: style, icon: Icon(icon), label: content),
      ),
    );
  }
}

/// Round yellow initial (grey when [active] is false) for people rows.
class DashAvatar extends StatelessWidget {
  const DashAvatar({required this.name, this.active = true, this.size = 48, super.key});

  final String name;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppColors.brandYellow : DashColors.inset(context),
        shape: BoxShape.circle,
      ),
      child: Text(
        name.trim().characters.firstOrNull?.toUpperCase() ?? '?',
        style: TextStyle(
          color: active ? AppColors.onBrand : colors.textSecondary,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// One entry of a [DashMenuButton].
typedef DashMenuItem = ({String value, IconData icon, String label, bool destructive});

/// "⋯" button opening a rounded menu of row actions (edit, (de)activate,
/// delete); destructive entries are red.
class DashMenuButton extends StatelessWidget {
  const DashMenuButton({required this.items, required this.onSelected, super.key});

  final List<DashMenuItem> items;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final error = Theme.of(context).colorScheme.error;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz_rounded, color: colors.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: DashColors.card(context),
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem(
            value: item.value,
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: item.destructive ? error : colors.textSecondary),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(color: item.destructive ? error : colors.textPrimary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// "3 / 5 … in use" card with a progress bar (waiter / courier limits).
class DashUsageCard extends StatelessWidget {
  const DashUsageCard({required this.label, required this.used, required this.limit, required this.icon, super.key});

  final String label;
  final int used;
  final int limit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final full = limit > 0 && used >= limit;
    return DashCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brandYellow.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colors.accentText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: limit <= 0 ? 0 : (used / limit).clamp(0, 1).toDouble(),
                    minHeight: 7,
                    backgroundColor: DashColors.inset(context),
                    color: full ? Theme.of(context).colorScheme.error : AppColors.brandYellow,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
