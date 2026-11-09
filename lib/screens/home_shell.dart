import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/materials.dart';
import 'analytics_screen.dart';
import 'console_screen.dart';
import 'ledger_screen.dart';
import 'vault_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Console', 'Ledger', 'Analytics', 'Vault'];
  static const _icons = [
    Icons.speed_outlined,
    Icons.menu_book_outlined,
    Icons.query_stats,
    Icons.shield_outlined,
  ];
  static const _selIcons = [
    Icons.speed,
    Icons.menu_book,
    Icons.query_stats,
    Icons.shield,
  ];

  Widget _page() {
    switch (_index) {
      case 0:
        return const ConsoleScreen();
      case 1:
        return const LedgerScreen();
      case 2:
        return const AnalyticsScreen();
      default:
        return const VaultScreen();
    }
  }

  void _add() => Navigator.pushNamed(context, '/add');

  Widget _addButton(double size) => PressScale(
        onTap: _add,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              center: Alignment(-0.3, -0.4),
              colors: [AppColors.goldLight, AppColors.mustard, Color(0xFF9A6A00)],
              stops: [0, 0.55, 1],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.45), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.7),
                  blurRadius: 14,
                  offset: const Offset(0, 6)),
              BoxShadow(
                  color: AppColors.mustard.withOpacity(0.45), blurRadius: 24),
            ],
          ),
          child: Icon(Icons.add_rounded,
              color: AppColors.onGold, size: size * 0.55),
        ),
      );

  Widget _navItem(int i) {
    final sel = _index == i;
    return Expanded(
      child: PressScale(
        onTap: () => setState(() => _index = i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              sel ? _selIcons[i] : _icons[i],
              color: sel ? AppColors.goldLight : AppColors.muted,
              shadows: sel
                  ? [
                      Shadow(
                          color: AppColors.mustard.withOpacity(0.9),
                          blurRadius: 14)
                    ]
                  : null,
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: sel ? 14 : 4,
              height: 4,
              decoration: BoxDecoration(
                color: sel ? AppColors.mustard : Colors.white12,
                borderRadius: BorderRadius.circular(2),
                boxShadow: sel
                    ? [
                        BoxShadow(
                            color: AppColors.mustard.withOpacity(0.9),
                            blurRadius: 8)
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dock() => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Container(
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1D2328), Color(0xFF0B0E10)],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.85),
                    blurRadius: 26,
                    offset: const Offset(0, 10)),
              ],
            ),
            child: Row(children: [
              _navItem(0),
              _navItem(1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _addButton(58),
              ),
              _navItem(2),
              _navItem(3),
            ]),
          ),
        ),
      );

  Widget _rail() => Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 0, 14),
        child: Container(
          width: 92,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1D2328), Color(0xFF0B0E10)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.85),
                  blurRadius: 26,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: Column(children: [
            const GoldText('O', size: 30, spacing: 0),
            const SizedBox(height: 18),
            _addButton(56),
            const SizedBox(height: 24),
            for (var i = 0; i < 4; i++)
              SizedBox(
                height: 76,
                child: Row(children: [_navItem(i)]),
              ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final wide = !Breakpoints.isMobile(w);

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0, 0.03), end: Offset.zero)
              .animate(anim),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(_index),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: _page(),
          ),
        ),
      ),
    );

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Row(children: [
          if (!wide) ...[
            const GoldText('OBSIDIAN', size: 16, spacing: 5),
            const SizedBox(width: 10),
            Text('/', style: mono(16, AppColors.muted)),
            const SizedBox(width: 10),
          ],
          Text(_titles[_index].toUpperCase(),
              style: mono(14, AppColors.ink, spacing: 3)),
        ]),
      ),
      body: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_rail(), Expanded(child: body)],
            )
          : body,
      bottomNavigationBar: wide ? null : _dock(),
    );
  }
}
