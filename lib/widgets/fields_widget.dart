import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/variables.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/utils/type.dart';

// Base field widget
class BaseFieldWidget extends ConsumerWidget {
  final Block parent;
  final int index;

  const BaseFieldWidget({
    super.key,
    required this.parent,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (index >= parent.fields.length) return const SizedBox.shrink();
    final field = parent.fields[index];

    return TextFormField(
      initialValue: field.value.toString(),
      decoration: buildDecoration(field),
      onChanged: (value) => onFieldChanged(value, ref),
      validator: fieldValidator,
      keyboardType: getKeyboardType(),
    );
  }

  // Customizable methods for children
  InputDecoration buildDecoration(Field field) {
    return InputDecoration(
      hintText: 'Enter ${field.label}',
      border: const OutlineInputBorder(),
    );
  }

  void onFieldChanged(String value, WidgetRef ref) {
    print('Updating field: $value');
    ref.read(blockTreeProvider.notifier).updateField(
          parentId: parent.id,
          value: value,
          index: index,
        );
  }

  String? fieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    return null;
  }

  TextInputType getKeyboardType() => TextInputType.text;
}

// Specialized widgets
class StringFieldWidget extends BaseFieldWidget {
  const StringFieldWidget({
    super.key,
    required super.parent,
    required super.index,
  });
}

class NumericFieldWidget extends BaseFieldWidget {
  const NumericFieldWidget({
    super.key,
    required super.parent,
    required super.index,
  });

  @override
  TextInputType getKeyboardType() => TextInputType.number;

  @override
  void onFieldChanged(String value, WidgetRef ref) {
    final num parsedValue;
    try {
      parsedValue = num.parse(value);
    } catch (e) {
      ref.read(uiProvider.notifier).showMessage('Failed to parse number: $e');
      return;
    }
    ref.read(blockTreeProvider.notifier).updateField(
          parentId: parent.id,
          value: parsedValue,
          index: index,
        );
  }

  @override
  String? fieldValidator(String? value) {
    final baseValidation = super.fieldValidator(value);
    if (baseValidation != null) return baseValidation;

    if (num.tryParse(value!) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
}

class VariableNamesFieldWidget extends ConsumerStatefulWidget {
  final Block parent;
  final int index;
  const VariableNamesFieldWidget({
    super.key,
    required this.parent,
    required this.index,
  });

  @override
  ConsumerState<VariableNamesFieldWidget> createState() =>
      _VariableFieldWidgetState();
}

class _VariableFieldWidgetState
    extends ConsumerState<VariableNamesFieldWidget> {
  @override
  Widget build(BuildContext context) {
    final Field field = widget.parent.fields[widget.index];
    final BlockTypes? variableType = field.variableType;

    Map<String, Variable> variables = ref.watch(variablesProvider);

    print("variable type: $variableType");
    final filteredVariables = variables.entries
        .where((entry) => entry.value.type == variableType)
        .toList();
    print("variables: $variables");
    print("filteredVariables: $filteredVariables");

    // Last check. Should not happen
    if (filteredVariables.isEmpty) {
      return const Text("No variables found");
    }

    print("field.value: ${field.value}");
    return DropdownMenu(
        label: const Text('Select a variable'),
        initialSelection: field.value as String? ?? ' ',
        onSelected: (String? name) {
          if (name == null) return;
          ref.read(blockTreeProvider.notifier).updateField(
                parentId: widget.parent.id,
                value: name,
                index: widget.index,
              );
        },
        dropdownMenuEntries: filteredVariables
            .map((entry) => DropdownMenuEntry(
                  value: entry.key,
                  label: entry.key,
                ))
            .toList());
  }
}

class DropdownFieldWidget extends ConsumerStatefulWidget {
  final Block parent;
  final int index;
  const DropdownFieldWidget({
    super.key,
    required this.parent,
    required this.index,
  });

  @override
  ConsumerState<DropdownFieldWidget> createState() =>
      _DropdownFieldWidgetState();
}

class _DropdownFieldWidgetState extends ConsumerState<DropdownFieldWidget> {
  @override
  Widget build(BuildContext context) {
    final List<dynamic> options = widget.parent.fields[widget.index].options;
    int selectedOption = widget.parent.fields[widget.index].value as int;
    return DropdownMenu(
      dropdownMenuEntries: [
        for (final option in options)
          DropdownMenuEntry(
            value: option,
            label: option.toString(),
          ),
      ],
      initialSelection: options[selectedOption],
      onSelected: (dynamic value) {
        if (value != null) {
          ref.read(blockTreeProvider.notifier).updateField(
                parentId: widget.parent.id,
                value: options.indexOf(value),
                index: widget.index,
              );
        }
      },
    );
  }
}
