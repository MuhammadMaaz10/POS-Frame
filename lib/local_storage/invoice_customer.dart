import 'package:hive/hive.dart';

part 'invoice_customer.g.dart';

@HiveType(typeId: 7)
class InvoiceCustomer {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String pic; // Path or URL

  @HiveField(2)
  final String email;

  InvoiceCustomer({
    required this.name,
    required this.pic,
    required this.email,
  });
}
