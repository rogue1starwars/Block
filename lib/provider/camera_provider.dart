import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

class CameraControllerInfo {
  final CameraDescription? camera;
  final CameraController? controller;
  final bool isCameraActive;

  CameraControllerInfo({
    this.camera,
    this.controller,
    this.isCameraActive = false,
  });

  CameraControllerInfo copyWith({
    CameraDescription? camera,
    CameraController? controller,
    bool? isCameraActive,
  }) {
    return CameraControllerInfo(
      camera: camera ?? this.camera,
      controller: controller ?? this.controller,
      isCameraActive: isCameraActive ?? this.isCameraActive,
    );
  }
}

class CameraControllerNotifier extends StateNotifier<CameraControllerInfo> {
  CameraControllerNotifier() : super(CameraControllerInfo());

  void setCamera(CameraDescription camera) {
    if (state.camera != null) {
      state.controller?.dispose();
    }
    state = state.copyWith(camera: camera);
  }

  Future<bool> activateCamera() async {
    if (state.isCameraActive) {
      return false;
    }
    if (state.controller != null) {
      await state.controller!.dispose();
    }
    if (state.camera == null) {
      return false;
    }
    final controller = CameraController(
      state.camera!,
      ResolutionPreset.medium,
    );
    try {
      await controller.initialize();
      state = state.copyWith(
        controller: controller,
        isCameraActive: true,
      );
      return true;
    } catch (e) {
      await controller.dispose();
      return false;
    }
  }

  Future<XFile?> takePicture() async {
    if (state.controller == null) {
      return null;
    }
    try {
      final XFile picture = await state.controller!.takePicture();
      return picture;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  void deactivateCamera() {
    if (state.controller != null) {
      state.controller!.dispose();
    }
    state = state.copyWith(isCameraActive: false);
  }
}

final cameraProvider =
    StateNotifierProvider<CameraControllerNotifier, CameraControllerInfo>(
  (ref) => CameraControllerNotifier(),
);
