import 'package:hive/hive.dart';

part 'invoice_item.g.dart';

@HiveType(typeId: 6)
class InvoiceItem {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String category;

  @HiveField(2)
  final String price;

  @HiveField(3)
  final dynamic quantity;

  @HiveField(4)
  final dynamic taxName;

  @HiveField(5)
  final dynamic taxPercentage;

  @HiveField(6)
  final dynamic taxID;

  @HiveField(6)
  final dynamic hsCode;

  InvoiceItem({
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.taxName,
    required this.taxPercentage,
    required this.taxID,
    required this.hsCode,
  });
}
