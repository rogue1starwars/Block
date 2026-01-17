import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/provider/camera_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/utils/type.dart';
import 'package:phoneduino_block/data/block_data_core.dart';

final List<BlockBluePrint> blockDataCamera = [
  BlockBluePrint(
      name: "Activate Camera",
      fields: [],
      children: [],
      returnType: BlockTypes.none,
      originalFunc: (WidgetRef ref, Block block) async {
        if (ref.read(cameraProvider).isCameraActive) {
          ref.read(uiProvider.notifier).showMessage(
                'Camera is already activated',
              );
          return;
        }

        try {
          final bool updated =
              await ref.read(cameraProvider.notifier).activateCamera();
          if (updated) {
            ref.read(uiProvider.notifier).showMessage(
                  'Camera activated successfully',
                );
          } else {
            ref.read(uiProvider.notifier).showMessage(
                  'Failed to activate camera',
                );
          }
        } catch (e) {
          ref.read(uiProvider.notifier).showMessage(
                'Failed to activate camera: $e',
              );
        }
      }),
  BlockBluePrint(
    name: "Take Picture",
    fields: [],
    children: [],
    returnType: BlockTypes.image,
    originalFunc: (WidgetRef ref, Block block) async {
      if (!ref.read(cameraProvider).isCameraActive) {
        ref.read(uiProvider.notifier).showMessage(
              'Camera is not activated',
            );
        return null;
      }

      try {
        final image = await ref.read(cameraProvider.notifier).takePicture();
        if (image != null) {
          ref.read(uiProvider.notifier).showMessage(
                'Picture taken successfully',
              );
          return image;
        } else {
          ref.read(uiProvider.notifier).showMessage(
                'Failed to take picture',
              );
        }
        return null;
      } catch (e) {
        ref.read(uiProvider.notifier).showMessage(
              'Failed to take picture: $e',
            );
        return null;
      }
    },
  ),
];
