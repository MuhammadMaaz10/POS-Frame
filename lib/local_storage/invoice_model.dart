import 'package:hive/hive.dart';

import 'invoice_customer.dart';
import 'invoice_item.dart';

part 'invoice_model.g.dart';

@HiveType(typeId: 5)
class InvoiceModel extends HiveObject {
  @HiveField(0)
  final String invoiceNo;

  @HiveField(1)
  final InvoiceCustomer customer;

  @HiveField(2)
  final InvoiceItem items;

  @HiveField(3)
  final String invoiceDate;

  @HiveField(4)
  final String invoiceDueDate;

  @HiveField(5)
  final String notes;

  @HiveField(6)
  final String termsAndConditions;

  InvoiceModel({
    required this.invoiceNo,
    required this.customer,
    required this.items,
    required this.invoiceDate,
    required this.invoiceDueDate,
    required this.notes,
    required this.termsAndConditions,
  });
}
