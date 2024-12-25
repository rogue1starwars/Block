import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BleInfo {
  final BluetoothDevice? device;
  final bool connected;
  final List<BluetoothService> services;
  final List<BluetoothCharacteristic> characteristics;

  const BleInfo({
    this.device,
    this.connected = false,
    this.services = const [],
    this.characteristics = const [],
  });

  BleInfo copyWith({
    BluetoothDevice? device,
    bool? connected,
    List<BluetoothService>? services,
    List<BluetoothCharacteristic>? characteristics,
  }) {
    return BleInfo(
      device: device ?? this.device,
      connected: connected ?? this.connected,
      services: services ?? this.services,
      characteristics: characteristics ?? this.characteristics,
    );
  }
}

class BleNotifier extends StateNotifier<BleInfo> {
  BleNotifier() : super(const BleInfo());
}

final bleProvider = StateNotifierProvider<BleNotifier, BleInfo>((ref) {
  return BleNotifier();
});
