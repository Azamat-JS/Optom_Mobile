import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bsmart/core/enums/currency.dart';
import 'package:bsmart/core/enums/expenditure_type.dart';
import 'package:bsmart/core/utils/currency_formatter.dart';
import 'package:bsmart/features/expenditures/domain/entities/expenditure.dart';
import 'package:bsmart/features/expenditures/presentation/providers/expenditures_list_notifier.dart';
import 'package:bsmart/features/expenditures/presentation/screens/expenditure_form_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
        title: const Text("Harajatni o'chirish"),
        content: Text(
          '${expenditure.type.label} — ${CurrencyFormatter.format(expenditure.amount, Currency.uzs)} '
          "butunlay o'chirilsinmi?",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("O'chirish")),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(expendituresListProvider.notifier).delete(expenditure.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(expendituresListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Harajatlarim'),
        actions: [
          // PopupMenuButton<T?> can't be used with a null-valued item here:
          // Flutter's own showButtonMenu() treats a null result as "menu
          // dismissed without a selection" and never calls onSelected in
          // that case (popup_menu.dart) — so a `PopupMenuItem(value: null,
          // ...)` for "Barchasi" would be silently unselectable. Sidestepped
          // by keying the button on the wire string instead, with a
          // non-null '' sentinel for "no filter".
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Turi bo\'yicha filtr',
            onSelected: (value) => ref
                .read(expendituresListProvider.notifier)
                .setTypeFilter(value.isEmpty ? null : ExpenditureType.fromWire(value)),
            itemBuilder: (context) => [
              const PopupMenuItem(value: '', child: Text('Barchasi')),
              for (final type in ExpenditureType.values)
                PopupMenuItem(value: type.toWire(), child: Text(type.label)),
            ],
          ),
        ],
      ),
      body: listState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Xatolik: $error')),
        data: (state) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jami xarajat'),
                    Text(
                      CurrencyFormatter.format(state.totalAmount, Currency.uzs),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.items.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () => ref.read(expendituresListProvider.notifier).refresh(),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            Padding(padding: EdgeInsets.only(top: 96), child: Center(child: Text('Harajatlar topilmadi'))),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(expendituresListProvider.notifier).refresh(),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: _scrollController,
                          itemCount: state.items.length + (state.hasNext ? 1 : 0),
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            if (index >= state.items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final expenditure = state.items[index];
                            return ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
                              title: Text(expenditure.type.label),
                              subtitle: Text(
                                [_dateFormat.format(expenditure.date), if (expenditure.notes?.isNotEmpty ?? false) expenditure.notes]
                                    .join(' • '),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(expenditure.amount, Currency.uzs),
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    tooltip: "O'chirish",
                                    onPressed: () => _delete(expenditure),
                                  ),
                                ],
                              ),
                              onTap: () => _openForm(editing: expenditure),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _openForm(), child: const Icon(Icons.add)),
    );
  }
}
