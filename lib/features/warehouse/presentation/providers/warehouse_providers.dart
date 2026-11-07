import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/business_type.dart';
import 'package:bsmart/core/enums/user_role.dart';
import 'package:bsmart/core/network/result.dart';
import 'package:bsmart/features/active_store/presentation/active_store_notifier.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';
import 'package:bsmart/features/warehouse/domain/entities/dish.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient.dart';
import 'package:bsmart/features/warehouse/domain/entities/ingredient_movement.dart';
import 'package:bsmart/features/warehouse/domain/entities/warehouse_params.dart';
import 'package:bsmart/features/warehouse/domain/usecases/get_dish_availability_usecase.dart';
import 'package:bsmart/features/warehouse/domain/usecases/get_ingredient_usecase.dart';
import 'package:bsmart/features/warehouse/domain/usecases/get_recipe_usecase.dart';
import 'package:bsmart/features/warehouse/domain/usecases/get_warehouse_summary_usecase.dart';
import 'package:bsmart/features/warehouse/domain/usecases/list_ingredient_movements_usecase.dart';
import 'package:bsmart/features/warehouse/domain/usecases/list_ingredients_usecase.dart';
import 'package:bsmart/features/warehouse/domain/usecases/list_menu_dishes_usecase.dart';

// Restaurant warehouse + recipes (Optom_Savdo "Restaurant Warehouse & Recipes"). Everything is
// scoped to the active branch server-side, so the app-wide providers watch the signed-in user and
// the active store and start over when either changes.

T _unwrap<T>(Result<T> result) => result.fold((value) => value, (failure) => throw failure);

/// Owner and admins of a restaurant: may open Ombor / Retseptlar.
final canManageWarehouseProvider = Provider<bool>((ref) {
  final user = ref.watch(sessionNotifierProvider).valueOrNull?.user;
  return user?.businessType == BusinessType.restaurant &&
      (user?.role == UserRole.retailer || user?.role == UserRole.retailerAdmin);
});

/// Those plus waiters: may read whether a dish can be made (menu badges).
final canReadDishAvailabilityProvider = Provider<bool>((ref) {
  final user = ref.watch(sessionNotifierProvider).valueOrNull?.user;
  return user?.businessType == BusinessType.restaurant &&
      (user?.role == UserRole.retailer || user?.role == UserRole.retailerAdmin || user?.role == UserRole.waiter);
});

// --- Ingredients ----------------------------------------------------------------------------

class IngredientsListState {
  const IngredientsListState({
    required this.result,
    required this.items,
    required this.query,
    this.isLoadingMore = false,
  });

  /// The latest page's counts / total value (tabs and stat cards).
  final IngredientListResult result;
  final List<Ingredient> items;
  final IngredientQuery query;
  final bool isLoadingMore;

  bool get hasNext => result.hasNext;

  IngredientsListState copyWith({
    IngredientListResult? result,
    List<Ingredient>? items,
    IngredientQuery? query,
    bool? isLoadingMore,
  }) => IngredientsListState(
    result: result ?? this.result,
    items: items ?? this.items,
    query: query ?? this.query,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

class IngredientsListNotifier extends AsyncNotifier<IngredientsListState> {
  @override
  Future<IngredientsListState> build() {
    ref.watch(currentUserIdProvider);
    ref.watch(activeStoreNotifierProvider);
    return _fetch(const IngredientQuery());
  }

  Future<IngredientsListState> _fetch(IngredientQuery query) async {
    final result = _unwrap(await getIt<ListIngredientsUseCase>().call(query));
    return IngredientsListState(result: result, items: result.items, query: query);
  }

  IngredientQuery get _query => state.valueOrNull?.query ?? const IngredientQuery();

  Future<void> refresh() async => state = await AsyncValue.guard(() => _fetch(_query.copyWith(page: 1)));

  Future<void> search(String text) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(_query.copyWith(page: 1, search: text)));
  }

  Future<void> setLevel(IngredientLevelFilter level) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(_query.copyWith(page: 1, level: level)));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final next = current.query.copyWith(page: current.query.page + 1);
    final result = await getIt<ListIngredientsUseCase>().call(next);
    state = AsyncData(
      result.fold(
        (page) =>
            current.copyWith(result: page, items: [...current.items, ...page.items], query: next, isLoadingMore: false),
        (_) => current.copyWith(isLoadingMore: false),
      ),
    );
  }
}

final ingredientsListProvider = AsyncNotifierProvider<IngredientsListNotifier, IngredientsListState>(
  IngredientsListNotifier.new,
);

/// One ingredient with the recipes that use it.
final ingredientDetailProvider = FutureProvider.autoDispose.family<Ingredient, String>((ref, id) async {
  return _unwrap(await getIt<GetIngredientUseCase>().call(id));
});

class IngredientMovementsState {
  const IngredientMovementsState({
    required this.items,
    required this.page,
    required this.hasNext,
    this.isLoadingMore = false,
  });

  final List<IngredientMovement> items;
  final int page;
  final bool hasNext;
  final bool isLoadingMore;
}

