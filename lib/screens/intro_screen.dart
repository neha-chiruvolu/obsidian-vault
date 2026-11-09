import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../theme.dart';
import '../widgets/instruments.dart';
import '../widgets/materials.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  late final AnimationController _spin =
      AnimationController(vsync: this, duration: const Duration(seconds: 30))
        ..repeat();
  late final AnimationController _unlock = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1300));
  bool _busy = false;

  @override
  void dispose() {
    _spin.dispose();
    _unlock.dispose();
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    context.read<ExpenseProvider>().setUser(_name.text);
    await _unlock.forward();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  Widget _formCard() => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: FadeIn(
          delayMs: 200,
          child: Panel(
            padding: const EdgeInsets.all(26),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionLabel('Authorise access'),
                  TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.badge_outlined)),
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? 'Enter at least 2 characters'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.alternate_email)),
                    validator: (v) =>
                        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(v?.trim() ?? '')
                            ? null
                            : 'Enter a valid email address',
                  ),
                  const SizedBox(height: 22),
                  GoldButton(
                    label: 'UNLOCK VAULT',
                    icon: Icons.lock_open_rounded,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([_spin, _unlock]),
          builder: (context, _) {
            final u = Curves.easeInOutCubic.transform(_unlock.value);
            final rot = _spin.value * 2 * math.pi + u * 6 * math.pi;
            final hero = Column(mainAxisSize: MainAxisSize.min, children: [
              Transform.scale(
                scale: 1 + u * 0.28,
                child: DialRing(
                  size: wide ? 340 : 230,
                  rotation: rot,
                  glow: u,
                  open: u > 0.55,
                ),
              ),
              const SizedBox(height: 22),
              GoldText('OBSIDIAN',
                  size: wide ? 42 : 30, spacing: wide ? 12 : 8),
              const SizedBox(height: 8),
              Text('PRIVATE EXPENSE VAULT',
                  style: mono(wide ? 12 : 10, AppColors.muted, spacing: 4)),
            ]);
            final form = Opacity(
              opacity: (1 - u * 1.2).clamp(0.0, 1.0).toDouble(),
              child: IgnorePointer(ignoring: _busy, child: _formCard()),
            );
            return wide
                ? Row(children: [
                    Expanded(child: Center(child: hero)),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: form,
                        ),
                      ),
                    ),
                  ])
                : Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        hero,
                        const SizedBox(height: 26),
                        form,
                      ]),
                    ),
                  );
          },
        ),
      ),
    );
  }
}
