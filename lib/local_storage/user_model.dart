import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String password;

  @HiveField(2)
  bool? isCompanySetup;

  UserModel({required this.username, required this.password, this.isCompanySetup = false,});
}
