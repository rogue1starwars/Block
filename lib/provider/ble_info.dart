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
    bool? disconnected,
  }) {
    if (disconnected != null && disconnected) {
      return BleInfo(
        device: device ?? this.device,
        connected: false,
        service: null,
        characteristics: null,
      );
    }
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
  bool _isDiscovering = false;

  Future<(BluetoothService?, BluetoothCharacteristic?)>
      _discoverServices() async {
    int retryCount = 0;

    if (state.device == null) {
      return (null, null);
    }

    try {
      if (!state.connected) return (null, null);
      final List<BluetoothService> services =
          await state.device!.discoverServices();
      final primaryService = services.firstWhere((service) =>
          service.serviceUuid == Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E"));

      // Discover characteristics
      final characteristic = primaryService.characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid ==
              Guid("6E400002-B5A3-F393-E0A9-E50E24DCCA9E"));

      return (primaryService, characteristic);
    } catch (e) {
      if (retryCount < 3) {
        retryCount++;
        await Future.delayed(const Duration(milliseconds: 1000));
        rethrow;
      } else {
        return (null, null);
      }
    }
  }

  void updateDevice({
    BluetoothDevice? device,
    BluetoothService? service,
    BluetoothCharacteristic? characteristics,
  }) {
    state = state.copyWith(
      device: device,
    );
    if (device != null) {
      _connectionStateSubscription?.cancel();
      _connectionStateSubscription =
          device.connectionState.listen((connectionState) {
        if (connectionState == BluetoothConnectionState.connected) {
          print("Connected");
          state = state.copyWith(connected: true);

          // Try to discover services
          if (!_isDiscovering &&
              (state.characteristics == null || state.service == null)) {
            _isDiscovering = true;
            Future.delayed(
              const Duration(milliseconds: 1000),
              () async {
                try {
                  final services = await _discoverServices();
                  if (services.$1 == null || services.$2 == null) {
                    throw Exception("Failed to discover services");
                  } else {
                    state = state.copyWith(
                      service: services.$1,
                      characteristics: services.$2,
                    );
                  }
                } finally {
                  _isDiscovering = false;
                }
              },
            );
          }
        } else if (connectionState == BluetoothConnectionState.disconnected) {
          print("Disconnected");
          state = state.copyWith(
            disconnected: true,
          );
        }
      }, onError: (e) {
        state = state.copyWith(
          disconnected: true,
        );
      });
    }
  }
}

final bleProvider = StateNotifierProvider<BleNotifier, BleInfo>((ref) {
  return BleNotifier();
});
