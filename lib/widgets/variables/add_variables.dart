import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/utils/type.dart';

class AddVariableButton extends ConsumerStatefulWidget {
  const AddVariableButton({super.key});

  @override
  ConsumerState<AddVariableButton> createState() => _AddVariableButtonState();
}

class _AddVariableButtonState extends ConsumerState<AddVariableButton> {
  final TextEditingController _controller = TextEditingController();
  BlockTypes _selectedType = BlockTypes.number;

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Variable'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Variable Name',
                  hintText: 'Enter variable name',
                ),
              ),
              const SizedBox(height: 16),
              DropdownMenu<BlockTypes>(
                width: MediaQuery.of(context).size.width * 0.7,
                label: const Text('Type'),
                initialSelection: _selectedType,
                onSelected: (BlockTypes? type) {
                  if (type != null) {
                    setState(() => _selectedType = type);
                  }
                },
                dropdownMenuEntries: BlockTypes.values
                    .map((blockType) => DropdownMenuEntry(
                        value: blockType,
                        label: blockType.toString().split('.').last))
                    .toList(),
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
                if (_controller.text.isNotEmpty) {
                  ref.read(variablesProvider.notifier).setVariable(
                        _controller.text,
                        null,
                        _selectedType,
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _showDialog(context),
      child: const Text('Add Variable'),
    );
  }
}
