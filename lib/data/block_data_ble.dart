import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/provider/ble_info.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/utils/type.dart';
import 'package:phoneduino_block/data/block_data_core.dart';

final List<BlockBluePrint> blockDataBle = [
  BlockBluePrint(
      name: "Send Data",
      fields: [],
      children: [
        ValueInput(
            label: 'Data',
            filter: [
              BlockTypes.number,
              BlockTypes.string,
            ],
            block: null),
      ],
      returnType: BlockTypes.none,
      originalFunc: (WidgetRef ref, Block block) {
        final value = block.children[0] as ValueInput;

        final BleInfo bleInfo = ref.read(bleProvider);
        print("BleInfo: ${bleInfo.characteristics}");
        if (bleInfo.characteristics == null) {
          ref.read(uiProvider.notifier).showMessage(
                'Please connect to a device first',
              );
          print("Send Data: null");
          return;
        }

        try {
          bleInfo.characteristics!
              .write(value.block!.execute(ref).toString().codeUnits);
        } catch (e) {
          ref.read(uiProvider.notifier).showMessage(
                'Failed to send data',
              );
        }
      }),
];
