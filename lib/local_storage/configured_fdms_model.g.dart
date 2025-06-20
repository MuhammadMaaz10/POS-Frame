// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configured_fdms_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfiguredFDMsAdapter extends TypeAdapter<ConfiguredFDMs> {
  @override
  final int typeId = 8;

  @override
  ConfiguredFDMs read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConfiguredFDMs(
      clientID: fields[0] as String,
      deviceID: fields[1] as String,
      apiKey: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ConfiguredFDMs obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.clientID)
      ..writeByte(1)
      ..write(obj.deviceID)
      ..writeByte(2)
      ..write(obj.apiKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfiguredFDMsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
