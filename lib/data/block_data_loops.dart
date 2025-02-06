import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data_core.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/intervals_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/utils/type.dart';

List<BlockBluePrint> blockDataLoops = [
  BlockBluePrint(
    name: 'For Loop',
    fields: [
      Field(
        type: FieldTypes.number,
        label: "Times",
        value: 0,
      ),
    ],
    children: [
      StatementInput(
        label: 'Do',
        blocks: [],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final statement = block.children[0] as StatementInput;
      final value = int.parse(block.fields[0].value);
      for (int i = 0; i < value; i++) {
        for (var block in statement.blocks) {
          block.execute(ref);
        }
      }
    },
  ),
  BlockBluePrint(
    name: 'Interval',
    fields: [
      Field(
        type: FieldTypes.number,
        label: "Miliseconds",
        value: 0,
      ),
    ],
    children: [
      StatementInput(
        label: 'Do',
        blocks: [],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final statement = block.children[0] as StatementInput;
      final value = block.fields[0].value;
      if (value is! int) {
        ref.read(uiProvider.notifier).showMessage(
              'Invalid interval',
            );
        return;
      }
      final interval = Timer.periodic(Duration(milliseconds: value), (timer) {
        for (var block in statement.blocks) {
          block.execute(ref);
        }
      });

      ref.watch(intervalProvider.notifier).addInterval(interval);
    },
  ),
];
