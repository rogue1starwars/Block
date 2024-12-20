import 'package:phoneduino_block/models/fields.dart';
import 'package:phoneduino_block/models/inputs.dart';
import 'package:phoneduino_block/utils/type.dart';
import 'package:uuid/uuid.dart';

class BlockBluePrint {
  final String name;
  final List<Field>? fields;
  final List<Input>? children;
  final BlockTypes returnType;
  final Function originalFunc;

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
    originalFunc: (List<Field>? field, List<Input> children) {
      final statement = children[0] as StatementInput;
      statement.blocks.forEach((block) {
        block.execute();
      });
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
    originalFunc: (List<Field> fields, List<Input> children) {
      final statement = children[0] as StatementInput;
      final value = int.parse(fields[0].value);
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
    originalFunc: (List<Field>? fields, List<Input> children) {
      final value = children[0] as ValueInput;
      if (value.block == null) {
        print("Print: null");
      }
      print(value.block!.execute());
    },
  ),
  BlockBluePrint(
    name: 'Int',
    fields: [
      NumericField(label: "Value", value: 0),
    ],
    children: [],
    returnType: BlockTypes.number,
    originalFunc: (List<Field> fields, List<Input>? children) {
      return fields[0].value;
    },
  ),
  BlockBluePrint(
      name: 'UUID',
      returnType: BlockTypes.string,
      originalFunc: (
        List<Field>? fields,
        List<Input>? children,
      ) {
        return const Uuid().v4();
      })
];
