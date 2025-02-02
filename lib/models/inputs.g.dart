// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inputs.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InputAdapter extends TypeAdapter<Input> {
  @override
  final int typeId = 1;

  @override
  Input read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Input(
      label: fields[0] as String,
      filter: (fields[1] as Map?)?.cast<BlockTypes, bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, Input obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.filter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InputAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatementInputAdapter extends TypeAdapter<StatementInput> {
  @override
  final int typeId = 2;

  @override
  StatementInput read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatementInput(
      label: fields[0] as String,
      blocks: (fields[2] as List).cast<Block>(),
      filter: (fields[1] as Map?)?.cast<BlockTypes, bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, StatementInput obj) {
    writer
      ..writeByte(3)
      ..writeByte(2)
      ..write(obj.blocks)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.filter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatementInputAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ValueInputAdapter extends TypeAdapter<ValueInput> {
  @override
  final int typeId = 3;

  @override
  ValueInput read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ValueInput(
      label: fields[0] as String,
      filter: (fields[1] as Map?)?.cast<BlockTypes, bool>(),
      block: fields[2] as Block?,
    );
  }

  @override
  void write(BinaryWriter writer, ValueInput obj) {
    writer
      ..writeByte(3)
      ..writeByte(2)
      ..write(obj.block)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.filter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueInputAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
