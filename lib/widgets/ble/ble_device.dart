import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/provider/ble_info.dart';

class BleDevice extends ConsumerStatefulWidget {
  const BleDevice({super.key});

  @override
  ConsumerState<BleDevice> createState() => _BleDeviceState();
}

class _BleDeviceState extends ConsumerState<BleDevice> {
  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(
        autoConnect: true,
        mtu: null,
        timeout: const Duration(seconds: 10),
      );

      await Future.delayed(const Duration(milliseconds: 1000));
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

    return Row(
      children: [
        Text(
          bleInfo.device!.advName.isEmpty
              ? bleInfo.device!.remoteId.toString()
              : bleInfo.device!.advName,
        ),
        if (!bleInfo.connected)
          TextButton(
            onPressed: () async {
              await _connectToDevice(bleInfo.device!);
            },
            child: const Text("Connect"),
          )
        else if (bleInfo.service == null)
          const CircularProgressIndicator(),
        IconButton(
          onPressed: () async {
            await bleInfo.device!.disconnect();
          },
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}
