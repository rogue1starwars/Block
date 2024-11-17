enum BluePrintType {
  name,
  description,
  inputParameters,
  blockParameters,
  returnType,
  execute,
}

Map<int, Map<BluePrintType, dynamic>> bluePrints = {
  1: {
    BluePrintType.name: 'For Loop',
    BluePrintType.description: 'Loop for [times] times',
    BluePrintType.inputParameters: [int],
    BluePrintType.blockParameters: [List],
    BluePrintType.returnType: null,
    BluePrintType.execute: (List<int> inputParameters,
        List<List<ExecutionBlock>> blockParameters) {
      for (int i = 0; i < inputParameters[0]; i++) {
        blockParameters[0].forEach((block) => block.execute());
      }
    },
  },
  2: {
    BluePrintType.name: 'Print',
    BluePrintType.description: 'Print: ',
    BluePrintType.inputParameters: [],
    BluePrintType.blockParameters: [dynamic],
    BluePrintType.returnType: null,
    BluePrintType.execute:
        (List inputParameters, List<List<ExecutionBlock>> blockParameters) {
      blockParameters[0].forEach((block) {
        var result = 100;
        result = block.execute();
        print('Print: $result');
      });
    },
  },
  3: {
    BluePrintType.name: 'Int',
    BluePrintType.description: 'Create constant integer',
    BluePrintType.inputParameters: [int],
    BluePrintType.blockParameters: [null],
    BluePrintType.returnType: int,
    BluePrintType.execute: (List<int> inputParameters,
        List<List<ExecutionBlock>> blockParameters) {
      print('Int: ${inputParameters[0]}');
      return inputParameters[0];
    },
  },
};

enum TreeTypes {
  id,
  inputParameters,
  blockParameters,
  execute,
}

Function executeTree(Map<TreeTypes, dynamic> blockTree) {
  return blockTree[TreeTypes.execute](blockTree[TreeTypes.inputParameters],
      blockTree[TreeTypes.blockParameters]);
}

Map<TreeTypes, dynamic> blockTree = {
  TreeTypes.id: 1,
  TreeTypes.execute: (List<int> inputParameters,
      List<List<Map<TreeTypes, dynamic>>> blockParameters) {
    for (int i = 0; i < inputParameters[0]; i++) {
      blockParameters[0].forEach((tree) {
        executeTree(tree);
      });
    }
  },
  TreeTypes.inputParameters: [5],
  TreeTypes.blockParameters: [
    [
      {
        TreeTypes.id: 2,
        TreeTypes.execute: (List inputParameters,
            List<List<Map<TreeTypes, dynamic>>> blockParameters) {
          blockParameters[0].forEach((tree) {
            print(executeTree(tree));
          });
        },
        TreeTypes.inputParameters: [],
        TreeTypes.blockParameters: [
          [
            {
              TreeTypes.id: 3,
              TreeTypes.execute: (List<int> inputParameters,
                  List<List<Map<TreeTypes, dynamic>>> blockParameters) {
                return inputParameters[0];
              },
              TreeTypes.inputParameters: [10],
              TreeTypes.blockParameters: [<Map<TreeTypes, dynamic>>[]]
            },
          ]
        ],
      }
    ]
  ]
};

void main() {
  var mainBlock = ExecutionBlock(blockTree: blockTree);
  mainBlock.execute();
}

class ExecutionBlock {
  final int id;
  final List<dynamic> inputParameters;
  final List<List<ExecutionBlock>> blockParameters;
  late final Function() execute;

  ExecutionBlock({required Map<TreeTypes, dynamic> blockTree})
      : id = blockTree[TreeTypes.id],
        inputParameters = blockTree[TreeTypes.inputParameters],
        blockParameters =
            (blockTree[TreeTypes.blockParameters] as List<dynamic>)
                .map<List<ExecutionBlock>>((blockList) =>
                    (blockList as List<dynamic>)
                        .map<ExecutionBlock>(
                            (block) => ExecutionBlock(blockTree: block))
                        .toList())
                .toList() {
    execute = () {
      return bluePrints[id]![BluePrintType.execute](
          inputParameters, blockParameters);
    };
  }
}
