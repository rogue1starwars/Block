import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/provider/intervals_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/utils/type.dart';

class Block {
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
    for (final block in blockData) {
      if (block.name == json['name']) {
        final Block root = Block(
          id: json['id'],
          name: block.name,
          returnType: block.returnType,
          originalFunc: block.originalFunc,
          fields: block.fields
              .map((field) => Field.fromJson(
                    init: field,
                    value: json['fields'][field.label],
                  ))
              .toList(),
          children: block.children.map((child) {
            final dynamic rawChildren = json['children'][child.label];
            switch (child) {
              case StatementInput init:
                if (rawChildren == null) {
                  return StatementInput(
                    label: init.label,
                    blocks: [],
                  );
                }

                if (rawChildren is! List) {
                  throw FormatException(
                      'Expected List for children of ${child.label}');
                }

                final List<Map<String, dynamic>> blockListJson =
                    rawChildren.map((item) {
                  if (item is! Map) {
                    throw const FormatException(
                        'Expected Map in children list');
                  }
                  return Map<String, dynamic>.from(item);
                }).toList();

                return StatementInput.fromJson(
                  init: init,
                  json: blockListJson,
                );
              case ValueInput init:
                final dynamic rawChildren = json['children'][child.label];
                if (rawChildren == null) {
                  return ValueInput(
                    label: init.label,
                    block: null,
                  );
                }
                if (rawChildren is! Map) {
                  throw FormatException(
                      'Expected Map for children of ${child.label}');
                }
                final Map<String, dynamic> blockJson =
                    Map<String, dynamic>.from(rawChildren);
                return ValueInput.fromJson(
                  init: init,
                  json: blockJson,
                );
              default:
                throw 'Invalid input type';
            }
          }).toList(),
        );
        return root;
      }
    }
    throw 'Block not found';
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
      'fields': fields.fold(
        <String, dynamic>{},
        (acc, field) {
          acc[field.label] = field.value;
          return acc;
        },
      ),
      'children': children.fold(<String, dynamic>{}, (acc, child) {
        switch (child) {
          case StatementInput child:
            acc[child.label] = child.toJson();
            return acc;
          case ValueInput child:
            acc[child.label] = child.toJson();
            return acc;
          default:
            throw 'Invalid input type';
        }
      }),
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
      print('Error: $e');
      ref.read(uiProvider.notifier).showMessage(
            'Error: $e',
          );
      // Re running entire program
      // rerun(ref);
    }
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
