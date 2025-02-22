import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/variables.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/provider/intervals_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/screens/logger_screen.dart';
import 'package:phoneduino_block/utils/encode_decode_project.dart';
import 'package:phoneduino_block/widgets/ble/ble_home.dart';
import 'package:phoneduino_block/widgets/block_tree.dart';
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
          const BleHome(),
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
        ],
      ),
      body: intervals.intervals.isNotEmpty
          ? const PrintBoard()
          : SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BleHome(),
                      ImportExportButton(),
                      IconButton(
                        onPressed: () async {
                          final String blockTreeJson =
                              jsonEncode(root.toJson());
                          print(blockTreeJson);
                          // box.put('block_tree', blockTreeJson);

                          final Map<String, Variable> variables =
                              ref.read(variablesProvider);
                          final Map<String, dynamic> variablesJson =
                              variables.map((key, value) {
                            return MapEntry(key, value.toJson());
                          });
                          variablesJson
                              .removeWhere((key, value) => key[0] == '_');

                          final Map<String, dynamic> projectData = {
                            'block_tree': root.toJson(),
                            'variables': variablesJson,
                          };
                          final String? projectDataJson =
                              jsonEncode(projectData);
                          if (projectDataJson == null) {
                            ref.read(uiProvider.notifier).showMessage(
                                  'Failed to copy project data',
                                );
                            return;
                          }
                          Clipboard.setData(
                              ClipboardData(text: projectDataJson));
                        },
                        icon: Icon(Icons.share),
                      ),
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
