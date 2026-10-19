import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/storefront/presentation/providers/delivery_address_providers.dart';
import 'package:bsmart/features/storefront/presentation/screens/delivery_pin_screen.dart';
import 'package:bsmart/features/storefront/presentation/widgets/storefront_search_parts.dart';

/// "Manzilni tanlang" (the reference's "Select your location"): search over
/// this device's saved addresses, current location, pick on the map, and the
/// recent-address list. Pops a [SavedAddress]; the choice is also remembered.
///
/// The search only filters saved addresses: the app has no place search
/// (that would need a paid places API).
class DeliveryAddressScreen extends ConsumerStatefulWidget {
  const DeliveryAddressScreen({super.key});

  static Future<SavedAddress?> open(BuildContext context) =>
      Navigator.of(context).push<SavedAddress>(MaterialPageRoute(builder: (_) => const DeliveryAddressScreen()));

  @override
  ConsumerState<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends ConsumerState<DeliveryAddressScreen> {
  String _query = '';

  Future<void> _done(SavedAddress? address) async {
    if (address == null) return;
    await ref.read(savedAddressesProvider.notifier).remember(address);
    if (mounted) Navigator.of(context).pop(address);
  }

  Future<void> _fromMap({required bool locate}) async {
    final picked = await DeliveryPinScreen.open(context, locateOnStart: locate);
    await _done(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: BrandTheme.of(context),
      child: Builder(
        builder: (context) {
          final colors = BrandColors.of(context);
          final saved = ref.watch(savedAddressesProvider).valueOrNull ?? const <SavedAddress>[];
          final needle = _query.trim().toLowerCase();
          final shown = needle.isEmpty ? saved : saved.where((a) => a.text.toLowerCase().contains(needle)).toList();
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
              statusBarColor: Colors.transparent,
            ),
            child: Scaffold(
              backgroundColor: dark ? colors.sheet : const Color(0xFFF2F3F6),
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.addrSelectTitle,
                          style: TextStyle(color: colors.textPrimary, fontSize: 21, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (v) => setState(() => _query = v),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.addrSearchHint,
                        filled: true,
                        fillColor: colors.sheet,
                        suffixIcon: Icon(Icons.search_rounded, color: colors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Panel(
                      children: [
                        _ActionRow(
                          icon: Icons.my_location_rounded,
                          label: l10n.addrUseCurrent,
                          onTap: () => _fromMap(locate: true),
                        ),
                        Divider(height: 1, indent: 64, color: colors.outline),
                        _ActionRow(
                          icon: Icons.map_rounded,
                          label: l10n.addrPickOnMap,
                          onTap: () => _fromMap(locate: false),
                        ),
                      ],
                    ),
                    SearchSectionLabel(text: l10n.addrRecent),
                    if (shown.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          l10n.addrNoneSaved,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      )
                    else
                      _Panel(
                        children: [
                          for (var i = 0; i < shown.length; i++) ...[
                            if (i > 0) Divider(height: 1, indent: 76, color: colors.outline),
                            _AddressRow(
                              address: shown[i],
                              onTap: () => _done(shown[i]),
                              onRemove: () => ref.read(savedAddressesProvider.notifier).remove(shown[i]),
                            ).animate().fadeIn(delay: (40 * i).ms, duration: AppMotion.standard),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark ? colors.field : Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: colors.accentText),
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: colors.accentText, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({required this.address, required this.onTap, required this.onRemove});

  final SavedAddress address;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: colors.field, borderRadius: BorderRadius.circular(14)),
              child: Icon(
                address.point != null ? Icons.location_on_outlined : Icons.history_rounded,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textPrimary, fontSize: 16.5, fontWeight: FontWeight.w800),
                  ),
                  if (address.rest.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      address.rest,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colors.textSecondary, fontSize: 14, height: 1.35),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.addrRemove,
              onPressed: onRemove,
              icon: Icon(Icons.close_rounded, size: 20, color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// The yellow-tinted location badge used for "Yetkazish manzili" rows.
class AddressBadge extends StatelessWidget {
  const AddressBadge({this.pickup = false, super.key});

  final bool pickup;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.brandYellow.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(pickup ? Icons.storefront_rounded : Icons.near_me_rounded, color: AppColors.brandAmber),
    );
  }
}
