import 'package:hive/hive.dart';
import 'vat_category_model.dart';

part 'item_model.g.dart';

@HiveType(typeId: 2)
class ItemModel extends HiveObject {
  @HiveField(0)
  String hsCode;

  @HiveField(1)
  String itemName;

  @HiveField(2)
  String itemCategory;

  @HiveField(3)
  String itemDescription;

  @HiveField(4)
  double unitPrice;

  @HiveField(5)
  String vatCategoryName;

  @HiveField(6)
  dynamic vatCategoryPercentage;

  @HiveField(7)
  dynamic vatCategoryID;

  ItemModel({
    required this.hsCode,
    required this.itemName,
    required this.itemCategory,
    required this.itemDescription,
    required this.unitPrice,
    required this.vatCategoryName,
    required this.vatCategoryPercentage,
    required this.vatCategoryID,
  });
}
