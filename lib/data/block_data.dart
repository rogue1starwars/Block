import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:phoneduino_block/models/ble_info.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/utils/type.dart';

class BlockBluePrint {
  final String name;
  final List<Field>? fields;

  final List<Input>? children;
  final BlockTypes returnType;
  final Function(Block) originalFunc;

  BlockBluePrint({
    required this.name,
    required this.returnType,
    required this.originalFunc,
    this.fields,
    this.children,
  });
}

List<BlockBluePrint> filterBlockData(Map<BlockTypes, bool>? filter) {
  if (filter == null) {
    return blockData;
  }

  return blockData.where((block) {
    return filter.containsKey(block.returnType)
        ? filter[block.returnType]!
        : true;
  }).toList();
}

List<BlockBluePrint> blockData = [
  BlockBluePrint(
    name: 'Main',
    children: [
      StatementInput(
        label: 'Do',
        blocks: [],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (Block block) {
      if (block.children == null) return;
      if (block.children!.isEmpty) return;

      final statement = block.children![0] as StatementInput;
      statement.blocks.forEach((block) {
        block.execute();
      });
    },
  ),
  BlockBluePrint(
      name: "Send Data",
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
      originalFunc: (Block block) {
        ScaffoldMessenger.of(Block.getVariable("_context")).showSnackBar(
          const SnackBar(
            content: Text('Please connect to a device first'),
          ),
        );
        if (block.children == null) return;
        if (block.children!.isEmpty) return;

        final value = block.children![0] as ValueInput;
        if (value.block == null) {
          print("Send Data: null");
          return;
        }

        final BleInfo bleInfo = Block.getVariable("_ble");
        if (bleInfo == null) {
          print("Send Data: null");
          return;
        }
        if (bleInfo.characteristics == null) {
          print("Send Data: null");
          return;
        }

        bleInfo.characteristics!
            .write(value.block!.execute().toString().codeUnits);
      }),
  BlockBluePrint(
    name: 'Activate Orientation',
    returnType: BlockTypes.none,
    originalFunc: (Block block) {
      final events = FlutterCompass.events;
      if (events == null) {
        print("Activate Orientation: null");
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
    returnType: BlockTypes.number,
    originalFunc: (Block block) {
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
    returnType: BlockTypes.none,
    originalFunc: (Block block) async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
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
        locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
      ).listen((Position? position) {
        if (position == null) {
          print('uknown');
          return;
        }
        // print(position.latitude.toString() +
        //     ', ' +
        //     position.longitude.toString());
        Block.setVariable("_lat", position.latitude, BlockTypes.number);
        Block.setVariable("_long", position.longitude, BlockTypes.number);
      });
      Block.setVariable("_positionStream", positionStream, BlockTypes.none);
    },
  ),
  BlockBluePrint(
    name: 'Get Latitude',
    returnType: BlockTypes.number,
    originalFunc: (Block block) {
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
    returnType: BlockTypes.number,
    originalFunc: (Block block) {
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
    originalFunc: (Block block) {
      if (block.children == null) return;
      if (block.children!.isEmpty) return;

      final value = block.children![0] as ValueInput;
      if (value.block == null) {
        print("Set Variable: null");
        return;
      }
      if (block.fields == null) return;
      if (block.fields!.isEmpty) return;
      final type = BlockTypes.values.firstWhere(
          (e) => e.toString() == 'BlockTypes.' + block.fields![1].value);
      Block.setVariable(block.fields![0].value, value.block!.execute(), type);
    },
  ),
  BlockBluePrint(
    name: 'Get Variable',
    fields: [
      StringField(label: 'Name', value: ''),
    ],
    children: [],
    returnType: BlockTypes.none,
    originalFunc: (Block block) {
      if (block.fields == null) return;
      if (block.fields!.isEmpty) return;

      final name = block.fields![0].value;
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
    originalFunc: (Block block) {
      if (block.fields == null) return;
      if (block.fields!.isEmpty) return;

      final statement = block.children![0] as StatementInput;
      final value = int.parse(block.fields![0].value);
      Timer.periodic(Duration(milliseconds: value), (timer) {
        statement.blocks.forEach((block) {
          block.execute();
        });
      });
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
    originalFunc: (Block block) {
      if (block.fields == null) return;
      if (block.fields!.isEmpty) return;

      final statement = block.children![0] as StatementInput;
      final value = int.parse(block.fields![0].value);
      for (int i = 0; i < value; i++) {
        statement.blocks.forEach((block) {
          block.execute();
        });
      }
    },
  ),
  BlockBluePrint(
    name: 'Print',
    children: [
      ValueInput(
        label: 'Value',
        block: null,
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (Block block) {
      if (block.children == null) return;
      if (block.children!.isEmpty) return;

      final value = block.children![0] as ValueInput;
      if (value.block == null) {
        print("Print: null");
      }
      print("Printing from print block: ${value.block!.execute()}");
    },
  ),
  BlockBluePrint(
    name: 'Int',
    fields: [
      NumericField(label: "Value", value: 0),
    ],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (Block block) {
      if (block.fields == null) return;
      if (block.fields!.isEmpty) return;
      return block.fields![0].value;
    },
  ),
];
