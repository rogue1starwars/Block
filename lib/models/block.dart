import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';

class Block {
  final String id;
  final String name;
  final List<Field>? fields;
  final List<Input>? children;
  final String returnType;
  late final Function execute;

  Block({
    required this.id,
    required this.name,
    required this.returnType,
    required execute,
    this.fields,
    this.children,
  }) {
    this.execute = () => execute(fields, children);
  }

  Block copyWith({
    String? id,
    String? name,
    List<Field>? fields,
    List<Input>? children,
    String? returnType,
    Function? execute,
  }) {
    return Block(
      id: id ?? this.id,
      name: name ?? this.name,
      fields: fields ?? this.fields,
      children: children ?? this.children,
      returnType: returnType ?? this.returnType,
      execute: execute ?? this.execute,
    );
  }
}
