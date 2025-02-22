import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:ambient_light/ambient_light.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/utils/orientation_util.dart';
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
      final barometerStream = barometerEventStream().listen(
        (event) {
          ref.read(variablesProvider.notifier).setVariable(
                "_pressure",
                event.pressure,
                BlockTypes.number,
              );
        },
      );
      ref.read(variablesProvider.notifier).setVariable(
            "_barometerStream_",
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
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
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
            "_accelerometerStream_",
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
    name: 'Activate Magnetometer',
    fields: [],
    children: [],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final magnetometerStream = magnetometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
        (event) {
          ref.read(variablesProvider.notifier).setVariable(
                "_magnetometerX",
                event.x,
                BlockTypes.number,
              );
          ref.read(variablesProvider.notifier).setVariable(
                "_magnetometerY",
                event.y,
                BlockTypes.number,
              );
          ref.read(variablesProvider.notifier).setVariable(
                "_magnetometerZ",
                event.z,
                BlockTypes.number,
              );
        },
      );
      ref.read(variablesProvider.notifier).setVariable(
            "_magnetometerStream_",
            magnetometerStream,
            BlockTypes.none,
          );
    },
  ),
  BlockBluePrint(
    name: 'Get Magnetometer X',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value =
          ref.read(variablesProvider.notifier).getVariable("_magnetometerX");
      if (value == null) {
        print("Get Magnetometer X: null");
        return;
      }
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Get Magnetometer Y',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value =
          ref.read(variablesProvider.notifier).getVariable("_magnetometerY");
      if (value == null) {
        print("Get Magnetometer Y: null");
        return;
      }
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Get Magnetometer Z',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final value =
          ref.read(variablesProvider.notifier).getVariable("_magnetometerZ");
      if (value == null) {
        print("Get Magnetometer Z: null");
        return;
      }
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Orientation from Magnetometer',
    fields: [],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final x = ref
          .read(variablesProvider.notifier)
          .getVariable("_magnetometerX") as num?;
      final y = ref
          .read(variablesProvider.notifier)
          .getVariable("_magnetometerY") as num?;
      final z = ref
          .read(variablesProvider.notifier)
          .getVariable("_magnetometerZ") as num?;

      if (x == null || y == null || z == null) {
        print("Orientation from Magnetometer: null");
        return null;
      }
      return atan2(y, x) * 180 / pi;
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

      if (ref
              .read(variablesProvider.notifier)
              .getVariable("_positionStream_") !=
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
            "_positionStream_",
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
        label: 'Latitude (start)',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Latitude (start)',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Latitude (dest)',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Longitude (dest)',
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
        label: 'Latitude (start)',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Longitude (start)',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Latitude (dest)',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Longitude (dest)',
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
      Field(label: 'Dest Lat', type: FieldTypes.number, value: 0),
      Field(label: 'Dest Lon', type: FieldTypes.number, value: 0),
      Field(label: 'Orientation error', type: FieldTypes.number, value: 0),
      Field(label: 'Threshold', type: FieldTypes.number, value: 20),
    ],
    children: [
      ValueInput(
        label: 'Current Lat',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Current Lon',
        block: null,
        filter: [BlockTypes.number],
      ),
      ValueInput(
        label: 'Orientation',
        block: null,
        filter: [BlockTypes.number],
      ),
    ],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final destLat = block.fields[0].value;
      final destLon = block.fields[1].value;
      final orientationError = block.fields[2].value;
      final threshold = block.fields[3].value;

      final currentLat = (block.children[0] as ValueInput).block?.execute(ref);
      final currentLon = (block.children[1] as ValueInput).block?.execute(ref);

      final orientation = (block.children[2] as ValueInput).block?.execute(ref);

      if (destLat == null ||
          destLon == null ||
          threshold == null ||
          orientationError == null) {
        ref.read(uiProvider.notifier).showMessage(
              'Invalid input',
            );
        return null;
      }

      if (currentLon == null || currentLat == null) {
        ref.read(uiProvider.notifier).showMessage(
              'Invalid input',
            );
        return null;
      }

      if (currentLat is! num || currentLon is! num || orientation is! num) {
        ref.read(uiProvider.notifier).showMessage(
              'Invalid input',
            );
        return null;
      }

      final orientationCalibrated =
          formatBearing(orientation.toDouble() - orientationError);
      // print('orientation: $orientation');
      print('orientationCalibrated: $orientationCalibrated');

      final bearing = Geolocator.bearingBetween(
        currentLat.toDouble(),
        currentLon.toDouble(),
        destLat.toDouble(),
        destLon.toDouble(),
      );

      final double angle = formatBearing(orientationCalibrated - bearing);
      print('angle: $angle');

      if (angle.abs() < threshold) {
        return 1;
      } else if (angle < 0) {
        return 2;
      } else {
        return 3;
      }
    },
  )
];
