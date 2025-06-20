import 'package:hive/hive.dart';

part 'company_model.g.dart';

@HiveType(typeId: 1)
class CompanyModel extends HiveObject {
  @HiveField(0)
  String logoPath;

  @HiveField(1)
  String companyName;

  @HiveField(2)
  String city;

  @HiveField(3)
  String province;

  @HiveField(4)
  String address;

  @HiveField(5)
  String contactNumber;

  CompanyModel({
    required this.logoPath,
    required this.companyName,
    required this.city,
    required this.province,
    required this.address,
    required this.contactNumber,
  });
}
