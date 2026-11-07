import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/entities/warehouse_params.dart';
import 'package:bsmart/features/warehouse/presentation/providers/warehouse_providers.dart';
import 'package:bsmart/features/warehouse/presentation/screens/ingredient_detail_screen.dart';
import 'package:bsmart/features/warehouse/presentation/screens/ingredient_form_screen.dart';
import 'package:bsmart/features/warehouse/presentation/widgets/warehouse_widgets.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// "Ombor": a restaurant branch's raw ingredients — what's on hand, what's running low, what the
/// stock is worth. Tapping a row opens it (receive, count, write off, history). Owner and admins.
class WarehouseScreen extends ConsumerStatefulWidget {
  const WarehouseScreen({super.key});

  @override
  ConsumerState<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends ConsumerState<WarehouseScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  /// Local, because the provider has no query to read while it reloads after a change.
  IngredientLevelFilter _level = IngredientLevelFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final query = ref.read(ingredientsListProvider).valueOrNull?.query;
    _searchController.text = query?.search ?? '';
    _level = query?.level ?? IngredientLevelFilter.all;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(ingredientsListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => ref.read(ingredientsListProvider.notifier).search(value),
    );
  }

  Future<void> _create() async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const IngredientFormScreen()));
    if (saved == true && mounted) refreshWarehouseViews(ref);
  }

  void _open(Ingredient ingredient) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => IngredientDetailScreen(ingredientId: ingredient.id)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final listState = ref.watch(ingredientsListProvider);
    final result = listState.valueOrNull?.result;

    return DashPage(
      title: l10n.whTitle,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashSearchField(controller: _searchController, hint: l10n.whSearchHint, onChanged: _onSearchChanged),
          const SizedBox(height: 10),
          DashChoiceChips<IngredientLevelFilter>(
            values: IngredientLevelFilter.values,
            selected: _level,
            label: (f) {
              final name = switch (f) {
                IngredientLevelFilter.all => l10n.commonAll,
                IngredientLevelFilter.low => l10n.whFilterLow,
                IngredientLevelFilter.out => l10n.whFilterOut,
              };
              if (result == null) return name;
              final n = switch (f) {
                IngredientLevelFilter.all => result.totalCount,
                IngredientLevelFilter.low => result.lowCount + result.outCount,
                IngredientLevelFilter.out => result.outCount,
              };
              return '$name · $n';
            },
            onSelected: (f) {
              setState(() => _level = f);
              ref.read(ingredientsListProvider.notifier).setLevel(f);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.whAdd,
        onPressed: _create,
        child: const Icon(Icons.add_rounded),
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.cloud_off_rounded,
          text: warehouseErrorText(context, error),
          action: TextButton(onPressed: () => ref.invalidate(ingredientsListProvider), child: Text(l10n.commonRetry)),
        ),
        data: (state) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(ingredientsListProvider.notifier).refresh(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            itemCount: 1 + (state.items.isEmpty ? 1 : state.items.length) + (state.hasNext ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) return _StatsGrid(result: state.result);
              if (state.items.isEmpty) {
                final filtered = _level != IngredientLevelFilter.all || _searchController.text.trim().isNotEmpty;
                return Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    filtered ? l10n.commonNothingFound : l10n.whEmpty,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: BrandColors.of(context).textSecondary, fontWeight: FontWeight.w600),
                  ),
                );
              }
              final i = index - 1;
              if (i >= state.items.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final ingredient = state.items[i];
              return _IngredientRow(
                ingredient: ingredient,
                onTap: () => _open(ingredient),
              ).animate().fadeIn(delay: (25 * (i % 12)).ms, duration: AppMotion.standard);
            },
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.result});

  final IngredientListResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = Theme.of(context).colorScheme.error;
    Widget cell(String label, String value, {Color? color}) => Expanded(
      child: DashCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: BrandColors.of(context).textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  color: color ?? BrandColors.of(context).textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return Column(
      children: [
        Row(
          children: [
            cell(l10n.whStatTotal, '${result.totalCount}'),
            const SizedBox(width: 10),
            cell(l10n.whStatValue, formatSom(result.totalValue)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            cell(l10n.whStatLow, '${result.lowCount}', color: result.lowCount > 0 ? warehouseAmber : null),
            const SizedBox(width: 10),
            cell(l10n.whStatOut, '${result.outCount}', color: result.outCount > 0 ? error : null),
          ],
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.ingredient, required this.onTap});

  final Ingredient ingredient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tint = levelColor(context, ingredient.level);
    return DashListCard(
      onTap: onTap,
      dimmed: !ingredient.isActive,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: tint.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.kitchen_rounded, color: tint),
      ),
      title: ingredient.name,
      titleTrailing: ingredient.isActive
          ? null
          : DashTag(label: l10n.commonInactive, color: Theme.of(context).colorScheme.outline),
      subtitle: [
        if (ingredient.minStock > 0) l10n.whMinShort(formatIngredientQty(ingredient.minStock, ingredient.unit)),
        if (ingredient.avgCost != null) l10n.whAvgPerUnit(formatSom(ingredient.avgCost!), ingredient.unit.shortLabel),
      ].join(' · '),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatIngredientQty(ingredient.stock, ingredient.unit),
            style: TextStyle(
              color: ingredient.stock < 0 ? Theme.of(context).colorScheme.error : BrandColors.of(context).textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          IngredientLevelTag(level: ingredient.level),
        ],
      ),
    );
  }
}
