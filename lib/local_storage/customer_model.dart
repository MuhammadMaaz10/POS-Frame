import 'package:hive/hive.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 4)
class CustomerModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phone;

  @HiveField(2)
  String email;

  @HiveField(3)
  String address;

  @HiveField(4)
  String? imagePath; // optional for profile photo

  CustomerModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.imagePath,
  });
}
