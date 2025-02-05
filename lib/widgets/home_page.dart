import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/variables.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/provider/intervals_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/screens/logger_screen.dart';
import 'package:phoneduino_block/widgets/ble/ble_home.dart';
import 'package:phoneduino_block/widgets/block_tree.dart';
import 'package:phoneduino_block/widgets/print_board.dart';
import 'package:phoneduino_block/widgets/variables/add_variables.dart';
import 'package:phoneduino_block/widgets/variables/variable_list.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Block root = ref.watch(blockTreeProvider);
    final Box<dynamic> box = Hive.box('block_tree');
    IntervalList intervals = ref.watch(intervalProvider);
    ref.listen<UiState>(uiProvider, (previous, next) {
      if (intervals.intervals.isNotEmpty) {
        return;
      }
      if (next.messageDequeue.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text(next.messageDequeue.first),
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
              final String blockTreeJson = jsonEncode(root.toJson());
              print(blockTreeJson);
              box.put('block_tree', blockTreeJson);

              final Map<String, Variable> variables =
                  ref.read(variablesProvider);
              final Map<String, dynamic> variablesJson =
                  variables.map((key, value) {
                return MapEntry(key, value.toJson());
              });
              box.put('variables', jsonEncode(variablesJson));
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
              final blockTreeJson = box.get('block_tree');
              final blockTreeData = jsonDecode(blockTreeJson);
              print(blockTreeData);
              Block root = Block.fromJson(blockTreeData);
              ref.read(blockTreeProvider.notifier).updateRoot(root);

              final variablesJson = box.get('variables');
              final Map<String, dynamic> variablesData =
                  jsonDecode(variablesJson);
              final Map<String, Variable> variables =
                  variablesData.map((key, value) {
                return MapEntry(key, Variable.fromJson(value));
              });
              ref
                  .read(variablesProvider.notifier)
                  .updateAllVariables(variables);
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
            ref.read(uiProvider.notifier).clearMessage();
          },
          icon: const Icon(Icons.stop),
        ),
      ]),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const BleHome(),
              const AddVariableButton(),
              TextButton(
                  child: Text("Variables"),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return VariableListDialog();
                        });
                  })
            ],
          ),
          Expanded(
            child: intervals.intervals.isNotEmpty
                ? const PrintBoard()
                : SingleChildScrollView(
                    child: BlockTree(block: root),
                  ),
          ),
        ],
      ),
    );
  }
}
