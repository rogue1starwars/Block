import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/intervals_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/utils/file_logger.dart';
import 'package:phoneduino_block/utils/type.dart';
import 'package:phoneduino_block/data/block_data_core.dart';

final List<BlockBluePrint> blockDataLogs = [
  BlockBluePrint(
    name: 'Create very long log',
    fields: [
      Field(
        type: FieldTypes.number,
        label: 'Length',
        value: 1000,
      ),
    ],
    children: [],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final length = block.fields[0].value;
      if (length is! int) {
        ref.read(uiProvider.notifier).showMessage(
              'Invalid length',
            );
        return;
      }
      if (length < 1) {
        ref.read(uiProvider.notifier).showMessage(
              'Length must be at least 1',
            );
        return;
      }
      final log = List.generate(length, (index) => 'Log $index').join(', ');
      writeLog(log, ref);
    },
  ),
  BlockBluePrint(
      name: 'Logger',
      fields: [
        Field(
          type: FieldTypes.number,
          label: 'Interval (ms)',
          value: 1000,
        )
      ],
      children: [
        StatementInput(
          label: 'Data',
          blocks: [],
          filter: [
            BlockTypes.number,
            BlockTypes.string,
          ],
        )
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
        if (value < 100) {
          ref.read(uiProvider.notifier).showMessage(
                'Interval must be at least 100ms',
              );
          return;
        }
        final interval = Timer.periodic(
          Duration(milliseconds: value),
          (timer) {
            String logTotal = '';
            for (var block in statement.blocks) {
              final valueToLog = block.execute(ref);
              if (valueToLog is! String && valueToLog is! num) {
                ref.read(uiProvider.notifier).showMessage(
                      'Invalid value to log',
                    );
                continue;
              }
              logTotal += '$valueToLog, ';
            }
            writeLog(logTotal, ref);
          },
        );

        ref.watch(intervalProvider.notifier).addInterval(interval);
      }),
  BlockBluePrint(
    name: 'Log',
    fields: [],
    children: [
      ValueInput(
        label: 'Value',
        block: null,
        filter: [
          BlockTypes.string,
          BlockTypes.number,
        ],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      // print("Logger");
      final value = block.children[0] as ValueInput;
      final valueToLog = value.block!.execute(ref);
      if (valueToLog is! String && valueToLog is! num) {
        ref.read(uiProvider.notifier).showMessage(
              'Invalid value to log',
            );
        return;
      }
      writeLog(valueToLog, ref);
    },
  ),
];
