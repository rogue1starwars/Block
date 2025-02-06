import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data_core.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
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
];
