import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:ambient_light/ambient_light.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/utils/type.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:phoneduino_block/data/block_data_core.dart';

final List<BlockBluePrint> blockDataSensors = [
  BlockBluePrint(
    name: 'Activate Ambient Light Sensor',
    fields: [],
    children: [],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      late final AmbientLight _ambientLight;
      if (Platform.isIOS) {
        _ambientLight = AmbientLight(frontCamera: true);
      } else {
        _ambientLight = AmbientLight();
      }

      _ambientLight.ambientLightStream.listen((double lightLevel) {
        ref.read(variablesProvider.notifier).setVariable(
              "_lightLevel",
              lightLevel,
              BlockTypes.number,
            );
      });
    },
  ),
  BlockBluePrint(
    name: 'Get Ambient Light Level',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value =
          ref.read(variablesProvider.notifier).getVariable("_lightLevel");
      if (value == null) {
        print("Get Ambient Light Level: null");
        return;
      }
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Activate Barometer',
    fields: [],
    children: [],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final barometerStream =
          barometerEventStream(samplingPeriod: SensorInterval.fastestInterval)
              .listen(
        (event) {
          ref.read(variablesProvider.notifier).setVariable(
                "_pressure",
                event.pressure,
                BlockTypes.number,
              );
        },
      );
      ref.read(variablesProvider.notifier).setVariable(
            "_barometerStream",
            barometerStream,
            BlockTypes.none,
          );
    },
  ),
  BlockBluePrint(
    name: "Get Barometer",
    returnType: BlockTypes.number,
    fields: [],
    children: [],
    originalFunc: (WidgetRef ref, Block block) {
      final value =
          ref.read(variablesProvider.notifier).getVariable("_pressure");
      if (value == null) {
        print("Get Barometer: null");
        return;
      }
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Activate Accelerometer',
    fields: [],
    children: [],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final accelerometerStream = accelerometerEventStream(
              samplingPeriod: SensorInterval.normalInterval)
          .listen(
        (event) {
          ref.read(variablesProvider.notifier).setVariable(
                "_accelerometerX",
                event.x,
                BlockTypes.number,
              );
          ref.read(variablesProvider.notifier).setVariable(
                "_accelerometerY",
                event.y,
                BlockTypes.number,
              );
          ref.read(variablesProvider.notifier).setVariable(
                "_accelerometerZ",
                event.z,
                BlockTypes.number,
              );
        },
      );
      ref.read(variablesProvider.notifier).setVariable(
            "_accelerometerStream",
            accelerometerStream,
            BlockTypes.none,
          );
    },
  ),
  BlockBluePrint(
    name: 'Get Accelerometer X',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value =
          ref.read(variablesProvider.notifier).getVariable("_accelerometerX");
      if (value == null) {
        print("Get Accelerometer X: null");
        return;
      }
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Get Accelerometer Y',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value =
          ref.read(variablesProvider.notifier).getVariable("_accelerometerY");
      if (value == null) {
        print("Get Accelerometer Y: null");
        return;
      }
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Get Accelerometer Z',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value =
          ref.read(variablesProvider.notifier).getVariable("_accelerometerZ");
      if (value == null) {
        print("Get Accelerometer Z: null");
        return;
      }
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Accelerometer Total',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final x = ref
          .read(variablesProvider.notifier)
          .getVariable("_accelerometerX") as num?;
      final y = ref
          .read(variablesProvider.notifier)
          .getVariable("_accelerometerY") as num?;
      final z = ref
          .read(variablesProvider.notifier)
          .getVariable("_accelerometerZ") as num?;

      if (x == null || y == null || z == null) {
        print("Accelerometer Total: null");
        return null;
      }
      return sqrt(x * x + y * y + z * z);
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
    name: 'Calculate Distance',
    fields: [],
    children: [
      ValueInput(
        label: 'Latitude 1',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Longitude 1',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Latitude 2',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Longitude 2',
        block: null,
        filter: [BlockTypes.number],
      ),
    ],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final lat1 = block.children[0] as ValueInput;
      final long1 = block.children[1] as ValueInput;
      final lat2 = block.children[2] as ValueInput;
      final long2 = block.children[3] as ValueInput;

      if (lat1.block == null ||
          long1.block == null ||
          lat2.block == null ||
          long2.block == null) {
        ref.read(uiProvider.notifier).showMessage(
              'Invalid input',
            );
        return null;
      }

      if (lat1.block!.execute(ref) == null ||
          long1.block!.execute(ref) == null ||
          lat2.block!.execute(ref) == null ||
          long2.block!.execute(ref) == null) {
        ref.read(uiProvider.notifier).showMessage(
              'Invalid input',
            );
        return null;
      }

      final double distance = Geolocator.distanceBetween(
        lat1.block!.execute(ref),
        long1.block!.execute(ref),
        lat2.block!.execute(ref),
        long2.block!.execute(ref),
      );
      return distance;
    },
  ),
  BlockBluePrint(
    name: 'Calculate Bearing',
    fields: [],
    children: [
      ValueInput(
        label: 'Latitude 1',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Longitude 1',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Latitude 2',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Longitude 2',
        block: null,
        filter: [BlockTypes.number],
      ),
    ],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final lat1 = block.children[0] as ValueInput;
      final long1 = block.children[1] as ValueInput;
      final lat2 = block.children[2] as ValueInput;
      final long2 = block.children[3] as ValueInput;

      if (lat1.block == null ||
          long1.block == null ||
          lat2.block == null ||
          long2.block == null) {
        ref.read(uiProvider.notifier).showMessage(
              'Invalid input',
            );
        return null;
      }

      if (lat1.block!.execute(ref) == null ||
          long1.block!.execute(ref) == null ||
          lat2.block!.execute(ref) == null ||
          long2.block!.execute(ref) == null) {
        ref.read(uiProvider.notifier).showMessage(
              'Invalid input',
            );
        return null;
      }

      final double bearing = Geolocator.bearingBetween(
        lat1.block!.execute(ref).toDouble(),
        long1.block!.execute(ref).toDouble(),
        lat2.block!.execute(ref).toDouble(),
        long2.block!.execute(ref).toDouble(),
      );
      return bearing;
    },
  ),
  BlockBluePrint(
    name: 'Calculate and Create Signal',
    fields: [
      Field(label: 'Dest Lon', type: FieldTypes.number, value: 0),
      Field(label: 'Dest Lat', type: FieldTypes.number, value: 0),
      Field(label: 'Orientation error', type: FieldTypes.number, value: 0),
      Field(label: 'Threshold', type: FieldTypes.number, value: 20),
    ],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final destLon = block.fields[0].value;
      final destLat = block.fields[1].value;
      final orientationError = block.fields[2].value;
      final threshold = block.fields[3].value;

      if (destLon == null ||
          destLat == null ||
          threshold == null ||
          orientationError == null) {
        ref.read(uiProvider.notifier).showMessage(
              'Invalid input',
            );
        return null;
      }

      final currentLon =
          ref.read(variablesProvider.notifier).getVariable('_long') as num?;
      final currentLat =
          ref.read(variablesProvider.notifier).getVariable('_lat') as num?;

      if (currentLon == null || currentLat == null) {
        ref.read(uiProvider.notifier).showMessage(
              'Invalid input',
            );
        return null;
      }

      final orientation = ref
              .read(variablesProvider.notifier)
              .getVariable('_orientation') as double? ??
          0;

      final orientationCalibrated = (orientation - orientationError) % 360;

      final bearing = Geolocator.bearingBetween(
        currentLon.toDouble(),
        currentLat.toDouble(),
        destLon.toDouble(),
        destLat.toDouble(),
      );

      if ((orientationCalibrated - bearing).abs() < threshold) {
        return 0;
      } else if ((bearing - orientationCalibrated) < 0) {
        return -1;
      } else {
        return 1;
      }
    },
  )
];
