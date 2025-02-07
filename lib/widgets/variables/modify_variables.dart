import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';

class ModifyVariables extends ConsumerStatefulWidget {
  final String name;
  const ModifyVariables({super.key, required this.name});

  @override
  ConsumerState<ModifyVariables> createState() => _ModifyVariablesState();
}

class _ModifyVariablesState extends ConsumerState<ModifyVariables> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _showDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modify Variable: ${widget.name}'),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Rename Variable: ${widget.name}"),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Rename Variable'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(variablesProvider.notifier)
                    .deleteVariable(widget.name);
                // recreate block tree
                ref
                    .read(blockTreeProvider.notifier)
                    .removeVariable(name: widget.name);
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
            TextButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  if (_controller.text != widget.name) {
                    ref
                        .read(variablesProvider.notifier)
                        .renameVariable(widget.name, _controller.text);
                    // recreate block tree
                    ref.read(blockTreeProvider.notifier).renameVariable(
                        oldName: widget.name, newName: _controller.text);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.text = widget.name;
    _controller.addListener(() {
      final String name = _controller.text.toLowerCase();
      _controller.value = _controller.value.copyWith(
        text: name,
        selection:
            TextSelection(baseOffset: name.length, extentOffset: name.length),
        composing: TextRange.empty,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        _showDialog(context);
      },
    );
  }
}

// class ModifyVariables extends ConsumerWidget {
//   final String name;

//   const ModifyVariables({super.key, required this.name});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final TextEditingController controller = TextEditingController(text: name);

//     return AlertDialog(
//       title: Text('Modify Variable: $name'),
//       content: Column(children: [
//         TextField(
//           controller: controller,
//           decoration: const InputDecoration(labelText: 'Rename Variable'),
//         ),
//         const SizedBox(height: 10),
//       ]),
//     );
//   }
// }
