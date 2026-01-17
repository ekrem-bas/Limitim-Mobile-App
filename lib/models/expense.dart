import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String monthId; // Hangi aya ait olduğunu belirten yabancı anahtar

  @HiveField(2)
  final String title;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime date;

  const Expense({
    required this.id,
    required this.monthId,
    required this.title,
    required this.amount,
    required this.date,
  });

  @override
  List<Object?> get props => [id, monthId, title, amount, date];
}
