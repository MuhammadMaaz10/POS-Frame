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

  @HiveField(3)
  final String phoneNumber;

 @HiveField(4)
  final String provience;

  @HiveField(5)
  final String city;

  @HiveField(6)
  final String street;

  @HiveField(7)
  final String houseNumber;

  @HiveField(8)
  final dynamic tinNumber;



  InvoiceCustomer({
    required this.name,
    required this.pic,
    required this.email,
    required this.phoneNumber,
    required this.provience,
    required this.city,
    required this.street,
    required this.houseNumber,
    required this.tinNumber,
  });
}
