import 'package:flutter/material.dart';
import '../theme.dart';

enum Category { food, travel, shopping, bills, health, learning, salary, other }

extension CategoryX on Category {
  String get label => switch (this) {
        Category.food => 'Food',
        Category.travel => 'Travel',
        Category.shopping => 'Shopping',
        Category.bills => 'Bills',
        Category.health => 'Health',
        Category.learning => 'Learning',
        Category.salary => 'Income',
        Category.other => 'Other',
      };

  IconData get icon => switch (this) {
        Category.food => Icons.restaurant,
        Category.travel => Icons.flight_takeoff,
        Category.shopping => Icons.shopping_bag,
        Category.bills => Icons.receipt_long,
        Category.health => Icons.favorite,
        Category.learning => Icons.school,
        Category.salary => Icons.account_balance_wallet,
        Category.other => Icons.category,
      };

  Color get color => switch (this) {
        Category.food => AppColors.mustard,
        Category.travel => AppColors.blue,
        Category.shopping => AppColors.teal,
        Category.bills => AppColors.navy,
        Category.health => const Color(0xFF52B788),
        Category.learning => const Color(0xFF5BA4D6),
        Category.salary => AppColors.green,
        Category.other => const Color(0xFF8AA7B5),
      };
}

class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final Category category;
  final DateTime date;
  final String note;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'isIncome': isIncome,
        'category': category.name,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory TransactionItem.fromJson(Map<String, dynamic> j) => TransactionItem(
        id: j['id'] as String,
        title: j['title'] as String,
        amount: (j['amount'] as num).toDouble(),
        isIncome: j['isIncome'] as bool,
        category: Category.values.byName(j['category'] as String),
        date: DateTime.parse(j['date'] as String),
        note: (j['note'] as String?) ?? '',
      );
}

String money(double v) {
  final s = v.abs().round().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => ',',
      );
  return '${v < 0 ? '-' : ''}₹$s';
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
