import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String monthId; // Aktif taslağın ID'si

  @HiveField(2)
  final String title;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime date;

  Expense({
    required this.id,
    required this.monthId,
    required this.title,
    required this.amount,
    required this.date,
  });
}
