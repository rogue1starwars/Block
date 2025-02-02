import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:phoneduino_block/provider/ble_info.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/intervals_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
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

List<BlockBluePrint> blockData = [
  BlockBluePrint(
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
      NumericField(
        value: 100,
        label: 'Period (ms)',
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
      final mainTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (timer) {
          for (var block in loopStatement.blocks) {
            block.execute(ref);
          }
        },
      );
      ref.read(intervalProvider.notifier).addInterval(mainTimer);
    },
  ),
  BlockBluePrint(
      name: "Send Data",
      fields: [],
      children: [
        ValueInput(
            label: 'Data',
            filter: {
              BlockTypes.number: true,
              BlockTypes.string: true,
              BlockTypes.none: false,
            },
            block: null),
      ],
      returnType: BlockTypes.none,
      originalFunc: (WidgetRef ref, Block block) {
        final value = block.children[0] as ValueInput;

        final BleInfo bleInfo = ref.read(bleProvider);
        print("BleInfo: ${bleInfo.characteristics}");
        if (bleInfo.characteristics == null) {
          ref.read(uiProvider.notifier).showMessage(
                'Please connect to a device first',
              );
          print("Send Data: null");
          return;
        }

        try {
          bleInfo.characteristics!
              .write(value.block!.execute(ref).toString().codeUnits);
        } catch (e) {
          ref.read(uiProvider.notifier).showMessage(
                'Failed to send data',
              );
        }
      }),
  BlockBluePrint(
    name: 'Activate Orientation',
    fields: [],
    children: [],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final events = FlutterCompass.events;
      if (events == null) {
        ref.read(uiProvider.notifier).showMessage(
              'Orientation sensor not available',
            );
        return;
      }
      StreamSubscription orientationStream = events.listen((event) {
        Block.setVariable("_orientation", event.heading, BlockTypes.number);
      });
      Block.setVariable(
          "_orientationStream", orientationStream, BlockTypes.none);
    },
  ),
  BlockBluePrint(
    name: 'Get Orientation',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value = Block.getVariable("_orientation");
      if (value == null) {
        print("Get Orientation: null");
        return;
      }
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Activate Geolocator',
    fields: [],
    children: [],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ref.read(uiProvider.notifier).showMessage(
              'Location services are disabled',
            );
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        print(
            'Location permissions are permanently denied, we cannot request permissions.');
        return;
      }
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          print('Location permissions are denied (actual value: $permission).');
          return;
        }
      }

      print('Location services are enabled.');
      StreamSubscription<Position> positionStream =
          Geolocator.getPositionStream(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.best),
      ).listen((Position? position) {
        if (position == null) {
          print('uknown');
          return;
        }
        Block.setVariable("_long", position.longitude, BlockTypes.number);
      });
      Block.setVariable("_positionStream", positionStream, BlockTypes.none);
    },
  ),
  BlockBluePrint(
    name: 'Get Latitude',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value = Block.getVariable("_lat");
      if (value == null) {
        print("Get Latitude: null");
        return;
      }
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Get Longitude',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value = Block.getVariable("_long");
      if (value == null) {
        print("Get Longitude: null");
        return;
      }
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Set Variable',
    fields: [
      StringField(label: 'Name', value: ''),
      StringField(label: 'Type', value: ''),
    ],
    children: [
      ValueInput(label: 'Value', block: null),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final value = block.children[0] as ValueInput;
      final type = BlockTypes.values.firstWhere(
          (e) => e.toString() == 'BlockTypes.' + block.fields[1].value);
      Block.setVariable(block.fields[0].value, value.block!.execute(ref), type);
    },
  ),
  BlockBluePrint(
    name: 'Get Variable',
    fields: [
      StringField(label: 'Name', value: ''),
    ],
    children: [],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final name = block.fields[0].value;
      final value = Block.getVariable(name);
      if (value == null) {
        print("Get Variable: null");
        return;
      }
      print(value);
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Interval',
    fields: [
      NumericField(label: "Miliseconds", value: 0),
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
      final interval = Timer.periodic(Duration(milliseconds: value), (timer) {
        for (var block in statement.blocks) {
          block.execute(ref);
        }
      });

      ref.watch(intervalProvider.notifier).addInterval(interval);
    },
  ),
  BlockBluePrint(
    name: 'For Loop',
    fields: [
      NumericField(label: "Times", value: 0),
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
    name: 'Int',
    fields: [
      NumericField(label: "Value", value: 0),
    ],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      return block.fields[0].value;
    },
  ),
];
