import 'package:flutter/material.dart';
import 'package:phoneduino_block/data/block_data.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/models/variables.dart';
import 'package:phoneduino_block/utils/type.dart';

class Block {
  static final Map<String, Variable> _globalVariables = {};

  final String id;
  final String name;
  final List<Field>? fields;
  final List<Input>? children;
  final BlockTypes returnType;
  final Function(Block) originalFunc;

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
    if (children != null) {
      for (final child in children!) {
        switch (child) {
          case ValueInput child:
            final valueInput = child as ValueInput;
            if (valueInput.block == null) {
              ScaffoldMessenger.of(Block.getVariable("_context")).showSnackBar(
                const SnackBar(
                  content: Text('Please connect to a device first'),
                ),
              );
              return;
            }
        }
      }
    }
    if (fields != null) {
      for (final field in fields!) {
        if (field.value == null) {
          ScaffoldMessenger.of(Block.getVariable("_context")).showSnackBar(
            const SnackBar(
              content: Text('Please fill in all fields'),
            ),
          );
          return;
        }
      }
    }
    return originalFunc(this);
  }

  static bool hasVariable(String name) {
    return _globalVariables.containsKey(name);
  }

  static BlockTypes? getVariableType(String name) {
    if (!hasVariable(name)) {
      return null;
    }
    return _globalVariables[name]!.type;
  }

  static void deleteVariable(String name) {
    if (hasVariable(name)) {
      _globalVariables.remove(name);
    }
  }

  static void setVariable(String name, dynamic value, BlockTypes type) {
    _globalVariables[name] = Variable(value: value, type: type, name: name);
  }

  static void updateVariable(String name, dynamic value) {
    if (hasVariable(name)) {
      _globalVariables[name]!.value = value;
    }
  }

  static dynamic getVariable(String name) {
    if (!hasVariable(name)) {
      return null;
    }
    return _globalVariables[name]!.value;
  }

  Block copyWith({
    String? id,
    String? name,
    List<Field>? fields,
    List<Input>? children,
    BlockTypes? returnType,
    Function(Block)? originalFunc,
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
