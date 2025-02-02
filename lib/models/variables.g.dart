// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'variables.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VariableAdapter extends TypeAdapter<Variable> {
  @override
  final int typeId = 3;

  @override
  Variable read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Variable(
      value: fields[0] as dynamic,
      type: fields[1] as BlockTypes,
      name: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Variable obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VariableAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
