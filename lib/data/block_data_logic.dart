import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phoneduino_block/data/block_data_core.dart';
import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/provider/ui_provider.dart';
import 'package:phoneduino_block/provider/variables_provider.dart';
import 'package:phoneduino_block/utils/type.dart';

List<BlockBluePrint> blockDataLogic = [
  BlockBluePrint(
    name: 'Compare',
    fields: [
      Field(
        type: FieldTypes.dropdown,
        label: 'Operator',
        value: 0,
        options: [
          '==',
          '!=',
          '>',
          '>=',
          '<',
          '<=',
        ],
      ),
    ],
    children: [
      ValueInput(
        label: 'Value 1',
        block: null,
        filter: [
          BlockTypes.number,
          BlockTypes.string,
          BlockTypes.boolean,
        ],
      ),
      ValueInput(
        label: 'Value 2',
        block: null,
        filter: [
          BlockTypes.number,
          BlockTypes.string,
          BlockTypes.boolean,
        ],
      ),
    ],
    returnType: BlockTypes.boolean,
    originalFunc: (WidgetRef ref, Block block) {
      final int operator = block.fields[0].value;
      final value1 = block.children[0] as ValueInput;
      final value2 = block.children[1] as ValueInput;

      final v1 = value1.block!.execute(ref);
      final v2 = value2.block!.execute(ref);

      switch (operator) {
        case 0:
          return v1 == v2;
        case 1:
          return v1 != v2;
        case 2:
          return v1 > v2;
        case 3:
          return v1 >= v2;
        case 4:
          return v1 < v2;
        case 5:
          return v1 <= v2;
        default:
          throw 'Invalid operator';
      }
    },
  ),
  BlockBluePrint(
    name: 'And/Or',
    fields: [
      Field(
        type: FieldTypes.dropdown,
        label: 'Operator',
        value: 0,
        options: [
          'And',
          'Or',
        ],
      ),
    ],
    children: [
      ValueInput(
        label: 'Value 1',
        block: null,
        filter: [BlockTypes.boolean],
      ),
      ValueInput(
        label: 'Value 2',
        block: null,
        filter: [BlockTypes.boolean],
      ),
    ],
    returnType: BlockTypes.boolean,
    originalFunc: (WidgetRef ref, Block block) {
      final int operator = block.fields[0].value;
      final value1 = block.children[0] as ValueInput;
      final value2 = block.children[1] as ValueInput;

      final v1 = value1.block!.execute(ref);
      final v2 = value2.block!.execute(ref);

      if (operator == 0) {
        return v1 == true && v2 == true;
      } else {
        return v1 == true || v2 == true;
      }
    },
  ),
  BlockBluePrint(
    name: 'Not',
    fields: [],
    children: [
      ValueInput(
        label: 'Value',
        block: null,
        filter: [BlockTypes.boolean],
      ),
    ],
    returnType: BlockTypes.boolean,
    originalFunc: (WidgetRef ref, Block block) {
      final value = block.children[0] as ValueInput;
      return value.block!.execute(ref) == false;
    },
  ),
  BlockBluePrint(
    name: 'True/False',
    fields: [
      Field(
          label: 'Value',
          type: FieldTypes.dropdown,
          value: 0,
          options: ['True', 'False'])
    ],
    children: [],
    returnType: BlockTypes.boolean,
    originalFunc: (WidgetRef ref, Block block) {
      return block.fields[0].value == 0;
    },
  ),
  BlockBluePrint(
    name: 'If',
    fields: [],
    children: [
      ValueInput(
        label: 'Condition',
        block: null,
        filter: [BlockTypes.boolean],
      ),
      StatementInput(
        label: 'Then',
        blocks: [],
        filter: [],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final condition = block.children[0] as ValueInput;
      final thenBlock = block.children[1] as StatementInput;

      if (condition.block!.execute(ref) == true) {
        for (var block in thenBlock.blocks) {
          block.execute(ref);
        }
      }
    },
  ),
  BlockBluePrint(
    name: 'If Else',
    fields: [],
    children: [
      ValueInput(
        label: 'Condition',
        block: null,
        filter: [BlockTypes.boolean],
      ),
      StatementInput(
        label: 'Then',
        blocks: [],
        filter: [],
      ),
      StatementInput(
        label: 'Else',
        blocks: [],
        filter: [],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final condition = block.children[0] as ValueInput;
      final thenBlock = block.children[1] as StatementInput;
      final elseBlock = block.children[2] as StatementInput;

      if (condition.block!.execute(ref) == true) {
        for (var block in thenBlock.blocks) {
          block.execute(ref);
        }
      } else {
        for (var block in elseBlock.blocks) {
          block.execute(ref);
        }
      }
    },
  ),
  BlockBluePrint(
    name: 'Switch (time out)',
    fields: [
      Field(
        label: 'Condition',
        value: '',
        type: FieldTypes.variableNames,
        variableType: BlockTypes.number,
      ),
      Field(
        label: 'Case 0 (ms)',
        value: 1000,
        type: FieldTypes.number,
      ),
      Field(
        label: 'Case 1 (ms)',
        value: 1000,
        type: FieldTypes.number,
      ),
      Field(
        label: 'Case 2 (ms)',
        value: 1000,
        type: FieldTypes.number,
      ),
      Field(
        label: 'Case 3 (ms)',
        value: 1000,
        type: FieldTypes.number,
      ),
      Field(
        label: 'Case 4 (ms)',
        value: 1000,
        type: FieldTypes.number,
      ),
      Field(
        label: 'Case 5 (ms)',
        value: 1000,
        type: FieldTypes.number,
      )
    ],
    children: [
      StatementInput(
        label: 'Case 0',
        blocks: [],
      ),
      StatementInput(
        label: 'When time out (0)',
        blocks: [],
      ),
      StatementInput(
        label: 'Case 1',
        blocks: [],
      ),
      StatementInput(
        label: 'When time out (1)',
        blocks: [],
      ),
      StatementInput(
        label: 'Case 2',
        blocks: [],
      ),
      StatementInput(
        label: 'When time out (2)',
        blocks: [],
      ),
      StatementInput(
        label: 'Case 3',
        blocks: [],
      ),
      StatementInput(
        label: 'When time out (3)',
        blocks: [],
      ),
      StatementInput(
        label: 'Case 4',
        blocks: [],
      ),
      StatementInput(
        label: 'When time out (4)',
        blocks: [],
      ),
      StatementInput(
        label: 'Case 5',
        blocks: [],
      ),
      StatementInput(
        label: 'When time out (5)',
        blocks: [],
      ),
      StatementInput(
        label: 'Default',
        blocks: [],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final String condition = block.fields[0].value;
      if (!ref.read(variablesProvider.notifier).hasVariable(condition)) {
        ref.read(uiProvider.notifier).showMessage('Condition is empty');
        return;
      }

      final value = ref.read(variablesProvider.notifier).getVariable(condition);
      if (value is! int) {
        ref.read(uiProvider.notifier).showMessage('Condition is not a number');
        return;
      }
      if (value < 0 || value >= 6) {
        final defaultStatement = block.children.last as StatementInput;
        for (var block in defaultStatement.blocks) {
          block.execute(ref);
        }
        return;
      }

      final List<num> timeout =
          block.fields.sublist(1).map((e) => e.value as num).toList();

      final cases = [...block.children.map((child) => child as StatementInput)];

      // when status changed or first time
      if (!ref
              .read(variablesProvider.notifier)
              .hasVariable("_${block.id}_prev") ||
          ref
                  .read(variablesProvider.notifier)
                  .getVariable("_${block.id}_prev_status") !=
              value) {
        ref.read(variablesProvider.notifier).setVariable(
              "_${block.id}_prev_status",
              value,
              BlockTypes.number,
            );
        ref.read(variablesProvider.notifier).setVariable(
              "_${block.id}_prev",
              DateTime.now(),
              BlockTypes.timer,
            );
      }

      final prev =
          ref.read(variablesProvider.notifier).getVariable("_${block.id}_prev");
      if (prev is DateTime) {
        if (DateTime.now().difference(prev).inMilliseconds > timeout[value]) {
          ref
              .read(variablesProvider.notifier)
              .deleteVariable("_${block.id}_prev");
          if ((value + 1) * 2 < cases.length) {
            ref.read(variablesProvider.notifier).setVariable(
                block.fields[0].value as String, value + 1, BlockTypes.number);
          }
          for (var block in cases[value * 2 + 1].blocks) {
            block.execute(ref);
          }
          return;
        }
      }

      if (value >= 0 && value * 2 < cases.length) {
        for (var block in cases[value * 2].blocks) {
          block.execute(ref);
        }
      }
    },
  ),
  BlockBluePrint(
    name: 'Switch (5)',
    fields: [
      Field(
        label: 'Condition',
        value: '',
        type: FieldTypes.variableNames,
        variableType: BlockTypes.number,
      )
    ],
    children: [
      StatementInput(
        label: 'Case 0',
        blocks: [],
      ),
      StatementInput(
        label: 'Case 1',
        blocks: [],
      ),
      StatementInput(
        label: 'Case 2',
        blocks: [],
      ),
      StatementInput(
        label: 'Case 3',
        blocks: [],
      ),
      StatementInput(
        label: 'Case 4',
        blocks: [],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final condition = block.fields[0].value;
      if (!ref.read(variablesProvider.notifier).hasVariable(condition)) {
        ref.read(uiProvider.notifier).showMessage('Condition is empty');
        return;
      }

      final value = ref.read(variablesProvider.notifier).getVariable(condition);
      if (value is! int) {
        ref.read(uiProvider.notifier).showMessage('Condition is not a number');
        return;
      }

      final cases = [...block.children.map((child) => child as StatementInput)];

      if (value >= 0 && value < cases.length) {
        for (var block in cases[value].blocks) {
          block.execute(ref);
        }
      }
    },
  ),
  BlockBluePrint(
    name: 'Switch (3)',
    fields: [
      Field(
        label: 'Threshold',
        value: 20,
        type: FieldTypes.number,
      ),
    ],
    children: [
      ValueInput(
        label: 'Condition',
        block: null,
        filter: [BlockTypes.number],
      ),
      StatementInput(
        label: 'Bigger...',
        blocks: [],
        filter: [],
      ),
      StatementInput(
        label: 'Approximately Equal...',
        blocks: [],
        filter: [],
      ),
      StatementInput(
        label: 'Smaller...',
        blocks: [],
        filter: [],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (WidgetRef ref, Block block) {
      final threshold = block.fields[0].value;
      final condition = block.children[0] as ValueInput;
      final bigger = block.children[1] as StatementInput;
      final approximatelyEqual = block.children[2] as StatementInput;
      final smaller = block.children[3] as StatementInput;

      final value = condition.block!.execute(ref) as num;

      if (value.abs() < threshold) {
        for (var block in approximatelyEqual.blocks) {
          block.execute(ref);
        }
      } else if (value < 0) {
        for (var block in smaller.blocks) {
          block.execute(ref);
        }
      } else {
        for (var block in bigger.blocks) {
          block.execute(ref);
        }
      }
    },
  ),
];
