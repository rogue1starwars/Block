import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/models/variables.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/provider/intervals_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/utils/type.dart';

class Block {
  static final Map<String, Variable> _globalVariables = {};

  final String id;
  final String name;
  final List<Field> fields;
  final List<Input> children;
  final BlockTypes returnType;
  final Function(WidgetRef, Block) originalFunc;

  Block({
    required this.id,
    required this.name,
    required this.returnType,
    required this.originalFunc,
    required this.fields,
    required this.children,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    /*
      json format
      {
        "id": "1",
        "name": "Main",
        "fields": [
            100,
            'abc',
        ],
        "children": [
        // Statement
          [
            {
              "id": "2",
              "name": "Serial Begin",
              "fields": [
                {
                  "value": 9600,
                }
              ],
            }
            {
              "id": "3",
              "name": "Serial Begin",
              "fields": [
                {
                  "value": 9600,
                }
              ],
            }
          ]
          {
            "label": "Loop",
            "blocks": []
          }
        ]
      }

      block: 
      * id
      * name
      * fields
        * value
      * children
        *blocks...
    */
    try {
      for (final block in blockData) {
        if (block.name == json['name']) {
          final Block root = Block(
            id: json['id'],
            name: block.name,
            returnType: block.returnType,
            originalFunc: block.originalFunc,
            fields: List<Field>.from(
              block.fields.asMap().entries.map((entry) {
                return Field(
                  type: entry.value.type,
                  label: entry.value.label,
                  value: json['fields'][entry.key],
                );
              }),
            ),
            children:
                List<Input>.from(block.children.asMap().entries.map((entry) {
              switch (entry.value) {
                case StatementInput init:
                  return StatementInput.fromJson(
                    init: init,
                    json: json['children'][entry.key] ?? [],
                  );
                case ValueInput init:
                  return ValueInput.fromJson(
                    init: init,
                    json: json['children'][entry.key] ?? {},
                  );
              }
            })),
          );
          return root;
        }
      }
      throw 'Block not found';
    } catch (e) {
      print(e);
      return Block.fromBluePrint(block: blockData[0], id: '0');
    }
  }

  Block.fromBluePrint({required BlockBluePrint block, required this.id})
      : name = block.name,
        returnType = block.returnType,
        originalFunc = block.originalFunc,
        fields = block.fields,
        children = block.children;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'name': name,
      'fields': fields.map((field) => field.toJson()).toList(),
      'children': children.map((child) {
        switch (child) {
          case StatementInput child:
            return child.toJson();
          case ValueInput child:
            return child.toJson();
        }
      }).toList(),
    };
    return json;
  }

  void rerun(WidgetRef ref) {
    ref.read(intervalProvider.notifier).clearInterval();
    Block root = ref.read(blockTreeProvider);
    root.execute(ref);
  }

  dynamic execute(WidgetRef ref) {
    for (final child in children) {
      switch (child) {
        case ValueInput child:
          final valueInput = child;
          if (valueInput.block == null) {
            ref.read(uiProvider.notifier).showMessage(
                  'Please fill in all blocks',
                );
            return;
          }
      }
    }
    for (final field in fields) {
      if (field.value == null) {
        ref.read(uiProvider.notifier).showMessage(
              'Please fill in all fields',
            );
        return;
      }
    }
    try {
      return originalFunc(ref, this);
    } catch (e) {
      ref.read(uiProvider.notifier).showMessage(
            'Error: $e',
          );
      // Re running entire program
      rerun(ref);
    }
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
    Function(WidgetRef, Block)? originalFunc,
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
