// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompanyModelAdapter extends TypeAdapter<CompanyModel> {
  @override
  final int typeId = 1;

  @override
  CompanyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompanyModel(
      logoPath: fields[0] as String,
      companyName: fields[1] as String,
      city: fields[2] as String,
      province: fields[3] as String,
      address: fields[4] as String,
      contactNumber: fields[5] as String,
      email: fields[6] as String,
      tinNumber: fields[7] as String?,
      vatNumber: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CompanyModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.logoPath)
      ..writeByte(1)
      ..write(obj.companyName)
      ..writeByte(2)
      ..write(obj.city)
      ..writeByte(3)
      ..write(obj.province)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.contactNumber)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.tinNumber)
      ..writeByte(8)
      ..write(obj.vatNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompanyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