/// An ingredient's stock history, newest first, 30 at a time.
class IngredientMovementsNotifier extends AutoDisposeFamilyAsyncNotifier<IngredientMovementsState, String> {
  @override
  Future<IngredientMovementsState> build(String ingredientId) async {
    final page = _unwrap(await getIt<ListIngredientMovementsUseCase>().call(ingredientId));
    return IngredientMovementsState(items: page.data, page: 1, hasNext: page.meta.hasNext);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;
    state = AsyncData(
      IngredientMovementsState(items: current.items, page: current.page, hasNext: true, isLoadingMore: true),
    );
    final result = await getIt<ListIngredientMovementsUseCase>().call(arg, page: current.page + 1);
    state = AsyncData(
      result.fold(
        (page) => IngredientMovementsState(
          items: [...current.items, ...page.data],
          page: current.page + 1,
          hasNext: page.meta.hasNext,
        ),
        (_) => current,
      ),
    );
  }
}

final ingredientMovementsProvider = AsyncNotifierProvider.autoDispose
    .family<IngredientMovementsNotifier, IngredientMovementsState, String>(IngredientMovementsNotifier.new);

// --- Recipes / menu -------------------------------------------------------------------------

class RecipesMenuState {
  const RecipesMenuState({
    required this.items,
    required this.counts,
    required this.query,
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  final List<MenuDish> items;
  final DishStatusCounts counts;
  final MenuQuery query;
  final bool hasNext;
  final bool isLoadingMore;

  RecipesMenuState copyWith({
    List<MenuDish>? items,
    DishStatusCounts? counts,
    MenuQuery? query,
    bool? hasNext,
    bool? isLoadingMore,
  }) => RecipesMenuState(
    items: items ?? this.items,
    counts: counts ?? this.counts,
    query: query ?? this.query,
    hasNext: hasNext ?? this.hasNext,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// Every dish of the branch with whether it can be made now: unavailable first, then low, then
/// without a recipe, then fine (the server's order).
class RecipesMenuNotifier extends AsyncNotifier<RecipesMenuState> {
  @override
  Future<RecipesMenuState> build() {
    ref.watch(currentUserIdProvider);
    ref.watch(activeStoreNotifierProvider);
    return _fetch(const MenuQuery());
  }

  Future<RecipesMenuState> _fetch(MenuQuery query) async {
    final r = _unwrap(await getIt<ListMenuDishesUseCase>().call(query));
    return RecipesMenuState(items: r.items, counts: r.counts, query: query, hasNext: r.hasNext);
  }

  MenuQuery get _query => state.valueOrNull?.query ?? const MenuQuery();

  Future<void> refresh() async => state = await AsyncValue.guard(() => _fetch(_query.copyWith(page: 1)));

  Future<void> search(String text) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(_query.copyWith(page: 1, search: text)));
  }

  Future<void> setStatus(DishStatus? status) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(_query.copyWith(page: 1, status: status, clearStatus: status == null)));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final next = current.query.copyWith(page: current.query.page + 1);
    final result = await getIt<ListMenuDishesUseCase>().call(next);
    state = AsyncData(
      result.fold(
        (r) => current.copyWith(
          items: [...current.items, ...r.items],
          counts: r.counts,
          query: next,
          hasNext: r.hasNext,
          isLoadingMore: false,
        ),
        (_) => current.copyWith(isLoadingMore: false),
      ),
    );
  }
}

final recipesMenuProvider = AsyncNotifierProvider<RecipesMenuNotifier, RecipesMenuState>(RecipesMenuNotifier.new);

final recipeDetailProvider = FutureProvider.autoDispose.family<RecipeDetail, String>((ref, productId) async {
  return _unwrap(await getIt<GetRecipeUseCase>().call(productId));
});

/// productId → whether the warehouse can make the dish now (dishes with a recipe only). Empty for
/// anyone who can't read it, and on any error: the badge is advisory and never blocks ordering.
final dishAvailabilityProvider = FutureProvider<Map<String, DishAvailabilityEntry>>((ref) async {
  ref.watch(currentUserIdProvider);
  ref.watch(activeStoreNotifierProvider);
  if (!ref.watch(canReadDishAvailabilityProvider)) return const {};
  final result = await getIt<GetDishAvailabilityUseCase>().call();
  return result.fold((map) => map, (_) => const {});
});

/// Counts for the home-screen badges (null when not a restaurant owner/admin, or on error).
final warehouseSummaryProvider = FutureProvider<WarehouseSummary?>((ref) async {
  ref.watch(currentUserIdProvider);
  ref.watch(activeStoreNotifierProvider);
  if (!ref.watch(canManageWarehouseProvider)) return null;
  final result = await getIt<GetWarehouseSummaryUseCase>().call();
  return result.fold((s) => s, (_) => null);
});

/// After any stock or recipe change: everything that shows stock-derived figures reloads.
/// The two lists keep their search/filter: they reload in place when already open.
void refreshWarehouseViews(WidgetRef ref, {String? ingredientId}) {
  if (ref.exists(ingredientsListProvider)) ref.read(ingredientsListProvider.notifier).refresh();
  if (ref.exists(recipesMenuProvider)) ref.read(recipesMenuProvider.notifier).refresh();
  ref.invalidate(dishAvailabilityProvider);
  ref.invalidate(warehouseSummaryProvider);
  if (ingredientId != null) {
    ref.invalidate(ingredientDetailProvider(ingredientId));
    ref.invalidate(ingredientMovementsProvider(ingredientId));
  }
}
