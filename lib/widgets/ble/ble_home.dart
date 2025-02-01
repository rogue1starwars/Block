import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/widgets/ble/ble_device.dart';
import 'package:phoneduino_block/widgets/ble/start_scan.dart';

class BleHome extends ConsumerStatefulWidget {
  const BleHome({super.key});

  @override
  ConsumerState<BleHome> createState() => _BleHomeState();
}

class _BleHomeState extends ConsumerState<BleHome> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;

  String errorMessage = "Bluetooth is Off";

  bool _turningBluetoothOn = false;

  Future<void> _initBluetooth() async {
    if (await FlutterBluePlus.isSupported == false) {
      if (mounted) {
        setState(() {
          errorMessage = "Bluetooth is not supported";
        });
        return;
      }
    }

    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (!mounted) return;
      setState(() {
        _adapterState = state;
      });

      if (_adapterState != BluetoothAdapterState.on) {
        if (_turningBluetoothOn) return;
        if (Platform.isAndroid) {
          FlutterBluePlus.turnOn().then((value) {
            _turningBluetoothOn = true;
          }).catchError((e) {
            if (mounted) {
              setState(() {
                errorMessage = e.toString();
              });
            }
          });
        }
      }
    }, onError: (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  @override
  void dispose() {
    _adapterStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _adapterState == BluetoothAdapterState.on
          ? const StartScan()
          : Text(errorMessage),
      const BleDevice(),
    ]);
  }
}
