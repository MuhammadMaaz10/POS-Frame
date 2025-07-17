// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceModelAdapter extends TypeAdapter<InvoiceModel> {
  @override
  final int typeId = 5;

  @override
  InvoiceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceModel(
      invoiceNo: fields[0] as String,
      customer: fields[1] as InvoiceCustomer,
      items: (fields[2] as List).cast<InvoiceItem>(),
      invoiceDate: fields[3] as String,
      invoiceDueDate: fields[4] as String,
      notes: fields[5] as String,
      termsAndConditions: fields[6] as String,
      currency: fields[7] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.invoiceNo)
      ..writeByte(1)
      ..write(obj.customer)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.invoiceDate)
      ..writeByte(4)
      ..write(obj.invoiceDueDate)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.termsAndConditions)
      ..writeByte(7)
      ..write(obj.currency);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
