import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/provider/ble_info.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/utils/type.dart';
import 'package:phoneduino_block/widgets/ble/ble_home.dart';
import 'package:phoneduino_block/widgets/block_tree.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Block root = ref.watch(blockTreeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('PhoneDuino Block'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const BleHome(),
                IconButton(
                    onPressed: () {
                      final BleInfo bleInfo = ref.watch(bleProvider);
                      Block.setVariable(
                        "_ble",
                        bleInfo,
                        BlockTypes.ble,
                      );
                      Block.setVariable(
                        "_context",
                        context,
                        BlockTypes.context,
                      );
                      root.execute(ref);
                    },
                    icon: const Icon(Icons.play_arrow)),
              ],
            ),
            BlockTree(block: root),
          ],
        ),
      ),
    );
  }
}
