// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemModelAdapter extends TypeAdapter<ItemModel> {
  @override
  final int typeId = 2;

  @override
  ItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemModel(
      hsCode: fields[0] as String,
      itemName: fields[1] as String,
      itemCategory: fields[2] as String,
      itemDescription: fields[3] as String,
      unitPrice: fields[4] as double,
      vatCategory: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ItemModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.hsCode)
      ..writeByte(1)
      ..write(obj.itemName)
      ..writeByte(2)
      ..write(obj.itemCategory)
      ..writeByte(3)
      ..write(obj.itemDescription)
      ..writeByte(4)
      ..write(obj.unitPrice)
      ..writeByte(5)
      ..write(obj.vatCategory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
