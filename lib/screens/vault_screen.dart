import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../theme.dart';
import '../widgets/materials.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _budget;

  @override
  void initState() {
    super.initState();
    final p = context.read<ExpenseProvider>();
    _name = TextEditingController(text: p.userName);
    _budget = TextEditingController(text: p.budget.round().toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _budget.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final p = context.read<ExpenseProvider>();
    p.setUser(_name.text);
    p.setBudget(double.parse(_budget.text.trim()));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: FadeIn(
              child: Panel(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              center: Alignment(-0.3, -0.4),
                              colors: [
                                AppColors.goldLight,
                                AppColors.mustard,
                                Color(0xFF9A6A00)
                              ],
                              stops: [0, 0.55, 1],
                            ),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4)),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.mustard.withOpacity(0.4),
                                  blurRadius: 20)
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            p.userName.isEmpty
                                ? '?'
                                : p.userName[0].toUpperCase(),
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppColors.onGold),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GoldText(
                                  p.userName.isEmpty
                                      ? 'OPERATOR'
                                      : p.userName.toUpperCase(),
                                  size: 20,
                                  spacing: 3),
                              const SizedBox(height: 4),
                              Text('VAULT SETTINGS',
                                  style: mono(10, AppColors.muted, spacing: 3)),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.badge_outlined)),
                        validator: (v) => (v == null || v.trim().length < 2)
                            ? 'Enter at least 2 characters'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _budget,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Monthly budget (₹)',
                            prefixIcon: Icon(Icons.speed)),
                        validator: (v) {
                          final n = double.tryParse(v?.trim() ?? '');
                          return (n == null || n <= 0)
                              ? 'Enter a budget greater than 0'
                              : null;
                        },
                      ),
                      const SizedBox(height: 22),
                      GoldButton(
                        label: 'SAVE SETTINGS',
                        icon: Icons.check_rounded,
                        onPressed: _save,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          context.read<ExpenseProvider>().resetDemoData();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Demo data restored')));
                        },
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Restore demo data'),
                      ),
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: () {
                          context.read<ExpenseProvider>().signOut();
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/', (_) => false);
                        },
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('Lock vault'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
