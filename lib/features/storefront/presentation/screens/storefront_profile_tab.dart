import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/router/route_names.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/auth/presentation/widgets/telegram_notifications_tile.dart';
import 'package:bsmart/features/auth/presentation/widgets/verify_phone_banner.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// The "Profil" tab — a guest sees login/register entry points; a logged-in
/// `CUSTOMER` sees their own orders/debts (both reused as-is from their
/// respective owner-side features — see route wiring in `app_router.dart`)
/// and can log out.
///
/// Phase 9 U4c6: profile card (initial, name, phone, verified tag), the
/// verify banner, a menu card (orders, deliveries, debts), a card with the
/// Telegram notifications switch and settings, and a red logout button.
class StorefrontProfileTab extends ConsumerWidget {
  const StorefrontProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final user = ref.watch(sessionNotifierProvider).valueOrNull?.user;
    final error = Theme.of(context).colorScheme.error;

    final settingsRow = _MenuRow(
      icon: Icons.settings_rounded,
      tint: colors.textSecondary,
      label: l10n.commonSettings,
      onTap: () => context.push(RouteNames.settings),
    );

    if (user == null) {
      return DashPage(
        title: l10n.navProfile,
        showBack: false,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            DashCard(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(color: DashColors.inset(context), shape: BoxShape.circle),
                      child: Icon(Icons.person_rounded, size: 38, color: colors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.profileLoginPrompt,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () => context.push(RouteNames.login),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: Text(l10n.commonLogin),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => context.push(RouteNames.register),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: Text(l10n.commonRegister),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            DashCard(padding: const EdgeInsets.symmetric(vertical: 4), child: settingsRow),
          ],
        ),
      );
    }

    return DashPage(
      title: l10n.navProfile,
      showBack: false,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          DashCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                DashAvatar(name: user.firstName, size: 60),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.phone,
                        style: TextStyle(color: colors.textMuted, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      if (user.phoneVerified) ...[
                        const SizedBox(height: 6),
                        DashTag(label: l10n.profilePhoneVerified, color: AppColors.success),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (user.needsPhoneVerification) ...[
            const SizedBox(height: 12),
            VerifyPhoneBanner(message: l10n.verifyBannerProfile),
          ],
          const SizedBox(height: 12),
          DashCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                _MenuRow(
                  icon: Icons.receipt_long_rounded,
                  tint: colors.accentText,
                  label: l10n.profileMyOrders,
                  onTap: () => context.push(RouteNames.orders),
                ),
                Divider(height: 1, indent: 64, color: colors.outline),
                _MenuRow(
                  icon: Icons.delivery_dining_rounded,
                  tint: const Color(0xFF3D6FD6),
                  label: l10n.profileMyDeliveries,
                  onTap: () => context.push(RouteNames.customerDeliveries),
                ),
                Divider(height: 1, indent: 64, color: colors.outline),
                _MenuRow(
                  icon: Icons.account_balance_wallet_rounded,
                  tint: error,
                  label: l10n.profileMyDebts,
                  onTap: () => context.push(RouteNames.customerDebts),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DashCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                const TelegramNotificationsTile(),
                Divider(height: 1, indent: 64, color: colors.outline),
                settingsRow,
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => ref.read(sessionNotifierProvider.notifier).logout(),
            style: OutlinedButton.styleFrom(
              foregroundColor: error,
              side: BorderSide(color: error.withValues(alpha: 0.5)),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: Text(l10n.commonLogout),
          ),
        ],
      ),
    );
  }
}

/// Tinted icon tile + label + chevron.
class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.tint, required this.label, required this.onTap});

  final IconData icon;
  final Color tint;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: tint.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: tint, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w700),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}
