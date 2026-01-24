import 'package:hive/hive.dart';

part 'month.g.dart';

@HiveType(typeId: 1)
class Month {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final double limit;

  @HiveField(3)
  bool isDraft;

  @HiveField(4)
  int? year;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  String? customName;

  @HiveField(7)
  final double totalSpent;

  Month({
    required this.id,
    required this.name,
    required this.limit,
    this.isDraft = true,
    this.year,
    required this.createdAt,
    this.customName,
    this.totalSpent = 0.0,
  });

  Month copyWith({
    double? limit,
    String? customName,
    String? name,
    bool? isDraft,
    int? year,
    double? totalSpent,
  }) {
    return Month(
      id: id, // Mevcut ID'yi koru
      name: name ?? this.name,
      limit: limit ?? this.limit,
      isDraft: isDraft ?? this.isDraft,
      year: year ?? this.year,
      createdAt: createdAt,
      customName: customName ?? this.customName,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}

extension MonthFormatting on Month {
  bool get hasCustomName => customName != null && customName!.trim().isNotEmpty;

  String get displayTitle => hasCustomName ? customName! : "$name $year";
}
