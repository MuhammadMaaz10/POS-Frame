// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vat_category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VatCategoryModelAdapter extends TypeAdapter<VatCategoryModel> {
  @override
  final int typeId = 3;

  @override
  VatCategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VatCategoryModel(
      name: fields[0] as String,
      rate: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VatCategoryModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.rate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VatCategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
