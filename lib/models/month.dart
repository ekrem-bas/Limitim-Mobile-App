import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'month.g.dart';

@HiveType(typeId: 1)
class Month extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name; // Örn: "Haziran - Temmuz"

  @HiveField(2)
  final double limit; // Belirlenen bütçe limiti

  @HiveField(3)
  final DateTime startDate; // Sıralama ve filtreleme için gerçek tarih

  @HiveField(4)
  final int year;

  const Month({
    required this.id,
    required this.name,
    required this.limit,
    required this.startDate,
    required this.year,
  });

  @override
  List<Object?> get props => [id, name, limit, startDate, year];
}
