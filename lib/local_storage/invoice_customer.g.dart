// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_customer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceCustomerAdapter extends TypeAdapter<InvoiceCustomer> {
  @override
  final int typeId = 7;

  @override
  InvoiceCustomer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceCustomer(
      name: fields[0] as String,
      pic: fields[1] as String,
      email: fields[2] as String,
      phoneNumber: fields[3] as String,
      provience: fields[4] as String,
      city: fields[5] as String,
      street: fields[6] as String,
      houseNumber: fields[7] as String,
      tinNumber: fields[8] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceCustomer obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.pic)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.provience)
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
      other is InvoiceCustomerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
