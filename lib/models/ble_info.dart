import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BleInfo {
  final BluetoothDevice? device;
  final bool connected;
  final BluetoothService? service;
  final BluetoothCharacteristic? characteristics;

  BleInfo({
    this.device,
    this.connected = false,
    this.service,
    this.characteristics,
  });

  BleInfo copyWith({
    BluetoothDevice? device,
    bool? connected,
    BluetoothService? service,
    BluetoothCharacteristic? characteristics,
  }) {
    return BleInfo(
      device: device ?? this.device,
      connected: connected ?? this.connected,
      service: service ?? this.service,
      characteristics: characteristics ?? this.characteristics,
    );
  }
}

class BleNotifier extends StateNotifier<BleInfo> {
  BleNotifier() : super(BleInfo());
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  void copyWith({
    BluetoothDevice? device,
    BluetoothService? service,
    BluetoothCharacteristic? characteristics,
  }) {
    if (device != null) {
      _connectionStateSubscription =
          device.connectionState.listen((connectionState) {
        if (connectionState == BluetoothConnectionState.connected) {
          print("Connected");
          state = state.copyWith(connected: true);
        } else if (connectionState == BluetoothConnectionState.disconnected) {
          print("Disconnected");
          state = state.copyWith(connected: false);
        }
      });
    }
    state = state.copyWith(
      device: device,
      service: service,
      characteristics: characteristics,
    );
  }
}

final bleProvider = StateNotifierProvider<BleNotifier, BleInfo>((ref) {
  return BleNotifier();
});
