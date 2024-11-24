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

// // import 'package:phoneduino_block/provider/block_tree_provider.dart';
// List<Function> blocks = [
//   (String id) => MainBlockBluePrint(id),
//   (String id) => ForLoop(id),
//   (String id) => Print(id),
//   (String id) => Int(id),
// ];

// class MainBlockBluePrint extends Block {
//   MainBlockBluePrint(String id)
//       : super(
//           id: id,
//           name: 'Main',
//           children: [
//             StatementInput(
//               label: 'Do',
//               blocks: [],
//             ),
//           ],
//           returnType: 'void',
//         );
//   @override
//   void originalFunc() {
//     children?[0].blocks!.forEach((block) {
//       block.originalFunc();
//     });
//   }
// }

// class ForLoop extends BlockBluePrint {
//   ForLoop(String id)
//       : super(
//           id: id,
//           name: 'For Loop',
//           fields: [
//             NumericField(label: "Times", value: 0),
//           ],
//           children: [
//             StatementInput(
//               label: 'Do',
//               blocks: [],
//             ),
//           ],
//           returnType: 'void',
//         );
//   @override
//   void originalFunc() {
//     for (int i = 0; i < fields?[0].value; i++) {
//       children?[0].blocks!.forEach((block) {
//         block.originalFunc();
//       });
//     }
//   }
// }

// class Print extends BlockBluePrint {
//   Print(String id)
//       : super(
//           id: id,
//           name: 'Print',
//           fields: [],
//           children: [
//             ValueInput(
//               label: 'Value',
//               block: null,
//             ),
//           ],
//           returnType: 'void',
//         );
//   @override
//   void originalFunc() {
//     if (children?[0].block == null) {
//       print("Print: null");
//     }
//     print(children?[0].block!.originalFunc());
//   }
// }

// class Int extends BlockBluePrint {
//   Int(String id)
//       : super(
//           id: id,
//           name: 'Int',
//           fields: [
//             NumericField(label: "Value", value: 0),
//           ],
//           children: [],
//           returnType: 'number',
//         );
//   @override
//   int originalFunc() {
//     return fields?[0].value;
//   }
// }

// enum BluePrintType {
//   name,
//   description,
//   inputParameters,
//   blockParameters,
//   returnType,
//   originalFunc,
// }

// Map<int, Map<BluePrintType, dynamic>> bluePrints = {
//   1: {
//     BluePrintType.name: 'For Loop',
//     BluePrintType.description: 'Loop for [times] times',
//     BluePrintType.inputParameters: [int],
//     BluePrintType.blockParameters: [List],
//     BluePrintType.returnType: null,
//     BluePrintType.originalFunc: (List<int> inputParameters,
//         List<List<ExecutionBlockBluePrint>> blockParameters) {
//       for (int i = 0; i < inputParameters[0]; i++) {
//         blockParameters[0].forEach((block) => block.originalFunc());
//       }
//     },
//   },
//   2: {
//     BluePrintType.name: 'Print',
//     BluePrintType.description: 'Print: ',
//     BluePrintType.inputParameters: [],
//     BluePrintType.blockParameters: [dynamic],
//     BluePrintType.returnType: null,
//     BluePrintType.originalFunc:
//         (List inputParameters, List<List<ExecutionBlockBluePrint>> blockParameters) {
//       blockParameters[0].forEach((block) {
//         var result = 100;
//         result = block.originalFunc();
//         print('Print: $result');
//       });
//     },
//   },
//   3: {
//     BluePrintType.name: 'Int',
//     BluePrintType.description: 'Create constant integer',
//     BluePrintType.inputParameters: [int],
//     BluePrintType.blockParameters: [null],
//     BluePrintType.returnType: int,
//     BluePrintType.originalFunc: (List<int> inputParameters,
//         List<List<ExecutionBlockBluePrint>> blockParameters) {
//       print('Int: ${inputParameters[0]}');
//       return inputParameters[0];
//     },
//   },
// };

// enum TreeTypes {
//   id,
//   inputParameters,
//   blockParameters,
//   originalFunc,
// }

// Function originalFuncTree(Map<TreeTypes, dynamic> blockTree) {
//   return blockTree[TreeTypes.originalFunc](blockTree[TreeTypes.inputParameters],
//       blockTree[TreeTypes.blockParameters]);
// }

// Map<TreeTypes, dynamic> blockTree = {
//   TreeTypes.id: 1,
//   TreeTypes.originalFunc: (List<int> inputParameters,
//       List<List<Map<TreeTypes, dynamic>>> blockParameters) {
//     for (int i = 0; i < inputParameters[0]; i++) {
//       blockParameters[0].forEach((tree) {
//         originalFuncTree(tree);
//       });
//     }
//   },
//   TreeTypes.inputParameters: [5],
//   TreeTypes.blockParameters: [
//     [
//       {
//         TreeTypes.id: 2,
//         TreeTypes.originalFunc: (List inputParameters,
//             List<List<Map<TreeTypes, dynamic>>> blockParameters) {
//           blockParameters[0].forEach((tree) {
//             print(originalFuncTree(tree));
//           });
//         },
//         TreeTypes.inputParameters: [],
//         TreeTypes.blockParameters: [
//           [
//             {
//               TreeTypes.id: 3,
//               TreeTypes.originalFunc: (List<int> inputParameters,
//                   List<List<Map<TreeTypes, dynamic>>> blockParameters) {
//                 return inputParameters[0];
//               },
//               TreeTypes.inputParameters: [10],
//               TreeTypes.blockParameters: [<Map<TreeTypes, dynamic>>[]]
//             },
//           ]
//         ],
//       }
//     ]
//   ]
// };

// void main() {
//   var mainBlockBluePrint = ExecutionBlock(blockTree: blockTree);
//   mainBlockBluePrint.originalFunc();
// }

// class ExecutionBlockBluePrint {
//   final int id;
//   final List<dynamic> inputParameters;
//   final List<List<ExecutionBlockBluePrint>> blockParameters;
//   late final Function() originalFunc;

//   ExecutionBlockBluePrint({required Map<TreeTypes, dynamic> blockTree})
//       : id = blockTree[TreeTypes.id],
//         inputParameters = blockTree[TreeTypes.inputParameters],
//         blockParameters =
//             (blockTree[TreeTypes.blockParameters] as List<dynamic>)
//                 .map<List<ExecutionBlockBluePrint>>((blockList) =>
//                     (blockList as List<dynamic>)
//                         .map<ExecutionBlockBluePrint>(
//                             (block) => ExecutionBlockBluePrint(blockTree: block))
//                         .toList())
//                 .toList() {
//     originalFunc = () {
//       return bluePrints[id]![BluePrintType.originalFunc](
//           inputParameters, blockParameters);
//     };
//   }
// }
