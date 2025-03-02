import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data_core.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/utils/type.dart';

List<BlockBluePrint> blockDataStrings = [
  BlockBluePrint(
    name: 'String',
    fields: [
      Field(
        type: FieldTypes.string,
        label: 'Value',
        value: '',
      ),
    ],
    children: [],
    returnType: BlockTypes.string,
    originalFunc: (WidgetRef ref, Block block) {
      return block.fields[0].value;
    },
  ),
  BlockBluePrint(
    name: 'Print',
    fields: [],
    children: [
      ValueInput(
        label: 'Value',
        block: null,
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final value = block.children[0] as ValueInput;
      ref.read(uiProvider.notifier).showMessage(
            value.block!.execute(ref).toString(),
          );
    },
  ),
  BlockBluePrint(
    name: 'Color',
    fields: [
      Field(
        type: FieldTypes.dropdown,
        label: 'Color',
        value: 0,
        options: ['red', 'green', 'blue', 'yellow', 'purple', 'black'],
      )
    ],
    children: [],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      if (block.fields[0].value is! int) return;
      final int colorIndex = block.fields[0].value;
      ref.read(uiProvider.notifier).changeColor(
            colorIndex,
          );
    },
  )
];
