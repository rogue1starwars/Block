import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data_core.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/intervals_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/utils/type.dart';

List<BlockBluePrint> blockDataLoops = [
  BlockBluePrint(
    name: 'Repeat',
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
    name: 'Repeat While',
    fields: [],
    children: [
      ValueInput(
        label: 'Condition',
        block: null,
        filter: [BlockTypes.boolean],
      ),
      StatementInput(
        label: 'Do',
        blocks: [],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final condition = block.children[0] as ValueInput;
      final statement = block.children[1] as StatementInput;
      while (condition.block!.execute(ref)) {
        for (var block in statement.blocks) {
          block.execute(ref);
        }
      }
    },
  ),
  BlockBluePrint(
    name: 'Force Stop',
    fields: [],
    children: [],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      ref.watch(intervalProvider.notifier).clearInterval();
    },
  ),
  BlockBluePrint(
    name: 'Timer',
    fields: [
      Field(
        type: FieldTypes.number,
        label: "Miliseconds",
        value: 0,
      ),
      Field(
        type: FieldTypes.variableNames,
        label: "Timer Name",
        value: '',
        variableType: BlockTypes.timer,
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
      final timerName = block.fields[1].value;
      if (value is! int) {
        ref.read(uiProvider.notifier).showMessage(
              'Invalid interval',
            );
        return;
      }
      if (timerName is! String) {
        ref.read(uiProvider.notifier).showMessage(
              'Invalid timer name',
            );
        return;
      }

      if (!ref.read(variablesProvider.notifier).hasVariable(timerName)) {
        ref.read(uiProvider.notifier).showMessage(
              'Timer name not found',
            );
        return;
      }

      final timer = Future.delayed(
        Duration(milliseconds: value),
        () {
          for (var block in statement.blocks) {
            block.execute(ref);
          }
        },
      );
      if (ref.read(variablesProvider.notifier).hasVariable(timerName)) {
        ref.read(variablesProvider.notifier).updateVariable(timerName, timer);
      } else {
        ref
            .read(variablesProvider.notifier)
            .setVariable(timerName, timer, BlockTypes.timer);
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
