import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/ble_info.dart';

class StartScan extends ConsumerStatefulWidget {
  const StartScan({super.key});

  @override
  ConsumerState<StartScan> createState() => _StartScanState();
}

class _StartScanState extends ConsumerState<StartScan> {
  bool _isScanning = false;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((isScanning) {
      _isScanning = isScanning;
      if (mounted) setState(() {});
    }, onError: (e) {
      // TODO: handle error
    });
  }

  // Quick note. withServices is just a uuid of the services. Maybe we should include it when scanning.
  @override
  void dispose() {
    _isScanningSubscription.cancel();
    super.dispose();
  }

  // Future<void> _connectToDevice(BluetoothDevice device) async {
  //   try {
  //     setState(() => _isConnecting = true);

  //     // Listen to connection state changes
  //     _connectionStateSubscription = device.connectionState.listen((state) {
  //       if (state == BluetoothConnectionState.disconnected) {
  //         setState(() => _isConnecting = false);
  //       }
  //     });

  //     // Connect to device
  //     await device.connect(
  //       timeout: const Duration(seconds: 10),
  //     );

  //     // Discover services
  //     final services = await device.discoverServices();

  //     // Update UI or notify parent
  //     if (mounted) {
  //       setState(() => _isConnecting = false);
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to connect: ${e.toString()}')),
  //       );
  //       setState(() => _isConnecting = false);
  //     }
  //   }
  // }

  Future<void> _dialogBuilder(BuildContext context) async {
    // Show dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StreamBuilder<List<ScanResult>>(
          stream: FlutterBluePlus.scanResults,
          initialData: const [],
          builder: (context, snapshot) {
            return SimpleDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Scanning..."),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      FlutterBluePlus.stopScan();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              children: snapshot.data!
                  .map((result) => SimpleDialogOption(
                        onPressed: () {
                          FlutterBluePlus.stopScan();
                          ref.read(bleProvider.notifier).copyWith(
                                device: result.device,
                              );
                          Navigator.pop(context, result.device);
                        },
                        child: Text(
                          result.device.advName.isEmpty
                              ? result.device.remoteId.toString()
                              : result.device.advName,
                        ),
                      ))
                  .toList(),
            );
          },
        );
      },
    );

    // Start scanning after dialog is shown
    await FlutterBluePlus.startScan(
      withServices: [Guid("6E400001-B5A3-F393-E0A9-E50E24DCCA9E")],
      withNames: ["UART Service"],
      timeout: const Duration(seconds: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          if (_isScanning) {
            await FlutterBluePlus.stopScan();
          } else {
            await _dialogBuilder(context);
          }
        },
        icon: const Icon(
          Icons.bluetooth,
        ));
  }
}
