import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/provider/intervals_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/screens/logger_screen.dart';
import 'package:phoneduino_block/widgets/ble/ble_home.dart';
import 'package:phoneduino_block/widgets/block_tree.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Block root = ref.watch(blockTreeProvider);
    final Box<dynamic> box = Hive.box('block_tree');
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
            onPressed: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const LoggerScreen();
              }));
            },
            icon: const Icon(Icons.list)),
        IconButton(
          onPressed: () {
            try {
              final String json = jsonEncode(root.toJson());
              print(json);
              box.put('block_tree', json);
            } catch (e) {
              ref
                  .read(uiProvider.notifier)
                  .showMessage('Failed to save block tree: $e');
            }
          },
          icon: const Icon(Icons.save),
        ),
        IconButton(
          onPressed: () {
            try {
              final json = box.get('block_tree');
              final data = jsonDecode(json);
              print(data);
              Block root = Block.fromJson(data);
              ref.read(blockTreeProvider.notifier).updateRoot(root);
            } catch (e) {
              ref
                  .read(uiProvider.notifier)
                  .showMessage('Failed to load block tree: $e');
            }
          },
          icon: const Icon(Icons.restore),
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
