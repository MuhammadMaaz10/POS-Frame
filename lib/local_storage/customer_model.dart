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

  // optional for profile photo
  @HiveField(3)
  String? imagePath;

  @HiveField(4)
  dynamic province;

  @HiveField(5)
  dynamic city;

  @HiveField(6)
  dynamic street;

  @HiveField(7)
  dynamic houseNumber;

  @HiveField(8)
  dynamic? tinNumber;


  CustomerModel({
    required this.name,
    required this.phone,
    required this.email,
    this.imagePath,
    required this.province,
    required this.city,
    required this.street,
    required this.houseNumber,
    this.tinNumber,
  });
}




// @HiveType(typeId: 4)
// class CustomerModel extends HiveObject {
//   @HiveField(0)
//   String name;
//
//   @HiveField(1)
//   String phone;
//
//   @HiveField(2)
//   String email;
//
//   @HiveField(3)
//   String address;
//
//   @HiveField(4)
//   String? imagePath; // optional for profile photo
//
//   CustomerModel({
//     required this.name,
//     required this.phone,
//     required this.email,
//     required this.address,
//     this.imagePath,
//   });
// }
