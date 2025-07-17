// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceItemAdapter extends TypeAdapter<InvoiceItem> {
  @override
  final int typeId = 6;

  @override
  InvoiceItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceItem(
      name: fields[0] as String,
      category: fields[1] as String,
      price: fields[2] as String,
      quantity: fields[3] as dynamic,
      taxName: fields[4] as dynamic,
      taxPercentage: fields[5] as dynamic,
      taxID: fields[6] as dynamic,
      hsCode: fields[7] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.price)
    ..writeByte(3)
      ..write(obj.quantity)
    ..writeByte(4)
      ..write(obj.taxName)
    ..writeByte(5)
      ..write(obj.taxPercentage)
    ..writeByte(6)
      ..write(obj.taxID)
      ..writeByte(7)
      ..write(obj.hsCode)


    ;
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
