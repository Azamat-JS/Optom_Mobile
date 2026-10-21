import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/core/theme/app_colors.dart';
import 'package:bsmart/core/theme/app_motion.dart';
import 'package:bsmart/core/theme/brand_theme.dart';
import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/expenditure_type.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure.dart';
import 'package:bsmart/features/expenditures/presentation/providers/expenditures_list_notifier.dart';
import 'package:bsmart/features/expenditures/presentation/screens/expenditure_form_screen.dart';
import 'package:bsmart/features/expenditures/presentation/widgets/expenditure_visuals.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// Owner-only overhead-spending log ("Harajatlarim") — full CRUD, no
/// `_ADMIN` access at all (see `CLAUDE.md` "Expenditures"). Deliberately no
/// currency toggle anywhere in this feature — every amount is always so'm.
class ExpendituresListScreen extends ConsumerStatefulWidget {
  const ExpendituresListScreen({super.key});

  @override
  ConsumerState<ExpendituresListScreen> createState() => _ExpendituresListScreenState();
}

class _ExpendituresListScreenState extends ConsumerState<ExpendituresListScreen> {
  final _scrollController = ScrollController();
  static final _dateFormat = DateFormat('dd.MM.yyyy');

  /// Selected type chip ('' = all). Local, because the provider is briefly
  /// loading (no query to read) right after a change.
  String _typeWire = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _typeWire = ref.read(expendituresListProvider).valueOrNull?.query.type?.toWire() ?? '';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(expendituresListProvider.notifier).loadMore();
    }
  }

  Future<void> _openForm({Expenditure? editing}) async {
    final saved = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => ExpenditureFormScreen(editingExpenditure: editing)));
    if (saved == true) ref.read(expendituresListProvider.notifier).refresh();
  }

  Future<void> _delete(Expenditure expenditure) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.expensesDeleteTitle),
        content: Text(
          context.l10n.expensesDeleteConfirm(
            '${expenditure.type.label} — ${CurrencyFormatter.format(expenditure.amount, Currency.uzs)}',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(context.l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(context.l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(expendituresListProvider.notifier).delete(expenditure.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.commonErrorWith('$e'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = BrandColors.of(context);
    final listState = ref.watch(expendituresListProvider);

    return DashPage(
      title: l10n.expensesTitle,
      // A non-null '' sentinel keeps "Barchasi" selectable (see the
      // PopupMenuButton note in `CLAUDE.md`: never key a choice on null).
      header: DashChoiceChips<String>(
        values: ['', for (final type in ExpenditureType.values) type.toWire()],
        selected: _typeWire,
        label: (w) => w.isEmpty ? l10n.commonAll : ExpenditureType.fromWire(w).label,
        onSelected: (w) {
          setState(() => _typeWire = w);
          ref.read(expendituresListProvider.notifier).setTypeFilter(w.isEmpty ? null : ExpenditureType.fromWire(w));
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.expensesNewTitle,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add_rounded),
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => DashEmptyState(
          icon: Icons.cloud_off_rounded,
          text: l10n.commonErrorWith('$error'),
          action: TextButton(onPressed: () => ref.invalidate(expendituresListProvider), child: Text(l10n.commonRetry)),
        ),
        data: (state) => RefreshIndicator(
          color: AppColors.onBrand,
          backgroundColor: AppColors.brandYellow,
          onRefresh: () => ref.read(expendituresListProvider.notifier).refresh(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            // Total card + rows (or the empty message) + the paging spinner.
            itemCount: 1 + (state.items.isEmpty ? 1 : state.items.length) + (state.hasNext ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) return _TotalCard(total: state.totalAmount, label: l10n.expensesTotal);
              if (state.items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Text(
                    l10n.expensesNotFound,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
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
              final expenditure = state.items[i];
              final tint = expenditureColor(expenditure.type);
              return DashListCard(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(expenditureIcon(expenditure.type), color: tint),
                ),
                title: expenditure.type.label,
                subtitle: [
                  _dateFormat.format(expenditure.date),
                  if (expenditure.notes?.isNotEmpty ?? false) expenditure.notes!,
                ].join(' · '),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CurrencyFormatter.format(expenditure.amount, Currency.uzs),
                      style: TextStyle(color: colors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: colors.textMuted),
                      tooltip: l10n.commonDelete,
                      onPressed: () => _delete(expenditure),
                    ),
                  ],
                ),
                onTap: () => _openForm(editing: expenditure),
              ).animate().fadeIn(delay: (25 * (i % 12)).ms, duration: AppMotion.standard);
            },
          ),
        ),
      ),
    );
  }
}

/// Dark card with the filter-aware total (`meta.totalAmount`).
class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total, required this.label});

  final double total;
  final String label;

  @override
  Widget build(BuildContext context) {
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
          Text(
            label,
            style: TextStyle(
              fontFamily: BrandTheme.fontFamily,
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(total, Currency.uzs),
              style: const TextStyle(
                fontFamily: BrandTheme.fontFamily,
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
