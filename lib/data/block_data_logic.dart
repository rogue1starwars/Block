import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data_core.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/utils/type.dart';

List<BlockBluePrint> blockDataLogic = [
  BlockBluePrint(
    name: 'Compare',
    fields: [
      Field(
        type: FieldTypes.dropdown,
        label: 'Operator',
        value: '==',
        options: [
          '==',
          '!=',
          '>',
          '>=',
          '<',
          '<=',
        ],
      ),
    ],
    children: [
      ValueInput(
        label: 'Value 1',
        block: null,
      ),
      ValueInput(
        label: 'Value 2',
        block: null,
      ),
    ],
    returnType: BlockTypes.boolean,
    originalFunc: (WidgetRef ref, Block block) {
      final operator = block.fields[0].value;
      final value1 = block.children[0] as ValueInput;
      final value2 = block.children[1] as ValueInput;

      final v1 = value1.block!.execute(ref);
      final v2 = value2.block!.execute(ref);

      switch (operator) {
        case '==':
          return v1 == v2;
        case '!=':
          return v1 != v2;
        case '>':
          return v1 > v2;
        case '>=':
          return v1 >= v2;
        case '<':
          return v1 < v2;
        case '<=':
          return v1 <= v2;
        default:
          throw 'Invalid operator';
      }
    },
  ),
  BlockBluePrint(
    name: 'If',
    fields: [],
    children: [
      ValueInput(
        label: 'Condition',
        block: null,
        filter: [BlockTypes.boolean],
      ),
      StatementInput(
        label: 'Then',
        blocks: [],
        filter: [BlockTypes.none],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final condition = block.children[0] as ValueInput;
      final thenBlock = block.children[1] as StatementInput;

      if (condition.block!.execute(ref) == true) {
        thenBlock.blocks.forEach((block) {
          block.execute(ref);
        });
      }
    },
  ),
  BlockBluePrint(
    name: 'If Else',
    fields: [],
    children: [
      ValueInput(
        label: 'Condition',
        block: null,
        filter: [BlockTypes.boolean],
      ),
      StatementInput(
        label: 'Then',
        blocks: [],
        filter: [BlockTypes.none],
      ),
      StatementInput(
        label: 'Else',
        blocks: [],
        filter: [BlockTypes.none],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final condition = block.children[0] as ValueInput;
      final thenBlock = block.children[1] as StatementInput;
      final elseBlock = block.children[2] as StatementInput;

      if (condition.block!.execute(ref) == true) {
        thenBlock.blocks.forEach((block) {
          block.execute(ref);
        });
      } else {
        elseBlock.blocks.forEach((block) {
          block.execute(ref);
        });
      }
    },
  )
];
