import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phoneduino_block/provider/camera_provider.dart';

class CameraHome extends ConsumerStatefulWidget {
  const CameraHome({super.key});

  @override
  ConsumerState<CameraHome> createState() => _CameraHomeState();
}

class _CameraHomeState extends ConsumerState<CameraHome> {
  String _status = 'Requesting camera permission...';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          ref.read(cameraProvider.notifier).setCamera(cameras[0]);
          setState(() {
            _status = 'Camera ready: ${cameras[0].name}';
          });
        } else {
          setState(() {
            _status = 'No cameras found';
          });
        }
      } catch (e) {
        setState(() {
          _status = 'Error initializing camera: $e';
        });
      }
    } else {
      setState(() {
        _status = 'Camera permission denied';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(_status));
  }
}
