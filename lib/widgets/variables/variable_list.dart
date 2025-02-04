import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/variables.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/widgets/variables/add_variables.dart';
import 'package:phoneduino_block/widgets/variables/modify_variables.dart';

class VariableListDialog extends ConsumerWidget {
  const VariableListDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, Variable> variables = ref.watch(variablesProvider);
    return AlertDialog(
        title: const Text('Variable List'),
        content: SingleChildScrollView(
            child: Column(children: [
          const AddVariableButton(),
          for (final key in variables.keys)
            variables.containsKey(key)
                ? ListTile(
                    title: Text(variables[key]!.name),
                    subtitle: Text(variables[key]!.type.toString()),
                    trailing: ModifyVariables(name: key),
                  )
                : const SizedBox()
        ])));
  }
}
