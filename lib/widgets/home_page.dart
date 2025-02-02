import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/provider/intervals_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/widgets/ble/ble_home.dart';
import 'package:phoneduino_block/widgets/block_tree.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Block root = ref.watch(blockTreeProvider);
    final blocks = Hive.box<Block>('blocks');
    IntervalList intervals = ref.watch(intervalProvider);
    ref.listen<UiState>(uiProvider, (previous, next) {
      if (next.messageQueue.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text(next.messageQueue.first),
              ),
            )
            .closed
            .then((_) {
          ref.read(uiProvider.notifier).removeMessage();
        });
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('PhoneDuino Block'), actions: [
        IconButton(
          onPressed: () {
            blocks.put('root', root);
          },
          icon: const Icon(Icons.save),
        ),
        IconButton(
          onPressed: () {
            final loadedBlock = blocks.get('root');
            if (loadedBlock != null) {
              ref
                  .read(blockTreeProvider.notifier)
                  .updateRoot(root: loadedBlock);
            }
          },
          icon: const Icon(Icons.folder_open),
        ),
        IconButton(
          onPressed: () {
            root.execute(ref);
          },
          icon: const Icon(Icons.play_arrow),
        ),
        IconButton(
          onPressed: () {
            ref.read(intervalProvider.notifier).clearInterval();
            print(intervals.intervals[0]);
          },
          icon: const Icon(Icons.stop),
        ),
      ]),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BleHome(),
            BlockTree(block: root),
          ],
        ),
      ),
    );
  }
}
