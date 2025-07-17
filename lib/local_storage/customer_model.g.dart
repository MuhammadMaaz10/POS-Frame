// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerModelAdapter extends TypeAdapter<CustomerModel> {
  @override
  final int typeId = 4;

  @override
  CustomerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerModel(
      name: fields[0] as String,
      phone: fields[1] as String,
      email: fields[2] as String,
      imagePath: fields[3] as String?,
      province: fields[4] as dynamic,
      city: fields[5] as dynamic,
      street: fields[6] as dynamic,
      houseNumber: fields[7] as dynamic,
      tinNumber: fields[8] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.province)
      ..writeByte(5)
      ..write(obj.city)
      ..writeByte(6)
      ..write(obj.street)
      ..writeByte(7)
      ..write(obj.houseNumber)
      ..writeByte(8)
      ..write(obj.tinNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
