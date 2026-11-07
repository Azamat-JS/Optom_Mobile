import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient_movement.dart';
import 'package:bsmart/features/warehouse/domain/usecases/delete_ingredient_usecase.dart';
import 'package:bsmart/features/warehouse/presentation/providers/warehouse_providers.dart';
import 'package:bsmart/features/warehouse/presentation/screens/ingredient_adjust_screen.dart';
import 'package:bsmart/features/warehouse/presentation/screens/ingredient_form_screen.dart';
import 'package:bsmart/features/warehouse/presentation/screens/ingredient_receive_screen.dart';
import 'package:bsmart/features/warehouse/presentation/widgets/warehouse_widgets.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// One ingredient: stock and what it's worth, "Kirim" and "Sanoq / chiqarish", the dishes whose
/// recipes use it, and every stock change with what caused it.
class IngredientDetailScreen extends ConsumerWidget {
  const IngredientDetailScreen({required this.ingredientId, super.key});

  final String ingredientId;

  Future<void> _push(BuildContext context, WidgetRef ref, Widget screen) async {
    final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => screen));
    if (saved == true) refreshWarehouseViews(ref, ingredientId: ingredientId);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Ingredient ingredient) async {
    final l10n = context.l10n;
    if (ingredient.recipeCount > 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.whDeleteInRecipes(ingredient.recipeCount))));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.whDeleteTitle),
        content: Text(l10n.whDeleteConfirm(ingredient.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await getIt<DeleteIngredientUseCase>().call(ingredient.id);
    if (!context.mounted) return;
    result.fold((_) {
      refreshWarehouseViews(ref);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.whDeleted(ingredient.name))));
    }, (failure) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message))));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detail = ref.watch(ingredientDetailProvider(ingredientId));
    final ingredient = detail.valueOrNull;

    return DashPage(
      title: ingredient?.name ?? l10n.whTitle,
      actions: [
        if (ingredient != null) ...[
          DashRoundButton(
            icon: Icons.edit_rounded,
            tooltip: l10n.commonEdit,
            onTap: () => _push(context, ref, IngredientFormScreen(editing: ingredient)),
          ),
          DashRoundButton(
            icon: Icons.delete_outline_rounded,
            tooltip: l10n.commonDelete,
            onTap: () => _delete(context, ref, ingredient),
          ),
        ],
      ],
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.cloud_off_rounded,
          text: warehouseErrorText(context, error),
          action: TextButton(
            onPressed: () => ref.invalidate(ingredientDetailProvider(ingredientId)),
            child: Text(l10n.commonRetry),
          ),
        ),
        data: (ingredient) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () async {
            ref.invalidate(ingredientMovementsProvider(ingredientId));
            ref.invalidate(ingredientDetailProvider(ingredientId));
            await ref.read(ingredientDetailProvider(ingredientId).future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              _StockCard(ingredient: ingredient),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                      onPressed: () => _push(context, ref, IngredientReceiveScreen(ingredient: ingredient)),
                      icon: const Icon(Icons.add_box_rounded),
                      label: Text(l10n.whReceiveShort),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                      onPressed: () => _push(context, ref, IngredientAdjustScreen(ingredient: ingredient)),
                      icon: const Icon(Icons.scale_rounded),
                      // Shrinks rather than cutting "Sanoq / chiqarish" / "Пересчёт / списание".
                      label: FittedBox(fit: BoxFit.scaleDown, child: Text(l10n.whAdjustShort, maxLines: 1)),
                    ),
                  ),
                ],
              ),
              if (ingredient.notes?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                DashCard(child: Text(ingredient.notes!)),
              ],
              if (ingredient.usedIn.isNotEmpty) ...[
                DashSectionTitle(l10n.whUsedIn),
                DashCard(
                  child: Column(
                    children: [
                      for (final use in ingredient.usedIn)
                        DashInfoRow(
                          label: use.productName,
                          value: l10n.whPerPortionValue(formatIngredientQty(use.quantity, use.unit)),
                        ),
                    ],
                  ),
                ),
              ],
              DashSectionTitle(l10n.whHistory),
              _History(ingredient: ingredient),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  const _StockCard({required this.ingredient});

  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = Colors.white.withValues(alpha: 0.7);
    TextStyle small(Color c) =>
        TextStyle(fontFamily: BrandTheme.fontFamily, color: c, fontSize: 13.5, fontWeight: FontWeight.w700);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.ink, Color(0xFF2A2108)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.whInStock, style: small(muted))),
              IngredientLevelTag(level: ingredient.level),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatIngredientQty(ingredient.stock, ingredient.unit),
              style: TextStyle(
                fontFamily: BrandTheme.fontFamily,
                color: ingredient.stock < 0 ? const Color(0xFFFCA5A5) : Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
          ),
          if (ingredient.stock < 0) ...[
            const SizedBox(height: 4),
            Text(l10n.whNegativeHint, style: small(const Color(0xFFFCA5A5))),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 18,
            runSpacing: 6,
            children: [
              if (ingredient.minStock > 0)
                Text(l10n.whMinShort(formatIngredientQty(ingredient.minStock, ingredient.unit)), style: small(muted)),
              Text(
                ingredient.avgCost == null
                    ? l10n.whNoCost
                    : l10n.whAvgPerUnit(formatSom(ingredient.avgCost!), ingredient.unit.shortLabel),
                style: small(muted),
              ),
              if (ingredient.value != null) Text(l10n.whValue(formatSom(ingredient.value!)), style: small(muted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _History extends ConsumerWidget {
  const _History({required this.ingredient});

  final Ingredient ingredient;

  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm');

  String _typeLabel(BuildContext context, IngredientMovementType type) {
    final l10n = context.l10n;
    return switch (type) {
      IngredientMovementType.receipt => l10n.whMoveReceipt,
      IngredientMovementType.usage => l10n.whMoveUsage,
      IngredientMovementType.restore => l10n.whMoveRestore,
      IngredientMovementType.adjustment => l10n.whMoveAdjustment,
      IngredientMovementType.waste => l10n.whMoveWaste,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final history = ref.watch(ingredientMovementsProvider(ingredient.id));
    return history.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Text(warehouseErrorText(context, error)),
      data: (state) {
        if (state.items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              l10n.whHistoryEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted),
            ),
          );
        }
        return Column(
          children: [
            DashCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  for (final (i, m) in state.items.indexed) ...[
                    if (i > 0) Divider(height: 1, color: colors.outline),
                    _MovementRow(
                      movement: m,
                      ingredient: ingredient,
                      typeLabel: _typeLabel(context, m.type),
                      dateFormat: _dateFormat,
                    ),
                  ],
                ],
              ),
            ),
            if (state.hasNext)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: state.isLoadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : TextButton(
                        onPressed: () => ref.read(ingredientMovementsProvider(ingredient.id).notifier).loadMore(),
                        child: Text(l10n.whShowMore),
                      ),
              ),
          ],
        );
      },
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({
    required this.movement,
    required this.ingredient,
    required this.typeLabel,
    required this.dateFormat,
  });

  final IngredientMovement movement;
  final Ingredient ingredient;
  final String typeLabel;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final q = movement.quantity;
    final details = [
      ?movement.source,
      ?movement.note,
      [
        dateFormat.format(movement.createdAt),
        ?movement.actorName,
        if (movement.type == IngredientMovementType.receipt && movement.unitCost != null)
          l10n.whAvgPerUnit(formatSom(movement.unitCost!), ingredient.unit.shortLabel),
      ].join(' · '),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.reversed ? '$typeLabel (${l10n.whReversed})' : typeLabel,
                  style: TextStyle(color: colors.textPrimary, fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
                for (final line in details)
                  Text(
                    line,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${q > 0 ? '+' : ''}${formatIngredientQty(q, ingredient.unit)}',
                style: TextStyle(
                  color: q < 0 ? Theme.of(context).colorScheme.error : warehouseGreen,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                l10n.whBalance(formatIngredientQty(movement.balanceAfter, ingredient.unit)),
                style: TextStyle(color: colors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
