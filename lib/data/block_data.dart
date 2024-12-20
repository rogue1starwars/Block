import 'package:phoneduino_block/models/block.dart';
import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/utils/type.dart';

class BlockBluePrint {
  final String name;
  final List<Field>? fields;
  final List<Input>? children;
  final BlockTypes returnType;
  final Function(Block) originalFunc;

  BlockBluePrint({
    required this.name,
    required this.returnType,
    required this.originalFunc,
    this.fields,
    this.children,
  });
}

List<BlockBluePrint> filterBlockData(Map<BlockTypes, bool>? filter) {
  if (filter == null) {
    return blockData;
  }
  final List<BlockBluePrint> blockDataFiltered = blockData.where((block) {
    if (filter[BlockTypes.number] == false &&
        block.returnType == BlockTypes.number) {
      return false;
    }
    if (filter[BlockTypes.string] == false &&
        block.returnType == BlockTypes.string) {
      return false;
    }
    if (filter[BlockTypes.boolean] == false &&
        block.returnType == BlockTypes.boolean) {
      return false;
    }
    return true;
  }).toList();
  return blockDataFiltered;
}

List<BlockBluePrint> blockData = [
  BlockBluePrint(
    name: 'Main',
    children: [
      StatementInput(
        label: 'Do',
        blocks: [],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (Block block) {
      if (block.children == null) return;
      if (block.children!.isEmpty) return;

      final statement = block.children![0] as StatementInput;
      statement.blocks.forEach((block) {
        block.execute();
      });
    },
  ),
  BlockBluePrint(
    name: 'Set Variable',
    fields: [
      StringField(label: 'Name', value: ''),
      StringField(label: 'Type', value: ''),
    ],
    children: [
      ValueInput(label: 'Value', block: null),
    ],
    returnType: BlockTypes.none,
    originalFunc: (Block block) {
      if (block.children == null) return;
      if (block.children!.isEmpty) return;

      final value = block.children![0] as ValueInput;
      if (value.block == null) {
        print("Set Variable: null");
        return;
      }
      if (block.fields == null) return;
      if (block.fields!.isEmpty) return;
      final type = BlockTypes.values.firstWhere(
          (e) => e.toString() == 'BlockTypes.' + block.fields![1].value);
      Block.setVariable(block.fields![0].value, value.block!.execute(), type);
    },
  ),
  BlockBluePrint(
    name: 'Get Variable',
    fields: [
      StringField(label: 'Name', value: ''),
    ],
    children: [],
    returnType: BlockTypes.none,
    originalFunc: (Block block) {
      if (block.fields == null) return;
      if (block.fields!.isEmpty) return;

      final name = block.fields![0].value;
      final value = Block.getVariable(name);
      if (value == null) {
        print("Get Variable: null");
        return;
      }
      print(value);
      return value;
    },
  ),
  BlockBluePrint(
    name: 'For Loop',
    fields: [
      NumericField(label: "Times", value: 0),
    ],
    children: [
      StatementInput(
        label: 'Do',
        blocks: [],
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (Block block) {
      if (block.fields == null) return;
      if (block.fields!.isEmpty) return;

      final statement = block.children![0] as StatementInput;
      final value = int.parse(block.fields![0].value);
      for (int i = 0; i < value; i++) {
        statement.blocks.forEach((block) {
          block.execute();
        });
      }
    },
  ),
  BlockBluePrint(
    name: 'Print',
    children: [
      ValueInput(
        label: 'Value',
        block: null,
      ),
    ],
    returnType: BlockTypes.none,
    originalFunc: (Block block) {
      if (block.children == null) return;
      if (block.children!.isEmpty) return;

      final value = block.children![0] as ValueInput;
      if (value.block == null) {
        print("Print: null");
      }
      print("Printing from print block: ${value.block!.execute()}");
    },
  ),
  BlockBluePrint(
    name: 'Int',
    fields: [
      NumericField(label: "Value", value: 0),
    ],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (Block block) {
      if (block.fields == null) return;
      if (block.fields!.isEmpty) return;
      return block.fields![0].value;
    },
  ),
];
