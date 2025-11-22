import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/variables.dart';
import 'package:phoneduino_block/provider/ble_info.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/provider/camera_provider.dart';
import 'package:phoneduino_block/provider/intervals_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/screens/logger_screen.dart';
import 'package:phoneduino_block/utils/encode_decode_project.dart';
import 'package:phoneduino_block/widgets/ble/ble_home.dart';
import 'package:phoneduino_block/widgets/block_tree.dart';
import 'package:phoneduino_block/widgets/camera/camera_home.dart';
import 'package:phoneduino_block/widgets/print_board.dart';
import 'package:phoneduino_block/widgets/import_export_project.dart';
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
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const VariableListDialog();
                  });
            },
            icon: const Icon(Icons.edit),
          ),
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
                final Map<String, Variable> variables =
                    ref.read(variablesProvider);

                final String projectData = encode(root, variables);
                box.put('project', projectData);
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
                final Map<String, dynamic> projectData =
                    jsonDecode(box.get('project'));

                final Map<String, dynamic> blockTreeData =
                    projectData['block_tree'];
                print(blockTreeData);
                Block root = Block.fromJson(blockTreeData);
                ref.read(blockTreeProvider.notifier).updateRoot(root);

                final Map<String, dynamic> variablesData =
                    projectData['variables'];
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
          const ImportExportButton(),
        ],
      ),
      body: intervals.intervals.isNotEmpty
          ? const PrintBoard()
          : SingleChildScrollView(
              child: Column(
                children: [
                  const Row(
                    children: [
                      BleHome(),
                      SizedBox(width: 20),
                      CameraHome(),
                    ],
                  ),
                  BlockTree(block: root),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (intervals.intervals.isNotEmpty) {
            ref.read(intervalProvider.notifier).clearInterval();
            ref.read(uiProvider.notifier).clearMessage();
            ref.read(variablesProvider.notifier).clearAllVariables();
            ref.read(cameraProvider.notifier).deactivateCamera();
            try {
              final BleInfo bleInfo = ref.read(bleProvider);
              if (bleInfo.characteristics != null) {
                bleInfo.characteristics!.write('0'.toString().codeUnits);
              }
            } catch (e) {
              ref.read(uiProvider.notifier).showMessage('Failed to stop: $e');
            }
          } else {
            root.execute(ref);
          }
        },
        child: intervals.intervals.isNotEmpty
            ? const Icon(Icons.stop)
            : const Icon(Icons.play_arrow),
      ),
    );
  }
}
