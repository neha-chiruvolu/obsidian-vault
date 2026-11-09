import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/expense_provider.dart';
import '../theme.dart';
import '../widgets/instruments.dart';
import '../widgets/materials.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    final days = p.dailyExpense(70);
    var peak = 0.0;
    var peakIdx = 0;
    for (var i = 0; i < days.length; i++) {
      if (days[i] > peak) {
        peak = days[i];
        peakIdx = i;
      }
    }
    final peakDate =
        DateTime.now().subtract(Duration(days: days.length - 1 - peakIdx));
    final avg = p.monthExpense / DateTime.now().day;
    final cats = p.monthByCategory;
    final top = cats.entries.isEmpty
        ? null
        : (cats.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .first;

    final leds = FadeIn(
      child: Row(children: [
        Expanded(
            child: StatLed(
                label: 'AVG / DAY', value: avg, color: AppColors.teal)),
        const SizedBox(width: 12),
        Expanded(
            child: StatLed(
                label: 'PEAK DAY', value: peak, color: AppColors.mustard)),
        const SizedBox(width: 12),
        Expanded(
            child: StatLed(
                label: 'ENTRIES',
                value: p.monthCount.toDouble(),
                color: AppColors.green,
                fmt: (v) => v.round().toString())),
      ]),
    );

    final heat = FadeIn(
      delayMs: 120,
      child: Panel(
        glow: AppColors.teal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Spending heatmap · 70 days'),
            Center(child: Heatmap(days: days)),
          ],
        ),
      ),
    );

    final bars = FadeIn(
      delayMs: 220,
      child: Panel(
        glow: AppColors.green,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Category breakdown · this month'),
            CategoryBars(data: cats),
          ],
        ),
      ),
    );

    final insight = FadeIn(
      delayMs: 320,
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('System insight'),
            Inset(
              child: Text(
                top == null
                    ? '> No expenses recorded this month.'
                    : '> Highest category: ${top.key.label.toUpperCase()} '
                        '(${money(top.value)}).\n'
                        '> Peak spend: ${money(peak)} on ${fmtDate(peakDate)}.\n'
                        '> Budget remaining: ${money(p.budget - p.monthExpense)}.',
                style: mono(12.5, AppColors.green, weight: FontWeight.w500)
                    .copyWith(height: 1.7, shadows: [
                  Shadow(
                      color: AppColors.green.withOpacity(0.6), blurRadius: 8)
                ]),
              ),
            ),
          ],
        ),
      ),
    );

    return LayoutBuilder(builder: (context, c) {
      final two = c.maxWidth >= 760;
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        children: [
          leds,
          const SizedBox(height: 16),
          if (two)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: heat),
              const SizedBox(width: 16),
              Expanded(child: bars),
            ])
          else ...[
            heat,
            const SizedBox(height: 16),
            bars,
          ],
          const SizedBox(height: 16),
          insight,
        ],
      );
    });
  }
}
