import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/expense_provider.dart';
import '../theme.dart';
import '../widgets/materials.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  String _query = '';
  int _filter = 0; // 0 all, 1 income, 2 expense

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    final list = p.items.where((t) {
      final okType = _filter == 0 || (_filter == 1) == t.isIncome;
      final q = _query.toLowerCase();
      final okQuery = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.category.label.toLowerCase().contains(q);
      return okType && okQuery;
    }).toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: Column(children: [
          TextField(
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(color: AppColors.ink),
            decoration: const InputDecoration(
              hintText: 'Search title or category',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            PillToggle(
              labels: const ['ALL', 'INCOME', 'EXPENSE'],
              index: _filter,
              onChanged: (i) => setState(() => _filter = i),
            ),
            const Spacer(),
            Text('${list.length} ENTRIES',
                style: mono(10, AppColors.muted, spacing: 2)),
          ]),
        ]),
      ),
      Expanded(
        child: list.isEmpty
            ? const Center(
                child: Text('No matching entries',
                    style: TextStyle(color: AppColors.muted)))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final t = list[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Dismissible(
                      key: ValueKey(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: AppColors.red.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child:
                            const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        final prov = context.read<ExpenseProvider>();
                        prov.remove(t.id);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Deleted "${t.title}"'),
                          action: SnackBarAction(
                              label: 'UNDO',
                              textColor: AppColors.mustard,
                              onPressed: () => prov.add(t)),
                        ));
                      },
                      child: Panel(
                        radius: 20,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 2),
                        child: TxRow(tx: t),
                      ),
                    ),
                  );
                },
              ),
      ),
    ]);
  }
}
