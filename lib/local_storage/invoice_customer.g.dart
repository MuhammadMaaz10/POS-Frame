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
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceCustomer obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.pic)
      ..writeByte(2)
      ..write(obj.email);
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
