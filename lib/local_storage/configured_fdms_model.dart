import 'package:hive/hive.dart';

part 'configured_fdms_model.g.dart';

@HiveType(typeId: 8) // Choose a unique typeId
class ConfiguredFDMs extends HiveObject {
  @HiveField(0)
  String clientID;

  @HiveField(1)
  String deviceID;

  @HiveField(2)
  String apiKey;

  ConfiguredFDMs({
    required this.clientID,
    required this.deviceID,
    required this.apiKey,
  });
}
