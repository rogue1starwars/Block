import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data_core.dart';
import 'package:flutter_rotation_sensor/flutter_rotation_sensor.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/utils/orientation_util.dart';
import 'package:phoneduino_block/utils/type.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';

final List<BlockBluePrint> blockDataSensorsAngle = [
  BlockBluePrint(
    name: 'Activate Orientation',
    fields: [],
    children: [],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      RotationSensor.samplingPeriod = SensorInterval.uiInterval;
      final events = RotationSensor.orientationStream;
      if (ref
              .read(variablesProvider.notifier)
              .getVariable("_orientationStream_") !=
          null) {
        print("Orientation Stream already active");
        return;
      }
      StreamSubscription orientationStream = events.listen((event) {
        ref.read(variablesProvider.notifier).setVariable(
              "_orientation",
              formatBearing(event.eulerAngles.azimuth * 180 / pi),
              BlockTypes.number,
            );
        ref.read(variablesProvider.notifier).setVariable(
              "_pitch",
              formatBearing(event.eulerAngles.pitch * 180 / pi),
              BlockTypes.number,
            );
        ref.read(variablesProvider.notifier).setVariable(
              "_roll",
              formatBearing(event.eulerAngles.roll * 180 / pi),
              BlockTypes.number,
            );
      });
      ref.read(variablesProvider.notifier).setVariable(
            "_orientationStream_",
            orientationStream,
            BlockTypes.none,
          );
    },
  ),
  BlockBluePrint(
    name: 'Get Orientation',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value =
          ref.read(variablesProvider.notifier).getVariable("_orientation");

      if (value == null) {
        print("Get Orientation: null");
        return;
      }
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Get Pitch',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value = ref.read(variablesProvider.notifier).getVariable("_pitch");

      if (value == null) {
        print("Get Pitch: null");
        return;
      }
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Get Roll',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value = ref.read(variablesProvider.notifier).getVariable("_roll");

      if (value == null) {
        print("Get Roll: null");
        return;
      }
      return value;
    },
  ),
];
