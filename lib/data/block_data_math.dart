import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data_core.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/utils/type.dart';

final List<BlockBluePrint> blockDataMath = [
  BlockBluePrint(
    name: 'Number',
    fields: [
      Field(
        type: FieldTypes.number,
        label: "Value",
        value: 0,
      ),
    ],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: <num>(WidgetRef ref, Block block) {
      final value = block.fields[0].value;
      if (value is String) {
        return double.parse(value);
      } else if (value is num) {
        return value;
      } else {
        throw "Invalid return";
      }
    },
  ),
  BlockBluePrint(
    name: 'Operations',
    fields: [
      Field(
        type: FieldTypes.dropdown,
        label: 'Operator',
        value: 0,
        options: [
          '+',
          '-',
          '*',
          '/',
          '%',
        ],
      ),
    ],
    children: [
      ValueInput(
        label: 'Value 1',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Value 2',
        block: null,
        filter: [BlockTypes.number],
      ),
    ],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final operator = block.fields[0].value;
      final value1 = block.children[0] as ValueInput;
      final value2 = block.children[1] as ValueInput;

      final v1 = value1.block!.execute(ref);
      final v2 = value2.block!.execute(ref);

      switch (operator) {
        case 0:
          return v1 + v2;
        case 1:
          return v1 - v2;
        case 2:
          return v1 * v2;
        case 3:
          return v1 / v2;
        case 4:
          return v1 % v2;
        default:
          throw 'Invalid operator';
      }
    },
  ),
  BlockBluePrint(
    name: 'Abs',
    fields: [],
    children: [
      ValueInput(
        label: 'Value',
        block: null,
        filter: [BlockTypes.number],
      ),
    ],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value = block.children[0] as ValueInput;
      return (value.block!.execute(ref) as num).abs();
    },
  )
];
