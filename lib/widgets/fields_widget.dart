import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/provider/block_tree_provider.dart';

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
  String? fieldValidator(String? value) {
    final baseValidation = super.fieldValidator(value);
    if (baseValidation != null) return baseValidation;

    if (double.tryParse(value!) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
}
