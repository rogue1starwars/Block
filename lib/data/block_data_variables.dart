import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data_core.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/utils/type.dart';

final List<BlockBluePrint> blockDataVariables = [
  BlockBluePrint(
    name: 'Set Variable (Bool)',
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final value = block.children[0] as ValueInput;
      ref.read(variablesProvider.notifier).setVariable(
            block.fields[0].value,
            value.block!.execute(ref),
            BlockTypes.boolean,
          );
    },
    fields: [
      Field(
        type: FieldTypes.variableNames,
        label: 'Name',
        value: '',
        variableType: BlockTypes.boolean,
      ),
    ],
    children: [
      ValueInput(
        label: 'Value',
        block: null,
        filter: [BlockTypes.boolean],
      ),
    ],
  ),
  BlockBluePrint(
    name: 'Set Variable (Number)',
    fields: [
      Field(
        type: FieldTypes.variableNames,
        label: 'Name',
        value: '',
        variableType: BlockTypes.number,
      ),
    ],
    children: [
      ValueInput(
        label: 'Value',
        block: null,
        filter: [BlockTypes.number],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final value = block.children[0] as ValueInput;
      ref.read(variablesProvider.notifier).setVariable(
            block.fields[0].value,
            value.block!.execute(ref),
            BlockTypes.number,
          );
    },
  ),
  BlockBluePrint(
    name: 'Set Variable (String)',
    fields: [
      Field(
        type: FieldTypes.variableNames,
        label: 'Name',
        value: '',
        variableType: BlockTypes.string,
      ),
    ],
    children: [
      ValueInput(
        label: 'Value',
        block: null,
        filter: [BlockTypes.string],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final value = block.children[0] as ValueInput;
      // testing... store varibles in riverpod providers
      ref.read(variablesProvider.notifier).setVariable(
            block.fields[0].value,
            value.block!.execute(ref),
            BlockTypes.string,
          );
    },
  ),
  BlockBluePrint(
    name: 'Get Variable (Bool)',
    fields: [
      Field(
        type: FieldTypes.variableNames,
        label: 'Name',
        value: '',
        variableType: BlockTypes.boolean,
      ),
    ],
    children: [],
    returnType: BlockTypes.boolean,
    originalFunc: (WidgetRef ref, Block block) {
      final name = block.fields[0].value;
      final value = ref.read(variablesProvider.notifier).getVariable(name);
      if (value == null) {
        print("Get Variable ($name): null");
        return;
      }
      print(value);
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Get Variable (Number)',
    fields: [
      Field(
        type: FieldTypes.variableNames,
        label: 'Name',
        value: '',
        variableType: BlockTypes.number,
      ),
    ],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (WidgetRef ref, Block block) {
      final name = block.fields[0].value;
      final value = ref.read(variablesProvider.notifier).getVariable(name);
      if (value == null) {
        print("Get Variable: null");
        return;
      }
      print(value);
      return value;
    },
  ),
  BlockBluePrint(
    name: 'Get Variable (String)',
    fields: [
      Field(
        type: FieldTypes.variableNames,
        label: 'Name',
        value: '',
        variableType: BlockTypes.string,
      ),
    ],
    children: [],
    returnType: BlockTypes.string,
    originalFunc: (WidgetRef ref, Block block) {
      final name = block.fields[0].value;
      final value = ref.read(variablesProvider.notifier).getVariable(name);
      if (value == null) {
        print("Get Variable: null");
        return;
      }
      print(value);
      return value;
    },
  ),
];
