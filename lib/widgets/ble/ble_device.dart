import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/ble_info.dart';

class BleDevice extends ConsumerStatefulWidget {
  const BleDevice({super.key});

  @override
  ConsumerState<BleDevice> createState() => _BleDeviceState();
}

class _BleDeviceState extends ConsumerState<BleDevice> {
  Future<void> _discoverServices() async {
    int retryCount = 0;

    BluetoothDevice? device = ref.watch(bleProvider).device;
    if (device == null) {
      return;
    }

    try {
      final List<BluetoothService> services = await device.discoverServices();
      final primaryService = services.firstWhere((service) =>
          service.serviceUuid == Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E"));

      // Discover characteristics
      final characteristic = primaryService.characteristics.firstWhere(
          (characteristic) =>
              characteristic.uuid ==
              Guid("6E400002-B5A3-F393-E0A9-E50E24DCCA9E"));

      ref.read(bleProvider.notifier).copyWith(
            service: primaryService,
            characteristics: characteristic,
          );
    } catch (e) {
      if (retryCount < 3) {
        retryCount++;
        await Future.delayed(const Duration(milliseconds: 1000));
        rethrow;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to discover services: $e')),
          );
        }
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(
        autoConnect: true,
        mtu: null,
        timeout: const Duration(seconds: 10),
      );

      await Future.delayed(const Duration(milliseconds: 1000));

      if (ref.watch(bleProvider).connected == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to connect')),
          );
        }
        return;
      }

      await _discoverServices();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bleInfo = ref.watch(bleProvider);

    if (bleInfo.device == null) {
      return const Text("No Device");
    }

    if (bleInfo.connected) {
      return Row(
        children: [
          Text(
            bleInfo.device!.advName.isEmpty
                ? bleInfo.device!.remoteId.toString()
                : bleInfo.device!.advName,
          ),
          IconButton(
            onPressed: () async {
              await bleInfo.device!.disconnect();
            },
            icon: const Icon(Icons.close),
          ),
          if (bleInfo.service == null)
            IconButton(
              onPressed: () async {
                try {
                  await _discoverServices();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Failed to discover services: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.refresh),
            ),
        ],
      );
    }

    return Row(
      children: [
        Text(
          bleInfo.device!.advName.isEmpty
              ? bleInfo.device!.remoteId.toString()
              : bleInfo.device!.advName,
        ),
        IconButton(
          onPressed: () async {
            await _connectToDevice(bleInfo.device!);
          },
          icon: const Icon(Icons.bluetooth),
        ),
      ],
    );
  }
}
