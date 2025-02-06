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
        value: 0,
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
        filter: [
          BlockTypes.number,
          BlockTypes.string,
          BlockTypes.boolean,
        ],
      ),
      ValueInput(
        label: 'Value 2',
        block: null,
        filter: [
          BlockTypes.number,
          BlockTypes.string,
          BlockTypes.boolean,
        ],
      ),
    ],
    returnType: BlockTypes.boolean,
    originalFunc: (WidgetRef ref, Block block) {
      final int operator = block.fields[0].value;
      final value1 = block.children[0] as ValueInput;
      final value2 = block.children[1] as ValueInput;

      final v1 = value1.block!.execute(ref);
      final v2 = value2.block!.execute(ref);

      switch (operator) {
        case 0:
          return v1 == v2;
        case 1:
          return v1 != v2;
        case 2:
          return v1 > v2;
        case 3:
          return v1 >= v2;
        case 4:
          return v1 < v2;
        case 5:
          return v1 <= v2;
        default:
          throw 'Invalid operator';
      }
    },
  ),
  BlockBluePrint(
    name: 'And/Or',
    fields: [
      Field(
        type: FieldTypes.dropdown,
        label: 'Operator',
        value: 0,
        options: [
          'And',
          'Or',
        ],
      ),
    ],
    children: [
      ValueInput(
        label: 'Value 1',
        block: null,
        filter: [BlockTypes.boolean],
      ),
      ValueInput(
        label: 'Value 2',
        block: null,
        filter: [BlockTypes.boolean],
      ),
    ],
    returnType: BlockTypes.boolean,
    originalFunc: (WidgetRef ref, Block block) {
      final int operator = block.fields[0].value;
      final value1 = block.children[0] as ValueInput;
      final value2 = block.children[1] as ValueInput;

      final v1 = value1.block!.execute(ref);
      final v2 = value2.block!.execute(ref);

      if (operator == 0) {
        return v1 == true && v2 == true;
      } else {
        return v1 == true || v2 == true;
      }
    },
  ),
  BlockBluePrint(
    name: 'Not',
    fields: [],
    children: [
      ValueInput(
        label: 'Value',
        block: null,
        filter: [BlockTypes.boolean],
      ),
    ],
    returnType: BlockTypes.boolean,
    originalFunc: (WidgetRef ref, Block block) {
      final value = block.children[0] as ValueInput;
      return value.block!.execute(ref) == false;
    },
  ),
  BlockBluePrint(
    name: 'True/False',
    fields: [
      Field(
          label: 'Value',
          type: FieldTypes.dropdown,
          value: 0,
          options: ['True', 'False'])
    ],
    children: [],
    returnType: BlockTypes.boolean,
    originalFunc: (WidgetRef ref, Block block) {
      return block.fields[0].value == 0;
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
