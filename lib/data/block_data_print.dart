import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data_core.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/utils/type.dart';

final List<BlockBluePrint> blockDataPrint = [
  BlockBluePrint(
    name: 'Print',
    fields: [],
    children: [
      ValueInput(
        label: 'Value',
        block: null,
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final value = block.children[0] as ValueInput;
      ref.read(uiProvider.notifier).showMessage(
            value.block!.execute(ref).toString(),
          );
    },
  ),
];
