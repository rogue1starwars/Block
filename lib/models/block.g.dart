// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlockAdapter extends TypeAdapter<Block> {
  @override
  final int typeId = 0;

  @override
  Block read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Block(
      id: fields[0] as String,
      name: fields[1] as String,
      returnType: fields[4] as BlockTypes,
      originalFunc: fields[5] as dynamic Function(WidgetRef, Block),
      fields: (fields[2] as List?)?.cast<Field>(),
      children: (fields[3] as List?)?.cast<Input>(),
    );
  }

  @override
  void write(BinaryWriter writer, Block obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fields)
      ..writeByte(3)
      ..write(obj.children)
      ..writeByte(4)
      ..write(obj.returnType)
      ..writeByte(5)
      ..write(obj.originalFunc);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
