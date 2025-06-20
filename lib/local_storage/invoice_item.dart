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

  InvoiceItem({
    required this.name,
    required this.category,
    required this.price,
  });
}
