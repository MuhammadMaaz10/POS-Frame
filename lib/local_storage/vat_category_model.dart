import 'package:hive/hive.dart';

part 'vat_category_model.g.dart';

@HiveType(typeId: 3)
class VatCategoryModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String rate;

  VatCategoryModel({required this.name, required this.rate});
}
