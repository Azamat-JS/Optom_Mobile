import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsmart/features/customers/domain/entities/customer.dart';
import 'package:bsmart/features/customers/presentation/providers/customers_list_notifier.dart';
import 'package:bsmart/features/customers/presentation/screens/customer_form_screen.dart';

/// Full customer roster with search, create, and deactivate — a plain
/// full-screen list (pushed from the dashboard or picked from POS's
/// checkout sheet, see `CustomerPickerSheet`).
class CustomersListScreen extends ConsumerStatefulWidget {
  const CustomersListScreen({super.key});

  @override
  ConsumerState<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends ConsumerState<CustomersListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
      ref.read(customersListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(customersListProvider.notifier).search(value);
    });
  }

  Future<void> _openForm({Customer? editing}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CustomerFormScreen(editingCustomer: editing)),
    );
    if (saved == true) ref.read(customersListProvider.notifier).refresh();
  }

  Future<void> _deactivate(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mijozni faolsizlantirish'),
        content: Text('${customer.fullName} faolsizlantirilsinmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Bekor qilish')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Faolsizlantirish')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(customersListProvider.notifier).deactivate(customer.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(customersListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mijozlar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Ism yoki telefon bo\'yicha qidirish...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: listState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Xatolik: $error')),
              data: (state) {
                if (state.items.isEmpty) {
                  return const Center(child: Text('Mijozlar topilmadi'));
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(customersListProvider.notifier).refresh(),
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
                      final customer = state.items[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(customer.firstName.characters.first)),
                        title: Text(customer.fullName),
                        subtitle: Text(customer.phone ?? '—'),
                        trailing: customer.isActive
                            ? IconButton(
                                icon: const Icon(Icons.block_outlined),
                                tooltip: 'Faolsizlantirish',
                                onPressed: () => _deactivate(customer),
                              )
                            : const Chip(label: Text('Faol emas'), visualDensity: VisualDensity.compact),
                        onTap: () => _openForm(editing: customer),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}
