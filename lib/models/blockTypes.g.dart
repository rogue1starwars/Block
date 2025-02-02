// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blockTypes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlockTypesAdapter extends TypeAdapter<BlockTypes> {
  @override
  final int typeId = 5;

  @override
  BlockTypes read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BlockTypes.number;
      case 1:
        return BlockTypes.string;
      case 2:
        return BlockTypes.boolean;
      case 3:
        return BlockTypes.none;
      case 4:
        return BlockTypes.intervalList;
      default:
        return BlockTypes.number;
    }
  }

  @override
  void write(BinaryWriter writer, BlockTypes obj) {
    switch (obj) {
      case BlockTypes.number:
        writer.writeByte(0);
        break;
      case BlockTypes.string:
        writer.writeByte(1);
        break;
      case BlockTypes.boolean:
        writer.writeByte(2);
        break;
      case BlockTypes.none:
        writer.writeByte(3);
        break;
      case BlockTypes.intervalList:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockTypesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
