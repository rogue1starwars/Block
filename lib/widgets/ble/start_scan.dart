import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/provider/ble_info.dart';

class StartScan extends ConsumerStatefulWidget {
  const StartScan({super.key});

  @override
  ConsumerState<StartScan> createState() => _StartScanState();
}

class _StartScanState extends ConsumerState<StartScan> {
  bool _isScanning = false;
  bool _isConnecting = false;
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

  Future<void> _handleDeviceConnection(ScanResult result) async {
    if (_isConnecting) return;

    try {
      setState(() => _isConnecting = true);
      FlutterBluePlus.stopScan();
      ref.read(bleProvider.notifier).updateDevice(
            device: result.device,
            service: null,
            characteristics: null,
          );
      await result.device.connect(
        autoConnect: true,
        mtu: null,
        timeout: const Duration(seconds: 10),
      );
      if (mounted) Navigator.pop(context, result.device);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to device: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

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
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHigh,
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
                        // onPressed: _isConnecting
                        //     ? null
                        //     : () => _handleDeviceConnection(result),
                        child: Row(
                          children: [
                            Text(
                              result.device.advName.isEmpty
                                  ? result.device.remoteId.toString()
                                  : result.device.advName,
                            ),
                            const Spacer(),
                            _isConnecting
                                ? const CircularProgressIndicator()
                                : TextButton(
                                    child: const Text("Connect"),
                                    onPressed: () =>
                                        _handleDeviceConnection(result)),
                          ],
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
