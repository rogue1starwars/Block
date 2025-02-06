import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data_ble.dart';
import 'package:phoneduino_block/data/block_data_logic.dart';
import 'package:phoneduino_block/data/block_data_logs.dart';
import 'package:phoneduino_block/data/block_data_loops.dart';
import 'package:phoneduino_block/data/block_data_math.dart';
import 'package:phoneduino_block/data/block_data_sensors.dart';
import 'package:phoneduino_block/data/block_data_strings.dart';
import 'package:phoneduino_block/data/block_data_variables.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/intervals_provider.dart';
import 'package:phoneduino_block/utils/type.dart';

class BlockBluePrint {
  final String name;
  final List<Field> fields;

  final List<Input> children;
  final BlockTypes returnType;
  final Function(WidgetRef, Block) originalFunc;

  BlockBluePrint({
    required this.name,
    required this.returnType,
    required this.originalFunc,
    required this.fields,
    required this.children,
  });
}

final mainBlock = BlockBluePrint(
  name: 'Main',
  children: [
    StatementInput(
      label: 'Setup',
      blocks: [],
    ),
    StatementInput(
      label: 'Loop',
      blocks: [],
    ),
  ],
  fields: [
    Field(
      value: 100,
      label: 'Period (ms)',
      type: FieldTypes.number,
    )
  ],
  returnType: BlockTypes.none,
  originalFunc: (WidgetRef ref, Block block) {
    // Setup
    final setupStatement = block.children[0] as StatementInput;
    for (var block in setupStatement.blocks) {
      block.execute(ref);
    }

    // loop
    final loopStatement = block.children[1] as StatementInput;
    late final int interval;
    if (block.fields[0].value is String) {
      print(block.fields[0].value);
      interval = int.parse(block.fields[0].value);
    } else if (block.fields[0].value is int) {
      interval = block.fields[0].value;
    } else {
      throw const FormatException('Invalid period');
    }
    final mainTimer = Timer.periodic(
      Duration(milliseconds: interval),
      (timer) {
        for (var block in loopStatement.blocks) {
          block.execute(ref);
        }
      },
    );
    ref.read(intervalProvider.notifier).addInterval(mainTimer);
  },
);
Map<String, List<BlockBluePrint>> blockData = {
  'Main': [mainBlock],
  'Logic': blockDataLogic,
  'Loops': blockDataLoops,
  'Logs': blockDataLogs,
  'Bluetooth': blockDataBle,
  'Sensors': blockDataSensors,
  'Variables': blockDataVariables,
  'Strings': blockDataStrings,
  'Math': blockDataMath,
};
