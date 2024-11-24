import 'package:phoneduino_block/data/block_data.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/utils/type.dart';

class Block {
  final String id;
  final String name;
  final List<Field>? fields;
  final List<Input>? children;
  final BlockTypes returnType;
  final Function originalFunc;

  Block({
    required this.id,
    required this.name,
    required this.returnType,
    required this.originalFunc,
    this.fields,
    this.children,
  });

  Block.fromBluePrint({required BlockBluePrint block, required this.id})
      : name = block.name,
        returnType = block.returnType,
        originalFunc = block.originalFunc,
        fields = block.fields,
        children = block.children;

  dynamic execute() {
    return originalFunc(fields, children);
  }

  Block copyWith({
    String? id,
    String? name,
    List<Field>? fields,
    List<Input>? children,
    BlockTypes? returnType,
    Function? originalFunc,
  }) {
    return Block(
      id: id ?? this.id,
      name: name ?? this.name,
      fields: fields ?? this.fields,
      children: children ?? this.children,
      returnType: returnType ?? this.returnType,
      originalFunc: originalFunc ?? this.originalFunc,
    );
  }
}
