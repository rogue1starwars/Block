import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/variables.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/utils/encode_decode_project.dart';

class ImportExportButton extends ConsumerWidget {
  const ImportExportButton({super.key});

  Future<void> _showDialog(BuildContext context, WidgetRef ref) async {
    final textController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Import/Export'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy to Clipboard'),
                onTap: () {
                  try {
                    final Block root = ref.read(blockTreeProvider);
                    final Map<String, Variable> variables =
                        ref.read(variablesProvider);

                    final String projectData = encode(root, variables);
                    Clipboard.setData(ClipboardData(text: projectData));
                  } catch (e) {
                    ref
                        .read(uiProvider.notifier)
                        .showMessage('Failed to save block tree: $e');
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('Save to File'),
                onTap: () {
                  // TODO: Add save logic
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Import from text'),
              ),
              const Divider(),
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Paste project data here',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (textController.text.isEmpty) return;
                  // TODO: Handle import logic

                  Navigator.pop(context);
                },
                child: const Text('Import'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.share),
      onPressed: () => _showDialog(context, ref),
    );
  }
}
