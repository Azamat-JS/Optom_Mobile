import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/core/di/injection.dart';
import 'package:bsmart/features/agents/domain/entities/agent_account_user.dart';
import 'package:bsmart/features/agents/domain/entities/agent_requests.dart';
import 'package:bsmart/features/agents/domain/entities/agent_transfer.dart';
import 'package:bsmart/features/agents/domain/usecases/get_lead_account_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/list_agent_returns_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/list_agent_staff_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/list_payment_requests_usecase.dart';
import 'package:bsmart/features/agents/domain/usecases/list_received_transfers_usecase.dart';
import 'package:bsmart/features/auth/presentation/providers/session_notifier.dart';

// The lead agent's management screens (Phase 10 A7b). Requests and staff are small working sets
// (one page each); received transfers grow over time, so they page.

class LeadAccountNotifier extends AsyncNotifier<LeadAgentAccount> {
  @override
  Future<LeadAgentAccount> build() {
    ref.watch(currentUserIdProvider);
    return _fetch();
  }

  Future<LeadAgentAccount> _fetch() async {
    final result = await getIt<GetLeadAccountUseCase>().call();
    return result.fold((account) => account, (failure) => throw failure);
  }

  Future<void> refresh() async => state = await AsyncValue.guard(_fetch);
}

final leadAccountProvider = AsyncNotifierProvider<LeadAccountNotifier, LeadAgentAccount>(LeadAccountNotifier.new);

class LeadPaymentRequestsNotifier extends AsyncNotifier<List<AgentPaymentRequest>> {
  @override
  Future<List<AgentPaymentRequest>> build() {
    ref.watch(currentUserIdProvider);
    return _fetch();
  }

  Future<List<AgentPaymentRequest>> _fetch() async {
    final result = await getIt<ListPaymentRequestsUseCase>().call();
    return result.fold((page) => page.data, (failure) => throw failure);
  }

  Future<void> refresh() async => state = await AsyncValue.guard(_fetch);
}

final leadPaymentRequestsProvider = AsyncNotifierProvider<LeadPaymentRequestsNotifier, List<AgentPaymentRequest>>(
  LeadPaymentRequestsNotifier.new,
);

class LeadReturnsNotifier extends AsyncNotifier<List<AgentReturn>> {
  @override
  Future<List<AgentReturn>> build() {
    ref.watch(currentUserIdProvider);
    return _fetch();
  }

  Future<List<AgentReturn>> _fetch() async {
    final result = await getIt<ListAgentReturnsUseCase>().call();
    return result.fold((page) => page.data, (failure) => throw failure);
  }

  Future<void> refresh() async => state = await AsyncValue.guard(_fetch);
}

final leadReturnsProvider = AsyncNotifierProvider<LeadReturnsNotifier, List<AgentReturn>>(LeadReturnsNotifier.new);

class ReceivedTransfersState {
  const ReceivedTransfersState({
    required this.items,
    required this.page,
    this.hasNext = false,
    this.isLoadingMore = false,
  });

  final List<AgentTransfer> items;
  final int page;
  final bool hasNext;
  final bool isLoadingMore;

  ReceivedTransfersState copyWith({List<AgentTransfer>? items, int? page, bool? hasNext, bool? isLoadingMore}) =>
      ReceivedTransfersState(
        items: items ?? this.items,
        page: page ?? this.page,
        hasNext: hasNext ?? this.hasNext,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

class ReceivedTransfersNotifier extends AsyncNotifier<ReceivedTransfersState> {
  @override
  Future<ReceivedTransfersState> build() {
    ref.watch(currentUserIdProvider);
    return _fetch();
  }

  Future<ReceivedTransfersState> _fetch() async {
    final result = await getIt<ListReceivedTransfersUseCase>().call();
    return result.fold(
      (page) => ReceivedTransfersState(items: page.data, page: 1, hasNext: page.meta.hasNext),
      (failure) => throw failure,
    );
  }

  Future<void> refresh() async => state = await AsyncValue.guard(_fetch);

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasNext || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await getIt<ListReceivedTransfersUseCase>().call(page: current.page + 1);
    state = result.fold(
      (page) => AsyncData(
        current.copyWith(
          items: [...current.items, ...page.data],
          page: current.page + 1,
          hasNext: page.meta.hasNext,
          isLoadingMore: false,
        ),
      ),
      (_) => AsyncData(current.copyWith(isLoadingMore: false)),
    );
  }
}

final receivedTransfersProvider = AsyncNotifierProvider<ReceivedTransfersNotifier, ReceivedTransfersState>(
  ReceivedTransfersNotifier.new,
);

class AgentStaffListNotifier extends AsyncNotifier<List<AgentAccountUser>> {
  @override
  Future<List<AgentAccountUser>> build() {
    ref.watch(currentUserIdProvider);
    return _fetch();
  }

  Future<List<AgentAccountUser>> _fetch() async {
    final result = await getIt<ListAgentStaffUseCase>().call();
    return result.fold((page) => page.data, (failure) => throw failure);
  }

  Future<void> refresh() async => state = await AsyncValue.guard(_fetch);
}

final agentStaffListProvider = AsyncNotifierProvider<AgentStaffListNotifier, List<AgentAccountUser>>(
  AgentStaffListNotifier.new,
);
