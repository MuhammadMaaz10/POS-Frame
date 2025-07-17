// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:frame_virtual_fiscilation/local_storage/qrUrlsList_model.dart';
import 'package:hive/hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************



class QrUrlsModelAdapter extends TypeAdapter<QrUrlsModel> {
  @override
  final int typeId = 10;

  @override
  QrUrlsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QrUrlsModel(
      username: fields[0] as String,
      qrUrls: (fields[1] as List).cast<dynamic>(),

    );
  }

  @override
  void write(BinaryWriter writer, QrUrlsModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.qrUrls);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is QrUrlsModelAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}
