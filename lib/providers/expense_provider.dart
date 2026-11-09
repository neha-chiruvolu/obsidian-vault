import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' hide Category;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class ExpenseProvider extends ChangeNotifier {
  static const _kTx = 'vault_transactions';
  static const _kName = 'vault_name';
  static const _kBudget = 'vault_budget';

  final List<TransactionItem> _items = [];
  String userName = '';
  double budget = 30000;

  List<TransactionItem> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString(_kName) ?? '';
    budget = prefs.getDouble(_kBudget) ?? 30000;
    final raw = prefs.getString(_kTx);
    _items.clear();
    if (raw == null) {
      _items.addAll(_seed());
    } else {
      _items.addAll((jsonDecode(raw) as List)
          .map((e) => TransactionItem.fromJson(e as Map<String, dynamic>)));
    }
    _sort();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, userName);
    await prefs.setDouble(_kBudget, budget);
    await prefs.setString(
        _kTx, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  void _sort() => _items.sort((a, b) => b.date.compareTo(a.date));

  void _changed() {
    _sort();
    notifyListeners();
    _save();
  }

  void add(TransactionItem t) {
    _items.add(t);
    _changed();
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
    _changed();
  }

  void setUser(String name) {
    userName = name.trim();
    _changed();
  }

  void setBudget(double v) {
    budget = v;
    _changed();
  }

  void signOut() {
    userName = '';
    _changed();
  }

  void resetDemoData() {
    _items
      ..clear()
      ..addAll(_seed());
    _changed();
  }

  Iterable<TransactionItem> get _thisMonth {
    final now = DateTime.now();
    return _items
        .where((e) => e.date.year == now.year && e.date.month == now.month);
  }

  int get monthCount => _thisMonth.length;

  double get totalIncome =>
      _items.where((e) => e.isIncome).fold(0.0, (s, e) => s + e.amount);
  double get totalExpense =>
      _items.where((e) => !e.isIncome).fold(0.0, (s, e) => s + e.amount);
  double get balance => totalIncome - totalExpense;

  double get monthIncome =>
      _thisMonth.where((e) => e.isIncome).fold(0.0, (s, e) => s + e.amount);
  double get monthExpense =>
      _thisMonth.where((e) => !e.isIncome).fold(0.0, (s, e) => s + e.amount);

  Map<Category, double> get monthByCategory {
    final m = <Category, double>{};
    for (final e in _thisMonth.where((e) => !e.isIncome)) {
      m[e.category] = (m[e.category] ?? 0) + e.amount;
    }
    return m;
  }

  /// Daily spending for the last [days] days, oldest first.
  List<double> dailyExpense(int days) {
    final today = DateTime.now();
    return List.generate(days, (i) {
      final d = today.subtract(Duration(days: days - 1 - i));
      return _items
          .where((e) =>
              !e.isIncome &&
              e.date.year == d.year &&
              e.date.month == d.month &&
              e.date.day == d.day)
          .fold(0.0, (s, e) => s + e.amount);
    });
  }

  List<TransactionItem> _seed() {
    final now = DateTime.now();
    final rnd = Random(11);
    final titles = <Category, List<String>>{
      Category.food: ['Groceries', 'Cafe', 'Dinner out', 'Street food'],
      Category.travel: ['Metro recharge', 'Cab ride', 'Train ticket'],
      Category.shopping: ['Headphones', 'Sneakers', 'Books'],
      Category.bills: ['Electricity bill', 'Internet', 'Phone recharge'],
      Category.health: ['Pharmacy', 'Gym', 'Clinic'],
      Category.learning: ['Online course', 'Workshop', 'E-book'],
    };
    final cats = titles.keys.toList();
    final out = <TransactionItem>[];
    var n = 0;
    for (var d = 0; d < 70; d++) {
      final count = rnd.nextInt(3);
      for (var k = 0; k < count; k++) {
        final c = cats[rnd.nextInt(cats.length)];
        final list = titles[c]!;
        out.add(TransactionItem(
          id: 's${n++}',
          title: list[rnd.nextInt(list.length)],
          amount: (80 + rnd.nextInt(1400)).toDouble(),
          isIncome: false,
          category: c,
          date: now.subtract(Duration(days: d)),
        ));
      }
    }
    for (final d in [1, 31, 61]) {
      out.add(TransactionItem(
        id: 'inc$d',
        title: 'Monthly stipend',
        amount: 42000,
        isIncome: true,
        category: Category.salary,
        date: now.subtract(Duration(days: d)),
      ));
    }
    return out;
  }
}
