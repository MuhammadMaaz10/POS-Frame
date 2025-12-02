import 'package:hive/hive.dart';// For Hive generator

part 'qrUrlsList_model.g.dart';

@HiveType(typeId: 10) // Unique typeId
class QrUrlsModel extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  List<dynamic> qrUrls;

  QrUrlsModel({required this.username, required this.qrUrls});
}