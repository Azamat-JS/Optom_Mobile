import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/core/enums/master_product_status.dart';
import 'package:bsmart/features/master_catalog/domain/entities/master_product.dart';
import 'package:bsmart/features/master_catalog/domain/usecases/search_master_catalog_usecase.dart';

class MasterCatalogAdminQuery {
  const MasterCatalogAdminQuery({this.page = 1, this.search, this.status});

  final int page;
  final String? search;
  final MasterProductStatus? status;

  MasterCatalogAdminQuery copyWith({int? page, String? search, MasterProductStatus? status, bool clearStatus = false}) {
    return MasterCatalogAdminQuery(
      page: page ?? this.page,
      search: search ?? this.search,
      status: clearStatus ? null : (status ?? this.status),
    );
  }
}

class MasterCatalogAdminListState {
  const MasterCatalogAdminListState({
    required this.items,
    required this.query,
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  final List<MasterProduct> items;
  final MasterCatalogAdminQuery query;
  final bool hasNext;
  final bool isLoadingMore;

  MasterCatalogAdminListState copyWith({
    List<MasterProduct>? items,
    MasterCatalogAdminQuery? query,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return MasterCatalogAdminListState(
      items: items ?? this.items,
      query: query ?? this.query,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

const _limit = 20;

/// The master-catalog admin list — filtering [MasterCatalogAdminQuery.status]
/// to `pending` turns this same screen into the moderation review queue, per
/// the plan's "reusable ReviewQueueScreen" idea (one screen, not a separate
/// queue UI).
class MasterCatalogAdminListNotifier extends AsyncNotifier<MasterCatalogAdminListState> {
  @override
  Future<MasterCatalogAdminListState> build() => _fetch(const MasterCatalogAdminQuery());

  Future<MasterCatalogAdminListState> _fetch(MasterCatalogAdminQuery query) async {
    final result = await getIt<SearchMasterCatalogUseCase>().call(
      search: query.search,
      status: query.status,
      page: query.page,
      limit: _limit,
    );
    return result.fold(
      (page) => MasterCatalogAdminListState(items: page.data, query: query, hasNext: page.meta.hasNext),
      (failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    final current = state.valueOrNull?.query ?? const MasterCatalogAdminQuery();
    state = await AsyncValue.guard(() => _fetch(current.copyWith(page: 1)));
  }

  Future<void> setStatus(MasterProductStatus? status) async {
    final current = state.valueOrNull?.query ?? const MasterCatalogAdminQuery();
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(current.copyWith(status: status, clearStatus: status == null, page: 1)),
    );
  }

  Future<void> search(String? query) async {
    final current = state.valueOrNull?.query ?? const MasterCatalogAdminQuery();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(current.copyWith(search: query, page: 1)));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextQuery = current.query.copyWith(page: current.query.page + 1);
    final result = await getIt<SearchMasterCatalogUseCase>().call(
      search: nextQuery.search,
      status: nextQuery.status,
      page: nextQuery.page,
      limit: _limit,
    );
    state = result.fold(
      (page) => AsyncData(
        current.copyWith(
          items: [...current.items, ...page.data],
          query: nextQuery,
          hasNext: page.meta.hasNext,
          isLoadingMore: false,
        ),
      ),
      (failure) => AsyncData(current.copyWith(isLoadingMore: false)),
    );
  }
}

final masterCatalogAdminListProvider =
    AsyncNotifierProvider<MasterCatalogAdminListNotifier, MasterCatalogAdminListState>(
  MasterCatalogAdminListNotifier.new,
);
