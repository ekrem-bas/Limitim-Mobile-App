import 'package:hive/hive.dart';

part 'month.g.dart';

@HiveType(typeId: 1)
class Month {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name; // Başta "Aktif" olabilir, kaydedince kullanıcı seçer

  @HiveField(2)
  final double limit;

  @HiveField(3)
  bool isDraft; // true: Ana ekranda aktif, false: Geçmişe kaydedilmiş

  @HiveField(4)
  int? year;

  @HiveField(5)
  final DateTime createdAt;

  Month({
    required this.id,
    required this.name,
    required this.limit,
    this.isDraft = true,
    this.year,
    required this.createdAt,
  });
}
