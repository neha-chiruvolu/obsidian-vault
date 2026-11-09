import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/expense_provider.dart';
import '../theme.dart';
import '../widgets/instruments.dart';
import '../widgets/materials.dart';

class ConsoleScreen extends StatelessWidget {
  const ConsoleScreen({super.key});

  Widget _status(double f) {
    final Color c;
    final String t;
    if (f < 0.7) {
      c = AppColors.green;
      t = 'NOMINAL';
    } else if (f <= 1) {
      c = AppColors.mustard;
      t = 'CAUTION';
    } else {
      c = AppColors.red;
      t = 'OVER LIMIT';
    }
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: c.withOpacity(0.9), blurRadius: 10)],
        ),
      ),
      const SizedBox(width: 8),
      Text(t, style: mono(10, c, spacing: 2)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    final h = DateTime.now().hour;
    final greet = h < 12
        ? 'GOOD MORNING'
        : h < 17
            ? 'GOOD AFTERNOON'
            : 'GOOD EVENING';
    final f = p.budget <= 0 ? 0.0 : p.monthExpense / p.budget;
    final saved = p.monthIncome - p.monthExpense;
    final recent = p.items.take(5).toList();

    final card = FadeIn(child: MetalCard(name: p.userName, balance: p.balance));

    final gauge = FadeIn(
      delayMs: 120,
      child: Panel(
        child: Column(children: [
          SectionLabel('Budget gauge', trailing: _status(f)),
          GaugeDial(fraction: f, size: 250),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('SPENT ${money(p.monthExpense)}',
                style: mono(11, AppColors.muted, spacing: 1.5)),
            Text('LEFT ${money(math.max(0, p.budget - p.monthExpense))}',
                style: mono(11, AppColors.ink, spacing: 1.5)),
          ]),
        ]),
      ),
    );

    final stats = FadeIn(
      delayMs: 200,
      child: Row(children: [
        Expanded(
            child: StatLed(
                label: 'INCOME', value: p.monthIncome, color: AppColors.green)),
        const SizedBox(width: 12),
        Expanded(
            child: StatLed(
                label: 'SPENT',
                value: p.monthExpense,
                color: AppColors.mustard)),
        const SizedBox(width: 12),
        Expanded(
            child: StatLed(
                label: 'NET', value: saved, color: AppColors.teal)),
      ]),
    );

    final scope = FadeIn(
      delayMs: 280,
      child: Panel(
        glow: AppColors.teal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Cash flow · 14 days'),
            Inset(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
              child: Scope(values: p.dailyExpense(14), height: 210),
            ),
          ],
        ),
      ),
    );

    final recentPanel = FadeIn(
      delayMs: 360,
      child: Panel(
        glow: AppColors.blue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Latest entries'),
            if (recent.isEmpty)
              const Text('No entries yet. Press + to add one.',
                  style: TextStyle(color: AppColors.muted)),
            for (final t in recent) TxRow(tx: t),
          ],
        ),
      ),
    );

    final cats = FadeIn(
      delayMs: 440,
      child: Panel(
        glow: AppColors.green,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Spend by category'),
            CategoryBars(data: p.monthByCategory),
          ],
        ),
      ),
    );

    return LayoutBuilder(builder: (context, c) {
      final two = c.maxWidth >= 760;
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greet · ${fmtDate(DateTime.now()).toUpperCase()}',
                    style: mono(11, AppColors.muted, spacing: 3)),
                const SizedBox(height: 6),
                GoldText(
                  p.userName.isEmpty ? 'WELCOME' : p.userName.toUpperCase(),
                  size: 28,
                  spacing: 4,
                ),
              ],
            ),
          ),
          if (two)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 6, child: card),
              const SizedBox(width: 20),
              Expanded(flex: 5, child: gauge),
            ])
          else ...[
            card,
            const SizedBox(height: 22),
            gauge,
          ],
          const SizedBox(height: 16),
          stats,
          const SizedBox(height: 16),
          scope,
          const SizedBox(height: 16),
          if (two)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: recentPanel),
              const SizedBox(width: 16),
              Expanded(child: cats),
            ])
          else ...[
            recentPanel,
            const SizedBox(height: 16),
            cats,
          ],
        ],
      );
    });
  }
}
