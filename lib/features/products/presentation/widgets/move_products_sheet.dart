import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/products/domain/entities/product_move_result.dart';
import 'package:bsmart/features/products/domain/usecases/move_products_to_store_usecase.dart';
import 'package:bsmart/features/stores/domain/entities/store.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';

/// "Boshqa do'konga yuborish": pick one of the owner's other active stores and
/// send the selected products there (Optom_Savdo CLAUDE.md "Moving Products
/// Between Stores"). All or nothing: a refusal keeps the sheet open with the
/// server's reason (it names the products). Resolves to the result on success,
/// null when dismissed.
class MoveProductsSheet extends StatefulWidget {
  const MoveProductsSheet({super.key, required this.productIds, required this.source, required this.targets});

  final List<String> productIds;
  final Store? source;
  final List<Store> targets;

  static Future<ProductMoveResult?> show(
    BuildContext context, {
    required List<String> productIds,
    required Store? source,
    required List<Store> targets,
  }) => showModalBottomSheet<ProductMoveResult>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => MoveProductsSheet(productIds: productIds, source: source, targets: targets),
  );

  @override
  State<MoveProductsSheet> createState() => _MoveProductsSheetState();
}

class _MoveProductsSheetState extends State<MoveProductsSheet> {
  late String? _targetId = widget.targets.length == 1 ? widget.targets.single.id : null;
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    final targetId = _targetId;
    if (targetId == null) return setState(() => _error = context.l10n.productsMovePickStore);
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await getIt<MoveProductsToStoreUseCase>().call(widget.productIds, targetId);
    if (!mounted) return;
    result.fold(
      (moved) => Navigator.of(context).pop(moved),
      (failure) => setState(() {
        _busy = false;
        _error = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.productsMoveTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                l10n.productsMoveFrom(widget.productIds.length, widget.source?.name ?? ''),
                style: TextStyle(color: colors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.productsMoveTarget,
                style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              for (final (i, store) in widget.targets.indexed) ...[
                if (i > 0) const SizedBox(height: 8),
                _StoreOption(
                  store: store,
                  selected: store.id == _targetId,
                  onTap: _busy ? null : () => setState(() => _targetId = store.id),
                ).animate(delay: AppMotion.fast * 0.3 * i).fadeIn(duration: AppMotion.standard),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(color: DashColors.inset(context), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final note in [l10n.productsMoveNoteMoves, l10n.productsMoveNoteHistory, l10n.productsMoveNoteBlocked])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6, right: 8),
                              child: Icon(Icons.circle, size: 5, color: colors.textMuted),
                            ),
                            Expanded(
                              child: Text(
                                note,
                                style: TextStyle(color: colors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  key: const Key('moveProductsError'),
                  style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: _busy || _targetId == null ? null : _submit,
                icon: _busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.swap_horiz_rounded),
                label: Text(l10n.productsMoveSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreOption extends StatelessWidget {
  const _StoreOption({required this.store, required this.selected, required this.onTap});

  final Store store;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = BrandColors.of(context);
    return DashCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      outlineColor: selected ? AppColors.brandYellow : colors.textMuted.withValues(alpha: 0.25),
      child: Row(
        children: [
          Icon(Icons.storefront_rounded, color: selected ? colors.accentText : colors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w700),
                ),
                if (store.address != null && store.address!.trim().isNotEmpty)
                  Text(
                    store.address!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          Icon(
            selected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
            color: selected ? colors.accentText : colors.textMuted,
          ),
        ],
      ),
    );
  }
}
