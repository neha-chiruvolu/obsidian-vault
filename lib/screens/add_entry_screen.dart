import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/expense_provider.dart';
import '../theme.dart';
import '../widgets/materials.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _income = false;
  Category _category = Category.food;
  DateTime _date = DateTime.now();

  List<Category> get _options => _income
      ? [Category.salary, Category.other]
      : Category.values.where((c) => c != Category.salary).toList();

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _date = d);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ExpenseProvider>().add(TransactionItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: _title.text.trim(),
          amount: double.parse(_amount.text.trim()),
          isIncome: _income,
          category: _category,
          date: _date,
          note: _note.text.trim(),
        ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Entry committed')));
  }

  Widget _typeButton(String label, bool value, IconData icon, Color color) {
    final sel = _income == value;
    return Expanded(
      child: PressScale(
        onTap: () => setState(() {
          _income = value;
          _category = _options.first;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: sel
                  ? [color.withOpacity(0.35), color.withOpacity(0.12)]
                  : const [Color(0xFF14191D), Color(0xFF0A0D0F)],
            ),
            border: Border.all(
                color: sel ? color : Colors.white.withOpacity(0.08),
                width: sel ? 1.5 : 1),
            boxShadow: sel
                ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 18)]
                : [],
          ),
          child: Column(children: [
            Icon(icon, color: sel ? color : AppColors.muted),
            const SizedBox(height: 6),
            Text(label,
                style: mono(11, sel ? color : AppColors.muted, spacing: 2.5)),
          ]),
        ),
      ),
    );
  }

  Widget _catTile(Category c) {
    final sel = _category == c;
    return PressScale(
      onTap: () => setState(() => _category = c),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 92,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0A0D0F),
          border: Border.all(
              color: sel ? c.color : Colors.white.withOpacity(0.08),
              width: sel ? 1.5 : 1),
          boxShadow:
              sel ? [BoxShadow(color: c.color.withOpacity(0.45), blurRadius: 16)] : [],
        ),
        child: Column(children: [
          Icon(c.icon, color: sel ? c.color : AppColors.muted),
          const SizedBox(height: 6),
          Text(c.label,
              style: TextStyle(
                  fontSize: 12,
                  color: sel ? AppColors.ink : AppColors.muted)),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NEW ENTRY', style: mono(14, AppColors.ink, spacing: 3)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Panel(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      _typeButton('EXPENSE', false, Icons.north_east,
                          AppColors.mustard),
                      const SizedBox(width: 12),
                      _typeButton(
                          'INCOME', true, Icons.south_west, AppColors.green),
                    ]),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _title,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          labelText: 'Title',
                          prefixIcon: Icon(Icons.edit_outlined)),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter a title'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _amount,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: mono(22, AppColors.mustard),
                      decoration: const InputDecoration(
                          labelText: 'Amount (₹)',
                          prefixIcon: Icon(Icons.currency_rupee)),
                      validator: (v) {
                        final n = double.tryParse(v?.trim() ?? '');
                        if (n == null) return 'Enter a valid number';
                        if (n <= 0) return 'Amount must be greater than 0';
                        if (n > 100000000) return 'Amount is too large';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const SectionLabel('Category'),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [for (final c in _options) _catTile(c)],
                    ),
                    const SizedBox(height: 20),
                    PressScale(
                      onTap: _pickDate,
                      child: Inset(
                        child: Row(children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 18, color: AppColors.muted),
                          const SizedBox(width: 12),
                          Text(fmtDate(_date).toUpperCase(),
                              style: mono(13, AppColors.ink, spacing: 2)),
                          const Spacer(),
                          const Icon(Icons.expand_more, color: AppColors.muted),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _note,
                      maxLines: 2,
                      maxLength: 120,
                      decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          prefixIcon: Icon(Icons.notes)),
                    ),
                    const SizedBox(height: 8),
                    GoldButton(
                      label: 'COMMIT ENTRY',
                      icon: Icons.check_rounded,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
