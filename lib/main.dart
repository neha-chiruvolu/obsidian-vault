import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'screens/add_entry_screen.dart';
import 'screens/home_shell.dart';
import 'screens/intro_screen.dart';
import 'theme.dart';
import 'widgets/materials.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = ExpenseProvider();
  await provider.load();
  runApp(ChangeNotifierProvider.value(
    value: provider,
    child: const ObsidianApp(),
  ));
}

Route<dynamic> _fade(RouteSettings s, Widget page) => PageRouteBuilder(
      settings: s,
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
        child: child,
      ),
    );

class ObsidianApp extends StatelessWidget {
  const ObsidianApp({super.key});

  @override
  Widget build(BuildContext context) {
    final signedIn = context.read<ExpenseProvider>().userName.isNotEmpty;
    return MaterialApp(
      title: 'Obsidian - Expense Vault',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: StudioBackground()),
          if (child != null) child,
        ],
      ),
      initialRoute: signedIn ? '/home' : '/',
      onGenerateRoute: (s) {
        switch (s.name) {
          case '/home':
            return _fade(s, const HomeShell());
          case '/add':
            return PageRouteBuilder(
              settings: s,
              transitionDuration: const Duration(milliseconds: 450),
              pageBuilder: (_, __, ___) => const AddEntryScreen(),
              transitionsBuilder: (_, a, __, child) {
                final c = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
                return FadeTransition(
                  opacity: c,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.10), end: Offset.zero)
                        .animate(c),
                    child: child,
                  ),
                );
              },
            );
          default:
            return _fade(s, const IntroScreen());
        }
      },
    );
  }
}
