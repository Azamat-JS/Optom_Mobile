import 'package:flutter/material.dart';

import 'package:bsmart/core/l10n/l10n.dart';
import 'package:bsmart/shared/widgets/dash_page.dart';

/// One page of rows and whether there are more. Loaders throw the failure on error.
typedef AgentPage<T> = ({List<T> items, bool hasNext});

/// A paged list rendered as a plain [Column] (not scrollable), for tabs that sit inside a page
/// that already scrolls; further pages come with a "Yana ko'rsatish" button. Give it a new [Key]
/// to reload it from page 1.
class AgentPagedColumn<T> extends StatefulWidget {
  const AgentPagedColumn({
    required this.load,
    required this.itemBuilder,
    required this.emptyIcon,
    required this.emptyText,
    super.key,
  });

  final Future<AgentPage<T>> Function(int page) load;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final IconData emptyIcon;
  final String emptyText;

  @override
  State<AgentPagedColumn<T>> createState() => _AgentPagedColumnState<T>();
}

class _AgentPagedColumnState<T> extends State<AgentPagedColumn<T>> {
  final List<T> _items = [];
  int _page = 0;
  bool _hasNext = false;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _next();
  }

  Future<void> _next() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await widget.load(_page + 1);
      if (!mounted) return;
      setState(() {
        _items.addAll(page.items);
        _page += 1;
        _hasNext = page.hasNext;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_items.isEmpty) {
      if (_loading) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (_error != null) return DashEmptyState(icon: Icons.cloud_off_rounded, text: l10n.commonErrorWith('$_error'));
      return DashEmptyState(icon: widget.emptyIcon, text: widget.emptyText);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, item) in _items.indexed) ...[
          if (i > 0) const SizedBox(height: 10),
          widget.itemBuilder(context, item),
        ],
        if (_hasNext || _error != null) ...[
          const SizedBox(height: 12),
          Center(
            child: _loading
                ? const CircularProgressIndicator()
                : TextButton(onPressed: _next, child: Text(l10n.commonLoadMore)),
          ),
        ],
      ],
    );
  }
}
