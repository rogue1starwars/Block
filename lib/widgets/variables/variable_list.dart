import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/variables.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/widgets/variables/add_variables.dart';

class VariableListDialog extends ConsumerWidget {
  const VariableListDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, Variable> variables = ref.watch(variablesProvider);
    return Dialog(
      child: SizedBox(
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Variables'),
                AddVariableButton(),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: variables.length,
                itemBuilder: (context, index) {
                  final String key = variables.keys.elementAt(index);
                  if (!variables.containsKey(key))
                    return const SizedBox.shrink();
                  final Variable variable = variables[key]!;
                  return ListTile(
                    title: Text(variable.name),
                    subtitle: Text(variable.type.toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // ref.read(variablesProvider.notifier).removeVariable(key);
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
