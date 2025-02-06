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
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/utils/file_logger.dart';
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
  ),
  BlockBluePrint(
      name: "Send Data",
      fields: [],
      children: [
        ValueInput(
            label: 'Data',
            filter: [
              BlockTypes.number,
              BlockTypes.string,
            ],
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
        if (value < 1000) {
          ref.read(uiProvider.notifier).showMessage(
                'Interval must be at least 1000ms',
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

      if (ref
              .read(variablesProvider.notifier)
              .getVariable("_orientationStream") !=
          null) {
        print("Orientation Stream already active");
        return;
      }
      StreamSubscription orientationStream = events.listen((event) {
        ref.read(variablesProvider.notifier).setVariable(
              "_orientation",
              event.heading,
              BlockTypes.number,
            );
      });
      ref.read(variablesProvider.notifier).setVariable(
            "_orientationStream",
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

      if (ref.read(variablesProvider.notifier).getVariable("_positionStream") !=
          null) {
        print("Position Stream already active");
        return;
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
        ref.read(variablesProvider.notifier).setVariable(
              "_lat",
              position.latitude,
              BlockTypes.none,
            );
        ref.read(variablesProvider.notifier).setVariable(
              "_long",
              position.longitude,
              BlockTypes.number,
            );
      });
      ref.read(variablesProvider.notifier).setVariable(
            "_positionStream",
            positionStream,
            BlockTypes.none,
          );
    },
  ),
  BlockBluePrint(
    name: 'Get Latitude',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value = ref.read(variablesProvider.notifier).getVariable("_lat");
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
      final value = ref.read(variablesProvider.notifier).getVariable("_long");
      if (value == null) {
        print("Get Longitude: null");
        return;
      }
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Set Variable (Number)',
    fields: [
      Field(
        type: FieldTypes.variableNames,
        label: 'Name',
        value: '',
        variableType: BlockTypes.number,
      ),
    ],
    children: [
      ValueInput(
        label: 'Value',
        block: null,
        filter: [BlockTypes.number],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final value = block.children[0] as ValueInput;
      ref.read(variablesProvider.notifier).setVariable(
            block.fields[0].value,
            value.block!.execute(ref),
            BlockTypes.number,
          );
    },
  ),
  BlockBluePrint(
    name: 'Set Variable (String)',
    fields: [
      Field(
        type: FieldTypes.variableNames,
        label: 'Name',
        value: '',
        variableType: BlockTypes.string,
      ),
    ],
    children: [
      ValueInput(
        label: 'Value',
        block: null,
        filter: [BlockTypes.string],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final value = block.children[0] as ValueInput;
      // testing... store varibles in riverpod providers
      ref.read(variablesProvider.notifier).setVariable(
            block.fields[0].value,
            value.block!.execute(ref),
            BlockTypes.string,
          );
    },
  ),
  BlockBluePrint(
    name: 'Get Variable (Number)',
    fields: [
      Field(
        type: FieldTypes.variableNames,
        label: 'Name',
        value: '',
        variableType: BlockTypes.number,
      ),
    ],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final name = block.fields[0].value;
      final value = ref.read(variablesProvider.notifier).getVariable(name);
      if (value == null) {
        print("Get Variable: null");
        return;
      }
      print(value);
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Get Variable (String)',
    fields: [
      Field(
        type: FieldTypes.variableNames,
        label: 'Name',
        value: '',
        variableType: BlockTypes.string,
      ),
    ],
    children: [],
    returnType: BlockTypes.string,
    originalFunc: (WidgetRef ref, Block block) {
      final name = block.fields[0].value;
      final value = ref.read(variablesProvider.notifier).getVariable(name);
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
        return int.parse(value);
      } else if (value is num) {
        return value;
      } else {
        throw "Invalid return";
      }
    },
  ),
];
