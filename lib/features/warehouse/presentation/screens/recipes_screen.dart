import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/presentation/providers/warehouse_providers.dart';
import 'package:bsmart/features/warehouse/presentation/screens/recipe_editor_screen.dart';
import 'package:bsmart/features/warehouse/presentation/widgets/warehouse_widgets.dart';
import 'package:bsmart/shared/widgets/dash_kit.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Sentinel for "all dishes" in the status chips (a null choice can't be selected, see `CLAUDE.md`).
const _all = 'all';

/// "Retseptlar": every dish of the branch, its recipe, and whether the warehouse can make it now —
/// what can't be made comes first, with what's missing.
class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key});

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;
  String _status = _all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final query = ref.read(recipesMenuProvider).valueOrNull?.query;
    _searchController.text = query?.search ?? '';
    _status = query?.status?.toWire() ?? _all;
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
      ref.read(recipesMenuProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => ref.read(recipesMenuProvider.notifier).search(value));
  }

  Future<void> _open(MenuDish dish) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RecipeEditorScreen(productId: dish.productId, dishName: dish.name),
      ),
    );
    if (saved == true && mounted) refreshWarehouseViews(ref);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final menu = ref.watch(recipesMenuProvider);
    final counts = menu.valueOrNull?.counts;
    String chipLabel(String wire) {
      final status = wire == _all ? null : DishStatus.fromWire(wire);
      final name = switch (status) {
        null => l10n.commonAll,
        DishStatus.unavailable => l10n.whFilterUnavailable,
        DishStatus.low => l10n.whFilterLow,
        DishStatus.ok => l10n.whFilterEnough,
        DishStatus.noRecipe => l10n.whFilterNoRecipe,
      };
      return counts == null ? name : '$name · ${counts.of(status)}';
    }

    return DashPage(
      title: l10n.whRecipesTitle,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashSearchField(controller: _searchController, hint: l10n.whSearchDishHint, onChanged: _onSearchChanged),
          const SizedBox(height: 10),
          DashChoiceChips<String>(
            values: [
              _all,
              for (final s in [DishStatus.unavailable, DishStatus.low, DishStatus.ok, DishStatus.noRecipe]) s.toWire(),
            ],
            selected: _status,
            label: chipLabel,
            onSelected: (wire) {
              setState(() => _status = wire);
              ref.read(recipesMenuProvider.notifier).setStatus(wire == _all ? null : DishStatus.fromWire(wire));
            },
          ),
        ],
      ),
      body: menu.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.cloud_off_rounded,
          text: warehouseErrorText(context, error),
          action: TextButton(onPressed: () => ref.invalidate(recipesMenuProvider), child: Text(l10n.commonRetry)),
        ),
        data: (state) {
          final banner = state.counts.unavailable > 0;
          return RefreshIndicator(
            color: AppColors.onBrand,
            backgroundColor: AppColors.brandYellow,
            onRefresh: () => ref.read(recipesMenuProvider.notifier).refresh(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              itemCount: (banner ? 1 : 0) + (state.items.isEmpty ? 1 : state.items.length) + (state.hasNext ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (banner && index == 0) return _UnavailableBanner(count: state.counts.unavailable);
                final i = index - (banner ? 1 : 0);
                if (state.items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Text(
                      _status == _all && _searchController.text.trim().isEmpty
                          ? l10n.whDishesEmpty
                          : l10n.commonNothingFound,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: BrandColors.of(context).textSecondary, fontWeight: FontWeight.w600),
                    ),
                  );
                }
                if (i >= state.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final dish = state.items[i];
                return _DishCard(
                  dish: dish,
                  onTap: () => _open(dish),
                ).animate().fadeIn(delay: (25 * (i % 12)).ms, duration: AppMotion.standard);
              },
            ),
          );
        },
      ),
    );
  }
}

class _UnavailableBanner extends StatelessWidget {
  const _UnavailableBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.no_food_rounded, color: error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.whUnavailableBanner(count),
              style: TextStyle(color: error, fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({required this.dish, required this.onTap});

  final MenuDish dish;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final a = dish.availability;
    final cost = a.portionCost;
    final margin = cost != null && dish.price > 0 ? ((dish.price - cost) / dish.price * 100).round() : null;
    final error = Theme.of(context).colorScheme.error;
    return Opacity(
      opacity: dish.isActive ? 1 : 0.6,
      child: DashCard(
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DashThumb(url: dish.imageUrl, icon: Icons.restaurant_menu_rounded, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textPrimary, fontSize: 15.5, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        [
                          ?dish.categoryName,
                          dish.hasRecipe ? l10n.whIngredientCount(dish.ingredientCount) : l10n.whNoRecipe,
                          if (!dish.isActive) l10n.commonInactive,
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (dish.hasRecipe)
                  DishAvailabilityTag(status: a.status, portions: a.portions)
                else
                  Icon(Icons.add_circle_outline_rounded, color: colors.textMuted),
              ],
            ),
            if (a.missing.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final m in a.missing)
                Text(
                  l10n.whShortLine(m.name, formatIngredientQty(m.short, m.unit)),
                  style: TextStyle(color: error, fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
            ],
            if (dish.hasRecipe) ...[
              const SizedBox(height: 8),
              Text(
                cost == null
                    ? l10n.whCostUnknown
                    : [
                        l10n.whPortionCostValue(formatSom(cost)),
                        l10n.whPriceValue(CurrencyFormatter.format(dish.price, Currency.uzs)),
                        if (margin != null) l10n.whMarginValue(margin),
                      ].join(' · '),
                style: TextStyle(
                  color: margin != null && margin < 0 ? error : colors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
